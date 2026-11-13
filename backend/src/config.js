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

// The signing secret must be stable across restarts, otherwise tokens issued
// before a restart stop validating. Set JWT_SECRET in the environment for
// anything other than local demo use.
const defaultJWTSecret = "swiftpay-local-demo-secret-change-me";
const jwtSecret = process.env.JWT_SECRET ?? defaultJWTSecret;

if (jwtSecret.length < 16) {
  throw new Error("JWT_SECRET must be at least 16 characters long.");
}

module.exports = Object.freeze({
  port: readIntegerSetting("PORT", 8000, 1, 65535),
  seedTransactionCount: readIntegerSetting("SEED_TRANSACTION_COUNT", 100, 2, 10000),
  apiResponseDelayMs: readIntegerSetting("API_RESPONSE_DELAY_MS", 1000, 0, 60000),
  forceAPI401,
  forceAPI500,
  jwtSecret,
  usesDefaultJWTSecret: jwtSecret === defaultJWTSecret,
  jwtExpiresInSeconds: readIntegerSetting("JWT_EXPIRES_IN_SECONDS", 28800, 60, 604800),
});
