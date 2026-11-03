const express = require("express");
const { demoUser, readState, writeState, createTransfer } = require("./store");
const config = require("./config");

const app = express();
const port = config.port;
const simulatedTransferFailures = new Map([
  [
    1010,
    {
      status: 400,
      code: "AMOUNT_NOT_ALLOWED",
      message: "Amount not allowed",
    },
  ],
  [
    1020,
    {
      status: 409,
      code: "INSUFFICIENT_BALANCE",
      message: "Insufficient balance",
    },
  ],
  [
    1030,
    {
      status: 429,
      code: "TRANSACTION_LIMIT_REACHED",
      message: "Transaction limit reached",
    },
  ],
]);

// Apply one configurable delay centrally to every API response.
app.use((_request, response, next) => {
  if (config.apiResponseDelayMs === 0) return next();

  const timer = setTimeout(next, config.apiResponseDelayMs);
  response.on("close", () => clearTimeout(timer));
});

app.use(express.json({ limit: "16kb" }));

app.get("/api/health", (_request, response) => {
  response.json({ status: "ok" });
});

app.get(["/user", "/api/user"], (_request, response) => {
  response.json(demoUser);
});

app.get(["/wallet", "/api/wallet"], (_request, response) => {
  const { wallet } = readState();
  response.json({
    id: wallet.id,
    userId: wallet.userId,
    balance: wallet.balance,
    currency: wallet.currency,
    updatedAt: wallet.updatedAt,
  });
});

app.get(["/recipients/lookup", "/api/recipients/lookup"], (request, response) => {
  const phone = request.query.phone;
  if (typeof phone !== "string" || !/^\d{10}$/.test(phone)) {
    return response.status(400).json({
      error: {
        code: "INVALID_PHONE_NUMBER",
        message: "phone must contain exactly 10 digits.",
      },
    });
  }

  const normalizedPhone = `+91${phone}`;
  const { recipients } = readState();
  const recipient = recipients.find(({ phone: storedPhone }) => storedPhone === normalizedPhone);

  if (!recipient) {
    return response.status(404).json({
      error: {
        code: "RECIPIENT_NOT_FOUND",
        message: "No recipient was found for this phone number.",
      },
    });
  }

  return response.json({
    id: recipient.id,
    name: recipient.name,
    phone: recipient.phone,
  });
});

app.get("/api/recipients", (_request, response) => {
  const { recipients } = readState();
  response.json({ recipients });
});

function parsePaginationValue(value, defaultValue, maximum = Number.MAX_SAFE_INTEGER) {
  if (value === undefined) return defaultValue;
  if (typeof value !== "string" || !/^\d+$/.test(value)) {
    return null;
  }
  const parsedValue = Number(value);
  return Number.isSafeInteger(parsedValue) && parsedValue <= maximum ? parsedValue : null;
}

app.get(["/transactions", "/api/transactions"], (request, response) => {
  const limit = parsePaginationValue(request.query.limit, 10, 50);
  const offset = parsePaginationValue(request.query.offset, 0);

  if (limit === null || limit < 1) {
    return response.status(400).json({
      error: { code: "INVALID_LIMIT", message: "limit must be an integer from 1 to 50." },
    });
  }
  if (offset === null) {
    return response.status(400).json({
      error: { code: "INVALID_OFFSET", message: "offset must be a non-negative integer." },
    });
  }

  const state = readState();
  const transactions = [...state.transactions].sort(
    (first, second) => Date.parse(second.createdAt) - Date.parse(first.createdAt),
  );
  const page = transactions.slice(offset, offset + limit);
  const hasMore = offset + page.length < transactions.length;

  response.json({
    transactions: page,
    pagination: {
      limit,
      offset,
      total: transactions.length,
      hasMore,
      nextOffset: hasMore ? offset + page.length : null,
    },
  });
});

app.get("/api/transactions/:transactionId", (request, response) => {
  const { transactions } = readState();
  const transaction = transactions.find(({ id }) => id === request.params.transactionId);
  if (!transaction) {
    return response
      .status(404)
      .json({ error: { code: "TRANSACTION_NOT_FOUND", message: "Transaction not found." } });
  }
  return response.json(transaction);
});

app.post("/api/transfers", (request, response) => {
  const { recipientId, amount, note } = request.body || {};
  const idempotencyKey = request.get("Idempotency-Key");

  if (typeof amount === "number" && Number.isFinite(amount)) {
    const simulatedFailure = simulatedTransferFailures.get(Math.round(amount * 100));

    if (simulatedFailure) {
      return response.status(simulatedFailure.status).json({
        error: {
          code: simulatedFailure.code,
          message: simulatedFailure.message,
        },
      });
    }
  }

  if (typeof recipientId !== "string" || !recipientId.trim()) {
    return response
      .status(400)
      .json({ error: { code: "INVALID_RECIPIENT", message: "A recipientId is required." } });
  }
  if (typeof amount !== "number" || !Number.isFinite(amount) || amount <= 0) {
    return response.status(400).json({
      error: {
        code: "INVALID_AMOUNT",
        message: "Amount must be a positive number with at most two decimal places.",
      },
    });
  }

  const amountInCents = Math.round(amount * 100);
  const roundingDifference = Math.abs(amount * 100 - amountInCents);
  if (roundingDifference > 1e-7) {
    return response.status(400).json({
      error: {
        code: "INVALID_AMOUNT",
        message: "Amount must be a positive number with at most two decimal places.",
      },
    });
  }

  const state = readState();
  if (idempotencyKey && state.idempotency[idempotencyKey]) {
    return response.status(200).json(state.idempotency[idempotencyKey]);
  }

  const recipient = state.recipients.find(({ id }) => id === recipientId);
  if (!recipient) {
    return response
      .status(404)
      .json({ error: { code: "RECIPIENT_NOT_FOUND", message: "Recipient not found." } });
  }

  if (amount > state.wallet.balance) {
    return response.status(409).json({
      error: {
        code: "INSUFFICIENT_BALANCE",
        message: "The wallet balance is too low for this transfer.",
      },
    });
  }

  const transaction = createTransfer(state, {
    recipient,
    amount,
    note: typeof note === "string" ? note.trim().slice(0, 120) : "",
  });
  const result = {
    transaction,
    wallet: { balance: state.wallet.balance, currency: state.wallet.currency },
  };
  if (idempotencyKey) state.idempotency[idempotencyKey] = result;
  writeState(state);
  return response.status(201).json(result);
});

app.use((_request, response) => {
  response.status(404).json({ error: { code: "NOT_FOUND", message: "Endpoint not found." } });
});

app.use((error, _request, response, _next) => {
  if (error instanceof SyntaxError && error.status === 400 && "body" in error) {
    return response
      .status(400)
      .json({ error: { code: "INVALID_JSON", message: "Request body must be valid JSON." } });
  }
  console.error(error);
  return response
    .status(500)
    .json({ error: { code: "INTERNAL_ERROR", message: "An unexpected server error occurred." } });
});

app.listen(port, () => {
  console.log(`SwiftPay API listening on http://localhost:${port}`);
  console.log(`API response delay: ${config.apiResponseDelayMs} ms`);
  console.log(`Configured demo transaction count: ${config.seedTransactionCount}`);
});
