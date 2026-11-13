# SwiftPay Backend

Small Node.js and Express support API for the SwiftPay app. It serves one fictional demo user and stores wallet data in a local JSON file. Transfers are simulated; the API never moves money.

## Run locally

Requires Node.js 20 or later.

```sh
cd backend
npm install
npm start
```

The API listens on `http://localhost:8000` by default. On first request, the backend creates `data/wallet.json` with a sample balance and transaction history. Wallet balance and transactions persist across restarts. The demo user profile is held in memory and resets when the server restarts.

Issued access tokens are stateless JWTs, so restarting the backend does not invalidate a token that the app is still holding. There is no sign-out endpoint: the app drops the token from memory, and the token simply expires on its own.

> **Note:** `npm run dev` uses nodemon. Its watch scope is limited to `backend/src` (see `nodemonConfig` in `package.json`), so writing `data/wallet.json` during a transfer does not restart the server.

## Authentication

`POST /api/auth/login` issues a signed **HS256 JWT** access token. The token is the only credential the client needs: it carries the subject, issue time, expiry, and a unique token id (`jti`).

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkZW1vLXVzZXIiLCJpYXQiOjE3OTQ1NTA3MDksImV4cCI6MTc5NDU3OTUwOSwianRpIjoiMWI1Y2VhMzgtNDU1YS00NmE4LTk5ZTItYTcxNGUzMDc1ODgxIn0.8Clt0_IUw7hkk1PUUcNswlIxd7TPWhIsszMbDAYrhiQ",
  "tokenType": "Bearer",
  "expiresAt": "2026-11-13T14:18:29.000Z"
}
```

Every other endpoint except `/api/health` requires the token in the `Authorization` header:

```sh
curl http://localhost:8000/api/wallet -H "Authorization: Bearer <token>"
```

The authentication middleware verifies the signature and expiry **before** the route handler runs, so an invalid or expired token never reaches application code. Failures return HTTP `401` with a specific `code`:

| Code             | Meaning                                                        |
| ---------------- | -------------------------------------------------------------- |
| `MISSING_TOKEN`  | No `Authorization: Bearer` header was sent                       |
| `INVALID_TOKEN`  | The signature did not verify, or the token was malformed         |
| `TOKEN_EXPIRED`  | The signature verified but the `exp` claim has passed            |

The backend is fully stateless: it keeps no session table, and there is no sign-out endpoint. The app clears the token from memory on sign-out, and the token expires on its own after `JWT_EXPIRES_IN_SECONDS`. Revoking a token before it expires would require a server-side denylist, which a stateless API deliberately avoids.

## Local development settings

The backend reads these environment variables at startup:

| Variable                 | Default | Description                                                                                |
| ------------------------ | ------: | ------------------------------------------------------------------------------------------ |
| `PORT`                   |  `8000` | Port used by the API server                                                                |
| `SEED_TRANSACTION_COUNT` |   `100` | Minimum number of demo seed transactions to keep in the JSON store; valid range is 2–10000 |
| `API_RESPONSE_DELAY_MS`  |  `1000` | Central delay before each response in milliseconds; set to `0` to disable                  |
| `FORCE_API_401`          |    `0` | Return HTTP 401 for every request when set to `1` (local UI error-state testing)             |
| `FORCE_API_500`          |    `0` | Return HTTP 500 for every request when set to `1` (local UI error-state testing)             |
| `JWT_SECRET`             | dev key | Secret used to sign and verify access tokens; at least 16 characters                      |
| `JWT_EXPIRES_IN_SECONDS` | `28800` | Access token lifetime in seconds (8 hours); valid range is 60–604800                     |

`JWT_SECRET` must stay the same across restarts, otherwise tokens issued before a restart stop verifying. The server prints a warning at startup when the default secret is in use.

For example, start the dev server with 200 seed transactions and no artificial delay:

```sh
SEED_TRANSACTION_COUNT=200 API_RESPONSE_DELAY_MS=0 npm run dev
```

To test the app's HTTP 500 screens, start the backend with:

```sh
FORCE_API_500=1 API_RESPONSE_DELAY_MS=0 npm start
```

To test HTTP 401 handling, use `FORCE_API_401=1` instead. Enable only one force-status flag at a time. Stop the backend and restart it without either flag to restore normal API behavior.

The backend adds missing seed records to an existing `wallet.json` without duplicating them or removing existing transactions. Increasing `SEED_TRANSACTION_COUNT` adds more seed records after restart; lowering it does not delete records.

## Home screen APIs

### `GET /wallet`

Returns the current demo user's wallet.

```json
{
  "id": "demo-wallet",
  "userId": "demo-user",
  "balance": 2450.75,
  "currency": "USD",
  "updatedAt": "2026-10-28T00:00:00.000Z"
}
```

### `GET /transactions?limit=10&offset=0`

Returns transactions ordered newest first. `limit` defaults to 10 and must be from 1 to 50. `offset` defaults to 0 and must be a non-negative integer.

```json
{
  "transactions": [],
  "pagination": {
    "limit": 10,
    "offset": 0,
    "total": 0,
    "hasMore": false,
    "nextOffset": null
  }
}
```

Invalid pagination values return HTTP `400` with an `error` object containing a stable `code` and readable `message`.

## Recipient lookup API

### `GET /recipients/lookup?phone=9000000001`

Looks up a recipient by the 10-digit Indian mobile number entered in the app. The backend compares it using the `+91` country code and returns the recipient details:

```json
{
  "id": "recipient-1",
  "name": "Jordan Lee",
  "phone": "+919000000001"
}
```

An invalid phone number returns HTTP `400`. A valid number with no match returns HTTP `404` and error code `RECIPIENT_NOT_FOUND`. Demo lookup numbers are `9000000001`, `9000000002`, and `9000000003`.

## Supporting endpoints

| Method | Path                           | Purpose                                          |
| ------ | ------------------------------ | ------------------------------------------------ |
| `POST` | `/api/auth/login`              | Issue a JWT access token (no token required)      |
| `GET`  | `/api/health`                  | Check whether the API is running                 |
| `GET`  | `/user`                        | Read the in-memory demo user's profile           |
| `GET`  | `/api/recipients`              | List demo recipients                             |
| `GET`  | `/recipients/lookup?phone=...` | Look up a demo recipient by Indian mobile number |
| `GET`  | `/transactions/:transactionId` | Read transaction details and receipt data        |
| `POST` | `/api/transfers`               | Validate and simulate a wallet transfer          |

The earlier `/api/wallet` and `/api/transactions` paths remain aliases for the Home screen GET routes.

## Demo data and limitations

The JSON file store is for a single local demo instance; it is not a production database or a multi-user financial system. The user and recipient records are fictional. No real financial credentials or payment processing are involved.

The access token uses a single shared symmetric secret and the demo login accepts no credentials at all, so it demonstrates the token lifecycle rather than protecting anything. A real deployment would need per-user credentials, a secret that is never committed to the repository, and a refresh-token flow for long-lived sessions.
