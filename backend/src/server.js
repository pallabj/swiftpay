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

// Enable one force-status flag to exercise the app's API error states.
app.use((_request, response, next) => {
  if (config.forceAPI401) {
    return response.status(401).json({
      error: {
        code: "FORCED_UNAUTHORIZED",
        message: "Forced HTTP 401 for local testing.",
      },
    });
  }

  if (!config.forceAPI500) return next();

  return response.status(500).json({
    error: {
      code: "FORCED_INTERNAL_SERVER_ERROR",
      message: "Forced HTTP 500 for local testing.",
    },
  });
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

function encodeTransactionCursor(transaction) {
  return Buffer.from(
    JSON.stringify({ createdAt: transaction.createdAt, id: transaction.id }),
  ).toString("base64url");
}

function decodeTransactionCursor(value) {
  if (typeof value !== "string") return null;

  try {
    const cursor = JSON.parse(Buffer.from(value, "base64url").toString("utf8"));
    if (
      typeof cursor.createdAt !== "string" ||
      !Number.isFinite(Date.parse(cursor.createdAt)) ||
      typeof cursor.id !== "string" ||
      cursor.id.length === 0
    ) {
      return null;
    }

    return { createdAt: cursor.createdAt, id: cursor.id };
  } catch {
    return null;
  }
}

function comesAfterTransactionCursor(transaction, cursor) {
  const transactionTime = Date.parse(transaction.createdAt);
  const cursorTime = Date.parse(cursor.createdAt);

  return transactionTime < cursorTime || (
    transactionTime === cursorTime && transaction.id < cursor.id
  );
}

function compareTransactionsNewestFirst(first, second) {
  const timeDifference = Date.parse(second.createdAt) - Date.parse(first.createdAt);
  if (timeDifference !== 0) return timeDifference;
  if (first.id === second.id) return 0;
  return first.id > second.id ? -1 : 1;
}

app.get(["/transactions", "/api/transactions"], (request, response) => {
  const limit = parsePaginationValue(request.query.limit, 10, 50);
  const cursorValue = request.query.after;
  const cursor = cursorValue === undefined
    ? null
    : decodeTransactionCursor(cursorValue);

  if (limit === null || limit < 1) {
    return response.status(400).json({
      error: { code: "INVALID_LIMIT", message: "limit must be an integer from 1 to 50." },
    });
  }
  if (cursorValue !== undefined && cursor === null) {
    return response.status(400).json({
      error: { code: "INVALID_CURSOR", message: "after must be a valid transaction cursor." },
    });
  }

  const state = readState();
  const transactions = [...state.transactions].sort(
    compareTransactionsNewestFirst,
  );
  const eligibleTransactions = cursor
    ? transactions.filter((transaction) => comesAfterTransactionCursor(transaction, cursor))
    : transactions;
  const pageWithLookahead = eligibleTransactions.slice(0, limit + 1);
  const hasMore = pageWithLookahead.length > limit;
  const page = pageWithLookahead.slice(0, limit);
  const nextCursor = hasMore
    ? encodeTransactionCursor(page[page.length - 1])
    : null;

  response.json({
    transactions: page,
    pagination: {
      limit,
      hasMore,
      nextCursor,
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
  const forcedAPIStatus = config.forceAPI401 ? 401 : config.forceAPI500 ? 500 : "disabled";
  console.log(`Forced API status: ${forcedAPIStatus}`);
  console.log(`Configured demo transaction count: ${config.seedTransactionCount}`);
});
