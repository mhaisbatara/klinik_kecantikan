import express from "express";
import Joi from "joi";
import DB from "../../../core/config/knex.js";
import { sendSuccess, sendError } from "../../../utils/response.js";
import { status } from "../../../utils/general.js";
import { formatDateSystem } from "../../../utils/date_tools.js";
import {
  hashClinicPassword,
  verifyClinicPassword,
} from "../../../utils/encrypt_tools.js";
import {
  authenticateMobile,
  generateMobileTokens,
} from "../../../middleware/auth_middleware.js";

const router = express.Router();

/**
 * POST /api/v1/auth/login
 * Login untuk Pasien dan Tenaga Medis/Dokter/Staff via Mobile App
 */
router.post("/login", async (req, res) => {
  const { username, password, remember_me } = req.body || {};

  if (!username || !password) {
    return sendError(
      res,
      "Username/Email/No HP dan password wajib diisi",
      400,
      status.BAD_REQUEST
    );
  }

  try {
    const cleanUser = String(username).trim();

    // 1. Cari user di user_credential (bisa login via username, email, telp, atau user_code)
    let user = await DB("user_credential as u")
      .leftJoin("mst_cabang as c", "u.kode_cabang", "c.kode_cabang")
      .where("u.username", cleanUser)
      .orWhere("u.telp", cleanUser)
      .orWhere("u.user_code", cleanUser)
      .select(
        "u.id",
        "u.user_code",
        "u.username",
        "u.fullname",
        "u.telp",
        "u.role",
        "u.password",
        "u.status",
        "u.kode_cabang",
        "c.nama_cabang"
      )
      .first();

    // 2. Jika tidak ditemukan di user_credential, cari apakah no_rm atau email terdaftar di mst_pasien
    let patientData = null;
    if (!user) {
      patientData = await DB("mst_pasien")
        .where("no_rm", cleanUser)
        .orWhere("no_hp", cleanUser)
        .orWhere("email", cleanUser)
        .first();

      if (patientData) {
        // Cek apakah pasien punya user_credential yang terhubung via no_hp / email
        user = await DB("user_credential")
          .where("telp", patientData.no_hp)
          .orWhere("username", patientData.email)
          .first();
      }
    }

    if (!user) {
      return sendError(
        res,
        "Akun tidak ditemukan. Pastikan email atau nomor HP sudah terdaftar.",
        404,
        status.NOT_FOUND
      );
    }

    if (String(user.status) !== "1") {
      return sendError(
        res,
        "Akun Anda sedang dinonaktifkan. Silakan hubungi admin klinik.",
        403,
        status.GAGAL
      );
    }

    // 3. Verifikasi Password dengan format standar express_standart_be
    const isPasswordValid = verifyClinicPassword(
      user.user_code,
      password,
      user.password
    );

    if (!isPasswordValid) {
      return sendError(res, "Password salah", 400, status.GAGAL);
    }

    // 4. Jika user adalah pasien, ambil info tambahan dari mst_pasien
    let noRm = null;
    let fotoPasien = null;
    let detailPasien = null;

    if (user.role === "pasien" || !user.role) {
      detailPasien = await DB("mst_pasien")
        .where("no_hp", user.telp)
        .orWhere("email", user.username)
        .first();

      if (detailPasien) {
        noRm = detailPasien.no_rm;
        fotoPasien = detailPasien.foto;
      }
    }

    // 5. Generate Mobile JWT Token
    const tokenPayload = {
      user_code: user.user_code,
      username: user.username,
      role: user.role || "pasien",
      fullname: user.fullname,
      nama: user.fullname,
      no_rm: noRm,
      kode_cabang: user.kode_cabang || "CBG-001",
      nama_cabang: user.nama_cabang || "Klinik Utama",
    };

    const tokens = await generateMobileTokens(
      tokenPayload,
      remember_me === true || remember_me === "1"
    );

    return sendSuccess(res, "Login Berhasil", {
      access_token: tokens.access_token,
      refresh_token: tokens.refresh_token,
      user_info: {
        user_code: user.user_code,
        username: user.username,
        fullname: user.fullname,
        role: user.role || "pasien",
        telp: user.telp,
        no_rm: noRm,
        foto: fotoPasien,
        kode_cabang: user.kode_cabang || "CBG-001",
        nama_cabang: user.nama_cabang || "Klinik Utama",
        pasien_profile: detailPasien || null,
      },
    });
  } catch (error) {
    console.error("Login Mobile Error:", error);
    return sendError(
      res,
      process.env.APP_DEBUG === "true"
        ? `Error: ${error.message}`
        : "Terjadi kesalahan sistem saat proses login",
      500,
      status.BAD_REQUEST
    );
  }
});

