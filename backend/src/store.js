const fs = require("node:fs");
const path = require("node:path");
const { randomUUID } = require("node:crypto");

// This demo has one in-memory user. No user profile is written to disk.
const demoUser = Object.freeze({
  id: "demo-user",
  name: "Alex Morgan",
  email: "alex@example.test",
  currency: "USD",
});

const dataDirectory = path.join(__dirname, "..", "data");
const dataFile = path.join(dataDirectory, "wallet.json");

const initialState = {
  wallet: {
    id: "demo-wallet",
    userId: demoUser.id,
    balance: 2450.75,
    currency: demoUser.currency,
    updatedAt: "2026-10-28T00:00:00.000Z",
  },
  recipients: [
    { id: "recipient-1", name: "Jordan Lee", email: "jordan@example.test" },
    { id: "recipient-2", name: "Taylor Kim", email: "taylor@example.test" },
    { id: "recipient-3", name: "Casey Patel", email: "casey@example.test" },
  ],
  transactions: [
    {
      id: "txn-demo-2",
      type: "debit",
      amount: 45.5,
      currency: demoUser.currency,
      recipientId: "recipient-1",
      recipientName: "Jordan Lee",
      description: "Lunch",
      status: "completed",
      createdAt: "2026-10-22T12:30:00.000Z",
    },
    {
      id: "txn-demo-1",
      type: "credit",
      amount: 320,
      currency: demoUser.currency,
      description: "Demo wallet top-up",
      status: "completed",
      createdAt: "2026-10-20T10:00:00.000Z",
    },
  ],
  idempotency: {},
};

function ensureStore() {
  fs.mkdirSync(dataDirectory, { recursive: true });
  if (!fs.existsSync(dataFile)) {
    writeState(initialState);
  }
}

function readState() {
  ensureStore();
  const state = JSON.parse(fs.readFileSync(dataFile, "utf8"));

  // Convert the first backend version's file format without losing demo history.
  if (!state.wallet) {
    state.wallet = {
      id: "demo-wallet",
      userId: demoUser.id,
      balance: state.balance ?? 2450.75,
      currency: state.user?.currency ?? demoUser.currency,
      updatedAt: new Date().toISOString(),
    };
    delete state.balance;
    delete state.user;
    writeState(state);
  }

  return state;
}

function writeState(state) {
  fs.mkdirSync(dataDirectory, { recursive: true });
  const temporaryFile = `${dataFile}.tmp`;
  fs.writeFileSync(temporaryFile, JSON.stringify(state, null, 2));
  fs.renameSync(temporaryFile, dataFile);
}

function createTransfer(state, { recipient, amount, note }) {
  const transaction = {
    id: randomUUID(),
    type: "debit",
    amount,
    currency: state.wallet.currency,
    recipientId: recipient.id,
    recipientName: recipient.name,
    description: note || `Transfer to ${recipient.name}`,
    status: "completed",
    createdAt: new Date().toISOString(),
  };

  state.wallet.balance = Math.round((state.wallet.balance - amount) * 100) / 100;
  state.wallet.updatedAt = transaction.createdAt;
  state.transactions.push(transaction);
  return transaction;
}

module.exports = { demoUser, readState, writeState, createTransfer };
