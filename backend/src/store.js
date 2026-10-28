const fs = require('node:fs');
const path = require('node:path');
const { randomUUID } = require('node:crypto');

const dataDirectory = path.join(__dirname, '..', 'data');
const dataFile = path.join(dataDirectory, 'wallet.json');

const initialState = {
  user: {
    id: 'demo-user',
    name: 'Alex Morgan',
    email: 'alex@example.test',
    currency: 'USD',
  },
  balance: 2450.75,
  recipients: [
    { id: 'recipient-1', name: 'Jordan Lee', email: 'jordan@example.test' },
    { id: 'recipient-2', name: 'Taylor Kim', email: 'taylor@example.test' },
    { id: 'recipient-3', name: 'Casey Patel', email: 'casey@example.test' },
  ],
  transactions: [
    {
      id: 'txn-demo-1',
      type: 'credit',
      amount: 320.00,
      currency: 'USD',
      description: 'Demo wallet top-up',
      status: 'completed',
      createdAt: '2026-10-20T10:00:00.000Z',
    },
    {
      id: 'txn-demo-2',
      type: 'debit',
      amount: 45.50,
      currency: 'USD',
      recipientId: 'recipient-1',
      recipientName: 'Jordan Lee',
      description: 'Lunch',
      status: 'completed',
      createdAt: '2026-10-22T12:30:00.000Z',
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
  return JSON.parse(fs.readFileSync(dataFile, 'utf8'));
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
    type: 'debit',
    amount,
    currency: state.user.currency,
    recipientId: recipient.id,
    recipientName: recipient.name,
    description: note || `Transfer to ${recipient.name}`,
    status: 'completed',
    createdAt: new Date().toISOString(),
  };
  state.balance = Math.round((state.balance - amount) * 100) / 100;
  state.transactions.unshift(transaction);
  return transaction;
}

module.exports = { readState, writeState, createTransfer };