/**
 * POST /api/v1/auth/register
 * Pendaftaran Pasien Baru Mandiri dari Aplikasi Mobile Flutter
 */
router.post("/register", async (req, res) => {
  const body = req.body || {};

  // Validasi input registrasi
  const schema = Joi.object({
    nama: Joi.string().max(100).required().label("Nama Lengkap"),
    no_hp: Joi.string()
      .pattern(/^[0-9+]+$/)
      .min(10)
      .max(15)
      .required()
      .label("Nomor HP"),
    password: Joi.string().min(6).required().label("Password"),
    email: Joi.string().email().allow("", null).label("Email"),
    nik: Joi.string().pattern(/^\d{16}$/).allow("", null).label("NIK"),
    tanggal_lahir: Joi.string().allow("", null).label("Tanggal Lahir"),
    jenis_kelamin: Joi.string().valid("L", "P").default("P").label("Jenis Kelamin"),
    alamat: Joi.string().allow("", null).label("Alamat"),
    kode_cabang: Joi.string().allow("", null).default("CBG-001").label("Cabang"),
  });

  const { error, value } = schema.validate(body);
  if (error) {
    return sendError(res, error.details[0].message, 422, status.BAD_REQUEST);
  }

  const cleanPhone = value.no_hp.replace(/[\s-]/g, "");
  const branchCode = value.kode_cabang || "CBG-001";

  try {
    // 1. Cek apakah nomor HP sudah terdaftar
    const existingPhone = await DB("user_credential")
      .where("telp", cleanPhone)
      .first();

    if (existingPhone) {
      return sendError(
        res,
        "Nomor HP ini sudah terdaftar. Silakan login atau gunakan nomor lain.",
        400,
        status.GAGAL
      );
    }

    if (value.email) {
      const existingEmail = await DB("user_credential")
        .where("username", value.email)
        .first();

      if (existingEmail) {
        return sendError(
          res,
          "Email ini sudah terdaftar. Silakan login dengan email tersebut.",
          400,
          status.GAGAL
        );
      }
    }

    // 2. Transaksi pembuatan Rekam Medis (mst_pasien) + Akun (user_credential)
    let newUserInfo = null;

    await DB.transaction(async (trx) => {
      // a. Generate No RM (RM-000001 dst)
      const lastPasien = await trx("mst_pasien")
        .where("no_rm", "like", "RM-%")
        .orderBy("id", "desc")
        .first();

      let nextRmSeq = 1;
      if (lastPasien && lastPasien.no_rm) {
        const parts = lastPasien.no_rm.split("-");
        const num = parseInt(parts[1], 10);
        if (!isNaN(num)) nextRmSeq = num + 1;
      }
      const cNoRm = `RM-${String(nextRmSeq).padStart(6, "0")}`;

      // b. Generate User Code (USR000001 dst)
      const lastUser = await trx("user_credential")
        .where("user_code", "like", "USR%")
        .orderBy("user_code", "desc")
        .first();

      let nextUserSeq = 1;
      if (lastUser && lastUser.user_code) {
        const numPart = parseInt(lastUser.user_code.replace("USR", ""), 10);
        if (!isNaN(numPart)) nextUserSeq = numPart + 1;
      }
      const cUserCode = `USR${String(nextUserSeq).padStart(6, "0")}`;

      // c. Insert ke mst_pasien
      const patientRecord = {
        kode_cabang: branchCode,
        no_rm: cNoRm,
        nama: value.nama,
        nik: value.nik || null,
        tanggal_lahir: value.tanggal_lahir || "2000-01-01",
        jenis_kelamin: value.jenis_kelamin || "P",
        no_hp: cleanPhone,
        email: value.email || null,
        patokan: value.alamat || null,
        status: "aktif",
        tz: process.env.APP_TZ || "Asia/Jakarta",
        created_by: "mobile_register",
        created_at: formatDateSystem(),
      };
      await trx("mst_pasien").insert(patientRecord);

      // d. Insert ke user_credential
      const hashedPassword = hashClinicPassword(cUserCode, value.password);
      const userRecord = {
        user_code: cUserCode,
        username: value.email || cleanPhone,
        fullname: value.nama,
        telp: cleanPhone,
        role: "pasien",
        password: hashedPassword,
        status: "1",
        kode_cabang: branchCode,
        tz: process.env.APP_TZ || "Asia/Jakarta",
        created_by: "mobile_register",
        created_at: formatDateSystem(),
      };
      await trx("user_credential").insert(userRecord);

      newUserInfo = {
        user_code: cUserCode,
        no_rm: cNoRm,
        username: userRecord.username,
        fullname: value.nama,
        telp: cleanPhone,
        role: "pasien",
        kode_cabang: branchCode,
      };
    });

    // 3. Generate tokens langsung setelah registrasi
    const tokens = await generateMobileTokens(newUserInfo, true);

    return sendSuccess(
      res,
      "Registrasi berhasil! Selamat datang di aplikasi klinik kecantikan.",
      {
        access_token: tokens.access_token,
        refresh_token: tokens.refresh_token,
        user_info: newUserInfo,
      },
      201
    );
  } catch (error) {
    console.error("Register Mobile Error:", error);
    return sendError(
      res,
      process.env.APP_DEBUG === "true"
        ? `Gagal mendaftar: ${error.message}`
        : "Terjadi kesalahan saat pendaftaran akun",
      500,
      status.BAD_REQUEST
    );
  }
});

