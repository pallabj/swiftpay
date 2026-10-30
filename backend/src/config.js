function readIntegerSetting(name, defaultValue, minimum, maximum) {
  const rawValue = process.env[name];
  if (rawValue === undefined) return defaultValue;

  const value = Number(rawValue);
  if (!Number.isSafeInteger(value) || value < minimum || value > maximum) {
    throw new Error(`${name} must be an integer between ${minimum} and ${maximum}.`);
  }

  return value;
}

module.exports = Object.freeze({
  port: readIntegerSetting("PORT", 8000, 1, 65535),
  seedTransactionCount: readIntegerSetting("SEED_TRANSACTION_COUNT", 100, 2, 10000),
  apiResponseDelayMs: readIntegerSetting("API_RESPONSE_DELAY_MS", 1000, 0, 60000),
});
