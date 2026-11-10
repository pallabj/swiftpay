function readIntegerSetting(name, defaultValue, minimum, maximum) {
  const rawValue = process.env[name];
  if (rawValue === undefined) return defaultValue;

  const value = Number(rawValue);
  if (!Number.isSafeInteger(value) || value < minimum || value > maximum) {
    throw new Error(`${name} must be an integer between ${minimum} and ${maximum}.`);
  }

  return value;
}

const forceAPI401 = process.env.FORCE_API_401 === "1";
const forceAPI500 = process.env.FORCE_API_500 === "1";

if (forceAPI401 && forceAPI500) {
  throw new Error("Set only one of FORCE_API_401 or FORCE_API_500.");
}

module.exports = Object.freeze({
  port: readIntegerSetting("PORT", 8000, 1, 65535),
  seedTransactionCount: readIntegerSetting("SEED_TRANSACTION_COUNT", 100, 2, 10000),
  apiResponseDelayMs: readIntegerSetting("API_RESPONSE_DELAY_MS", 1000, 0, 60000),
  forceAPI401,
  forceAPI500,
});
