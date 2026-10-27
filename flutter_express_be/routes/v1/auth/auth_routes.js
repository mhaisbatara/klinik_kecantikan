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
        "u.no_rm",
        "u.password",
        "u.status",
        "u.kode_cabang",
        "c.nama_cabang"
      )
      .first();

    // 2. Jika tidak ditemukan langsung, cek apakah no_rm dimasukkan dan ada user_credential yang terhubung
    if (!user) {
      user = await DB("user_credential as u")
        .leftJoin("mst_cabang as c", "u.kode_cabang", "c.kode_cabang")
        .where("u.no_rm", cleanUser)
        .select(
          "u.id",
          "u.user_code",
          "u.username",
          "u.fullname",
          "u.telp",
          "u.role",
          "u.no_rm",
          "u.password",
          "u.status",
          "u.kode_cabang",
          "c.nama_cabang"
        )
        .first();
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

    // 4. Ambil info rekam medis pasien secara eksplisit dari user_credential.no_rm
    let noRm = user.no_rm || null;
    let fotoPasien = null;
    let detailPasien = null;

    if (noRm) {
      detailPasien = await DB("mst_pasien")
        .where("no_rm", noRm)
        .first();

      if (detailPasien) {
        fotoPasien = detailPasien.foto || null;
      } else {
        // Jika no_rm di user_credential tidak ditemukan di mst_pasien, reset ke null
        noRm = null;
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
        is_patient: Boolean(noRm),
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
 * Pendaftaran Akun Akses Pengguna Mobile (MURNI USER AUTH)
 * Tidak otomatis menerbitkan Rekam Medis (no_rm = null)
 */
router.post("/register", async (req, res) => {
  const body = req.body || {};

  // Normalisasi payload agar mendukung field 'nama'/'fullname', 'no_hp'/'telp', serta NIK/Tanggal Lahir
  const payloadToValidate = {
    fullname: (body.fullname || body.nama || "").trim(),
    telp: (body.telp || body.no_hp || "").trim(),
    email: (body.email || "").trim(),
    password: body.password,
    kode_cabang: body.kode_cabang || "CBG-001",
    nik: body.nik ? String(body.nik).trim() : null,
    tanggal_lahir: body.tanggal_lahir ? String(body.tanggal_lahir).trim() : null,
  };

  const schema = Joi.object({
    fullname: Joi.string().max(100).required().label("Nama Lengkap"),
    telp: Joi.string()
      .pattern(/^[0-9+]+$/)
      .min(10)
      .max(15)
      .required()
      .label("Nomor HP"),
    password: Joi.string().min(6).required().label("Password"),
    email: Joi.string().email().allow("", null).optional().label("Email"),
    kode_cabang: Joi.string().allow("", null).default("CBG-001").label("Cabang"),
    nik: Joi.string().pattern(/^[0-9]{16}$/).allow("", null).optional().label("NIK"),
    tanggal_lahir: Joi.string().pattern(/^\d{4}-\d{2}-\d{2}$/).allow("", null).optional().label("Tanggal Lahir"),
  });

  const { error, value } = schema.validate(payloadToValidate);
  if (error) {
    return sendError(res, error.details[0].message, 422, status.BAD_REQUEST);
  }

  const cleanPhone = value.telp.replace(/[\s-]/g, "");
  const branchCode = value.kode_cabang || "CBG-001";
  const userEmail = value.email && value.email.trim().length > 0 ? value.email.trim() : null;

  try {
    // 1. Cek apakah nomor HP sudah terdaftar di user_credential
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

    // 2. Cek apakah email sudah terdaftar di user_credential
    if (userEmail) {
      const existingEmail = await DB("user_credential")
        .where("username", userEmail)
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

    // 3. Generate User Code unik (USR000001 dst)
    const lastUser = await DB("user_credential")
      .where("user_code", "like", "USR%")
      .orderBy("user_code", "desc")
      .first();

    let nextUserSeq = 1;
    if (lastUser && lastUser.user_code) {
      const numPart = parseInt(lastUser.user_code.replace("USR", ""), 10);
      if (!isNaN(numPart)) nextUserSeq = numPart + 1;
    }
    const cUserCode = `USR${String(nextUserSeq).padStart(6, "0")}`;

    // 4. Strict Security: Registrasi Akun Mobile murni User Auth (no_rm = null).
    // Setiap penyambungan rekam medis lama WAJIB melalui proses verifikasi klaim eksplisit.
    const hashedPassword = hashClinicPassword(cUserCode, value.password);
    const userRecord = {
      user_code: cUserCode,
      username: userEmail || cleanPhone,
      fullname: value.fullname,
      telp: cleanPhone,
      role: "pasien",
      no_rm: null,
      password: hashedPassword,
      status: "1",
      kode_cabang: branchCode,
      tz: process.env.APP_TZ || "Asia/Jakarta",
      created_by: "mobile_register",
      created_at: formatDateSystem(),
    };

    await DB("user_credential").insert(userRecord);

    // Ambil nama cabang untuk info respons
    const actualBranch = userRecord.kode_cabang;
    const branchRow = await DB("mst_cabang").where("kode_cabang", actualBranch).first();
    const namaCabang = branchRow?.nama_cabang || "Klinik Utama";

    // 5. Generate Mobile JWT Token
    const tokenPayload = {
      user_code: cUserCode,
      username: userRecord.username,
      role: "pasien",
      fullname: value.fullname,
      nama: value.fullname,
      no_rm: null,
      kode_cabang: actualBranch,
      nama_cabang: namaCabang,
    };

    const tokens = await generateMobileTokens(tokenPayload, true);

    const message = "Akun berhasil didaftarkan! Selamat datang di aplikasi klinik.";

    return sendSuccess(
      res,
      message,
      {
        access_token: tokens.access_token,
        refresh_token: tokens.refresh_token,
        user_info: {
          user_code: cUserCode,
          username: userRecord.username,
          fullname: value.fullname,
          role: "pasien",
          telp: cleanPhone,
          no_rm: null,
          is_patient: false,
          foto: null,
          kode_cabang: actualBranch,
          nama_cabang: namaCabang,
          pasien_profile: null,
        },
      },
      201
    );
  } catch (error) {
    console.error("Register Mobile Error:", error);
    return sendError(
      res,
      process.env.APP_DEBUG === "true"
        ? `Error: ${error.message}`
        : "Terjadi kesalahan sistem saat proses registrasi",
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
    const cred = await DB("user_credential as u")
      .leftJoin("mst_cabang as c", "u.kode_cabang", "c.kode_cabang")
      .where("u.user_code", auth.user_code)
      .select("u.*", "c.nama_cabang")
      .first();

    if (!cred) {
      return sendError(res, "User tidak ditemukan", 404, status.NOT_FOUND);
    }

    let patientDetails = null;
    const noRm = cred.no_rm || null;
    if (noRm) {
      patientDetails = await DB("mst_pasien")
        .where("no_rm", noRm)
        .first();
    }

    return sendSuccess(res, "Profil berhasil dimuat", {
      user_code: cred.user_code,
      username: cred.username,
      fullname: cred.fullname,
      role: cred.role,
      telp: cred.telp,
      no_rm: noRm,
      is_patient: Boolean(noRm),
      kode_cabang: cred.kode_cabang || "CBG-001",
      nama_cabang: cred.nama_cabang || "Klinik Utama",
      foto: patientDetails?.foto || null,
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
