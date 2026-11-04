const fs = require("node:fs");
const path = require("node:path");
const { randomUUID } = require("node:crypto");
const config = require("./config");

// This demo has one in-memory user. No user profile is written to disk.
const demoUser = Object.freeze({
  id: "demo-user",
  name: "Alex Morgan",
  phone: "+919876543210",
  email: "alex@example.test",
  imageUrl: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1760&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=NHwxMjA3fDA%3D",
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
    { id: "recipient-1", name: "Jordan Lee", email: "jordan@example.test", phone: "+919000000001" },
    { id: "recipient-2", name: "Taylor Kim", email: "taylor@example.test", phone: "+919000000002" },
    { id: "recipient-3", name: "Casey Patel", email: "casey@example.test", phone: "+919000000003" },
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
  let hasChanges = false;

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
    hasChanges = true;
  }

  if (!Array.isArray(state.transactions)) {
    state.transactions = [];
    hasChanges = true;
  }
  if (!Array.isArray(state.recipients) || state.recipients.length === 0) {
    state.recipients = initialState.recipients;
    hasChanges = true;
  }
  for (const recipient of state.recipients) {
    const demoRecipient = initialState.recipients.find(({ id }) => id === recipient.id);
    if (!recipient.phone && demoRecipient) {
      recipient.phone = demoRecipient.phone;
      hasChanges = true;
    }
  }
  if (!state.idempotency || typeof state.idempotency !== "object") {
    state.idempotency = {};
    hasChanges = true;
  }

  if (addMissingSeedTransactions(state)) {
    hasChanges = true;
  }

  if (hasChanges) writeState(state);
  return state;
}

function addMissingSeedTransactions(state) {
  const demoTransactionCount = state.transactions.filter(({ id }) => (
    typeof id === "string"
    && (id === "txn-demo-1" || id === "txn-demo-2" || id.startsWith("seed-txn-"))
  )).length;

  if (demoTransactionCount >= config.seedTransactionCount) return false;

  const existingIds = new Set(state.transactions.map(({ id }) => id));
  const descriptions = ["Coffee", "Groceries", "Transit", "Utilities", "Subscription"];
  let seededCount = demoTransactionCount;
  let index = 1;

  while (seededCount < config.seedTransactionCount) {
    const id = `seed-txn-${String(index).padStart(3, "0")}`;
    if (!existingIds.has(id)) {
      const isCredit = index % 4 === 0;
      const recipient = state.recipients[(index - 1) % state.recipients.length];
      const amount = Math.round((8 + ((index * 17.31) % 225)) * 100) / 100;
      const createdAt = new Date(
        Date.UTC(2026, 9, 29, 12) - index * 60 * 60 * 1000,
      ).toISOString();

      const transaction = {
        id,
        type: isCredit ? "credit" : "debit",
        amount,
        currency: state.wallet.currency,
        description: isCredit ? "Wallet top-up" : descriptions[index % descriptions.length],
        status: "completed",
        createdAt,
      };

      if (!isCredit) {
        transaction.recipientId = recipient.id;
        transaction.recipientName = recipient.name;
      }

      state.transactions.push(transaction);
      existingIds.add(id);
      seededCount += 1;
    }
    index += 1;
  }

  return true;
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
