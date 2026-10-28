const express = require('express');
const { readState, writeState, createTransfer } = require('./store');

const app = express();
const port = Number(process.env.PORT || 3000);

app.use(express.json({ limit: '16kb' }));

app.get('/api/health', (_request, response) => {
  response.json({ status: 'ok' });
});

app.get('/api/user', (_request, response) => {
  const state = readState();
  response.json(state.user);
});

app.get('/api/wallet', (_request, response) => {
  const state = readState();
  response.json({
    userId: state.user.id,
    balance: state.balance,
    currency: state.user.currency,
  });
});

app.get('/api/recipients', (_request, response) => {
  const { recipients } = readState();
  response.json({ recipients });
});

app.get('/api/transactions', (request, response) => {
  const state = readState();
  const limit = Math.min(Math.max(Number.parseInt(request.query.limit, 10) || 20, 1), 100);
  const offset = Math.max(Number.parseInt(request.query.offset, 10) || 0, 0);
  response.json({
    transactions: state.transactions.slice(offset, offset + limit),
    total: state.transactions.length,
    limit,
    offset,
  });
});

app.get('/api/transactions/:transactionId', (request, response) => {
  const { transactions } = readState();
  const transaction = transactions.find(({ id }) => id === request.params.transactionId);
  if (!transaction) {
    return response.status(404).json({ error: { code: 'TRANSACTION_NOT_FOUND', message: 'Transaction not found.' } });
  }
  return response.json(transaction);
});

app.post('/api/transfers', (request, response) => {
  const { recipientId, amount, note } = request.body || {};
  const idempotencyKey = request.get('Idempotency-Key');

  if (typeof recipientId !== 'string' || !recipientId.trim()) {
    return response.status(400).json({ error: { code: 'INVALID_RECIPIENT', message: 'A recipientId is required.' } });
  }
  if (typeof amount !== 'number' || !Number.isFinite(amount) || amount <= 0 || Math.round(amount * 100) !== amount * 100) {
    return response.status(400).json({ error: { code: 'INVALID_AMOUNT', message: 'Amount must be a positive number with at most two decimal places.' } });
  }

  const state = readState();
  if (idempotencyKey && state.idempotency[idempotencyKey]) {
    return response.status(200).json(state.idempotency[idempotencyKey]);
  }

  const recipient = state.recipients.find(({ id }) => id === recipientId);
  if (!recipient) {
    return response.status(404).json({ error: { code: 'RECIPIENT_NOT_FOUND', message: 'Recipient not found.' } });
  }
  if (amount > state.balance) {
    return response.status(409).json({ error: { code: 'INSUFFICIENT_BALANCE', message: 'The wallet balance is too low for this transfer.' } });
  }

  const transaction = createTransfer(state, { recipient, amount, note: typeof note === 'string' ? note.trim().slice(0, 120) : '' });
  const result = { transaction, wallet: { balance: state.balance, currency: state.user.currency } };
  if (idempotencyKey) state.idempotency[idempotencyKey] = result;
  writeState(state);
  return response.status(201).json(result);
});

app.use((_request, response) => {
  response.status(404).json({ error: { code: 'NOT_FOUND', message: 'Endpoint not found.' } });
});

app.use((error, _request, response, _next) => {
  if (error instanceof SyntaxError && error.status === 400 && 'body' in error) {
    return response.status(400).json({ error: { code: 'INVALID_JSON', message: 'Request body must be valid JSON.' } });
  }
  console.error(error);
  return response.status(500).json({ error: { code: 'INTERNAL_ERROR', message: 'An unexpected server error occurred.' } });
});

app.listen(port, () => {
  console.log(`SwiftPay API listening on http://localhost:${port}`);
});
