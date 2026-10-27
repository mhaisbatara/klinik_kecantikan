import express from "express";
import Joi from "joi";
import DB from "../../../core/config/knex.js";
import { sendSuccess, sendError } from "../../../utils/response.js";
import { status } from "../../../utils/general.js";
import { formatDateSystem } from "../../../utils/date_tools.js";
import {
  authenticateMobile,
  generateMobileTokens,
} from "../../../middleware/auth_middleware.js";
import { upload } from "../../../middleware/upload_middleware.js";
import {
  sendRealWhatsAppMessage,
  getWhatsAppStatus,
} from "../../../services/whatsapp_service.js";

const router = express.Router();

// ============================================================================
// RATE LIMITER & SECURITY HELPERS FOR PATIENT CLAIM
// ============================================================================
export const claimRateLimitStore = new Map();
const MAX_CLAIM_ATTEMPTS = 5;
const CLAIM_WINDOW_MS = 5 * 60 * 1000; // 5 menit
const GENERIC_VERIF_ERROR_MSG =
  "Data verifikasi tidak sesuai dengan catatan rekam medis klinik. Pastikan NIK (16 digit), Nomor HP, dan Tanggal Lahir sesuai dengan yang terdaftar di resepsionis.";
const RATE_LIMIT_ERROR_MSG =
  "Terlalu banyak percobaan verifikasi yang gagal. Demi keamanan data medis, silakan coba lagi dalam beberapa menit.";

export function normalizeIndonesianPhone(phone) {
  if (!phone) return "";
  let p = String(phone).replace(/[^0-9]/g, "");
  if (p.startsWith("62")) {
    p = "0" + p.slice(2);
  }
  return p;
}

export function normalizeDateOnly(val) {
  if (!val) return "";
  if (val instanceof Date) {
    const year = val.getFullYear();
    const month = String(val.getMonth() + 1).padStart(2, "0");
    const day = String(val.getDate()).padStart(2, "0");
    return `${year}-${month}-${day}`;
  }
  return String(val).trim().slice(0, 10);
}

export function checkClaimRateLimit(userCode) {
  const now = Date.now();
  const record = claimRateLimitStore.get(userCode);
  if (!record) return { allowed: true };

  if (record.lockUntil) {
    if (now < record.lockUntil) {
      return { allowed: false, message: RATE_LIMIT_ERROR_MSG };
    } else {
      claimRateLimitStore.delete(userCode);
      return { allowed: true };
    }
  }

  if (now - record.firstAttemptAt > CLAIM_WINDOW_MS) {
    claimRateLimitStore.delete(userCode);
    return { allowed: true };
  }

  if (record.attempts >= MAX_CLAIM_ATTEMPTS) {
    return { allowed: false, message: RATE_LIMIT_ERROR_MSG };
  }

  return { allowed: true };
}

export function recordClaimFailure(userCode) {
  const now = Date.now();
  let record = claimRateLimitStore.get(userCode);

  if (!record || now - record.firstAttemptAt > CLAIM_WINDOW_MS) {
    record = { attempts: 1, firstAttemptAt: now, lockUntil: null };
  } else {
    record.attempts += 1;
  }

  if (record.attempts >= MAX_CLAIM_ATTEMPTS) {
    record.lockUntil = now + CLAIM_WINDOW_MS;
  }

  claimRateLimitStore.set(userCode, record);
  return record;
}

export function resetClaimRateLimit(userCode) {
  claimRateLimitStore.delete(userCode);
}

// ============================================================================
// OTP STORE & WHATSAPP GATEWAY (FONNTE / SIMULASI) UNTUK SINKRONISASI NO RM
// ============================================================================
export const claimOtpStore = new Map();
const OTP_EXPIRY_MS = 5 * 60 * 1000; // 5 menit
const MAX_OTP_FAILED_ATTEMPTS = 3;

export function maskPhoneNumber(phone) {
  if (!phone) return "";
  const cleaned = String(phone).replace(/[\s-]/g, "");
  if (cleaned.length <= 6) return cleaned;
  const prefix = cleaned.slice(0, 4);
  const suffix = cleaned.slice(-4);
  const maskLen = cleaned.length - 8 > 0 ? cleaned.length - 8 : 4;
  return `${prefix}${"*".repeat(maskLen)}${suffix}`;
}

export async function sendWhatsAppOtp(targetPhone, otpCode) {
  // Ambil data konfigurasi nomor klinik resmi yang diatur Super Admin di database
  let clinicName = "Klinik Kecantikan";
  let clinicWa = "";
  let clinicPhone = "";
  let footerNote = "Berlaku selama 5 menit. Jangan berikan kode ini kepada siapa pun demi keamanan data rekam medis Anda.";

  try {
    const configs = await DB("config")
      .whereIn("kode", ["msNamaPerusahaan", "msWaKlinik", "msTeleponPerusahaan", "msCatatanOtp"])
      .select("kode", "keterangan");
    const cfgMap = {};
    configs.forEach((c) => {
      cfgMap[c.kode] = c.keterangan;
    });
    if (cfgMap.msNamaPerusahaan) clinicName = cfgMap.msNamaPerusahaan;
    if (cfgMap.msWaKlinik) clinicWa = cfgMap.msWaKlinik;
    if (cfgMap.msTeleponPerusahaan) clinicPhone = cfgMap.msTeleponPerusahaan;
    if (cfgMap.msCatatanOtp) footerNote = cfgMap.msCatatanOtp;
  } catch (err) {
    console.error("Gagal membaca config klinik untuk OTP:", err.message);
  }

  const senderInfo = clinicWa ? `\nNomor Resmi WhatsApp Klinik: *${clinicWa}*` : "";
  const hotlineInfo = clinicPhone ? `\nHotline Layanan: ${clinicPhone}` : "";
  const message = `*[${clinicName}]*\nKode OTP Verifikasi Rekam Medis Anda adalah: *${otpCode}*.${senderInfo}${hotlineInfo}\n\n${footerNote}`;

  // 1. Prioritas Utama: Bot WhatsApp Self-Hosted Baileys (100% Gratis Tanpa Langganan)
  const wa = getWhatsAppStatus();
  if (wa.isConnected) {
    const realSendRes = await sendRealWhatsAppMessage(targetPhone, message);
    if (realSendRes.success) {
      return { success: true, via: "self_hosted_whatsapp", result: realSendRes };
    }
  }

  // 2. Prioritas Kedua: Fonnte API (Jika diisi token di .env)
  const token = process.env.FONNTE_TOKEN ? process.env.FONNTE_TOKEN.trim() : "";
  if (token) {
    try {
      const response = await fetch("https://api.fonnte.com/send", {
        method: "POST",
        headers: {
          Authorization: token,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          target: targetPhone,
          message: message,
        }),
      });
      const data = await response.json();
      console.log(`[Fonnte WhatsApp API] Sent to ${targetPhone}, result:`, data);
      return { success: true, via: "fonnte", data };
    } catch (err) {
      console.error("[Fonnte WhatsApp API Error]:", err.message);
    }
  }

  // 3. Fallback: Mode Simulasi Lokal (Gratis & Cepat untuk Dev / Testing)
  console.log("\n=======================================================");
  console.log(`📲 [SIMULASI WHATSAPP OTP - MODE PENGEMBANGAN LOKAL]`);
  console.log(`🎯 Nomor HP Terdaftar: ${targetPhone} (${maskPhoneNumber(targetPhone)})`);
  console.log(`🔑 KODE OTP 6 DIGIT  : ${otpCode}`);
  console.log(`⏳ Masa Berlaku       : 5 Menit (300 Detik)`);
  console.log(`💡 Hubungkan Bot WhatsApp Gratis di: http://localhost:8008/whatsapp-qr`);
  console.log("=======================================================\n");
  return { success: true, via: "simulation" };
}

