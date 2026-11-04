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

## Local development settings

The backend reads these environment variables at startup:

| Variable                 | Default | Description                                                                                |
| ------------------------ | ------: | ------------------------------------------------------------------------------------------ |
| `PORT`                   |  `8000` | Port used by the API server                                                                |
| `SEED_TRANSACTION_COUNT` |   `100` | Minimum number of demo seed transactions to keep in the JSON store; valid range is 2–10000 |
| `API_RESPONSE_DELAY_MS`  |  `1000` | Central delay before each response in milliseconds; set to `0` to disable                  |

For example, start the dev server with 200 seed transactions and no artificial delay:

```sh
SEED_TRANSACTION_COUNT=200 API_RESPONSE_DELAY_MS=0 npm run dev
```

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
| `GET`  | `/api/health`                  | Check whether the API is running                 |
| `GET`  | `/user`                        | Read the in-memory demo user's profile           |
| `GET`  | `/api/recipients`              | List demo recipients                             |
| `GET`  | `/recipients/lookup?phone=...` | Look up a demo recipient by Indian mobile number |
| `GET`  | `/transactions/:transactionId` | Read transaction details and receipt data        |
| `POST` | `/api/transfers`               | Validate and simulate a wallet transfer          |

The earlier `/api/wallet` and `/api/transactions` paths remain aliases for the Home screen GET routes.

## Demo data and limitations

The JSON file store is for a single local demo instance; it is not a production database or a multi-user financial system. The user and recipient records are fictional. No real financial credentials or payment processing are involved.
