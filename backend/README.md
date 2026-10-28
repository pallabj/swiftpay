# SwiftPay Backend

A small Node.js and Express API for the SwiftPay demo app. Transfers are simulated and stored locally; the API never moves money.

## Run locally

Requires Node.js 20 or later.

```sh
cd backend
npm install
npm start
```

The API listens on `http://localhost:3000` by default. Set `PORT` to use a different port. On first startup, the backend creates `data/wallet.json` with demo data. That file persists wallet changes across restarts and is ignored by Git.

## Endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/api/health` | Check whether the API is running |
| `GET` | `/api/user` | Read the demo user's profile |
| `GET` | `/api/wallet` | Read the current wallet balance and currency |
| `GET` | `/api/recipients` | List demo recipients |
| `GET` | `/api/transactions?limit=20&offset=0` | List transaction history |
| `GET` | `/api/transactions/:transactionId` | Read transaction details and receipt data |
| `POST` | `/api/transfers` | Validate and simulate a wallet transfer |

### Create a simulated transfer

```http
POST /api/transfers
Content-Type: application/json
Idempotency-Key: a-unique-request-id
```

```json
{
  "recipientId": "recipient-1",
  "amount": 25.5,
  "note": "Coffee"
}
```

Successful transfers return the new transaction and updated wallet balance. Reusing an `Idempotency-Key` returns the original result, preventing a repeated request from creating another debit. Validation errors use an `error` object with a stable `code` and readable `message`. Insufficient balance returns `409`.

## Demo data and limitations

The product brief mentions a public API for demo user and recipient data but does not name its URL. This starter backend serves safe, fictional demo profiles locally until that API is specified. Transactions are mock records, and the JSON file store is intended for local development only; it is not a production database or a multi-user financial system.
