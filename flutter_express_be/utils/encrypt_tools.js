import crypto from "crypto";

export const hash = (text, alg = "sha256") => {
  return crypto.createHash(alg).update(text).digest("hex");
};

export const hmac = (text, secret, alg = "sha256") => {
  return crypto.createHmac(alg, secret).update(text).digest("hex");
};

export const hashEquals = (hashedInput, storedHash) => {
  if (!hashedInput || !storedHash) return false;
  try {
    const bufferInput = Buffer.from(hashedInput, "hex");
    const bufferStored = Buffer.from(storedHash, "hex");

    if (bufferInput.length !== bufferStored.length) return false;
    return crypto.timingSafeEqual(bufferInput, bufferStored);
  } catch (e) {
    return false;
  }
};

/**
 * Standard password hashing formula matching express_standart_be:
 * HMAC_SHA512(USER_KEY + user_code + plainPassword, USER_SECRET)
 */
export const hashClinicPassword = (userCode, plainPassword) => {
  const userKey = process.env.USER_KEY || "random";
  const userSecret = process.env.USER_SECRET || "random";
  const rawPass = userKey + userCode + plainPassword;
  return hmac(rawPass, userSecret, "sha512");
};

export const verifyClinicPassword = (userCode, plainPassword, storedHash) => {
  const calculatedHash = hashClinicPassword(userCode, plainPassword);
  return hashEquals(calculatedHash, storedHash);
};