/**
 * GET /api/v1/auth/me
 * Mendapatkan profil akun yang sedang login
 */
router.get("/me", authenticateMobile, async (req, res) => {
  try {
    const auth = req.auth;
    let patientDetails = null;

    if (auth.no_rm) {
      patientDetails = await DB("mst_pasien")
        .where("no_rm", auth.no_rm)
        .first();
    } else {
      patientDetails = await DB("mst_pasien")
        .where("no_hp", auth.username)
        .orWhere("email", auth.username)
        .first();
    }

    return sendSuccess(res, "Profil berhasil dimuat", {
      ...auth,
      pasien_profile: patientDetails || null,
    });
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * POST /api/v1/auth/change-password
 * Mengubah password akun
 */
router.post("/change-password", authenticateMobile, async (req, res) => {
  const { password_lama, password_baru } = req.body || {};

  if (!password_lama || !password_baru) {
    return sendError(res, "Password lama dan baru wajib diisi", 400);
  }

  if (password_baru.length < 6) {
    return sendError(res, "Password baru minimal 6 karakter", 422);
  }

  try {
    const user = await DB("user_credential")
      .where("user_code", req.auth.user_code)
      .first();

    if (!user) {
      return sendError(res, "User tidak ditemukan", 404);
    }

    const isValid = verifyClinicPassword(
      user.user_code,
      password_lama,
      user.password
    );

    if (!isValid) {
      return sendError(res, "Password lama yang Anda masukkan salah", 400);
    }

    const newHashed = hashClinicPassword(user.user_code, password_baru);
    await DB("user_credential")
      .where("user_code", user.user_code)
      .update({
        password: newHashed,
        updated_at: formatDateSystem(),
      });

    return sendSuccess(res, "Password berhasil diperbarui");
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

export default router;
