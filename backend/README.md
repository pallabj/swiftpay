# SwiftPay Backend

Small Node.js and Express support API for the SwiftPay app. It serves one fictional demo user and stores wallet data in a local JSON file. Transfers are simulated; the API never moves money.

## Run locally

Requires Node.js 20 or later.

```sh
cd backend
npm install
npm start
```

The API listens on `http://localhost:3000` by default. Set `PORT` to use a different port. On first request, the backend creates `data/wallet.json` with a sample balance and transaction history. Wallet balance and transactions persist across restarts. The demo user profile is held in memory and resets when the server restarts.

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

## Supporting endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/api/health` | Check whether the API is running |
| `GET` | `/user` | Read the in-memory demo user's profile |
| `GET` | `/recipients` | List demo recipients |
| `GET` | `/transactions/:transactionId` | Read transaction details and receipt data |
| `POST` | `/api/transfers` | Validate and simulate a wallet transfer |

The earlier `/api/wallet` and `/api/transactions` paths remain aliases for the Home screen GET routes.

## Demo data and limitations

The JSON file store is for a single local demo instance; it is not a production database or a multi-user financial system. The user and recipient records are fictional. No real financial credentials or payment processing are involved.
