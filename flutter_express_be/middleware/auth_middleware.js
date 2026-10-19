import { jwtVerify, SignJWT } from "jose";
import { sendError } from "../utils/response.js";
import { status } from "../utils/general.js";
import crypto from "crypto";
import DB from "../core/config/knex.js";

/**
 * Generate Access Token & Refresh Token untuk Mobile User
 */
export const generateMobileTokens = async (payload, rememberMe = true) => {
  const secretKey = new TextEncoder().encode(process.env.USER_SECRET || "random");
  const accessExpiry = rememberMe ? "30d" : "7d"; // Mobile apps benefit from longer sessions
  const refreshExpireInSeconds = 60 * 24 * 60 * 60; // 60 days

  const accessToken = await new SignJWT(payload)
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime(accessExpiry)
    .sign(secretKey);

  const refreshToken = crypto.randomBytes(40).toString("hex");
  const expiresAt = new Date(Date.now() + refreshExpireInSeconds * 1000);

  try {
    // Revoke old tokens if table exists
    const hasTable = await DB.schema.hasTable("access_token");
    if (hasTable && payload.user_code) {
      await DB("access_token")
        .where("user_code", payload.user_code)
        .andWhere("expired", "0")
        .update({ expired: "1" });

      await DB("access_token").insert({
        user_code: payload.user_code,
        token: refreshToken,
        expired: "0",
        expires_at: expiresAt,
      });
    }
  } catch (err) {
    console.error("Warning: Gagal menyimpan access_token:", err.message);
  }

  return {
    access_token: accessToken,
    refresh_token: refreshToken,
  };
};

/**
 * Middleware Autentikasi JWT untuk Mobile API
 */
export const authenticateMobile = async (req, res, next) => {
  const header = req.headers["authorization"];
  const token = header && header.startsWith("Bearer ") ? header.split(" ")[1] : null;

  // Development Bypass via header jika APP_DEBUG aktif
  if (process.env.APP_DEBUG === "true" && req.headers["x-uniqueid"]) {
    req.auth = {
      user_code: req.headers["x-uniqueid"],
      role: req.headers["x-role"] || "pasien",
      username: req.headers["x-uniqueid"],
      no_rm: req.headers["x-norm"] || null,
      kode_cabang: req.headers["x-kode-cabang"] || "CBG-001",
    };
    req.user = req.auth;
    return next();
  }

  if (!token) {
    return sendError(
      res,
      "Akses ditolak. Token autentikasi tidak ditemukan.",
      401,
      status.BAD_REQUEST
    );
  }

  try {
    const secretKey = new TextEncoder().encode(process.env.USER_SECRET || "random");
    const { payload } = await jwtVerify(token, secretKey);

    const headerCabang = req.headers["x-kode-cabang"];
    const isSuperAdmin = (payload.role || "").toLowerCase() === "superadmin";

    req.auth = {
      user_code: payload.user_code,
      username: payload.username,
      role: payload.role || "pasien",
      no_rm: payload.no_rm || null,
      fullname: payload.fullname || payload.nama || payload.username,
      nama: payload.nama || payload.fullname || payload.username,
      kode_cabang: isSuperAdmin && headerCabang ? headerCabang : (payload.kode_cabang || "CBG-001"),
      nama_cabang: payload.nama_cabang || null,
      is_superadmin: isSuperAdmin,
    };
    req.user = req.auth;

    return next();
  } catch (error) {
    return sendError(
      res,
      "Sesi login telah berakhir atau token tidak valid. Silakan login kembali.",
      401,
      status.BAD_REQUEST
    );
  }
};

/**
 * Optional Authentication: jika ada token diparsing, jika tidak tetap lanjut (berguna untuk endpoint publik yg bisa personalisasi)
 */
export const optionalAuth = async (req, res, next) => {
  const header = req.headers["authorization"];
  const token = header && header.startsWith("Bearer ") ? header.split(" ")[1] : null;

  if (token) {
    try {
      const secretKey = new TextEncoder().encode(process.env.USER_SECRET || "random");
      const { payload } = await jwtVerify(token, secretKey);
      req.auth = payload;
      req.user = payload;
    } catch {
      // ignore error on optional auth
    }
  }
  return next();
};