/**
 * GET /api/v1/profile
 * Profil Lengkap Pengguna / Pasien
 */
router.get("/", authenticateMobile, async (req, res) => {
  const user = req.auth;

  try {
    const cred = await DB("user_credential as u")
      .leftJoin("mst_cabang as c", "u.kode_cabang", "c.kode_cabang")
      .where("u.user_code", user.user_code)
      .select(
        "u.id",
        "u.user_code",
        "u.username",
        "u.fullname",
        "u.telp",
        "u.role",
        "u.no_rm",
        "u.kode_cabang",
        "c.nama_cabang"
      )
      .first();

    if (!cred) {
      return sendError(res, "Data pengguna tidak ditemukan", 404, status.NOT_FOUND);
    }

    let pasien = null;
    if (cred.no_rm) {
      pasien = await DB("mst_pasien").where("no_rm", cred.no_rm).first();
    }

    return sendSuccess(res, "Profil pengguna berhasil dimuat", {
      user: {
        id: cred.id,
        user_code: cred.user_code,
        username: cred.username,
        fullname: cred.fullname,
        telp: cred.telp,
        role: cred.role,
        no_rm: cred.no_rm || null,
        is_patient: Boolean(cred.no_rm),
        kode_cabang: cred.kode_cabang || "CBG-001",
        nama_cabang: cred.nama_cabang || "Klinik Utama",
        foto: pasien?.foto || null,
      },
      pasien: pasien || null,
    });
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * POST /api/v1/profile/register-patient
 * Opsi A: Pendaftaran Pasien Baru Mandiri dari Akun Mobile
 */
router.post("/register-patient", authenticateMobile, async (req, res) => {
  const user = req.auth;
  const body = req.body || {};

  try {
    // 1. Cek status akun user_credential saat ini
    const cred = await DB("user_credential as u")
      .leftJoin("mst_cabang as c", "u.kode_cabang", "c.kode_cabang")
      .where("u.user_code", user.user_code)
      .select("u.*", "c.nama_cabang")
      .first();

    if (!cred) {
      return sendError(res, "Akun pengguna tidak ditemukan", 404, status.NOT_FOUND);
    }

    if (cred.no_rm) {
      return sendError(
        res,
        `Akun Anda sudah terhubung dengan Rekam Medis (${cred.no_rm}). Tidak perlu mendaftar pasien baru.`,
        400,
        status.BAD_REQUEST
      );
    }

    // 2. Validasi input formulir pasien baru (mengikuti web form lengkap)
    const schema = Joi.object({
      nama: Joi.string().trim().min(2).max(100).required().label("Nama Lengkap"),
      nik: Joi.string()
        .pattern(/^[0-9]{16}$/)
        .required()
        .messages({
          "string.pattern.base": "NIK harus berisi tepat 16 digit angka",
          "any.required": "NIK wajib diisi",
        }),
      tempat_lahir: Joi.string().trim().allow("", null).max(100).optional().label("Tempat Lahir"),
      tanggal_lahir: Joi.string()
        .pattern(/^\d{4}-\d{2}-\d{2}$/)
        .required()
        .messages({
          "string.pattern.base": "Format tanggal lahir harus YYYY-MM-DD",
          "any.required": "Tanggal lahir wajib diisi",
        }),
      jenis_kelamin: Joi.string().valid("L", "P").required().label("Jenis Kelamin"),
      golongan_darah: Joi.string().allow("", null, "-", "A", "B", "AB", "O").optional().label("Golongan Darah"),
      agama: Joi.string().allow("", null).max(50).optional().label("Agama"),
      status_perkawinan: Joi.string().allow("", null, "belum_menikah", "menikah", "cerai_hidup", "cerai_mati").optional().label("Status Perkawinan"),
      kewarganegaraan: Joi.string().allow("", null, "WNI", "WNA").optional().label("Kewarganegaraan"),
      pekerjaan: Joi.string().allow("", null).max(100).optional().label("Pekerjaan"),

      // Alamat
      provinsi: Joi.string().trim().min(2).max(100).required().label("Provinsi"),
      kota_kabupaten: Joi.string().trim().allow("", null).max(100).optional().label("Kota/Kabupaten"),
      kecamatan: Joi.string().trim().allow("", null).max(100).optional().label("Kecamatan"),
      kelurahan_desa: Joi.string().trim().allow("", null).max(100).optional().label("Kelurahan/Desa"),
      kode_pos: Joi.string().trim().allow("", null).max(20).optional().label("Kode Pos"),
      patokan: Joi.string().trim().allow("", null).max(255).optional().label("Patokan/Alamat Detail"),
      alamat: Joi.string().trim().allow("", null).max(255).optional().label("Alamat"),

      // Kontak & Darurat
      no_hp: Joi.string().pattern(/^[0-9+]+$/).min(10).max(15).required().label("Nomor HP (WhatsApp)"),
      email: Joi.string().email().allow("", null).optional().label("Email"),
      nama_kontak_darurat: Joi.string().trim().allow("", null).max(100).optional().label("Nama Kontak Darurat"),
      no_hp_kontak_darurat: Joi.string().trim().allow("", null).max(20).optional().label("No. HP Kontak Darurat"),
      hubungan_kontak_darurat: Joi.string().trim().allow("", null).max(50).optional().label("Hubungan Kontak Darurat"),

      // Alergi
      alergi: Joi.string().trim().allow("", null).optional().label("Riwayat Alergi"),
    });

    const { error, value } = schema.validate(body);
    if (error) {
      return sendError(res, error.details[0].message, 422, status.BAD_REQUEST);
    }

    // 3. Cek keunikan NIK di mst_pasien
    const existingNik = await DB("mst_pasien").where("nik", value.nik).first();
    if (existingNik) {
      return sendError(
        res,
        `NIK ${value.nik} sudah terdaftar pada Rekam Medis ${existingNik.no_rm}. Silakan gunakan opsi 'Sinkronisasi Pasien Lama'.`,
        400,
        status.GAGAL
      );
    }

    const cleanNama = (value.nama || cred.fullname || "Pasien").trim();
    const cleanPhone = (value.no_hp || cred.telp || "").replace(/[\s-]/g, "");
    const branchCode = cred.kode_cabang || "CBG-001";
    const namaCabang = cred.nama_cabang || "Klinik Utama";
    const fullAlamat = (value.patokan || value.alamat || "").trim();

    // 4. Transaksi DB: generate RM, insert mst_pasien, update user_credential
    let cNoRm = "";
    await DB.transaction(async (trx) => {
      const lastPasien = await trx("mst_pasien")
        .where("no_rm", "like", "RM-%")
        .whereNot("no_rm", "RM-000000")
        .orderBy("id", "desc")
        .first();

      let nextRmSeq = 1;
      if (lastPasien && lastPasien.no_rm) {
        const parts = lastPasien.no_rm.split("-");
        const num = parseInt(parts[1], 10);
        if (!isNaN(num)) nextRmSeq = num + 1;
      }
      cNoRm = `RM-${String(nextRmSeq).padStart(6, "0")}`;
      while (await trx("mst_pasien").where("no_rm", cNoRm).first()) {
        nextRmSeq++;
        cNoRm = `RM-${String(nextRmSeq).padStart(6, "0")}`;
      }

      await trx("mst_pasien").insert({
        kode_cabang: branchCode,
        no_rm: cNoRm,
        nama: cleanNama,
        nik: value.nik,
        tempat_lahir: value.tempat_lahir ? value.tempat_lahir.trim() : null,
        tanggal_lahir: value.tanggal_lahir,
        jenis_kelamin: value.jenis_kelamin,
        golongan_darah: value.golongan_darah || null,
        agama: value.agama || "Islam",
        status_perkawinan: value.status_perkawinan || "belum_menikah",
        kewarganegaraan: value.kewarganegaraan || "WNI",
        pekerjaan: value.pekerjaan ? value.pekerjaan.trim() : null,
        provinsi: value.provinsi ? value.provinsi.trim() : null,
        kota_kabupaten: value.kota_kabupaten ? value.kota_kabupaten.trim() : null,
        kecamatan: value.kecamatan ? value.kecamatan.trim() : null,
        kelurahan_desa: value.kelurahan_desa ? value.kelurahan_desa.trim() : null,
        kode_pos: value.kode_pos ? value.kode_pos.trim() : null,
        patokan: fullAlamat || null,
        no_hp: cleanPhone,
        email: value.email || (cred.username && cred.username.includes("@") ? cred.username : null),
        nama_kontak_darurat: value.nama_kontak_darurat ? value.nama_kontak_darurat.trim() : null,
        no_hp_kontak_darurat: value.no_hp_kontak_darurat ? value.no_hp_kontak_darurat.trim() : null,
        hubungan_kontak_darurat: value.hubungan_kontak_darurat ? value.hubungan_kontak_darurat.trim() : null,
        alergi: value.alergi ? value.alergi.trim() : null,
        status: "aktif",
        tz: process.env.APP_TZ || "Asia/Jakarta",
        created_by: cred.user_code,
        created_at: formatDateSystem(),
      });

      await trx("user_credential")
        .where("user_code", cred.user_code)
        .update({
          no_rm: cNoRm,
          fullname: cleanNama,
          telp: cleanPhone || cred.telp,
          updated_at: formatDateSystem(),
        });
    });

    // 5. Ambil profil pasien yang baru dibuat
    const newPasien = await DB("mst_pasien").where("no_rm", cNoRm).first();

    // 6. Generate Token Baru yang sudah memuat no_rm
    const tokenPayload = {
      user_code: cred.user_code,
      username: cred.username,
      role: cred.role || "pasien",
      fullname: cleanNama,
      nama: cleanNama,
      no_rm: cNoRm,
      kode_cabang: branchCode,
      nama_cabang: namaCabang,
    };

    const tokens = await generateMobileTokens(tokenPayload, true);

    return sendSuccess(
      res,
      "Pendaftaran pasien baru berhasil! Rekam Medis Anda telah terbit.",
      {
        access_token: tokens.access_token,
        refresh_token: tokens.refresh_token,
        user_info: {
          user_code: cred.user_code,
          username: cred.username,
          fullname: cleanNama,
          role: cred.role || "pasien",
          telp: cleanPhone,
          no_rm: cNoRm,
          is_patient: true,
          foto: null,
          kode_cabang: branchCode,
          nama_cabang: namaCabang,
          pasien_profile: newPasien,
        },
      }
    );
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * Helper: Mencocokkan data pasien di mst_pasien dengan data verifikasi input
 */
export async function matchPatientCandidate(cred, body) {
  let cleanNoRm = body.no_rm ? String(body.no_rm).trim().toUpperCase() : "";
  if (cleanNoRm && !cleanNoRm.startsWith("RM-")) {
    const numOnly = cleanNoRm.replace(/[^0-9]/g, "");
    if (numOnly.length > 0) {
      cleanNoRm = `RM-${numOnly.padStart(6, "0")}`;
    }
  }

  const cleanInputNik = body.nik ? String(body.nik).replace(/[^0-9]/g, "") : "";
  const rawPhone = body.no_hp || cred.telp || "";
  const cleanInputPhone = normalizeIndonesianPhone(rawPhone);
  const inputDob = body.tanggal_lahir ? String(body.tanggal_lahir).trim().slice(0, 10) : "";

  const hasValidNik = cleanInputNik.length === 16;
  const hasNoRm = Boolean(cleanNoRm && cleanNoRm.startsWith("RM-"));
  const hasDob = Boolean(inputDob && /^\d{4}-\d{2}-\d{2}$/.test(inputDob));
  const hasPhone = Boolean(cleanInputPhone && cleanInputPhone.length >= 8);

  console.log(`\n🔍 [Check / Match Candidate Patient] User: ${cred.user_code}`);
  console.log(`   Input -> NIK: "${cleanInputNik}", NoRM: "${cleanNoRm}", DOB: "${inputDob}", Phone: "${cleanInputPhone}"`);

  if (!hasDob || !hasPhone || (!hasValidNik && !hasNoRm)) {
    return { error: "Format input tidak lengkap (wajib Tanggal Lahir, Nomor HP, serta NIK 16 digit atau Nomor RM)." };
  }

  let candidate = null;

  if (hasValidNik) {
    let q = DB("mst_pasien").where("nik", cleanInputNik);
    if (hasNoRm) {
      q = q.where("no_rm", cleanNoRm);
    }
    const rows = await q.select("*");

    for (const r of rows) {
      const dbDob = normalizeDateOnly(r.tanggal_lahir);
      const dbPhone = normalizeIndonesianPhone(r.no_hp);

      if (dbDob === inputDob && dbPhone === cleanInputPhone) {
        candidate = r;
        break;
      }
    }
  } else if (hasNoRm) {
    const r = await DB("mst_pasien").where("no_rm", cleanNoRm).first();
    if (r) {
      const dbDob = normalizeDateOnly(r.tanggal_lahir);
      const dbPhone = normalizeIndonesianPhone(r.no_hp);

      if (dbDob === inputDob && dbPhone === cleanInputPhone) {
        if (cleanInputNik && r.nik && cleanInputNik !== r.nik) {
          candidate = null;
        } else {
          candidate = r;
        }
      }
    }
  }

  if (!candidate) {
    return { notFound: true };
  }

  // Anti-Hijacking Check
  const existingClaim = await DB("user_credential")
    .where("no_rm", candidate.no_rm)
    .whereNot("user_code", cred.user_code)
    .first();

  if (existingClaim) {
    return {
      hijacked: true,
      message: `Nomor Rekam Medis ini (${candidate.no_rm}) sudah terhubung dengan akun lain. Hubungi resepsionis klinik jika ini adalah milik Anda.`,
    };
  }

  return {
    candidate,
    cleanNoRm,
    cleanInputNik,
    cleanInputPhone,
    rawPhone,
    inputDob,
  };
}

/**
 * POST /api/v1/profile/check-claim-patient
 * Langkah Pra-Verifikasi Sinkronisasi Rekam Medis:
 * Mengidentifikasi dan menampilkan data pasien (Nama, No RM, DOB, Jenis Kelamin, Kota, dsb)
 * untuk divalidasi oleh pasien sebelum kode OTP WhatsApp dikirimkan.
 */
router.post("/check-claim-patient", authenticateMobile, async (req, res) => {
  const user = req.auth;
  const body = req.body || {};

  try {
    const cred = await DB("user_credential as u")
      .leftJoin("mst_cabang as c", "u.kode_cabang", "c.kode_cabang")
      .where("u.user_code", user.user_code)
      .select("u.*", "c.nama_cabang")
      .first();

    if (!cred) {
      return sendError(res, "Akun pengguna tidak ditemukan", 404, status.NOT_FOUND);
    }

    if (cred.no_rm) {
      return sendError(
        res,
        `Akun Anda sudah terhubung dengan Rekam Medis (${cred.no_rm}). Tidak dapat menautkan kembali.`,
        400,
        status.BAD_REQUEST
      );
    }

    const rateCheck = checkClaimRateLimit(cred.user_code);
    if (!rateCheck.allowed) {
      return sendError(res, rateCheck.message, 429, status.GAGAL);
    }

    const result = await matchPatientCandidate(cred, body);
    if (result.error) {
      return sendError(res, result.error, 422, status.GAGAL);
    }
    if (result.notFound) {
      const rec = recordClaimFailure(cred.user_code);
      if (rec.attempts >= MAX_CLAIM_ATTEMPTS) {
        return sendError(res, RATE_LIMIT_ERROR_MSG, 429, status.GAGAL);
      }
      return sendError(res, GENERIC_VERIF_ERROR_MSG, 422, status.GAGAL);
    }
    if (result.hijacked) {
      return sendError(res, result.message, 409, status.GAGAL);
    }

    const { candidate, rawPhone } = result;
    const maskedPhone = maskPhoneNumber(candidate.no_hp || rawPhone);
    const maskedNik = candidate.nik ? `${candidate.nik.slice(0, 4)}********${candidate.nik.slice(-4)}` : null;

    let jenisKelaminLabel = "Laki-laki";
    if (candidate.jenis_kelamin === "P" || candidate.jenis_kelamin === "Perempuan") {
      jenisKelaminLabel = "Perempuan";
    }

    return sendSuccess(res, "Data rekam medis berhasil ditemukan", {
      no_rm: candidate.no_rm,
      nama: candidate.nama || candidate.nama_lengkap || "Pasien",
      nik: maskedNik,
      nik_raw: candidate.nik,
      tanggal_lahir: candidate.tanggal_lahir,
      tempat_lahir: candidate.tempat_lahir,
      jenis_kelamin: jenisKelaminLabel,
      kota_kabupaten: candidate.kota_kabupaten,
      provinsi: candidate.provinsi,
      masked_phone: maskedPhone,
      target_phone: candidate.no_hp || rawPhone,
    });
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * POST /api/v1/profile/request-claim-otp
 * Langkah 1 Sinkronisasi Rekam Medis:
 * Verifikasi Identitas Ketat (NIK 16 digit + Tanggal Lahir + No. HP Terdaftar).
 * Jika cocok, generate & kirim 6-digit OTP ke Nomor HP / WhatsApp pasien.
 */
router.post("/request-claim-otp", authenticateMobile, async (req, res) => {
  const user = req.auth;
  const body = req.body || {};

  try {
    // 1. Cek status akun user_credential saat ini
    const cred = await DB("user_credential as u")
      .leftJoin("mst_cabang as c", "u.kode_cabang", "c.kode_cabang")
      .where("u.user_code", user.user_code)
      .select("u.*", "c.nama_cabang")
      .first();

    if (!cred) {
      return sendError(res, "Akun pengguna tidak ditemukan", 404, status.NOT_FOUND);
    }

    if (cred.no_rm) {
      return sendError(
        res,
        `Akun Anda sudah terhubung dengan Rekam Medis (${cred.no_rm}). Tidak dapat menautkan kembali.`,
        400,
        status.BAD_REQUEST
      );
    }

    // 2. Cek Rate Limiting Anti Brute-Force (Maks 3 kali gagal dalam 15 menit)
    const rateCheck = checkClaimRateLimit(cred.user_code);
    if (!rateCheck.allowed) {
      return sendError(res, rateCheck.message, 429, status.GAGAL);
    }

    const result = await matchPatientCandidate(cred, body);
    if (result.error) {
      return sendError(res, result.error, 422, status.GAGAL);
    }
    if (result.notFound) {
      console.log("❌ [Request Claim OTP Gagal] Data tidak cocok dengan catatan mst_pasien.");
      const rec = recordClaimFailure(cred.user_code);
      if (rec.attempts >= MAX_CLAIM_ATTEMPTS) {
        return sendError(res, RATE_LIMIT_ERROR_MSG, 429, status.GAGAL);
      }
      return sendError(res, GENERIC_VERIF_ERROR_MSG, 422, status.GAGAL);
    }
    if (result.hijacked) {
      return sendError(res, result.message, 409, status.GAGAL);
    }

    const { candidate, cleanInputNik, rawPhone } = result;
    console.log(`✅ [Request Claim OTP Match!] Ditemukan pasien: ${candidate.no_rm} - ${candidate.nama || candidate.nama_lengkap || 'Pasien'}`);

    // 6. Generate 6-Digit Numeric OTP Code & Simpan di Memory Store (5 Menit)
    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = Date.now() + OTP_EXPIRY_MS;

    claimOtpStore.set(cred.user_code, {
      otp_code: otpCode,
      no_rm: candidate.no_rm,
      nik: cleanInputNik || candidate.nik || "",
      phone: candidate.no_hp || rawPhone,
      expires_at: expiresAt,
      failed_attempts: 0,
    });

    // 7. Kirim Kode OTP via WhatsApp (Self-Hosted Bot / Fonnte / Simulasi)
    const targetPhone = candidate.no_hp || rawPhone;
    const waResult = await sendWhatsAppOtp(targetPhone, otpCode);
    const maskedPhone = maskPhoneNumber(targetPhone);
    const isRealSent = waResult.via === "self_hosted_whatsapp" || waResult.via === "fonnte";

    return sendSuccess(
      res,
      isRealSent
        ? `Kode OTP verifikasi berhasil dikirimkan ke nomor WhatsApp Anda (${maskedPhone}).`
        : `Kode OTP verifikasi berhasil dibuat untuk nomor (${maskedPhone}).`,
      {
        masked_phone: maskedPhone,
        expires_in: 300,
        whatsapp_sent: isRealSent,
        dev_otp_code: isRealSent ? null : otpCode,
      }
    );
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * POST /api/v1/profile/verify-claim-otp
 * Langkah 2 Sinkronisasi Rekam Medis:
 * Verifikasi 6-Digit Kode OTP dari Nomor HP / WhatsApp Pasien.
 * Jika cocok, tautkan no_rm ke user_credential & kembalikan token JWT baru.
 */
router.post("/verify-claim-otp", authenticateMobile, async (req, res) => {
  const user = req.auth;
  const { otp_code } = req.body || {};

  try {
    const cred = await DB("user_credential as u")
      .leftJoin("mst_cabang as c", "u.kode_cabang", "c.kode_cabang")
      .where("u.user_code", user.user_code)
      .select("u.*", "c.nama_cabang")
      .first();

    if (!cred) {
      return sendError(res, "Akun pengguna tidak ditemukan", 404, status.NOT_FOUND);
    }

    if (cred.no_rm) {
      return sendError(
        res,
        `Akun Anda sudah terhubung dengan Rekam Medis (${cred.no_rm}).`,
        400,
        status.BAD_REQUEST
      );
    }

    const cleanInputOtp = otp_code ? String(otp_code).replace(/[^0-9]/g, "").trim() : "";
    if (!cleanInputOtp || cleanInputOtp.length !== 6) {
      return sendError(res, "Kode OTP harus berisi 6 digit angka", 422, status.BAD_REQUEST);
    }

    const session = claimOtpStore.get(cred.user_code);
    if (!session) {
      return sendError(
        res,
        "Sesi OTP tidak ditemukan atau sudah kedaluwarsa. Silakan minta kode OTP baru.",
        400,
        status.BAD_REQUEST
      );
    }

    if (Date.now() > session.expires_at) {
      claimOtpStore.delete(cred.user_code);
      return sendError(
        res,
        "Kode OTP telah kedaluwarsa (lebih dari 5 menit). Silakan minta kode OTP baru.",
        400,
        status.BAD_REQUEST
      );
    }

    // Validasi kecocokan kode OTP
    if (session.otp_code !== cleanInputOtp) {
      session.failed_attempts = (session.failed_attempts || 0) + 1;

      if (session.failed_attempts >= MAX_OTP_FAILED_ATTEMPTS) {
        claimOtpStore.delete(cred.user_code);
        return sendError(
          res,
          "Kode OTP salah sebanyak 3 kali. Kode telah hangus demi keamanan. Silakan minta kode OTP baru.",
          422,
          status.GAGAL
        );
      }

      const sisa = MAX_OTP_FAILED_ATTEMPTS - session.failed_attempts;
      return sendError(
        res,
        `Kode OTP tidak sesuai. Sisa kesempatan mencoba: ${sisa} kali.`,
        422,
        status.GAGAL
      );
    }

    // -----------------------------------------------------------------
    // KODE OTP VALID! Tautkan no_rm ke user_credential
    // -----------------------------------------------------------------
    claimOtpStore.delete(cred.user_code);
    resetClaimRateLimit(cred.user_code);

    const noRm = session.no_rm;
    const candidate = await DB("mst_pasien").where("no_rm", noRm).first();

    if (!candidate) {
      return sendError(res, "Data rekam medis pasien tidak ditemukan di database klinik", 404, status.NOT_FOUND);
    }

    // Double check anti-hijacking
    const existingClaim = await DB("user_credential")
      .where("no_rm", noRm)
      .whereNot("user_code", cred.user_code)
      .first();

    if (existingClaim) {
      return sendError(
        res,
        `Nomor Rekam Medis ini (${noRm}) sudah terhubung dengan akun lain. Hubungi resepsionis klinik jika ini adalah milik Anda.`,
        409,
        status.GAGAL
      );
    }

    const branchCode = candidate.kode_cabang || cred.kode_cabang || "CBG-001";
    const namaCabang = cred.nama_cabang || "Klinik Utama";

    await DB("user_credential")
      .where("user_code", cred.user_code)
      .update({
        no_rm: noRm,
        fullname: cred.fullname || candidate.nama,
        telp: cred.telp || candidate.no_hp,
        kode_cabang: branchCode,
        updated_at: formatDateSystem(),
      });

    // Lengkapi NIK di mst_pasien jika di klinik masih kosong
    if (!candidate.nik && session.nik && session.nik.length === 16) {
      await DB("mst_pasien")
        .where("no_rm", noRm)
        .update({ nik: session.nik, updated_at: formatDateSystem() });
      candidate.nik = session.nik;
    }

    // Generate JWT token baru yang sudah memuat no_rm
    const tokenPayload = {
      user_code: cred.user_code,
      username: cred.username,
      role: cred.role || "pasien",
      fullname: cred.fullname || candidate.nama,
      nama: cred.fullname || candidate.nama,
      no_rm: noRm,
      kode_cabang: branchCode,
      nama_cabang: namaCabang,
    };

    const tokens = await generateMobileTokens(tokenPayload, true);

    return sendSuccess(
      res,
      `Verifikasi OTP berhasil! Rekam Medis Anda (${noRm}) telah sukses terhubung.`,
      {
        access_token: tokens.access_token,
        refresh_token: tokens.refresh_token,
        user_info: {
          user_code: cred.user_code,
          username: cred.username,
          fullname: cred.fullname || candidate.nama,
          role: cred.role || "pasien",
          telp: cred.telp || candidate.no_hp,
          no_rm: noRm,
          is_patient: true,
          foto: candidate.foto || null,
          kode_cabang: branchCode,
          nama_cabang: namaCabang,
          pasien_profile: candidate,
        },
      }
    );
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * POST /api/v1/profile/reset-claim-rate-limit
 * Reset status rate limiter claim/verifikasi untuk akun saat ini (Development / Admin Tool)
 */
router.post("/reset-claim-rate-limit", authenticateMobile, (req, res) => {
  const user = req.auth;
  resetClaimRateLimit(user.user_code);
  console.log(`[Rate Limit Reset] Kunci rate limit dibuka untuk ${user.user_code}`);
  return sendSuccess(res, "Kunci rate limit verifikasi berhasil di-reset. Anda dapat mencoba kembali sekarang.", {
    user_code: user.user_code,
  });
});

/**
 * POST /api/v1/profile/unlink-patient
 * Melepaskan tautan rekam medis dari akun user saat ini
 */
router.post("/unlink-patient", authenticateMobile, async (req, res) => {
  const user = req.auth;
  try {
    await DB("user_credential")
      .where("user_code", user.user_code)
      .update({
        no_rm: null,
        updated_at: formatDateSystem(),
      });

    resetClaimRateLimit(user.user_code);

    const cred = await DB("user_credential as u")
      .leftJoin("mst_cabang as c", "u.kode_cabang", "c.kode_cabang")
      .where("u.user_code", user.user_code)
      .select("u.*", "c.nama_cabang")
      .first();

    const branchCode = cred?.kode_cabang || "CBG-001";
    const namaCabang = cred?.nama_cabang || "Klinik Utama";

    const tokenPayload = {
      user_code: cred.user_code,
      username: cred.username,
      role: cred.role || "pasien",
      fullname: cred.fullname,
      nama: cred.fullname,
      no_rm: null,
      kode_cabang: branchCode,
      nama_cabang: namaCabang,
    };

    const tokens = await generateMobileTokens(tokenPayload, true);

    return sendSuccess(res, "Tautan Rekam Medis berhasil dilepaskan dari akun Anda.", {
      access_token: tokens.access_token,
      refresh_token: tokens.refresh_token,
      user_info: {
        user_code: cred.user_code,
        username: cred.username,
        fullname: cred.fullname,
        role: cred.role || "pasien",
        telp: cred.telp,
        no_rm: null,
        is_patient: false,
        foto: null,
        kode_cabang: branchCode,
        nama_cabang: namaCabang,
        pasien_profile: null,
      },
    });
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});


/**
 * POST /api/v1/profile/claim-patient
 * Opsi B: Klaim / Sinkronisasi Pasien Lama (Direct Strict Matching)
 * Wajib NIK KTP (16 Digit) + Nomor HP Terdaftar + Tanggal Lahir (AND Condition).
 * Atau No. RM + Nomor HP + Tanggal Lahir (jika data klinik tanpa NIK / pasien tahu No. RM).
 */
router.post("/claim-patient", authenticateMobile, async (req, res) => {
  const user = req.auth;
  const body = req.body || {};

  try {
    // 1. Cek status akun user_credential saat ini
    const cred = await DB("user_credential as u")
      .leftJoin("mst_cabang as c", "u.kode_cabang", "c.kode_cabang")
      .where("u.user_code", user.user_code)
      .select("u.*", "c.nama_cabang")
      .first();

    if (!cred) {
      return sendError(res, "Akun pengguna tidak ditemukan", 404, status.NOT_FOUND);
    }

    if (cred.no_rm) {
      return sendError(
        res,
        `Akun Anda sudah terhubung dengan Rekam Medis (${cred.no_rm}). Tidak dapat menautkan kembali.`,
        400,
        status.BAD_REQUEST
      );
    }

    // 2. Cek Rate Limiting Anti Brute-Force (Maks 3 kali gagal dalam 15 menit)
    const rateCheck = checkClaimRateLimit(cred.user_code);
    if (!rateCheck.allowed) {
      return sendError(res, rateCheck.message, 429, status.GAGAL);
    }

    // 3. Normalisasi & Validasi Input
    let cleanNoRm = body.no_rm ? String(body.no_rm).trim().toUpperCase() : "";
    if (cleanNoRm && !cleanNoRm.startsWith("RM-")) {
      const numOnly = cleanNoRm.replace(/[^0-9]/g, "");
      if (numOnly.length > 0) {
        cleanNoRm = `RM-${numOnly.padStart(6, "0")}`;
      }
    }

    const cleanInputNik = body.nik ? String(body.nik).replace(/[^0-9]/g, "") : "";
    const rawPhone = body.no_hp || cred.telp || "";
    const cleanInputPhone = normalizeIndonesianPhone(rawPhone);
    const inputDob = body.tanggal_lahir ? String(body.tanggal_lahir).trim().slice(0, 10) : "";

    const hasValidNik = cleanInputNik.length === 16;
    const hasNoRm = Boolean(cleanNoRm && cleanNoRm.startsWith("RM-"));
    const hasDob = Boolean(inputDob && /^\d{4}-\d{2}-\d{2}$/.test(inputDob));
    const hasPhone = Boolean(cleanInputPhone && cleanInputPhone.length >= 8);

    // Strict Multi-Factor Check:
    // Wajib memiliki Tanggal Lahir, Nomor HP terdaftar, serta minimal NIK 16 digit ATAU No. RM.
    // Dilarang keras klaim tanpa NIK dan tanpa No. RM sekaligus!
    if (!hasDob || !hasPhone || (!hasValidNik && !hasNoRm)) {
      const rec = recordClaimFailure(cred.user_code);
      if (rec.attempts >= MAX_CLAIM_ATTEMPTS) {
        return sendError(res, RATE_LIMIT_ERROR_MSG, 429, status.GAGAL);
      }
      return sendError(res, GENERIC_VERIF_ERROR_MSG, 422, status.GAGAL);
    }

    // 4. Strict Multi-Factor Identity Match against mst_pasien
    let candidate = null;

    if (hasValidNik) {
      // Faktor Utama: NIK (16 Digit Eksak) + No. HP Terdaftar + Tanggal Lahir (AND Condition)
      let q = DB("mst_pasien").where("nik", cleanInputNik);
      if (hasNoRm) {
        q = q.where("no_rm", cleanNoRm);
      }
      const rows = await q.select("*");

      for (const r of rows) {
        const dbDob = normalizeDateOnly(r.tanggal_lahir);
        const dbPhone = normalizeIndonesianPhone(r.no_hp);

        if (dbDob === inputDob && dbPhone === cleanInputPhone) {
          candidate = r;
          break;
        }
      }
    } else if (hasNoRm) {
      // Alternatif: Pasien memasukkan No. RM (misal di database klinik NIK kosong/belum ada)
      // Wajib No. RM + No. HP Terdaftar + Tanggal Lahir
      const r = await DB("mst_pasien").where("no_rm", cleanNoRm).first();
      if (r) {
        const dbDob = normalizeDateOnly(r.tanggal_lahir);
        const dbPhone = normalizeIndonesianPhone(r.no_hp);

        if (dbDob === inputDob && dbPhone === cleanInputPhone) {
          // Jika di database klinik ada NIK tapi input NIK tidak cocok:
          if (cleanInputNik && r.nik && cleanInputNik !== r.nik) {
            candidate = null;
          } else {
            candidate = r;
          }
        }
      }
    }

    // Jika verifikasi gagal (Generic Error - Anti Enumeration)
    if (!candidate) {
      const rec = recordClaimFailure(cred.user_code);
      if (rec.attempts >= MAX_CLAIM_ATTEMPTS) {
        return sendError(res, RATE_LIMIT_ERROR_MSG, 429, status.GAGAL);
      }
      return sendError(res, GENERIC_VERIF_ERROR_MSG, 422, status.GAGAL);
    }

    // 5. Anti-Hijacking Check: Pastikan no_rm belum pernah ditautkan ke akun user lain
    const existingClaim = await DB("user_credential")
      .where("no_rm", candidate.no_rm)
      .whereNot("user_code", cred.user_code)
      .first();

    if (existingClaim) {
      return sendError(
        res,
        `Nomor Rekam Medis ini (${candidate.no_rm}) sudah terhubung dengan akun lain. Hubungi resepsionis klinik jika ini adalah milik Anda.`,
        409,
        status.GAGAL
      );
    }

    // 6. Verifikasi Sukses: Reset Rate Limit & Tautkan ke user_credential
    resetClaimRateLimit(cred.user_code);

    const branchCode = candidate.kode_cabang || cred.kode_cabang || "CBG-001";
    const namaCabang = cred.nama_cabang || "Klinik Utama";

    await DB("user_credential")
      .where("user_code", cred.user_code)
      .update({
        no_rm: candidate.no_rm,
        fullname: cred.fullname || candidate.nama,
        telp: cred.telp || candidate.no_hp,
        kode_cabang: branchCode,
        updated_at: formatDateSystem(),
      });

    // Jika di database klinik NIK masih kosong dan pasien menginput NIK 16 digit valid, lengkapi data klinik
    if (!candidate.nik && hasValidNik) {
      await DB("mst_pasien")
        .where("no_rm", candidate.no_rm)
        .update({ nik: cleanInputNik, updated_at: formatDateSystem() });
      candidate.nik = cleanInputNik;
    }

    // 7. Generate Token Baru yang sudah memuat no_rm
    const tokenPayload = {
      user_code: cred.user_code,
      username: cred.username,
      role: cred.role || "pasien",
      fullname: cred.fullname || candidate.nama,
      nama: cred.fullname || candidate.nama,
      no_rm: candidate.no_rm,
      kode_cabang: branchCode,
      nama_cabang: namaCabang,
    };

    const tokens = await generateMobileTokens(tokenPayload, true);

    return sendSuccess(
      res,
      `Berhasil terhubung! Nomor Rekam Medis Anda adalah ${candidate.no_rm}.`,
      {
        access_token: tokens.access_token,
        refresh_token: tokens.refresh_token,
        user_info: {
          user_code: cred.user_code,
          username: cred.username,
          fullname: cred.fullname || candidate.nama,
          role: cred.role || "pasien",
          telp: cred.telp || candidate.no_hp,
          no_rm: candidate.no_rm,
          is_patient: true,
          foto: candidate.foto || null,
          kode_cabang: branchCode,
          nama_cabang: namaCabang,
          pasien_profile: candidate,
        },
      }
    );
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * PUT /api/v1/profile
 * Update Informasi Profil Pasien (Murni update profil, tanpa auto-sync no_rm)
 */
router.put("/", authenticateMobile, async (req, res) => {
  const user = req.auth;
  const {
    nama,
    no_hp,
    alamat,
    tempat_lahir,
    tanggal_lahir,
    jenis_kelamin,
    alergi,
    nik,
    nama_kontak_darurat,
    no_hp_kontak_darurat,
  } = req.body || {};

  try {
    const cred = await DB("user_credential as u")
      .leftJoin("mst_cabang as c", "u.kode_cabang", "c.kode_cabang")
      .where("u.user_code", user.user_code)
      .select("u.*", "c.nama_cabang")
      .first();

    const noRm = cred?.no_rm || user.no_rm;

    // Strict Security: Tidak ada auto-sync no_rm di PUT /profile.
    // Hanya perbarui mst_pasien jika akun SUDAH terhubung no_rm resmi melalui klaim terverifikasi.
    if (noRm) {
      const updateData = {};
      if (nama) updateData.nama = nama;
      if (no_hp) updateData.no_hp = no_hp;
      if (alamat) updateData.patokan = alamat;
      if (tempat_lahir) updateData.tempat_lahir = tempat_lahir;
      if (tanggal_lahir) updateData.tanggal_lahir = tanggal_lahir;
      if (jenis_kelamin) updateData.jenis_kelamin = jenis_kelamin;
      if (alergi !== undefined) updateData.alergi = alergi;
      if (nik) updateData.nik = nik;
      if (nama_kontak_darurat) updateData.nama_kontak_darurat = nama_kontak_darurat;
      if (no_hp_kontak_darurat) updateData.no_hp_kontak_darurat = no_hp_kontak_darurat;
      updateData.updated_at = formatDateSystem();

      await DB("mst_pasien").where("no_rm", noRm).update(updateData);
    }

    // Update user_credential
    const userUpdate = {};
    if (nama) userUpdate.fullname = nama;
    if (no_hp) userUpdate.telp = no_hp;
    if (Object.keys(userUpdate).length > 0) {
      userUpdate.updated_at = formatDateSystem();
      await DB("user_credential")
        .where("user_code", user.user_code)
        .update(userUpdate);
    }

    return sendSuccess(res, "Profil berhasil diperbarui");
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * POST /api/v1/profile/foto
 * Upload Foto Profil Pasien
 */
router.post(
  "/foto",
  authenticateMobile,
  upload.single("foto"),
  async (req, res) => {
    if (!req.file) {
      return sendError(res, "File foto wajib diupload (field: 'foto')", 400);
    }

    try {
      const fileName = req.file.filename;
      const fileUrl = `/uploads/${fileName}`;

      const cred = await DB("user_credential").where("user_code", req.auth.user_code).first();
      const noRm = cred?.no_rm || req.auth.no_rm;

      if (noRm) {
        await DB("mst_pasien")
          .where("no_rm", noRm)
          .update({
            foto: fileUrl,
            updated_at: formatDateSystem(),
          });
      }

      return sendSuccess(res, "Foto profil berhasil diperbarui", { foto: fileUrl });
    } catch (err) {
      return sendError(res, err.message, 500);
    }
  }
);

/**
 * GET /api/v1/profile/packages
 * Daftar Kepemilikan Paket Perawatan Pasien (Kartu Stempel Multi-Sesi)
 */
router.get("/packages", authenticateMobile, async (req, res) => {
  const user = req.auth;

  try {
    const cred = await DB("user_credential").where("user_code", user.user_code).first();
    const noRm = cred?.no_rm || user.no_rm;

    if (!noRm) {
      return sendSuccess(res, "Daftar paket perawatan pasien", []);
    }

    // 1. Ambil kepemilikan paket
    const packages = await DB("trx_kepemilikan_paket_layanan as kpl")
      .leftJoin("mst_paket_layanan as p", function () {
        this.on(
          DB.raw(
            "kpl.kode_paket_layanan COLLATE utf8mb4_unicode_ci = p.kode_paket_layanan COLLATE utf8mb4_unicode_ci"
          )
        );
      })
      .leftJoin("mst_ruangan as rpkt", function () {
        this.on(
          DB.raw(
            "p.kode_ruangan COLLATE utf8mb4_unicode_ci = rpkt.kode_ruangan COLLATE utf8mb4_unicode_ci"
          )
        );
      })
      .leftJoin("mst_cabang as c", function () {
        this.on(
          DB.raw(
            "kpl.kode_cabang COLLATE utf8mb4_unicode_ci = c.kode_cabang COLLATE utf8mb4_unicode_ci"
          )
        );
      })
      .where(DB.raw("kpl.no_rm COLLATE utf8mb4_unicode_ci"), "=", noRm)
      .select(
        "kpl.id",
        "kpl.kode_kepemilikan_paket_layanan",
        "kpl.no_rm",
        "kpl.kode_paket_layanan",
        "p.nama as nama_paket",
        "p.foto as foto_paket",
        "p.tipe as tipe_paket",
        "p.harga_paket",
        "p.kode_ruangan as kode_ruangan_paket",
        "rpkt.nama_ruangan as nama_ruangan_paket",
        "p.is_include_konsultasi",
        DB.raw("DATE_FORMAT(kpl.tanggal_beli, '%Y-%m-%d') as tanggal_beli"),
        DB.raw("DATE_FORMAT(kpl.tanggal_expired, '%Y-%m-%d') as tanggal_expired"),
        "kpl.status",
        "kpl.kode_cabang",
        "c.nama_cabang"
      )
      .orderBy("kpl.id", "desc");

    if (packages.length === 0) {
      return sendSuccess(res, "Daftar paket perawatan pasien", []);
    }

    const kplCodes = packages.map((p) => p.kode_kepemilikan_paket_layanan);

    // 2. Ambil detail kepemilikan (layanan & sesi)
    const details = await DB("trx_detail_kepemilikan_paket_layanan as dkpl")
      .leftJoin("mst_layanan as l", function () {
        this.on(
          DB.raw(
            "dkpl.kode_layanan COLLATE utf8mb4_unicode_ci = l.kode_layanan COLLATE utf8mb4_unicode_ci"
          )
        );
      })
      .leftJoin("mst_ruangan as r", function () {
        this.on(
          DB.raw(
            "l.kode_ruangan COLLATE utf8mb4_unicode_ci = r.kode_ruangan COLLATE utf8mb4_unicode_ci"
          )
        );
      })
      .whereIn("dkpl.kode_kepemilikan_paket_layanan", kplCodes)
      .select(
        "dkpl.id",
        "dkpl.kode_detail_kepemilikan_paket_layanan",
        "dkpl.kode_kepemilikan_paket_layanan",
        "dkpl.kode_layanan",
        "l.nama as nama_layanan",
        "l.foto as foto_layanan",
        "l.kode_ruangan",
        "r.nama_ruangan",
        "l.durasi_menit",
        "l.wajib_konsultasi",
        "l.is_include_konsultasi as is_include_konsultasi_layanan",
        "l.harga",
        "dkpl.sesi_total",
        "dkpl.sesi_terpakai"
      );

    const detailCodes = details.map((d) => d.kode_detail_kepemilikan_paket_layanan);

    // 3. Ambil booking aktif untuk menghitung sisa sesi tersedia real-time
    const activeBookingsMap = {};
    if (detailCodes.length > 0) {
      try {
        const hasDetailTable = await DB.schema.hasTable("trx_detail_booking");
        if (hasDetailTable) {
          const activeRows = await DB("trx_detail_booking as db")
            .join("trx_booking as b", "db.kode_booking", "b.kode_booking")
            .whereIn("db.kode_detail_kepemilikan_paket_layanan", detailCodes)
            .whereIn("b.status", ["dikonfirmasi", "menunggu", "menunggu_pembayaran"])
            .groupBy("db.kode_detail_kepemilikan_paket_layanan")
            .select("db.kode_detail_kepemilikan_paket_layanan", DB.raw("COUNT(db.id) as total_booked"));

          activeRows.forEach((ar) => {
            activeBookingsMap[ar.kode_detail_kepemilikan_paket_layanan] = parseInt(ar.total_booked || 0, 10);
          });
        }
      } catch (err) {
        console.error("Error fetching active bookings for packages:", err);
      }
    }

    // 4. Ambil riwayat pemakaian per sesi dari trx_pemakaian_paket_layanan
    let riwayatList = [];
    if (detailCodes.length > 0) {
      riwayatList = await DB("trx_pemakaian_paket_layanan as ppl")
        .whereIn("ppl.kode_detail_kepemilikan_paket_layanan", detailCodes)
        .select(
          "ppl.id",
          "ppl.kode_pemakaian_paket_layanan",
          "ppl.kode_detail_kepemilikan_paket_layanan",
          "ppl.sesi_ke",
          "ppl.kode_kunjungan",
          "ppl.kode_booking",
          DB.raw("DATE_FORMAT(ppl.tanggal_pakai, '%Y-%m-%d') as tanggal_pakai"),
          "ppl.status_pemakaian",
          "ppl.keterangan",
          "ppl.created_at"
        )
        .orderBy("ppl.sesi_ke", "asc");
    }

    // 5. Susun struktur kartu paket & stempel
    const result = packages.map((pkg) => {
      const pkgDetails = details.filter(
        (d) => d.kode_kepemilikan_paket_layanan === pkg.kode_kepemilikan_paket_layanan
      );

      let totalSesiAll = 0;
      let totalSesiTerpakaiAll = 0;

      const formattedDetails = pkgDetails.map((d) => {
        const sesiTotal = parseInt(d.sesi_total || 0, 10);
        const sesiTerpakai = parseInt(d.sesi_terpakai || 0, 10);
        const sisaSesi = Math.max(0, sesiTotal - sesiTerpakai);
        const sesiTerbooking = activeBookingsMap[d.kode_detail_kepemilikan_paket_layanan] || 0;
        const sesiTersedia = Math.max(0, sisaSesi - sesiTerbooking);
        const kodeRuangan = d.kode_ruangan || pkg.kode_ruangan_paket || "RNG-002";
        const namaRuangan = d.nama_ruangan || pkg.nama_ruangan_paket || "Ruangan Treatment";

        totalSesiAll += sesiTotal;
        totalSesiTerpakaiAll += sesiTerpakai;

        const usageLogs = riwayatList.filter(
          (r) => r.kode_detail_kepemilikan_paket_layanan === d.kode_detail_kepemilikan_paket_layanan
        );

        // Buat representasi stempel untuk setiap sesi dari 1 sampai sesiTotal
        const stamps = [];
        for (let s = 1; s <= sesiTotal; s++) {
          const log = usageLogs.find((u) => parseInt(u.sesi_ke, 10) === s);
          if (log) {
            stamps.push({
              sesi_ke: s,
              status: log.status_pemakaian, // 'hadir' | 'hangus_no_show'
              tanggal_pakai: log.tanggal_pakai,
              kode_booking: log.kode_booking || null,
              kode_kunjungan: log.kode_kunjungan || null,
              keterangan: log.keterangan || (log.status_pemakaian === "hadir" ? "Hadir Perawatan" : "Hangus No-Show"),
            });
          } else if (s <= sesiTerpakai) {
            stamps.push({
              sesi_ke: s,
              status: "hadir",
              tanggal_pakai: null,
              kode_booking: null,
              kode_kunjungan: null,
              keterangan: "Sesi telah digunakan",
            });
          } else {
            stamps.push({
              sesi_ke: s,
              status: "tersedia",
              tanggal_pakai: null,
              kode_booking: null,
              kode_kunjungan: null,
              keterangan: "Sesi tersedia",
            });
          }
        }

        return {
          kode_detail_kepemilikan_paket_layanan: d.kode_detail_kepemilikan_paket_layanan,
          kode_kepemilikan_paket_layanan: d.kode_kepemilikan_paket_layanan,
          kode_layanan: d.kode_layanan,
          nama_layanan: d.nama_layanan || "Layanan Paket",
          nama_paket: pkg.nama_paket,
          foto_layanan: d.foto_layanan || pkg.foto_paket,
          kode_ruangan: kodeRuangan,
          nama_ruangan: namaRuangan,
          durasi_menit: d.durasi_menit || 30,
          wajib_konsultasi: d.wajib_konsultasi || "tidak",
          is_include_konsultasi: d.is_include_konsultasi_layanan ?? pkg.is_include_konsultasi ?? 0,
          harga: 0,
          sesi_total: sesiTotal,
          sesi_terpakai: sesiTerpakai,
          sesi_terbooking: sesiTerbooking,
          sisa_sesi: sisaSesi,
          sesi_tersedia: sesiTersedia,
          stamps,
          riwayat_pemakaian: usageLogs,
        };
      });

      const sisaSesiAll = Math.max(0, totalSesiAll - totalSesiTerpakaiAll);

      return {
        ...pkg,
        total_sesi: totalSesiAll,
        sesi_terpakai: totalSesiTerpakaiAll,
        sisa_sesi: sisaSesiAll,
        details: formattedDetails,
      };
    });

    return sendSuccess(res, "Daftar paket perawatan pasien berhasil dimuat", result);
  } catch (err) {
    console.error("GET /api/v1/profile/packages error:", err);
    return sendError(res, err.message, 500);
  }
});

export default router;
