import express from "express";
import Joi from "joi";
import DB from "../../../core/config/knex.js";
import { status } from "../components/tools/general.js";
import { formatDateSystem } from "../components/tools/date_tools.js";
import { ChangesLog, Logging } from "../components/tools/servertool.js";

const router = express.Router();

const ALLOWED_ROLES = ["superadmin", "manager", "owner"];

/**
 * Helper to check role authorization
 */
const verifyRole = (req, res) => {
  const user = req?.auth;
  if (!user || !user.role) {
    res.status(401).json({
      status: status.BAD_REQUEST,
      message: "Sesi tidak valid atau tidak terautentikasi.",
      datetime: formatDateSystem(),
    });
    return null;
  }

  const role = String(user.role).toLowerCase();
  if (!ALLOWED_ROLES.includes(role)) {
    res.status(403).json({
      status: status.GAGAL,
      message: "Akses ditolak: Anda tidak memiliki wewenang untuk modul Pengaturan Klinik.",
      datetime: formatDateSystem(),
    });
    return null;
  }

  return {
    ...user,
    role,
    isSuperAdmin: role === "superadmin",
  };
};

/**
 * GET /api/cabang/profil
 * - Non-superadmin: hanya mendapatkan cabangnya sendiri (user_credential.kode_cabang).
 * - Superadmin: dapat menentukan kode_cabang via query (?kode_cabang=...)
 */
const handleGetProfil = async (req, res) => {
  const authUser = verifyRole(req, res);
  if (!authUser) return;

  try {
    let targetKodeCabang = "";

    if (authUser.isSuperAdmin) {
      targetKodeCabang = req.query.kode_cabang || req.body?.kode_cabang || authUser.kode_cabang || "CBG-001";
    } else {
      targetKodeCabang = authUser.kode_cabang;
      if (!targetKodeCabang) {
        return res.status(400).json({
          status: status.BAD_REQUEST,
          message: "Akun Anda belum terasosiasi dengan cabang mana pun.",
          datetime: formatDateSystem(),
        });
      }

      // Jika non-superadmin mencoba meminta cabang lain lewat query/body, tolak 403
      const requestedKode = req.query.kode_cabang || req.body?.kode_cabang;
      if (requestedKode && requestedKode !== targetKodeCabang) {
        return res.status(403).json({
          status: status.GAGAL,
          message: `Akses ditolak: Anda hanya berhak mengakses data cabang Anda sendiri (${targetKodeCabang}).`,
          datetime: formatDateSystem(),
        });
      }
    }

    const cabang = await DB("mst_cabang")
      .where("kode_cabang", targetKodeCabang)
      .select(
        "id",
        "kode_cabang",
        "nama_cabang",
        "alamat",
        "no_telp",
        "email",
        "pj_manager",
        "jam_buka",
        "jam_tutup",
        "hari_operasional",
        "fasilitas",
        "tz",
        "status",
        "created_at",
        "updated_at"
      )
      .first();

    if (!cabang) {
      return res.status(404).json({
        status: status.GAGAL,
        message: `Data cabang dengan kode ${targetKodeCabang} tidak ditemukan.`,
        datetime: formatDateSystem(),
      });
    }

    // Parse fasilitas jika berbentuk JSON string
    let parsedFasilitas = [];
    if (cabang.fasilitas) {
      if (typeof cabang.fasilitas === "string") {
        try {
          parsedFasilitas = JSON.parse(cabang.fasilitas);
        } catch (_) {
          parsedFasilitas = [];
        }
      } else if (Array.isArray(cabang.fasilitas)) {
        parsedFasilitas = cabang.fasilitas;
      }
    }

    let cabangOptions = [];
    if (authUser.isSuperAdmin) {
      cabangOptions = await DB("mst_cabang")
        .select("kode_cabang", "nama_cabang", "status")
        .orderBy("kode_cabang", "asc");
    }

    return res.status(200).json({
      status: status.SUKSES,
      message: "Berhasil memuat informasi cabang",
      datetime: formatDateSystem(),
      data: {
        ...cabang,
        fasilitas: parsedFasilitas,
      },
      cabang_options: cabangOptions,
    });
  } catch (error) {
    Logging(error, {
      file: "routes/v1/setup/cabang_profil.js",
      func: "handleGetProfil",
      user: authUser?.username,
    });

    return res.status(500).json({
      status: status.BAD_REQUEST,
      message: "Gagal memuat profil cabang: " + error.message,
      datetime: formatDateSystem(),
    });
  }
};

/**
 * PUT /api/cabang/profil
 * - Non-superadmin: kode_cabang SELALU diambil dari sesi/token (user_credential.kode_cabang).
 * - Superadmin: boleh update cabang spesifik.
 * - Tidak boleh mengubah kode_cabang dan status.
 */
const handlePutProfil = async (req, res) => {
  const authUser = verifyRole(req, res);
  if (!authUser) return;

  const body = req.body || {};

  try {
    let targetKodeCabang = "";

    if (authUser.isSuperAdmin) {
      targetKodeCabang = body.kode_cabang || req.query.kode_cabang || authUser.kode_cabang || "CBG-001";
    } else {
      targetKodeCabang = authUser.kode_cabang;
      if (!targetKodeCabang) {
        return res.status(400).json({
          status: status.BAD_REQUEST,
          message: "Akun Anda belum terasosiasi dengan cabang mana pun.",
          datetime: formatDateSystem(),
        });
      }

      // Validasi mutlak: jika client mengirim kode_cabang berbeda, tolak 403
      const requestedKode = body.kode_cabang || req.query.kode_cabang;
      if (requestedKode && requestedKode !== targetKodeCabang) {
        return res.status(403).json({
          status: status.GAGAL,
          message: `Akses ditolak: Anda tidak memiliki wewenang untuk mengubah data cabang ${requestedKode}. Anda hanya berwenang untuk cabang ${targetKodeCabang}.`,
          datetime: formatDateSystem(),
        });
      }
    }

    // Ambil data cabang lama
    const oldCabang = await DB("mst_cabang")
      .where("kode_cabang", targetKodeCabang)
      .first();

    if (!oldCabang) {
      return res.status(404).json({
        status: status.GAGAL,
        message: `Cabang ${targetKodeCabang} tidak ditemukan.`,
        datetime: formatDateSystem(),
      });
    }

    // Validasi input server-side
    const schema = Joi.object({
      nama_cabang: Joi.string().trim().min(2).max(150).required().messages({
        "any.required": "Nama cabang wajib diisi",
        "string.empty": "Nama cabang tidak boleh kosong",
        "string.min": "Nama cabang minimal 2 karakter",
        "string.max": "Nama cabang maksimal 150 karakter",
      }),
      alamat: Joi.string().trim().min(5).required().messages({
        "any.required": "Alamat cabang wajib diisi",
        "string.empty": "Alamat cabang tidak boleh kosong",
        "string.min": "Alamat cabang minimal 5 karakter",
      }),
      no_telp: Joi.string().trim().min(5).max(50).required().messages({
        "any.required": "Nomor telepon / WhatsApp wajib diisi",
        "string.empty": "Nomor telepon tidak boleh kosong",
      }),
      email: Joi.string()
        .trim()
        .allow("", null)
        .email({ tlds: { allow: false } })
        .max(100)
        .messages({
          "string.email": "Format email tidak valid",
        }),
      pj_manager: Joi.string().trim().allow("", null).max(100),
      jam_buka: Joi.string()
        .trim()
        .regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?$/)
        .required()
        .messages({
          "any.required": "Jam buka wajib diisi",
          "string.pattern.base": "Format jam buka tidak valid (gunakan format HH:mm atau HH:mm:ss)",
        }),
      jam_tutup: Joi.string()
        .trim()
        .regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?$/)
        .required()
        .messages({
          "any.required": "Jam tutup wajib diisi",
          "string.pattern.base": "Format jam tutup tidak valid (gunakan format HH:mm atau HH:mm:ss)",
        }),
      hari_operasional: Joi.string().trim().required().messages({
        "any.required": "Hari operasional wajib dipilih minimal 1 hari",
        "string.empty": "Hari operasional wajib dipilih minimal 1 hari",
      }),
      fasilitas: Joi.array()
        .items(
          Joi.object({
            nama: Joi.string().trim().min(1).max(100).required().messages({
              "string.empty": "Nama fasilitas tidak boleh kosong",
              "any.required": "Nama fasilitas wajib diisi",
            }),
            icon: Joi.string().trim().allow("", null).max(30),
          })
        )
        .max(20)
        .allow(null)
        .messages({
          "array.max": "Maksimal fasilitas yang dapat ditambahkan adalah 20",
        }),
      kode_cabang: Joi.any().optional(), // diabaikan / divalidasi
      status: Joi.any().optional(), // dilarang diubah lewat endpoint ini
    });

    const { error, value } = schema.validate(body, { abortEarly: false, allowUnknown: true });
    if (error) {
      const messages = error.details.map((d) => d.message).join(", ");
      return res.status(422).json({
        status: status.GAGAL,
        message: messages,
        datetime: formatDateSystem(),
      });
    }

    // Validasi jam_tutup harus setelah jam_buka
    const parseTimeToMinutes = (t) => {
      const parts = String(t).split(":");
      return parseInt(parts[0], 10) * 60 + parseInt(parts[1], 10);
    };

    if (parseTimeToMinutes(value.jam_tutup) <= parseTimeToMinutes(value.jam_buka)) {
      return res.status(422).json({
        status: status.GAGAL,
        message: "Jam tutup harus lebih malam daripada jam buka.",
        datetime: formatDateSystem(),
      });
    }

    // Validasi hari_operasional: minimal 1 hari, angka 1-7
    const rawDays = String(value.hari_operasional)
      .split(",")
      .map((d) => d.trim())
      .filter((d) => Boolean(d));

    const validDays = rawDays.filter((d) => ["1", "2", "3", "4", "5", "6", "7"].includes(d));
    const uniqueDays = [...new Set(validDays)].sort((a, b) => Number(a) - Number(b));

    if (uniqueDays.length === 0) {
      return res.status(422).json({
        status: status.GAGAL,
        message: "Pilih minimal 1 hari operasional (Senin - Minggu).",
        datetime: formatDateSystem(),
      });
    }
    const cleanHariOperasional = uniqueDays.join(",");

    // Validasi fasilitas: tidak boleh ada nama duplikat
    let cleanFasilitas = [];
    if (Array.isArray(value.fasilitas)) {
      const seenNames = new Set();
      for (const item of value.fasilitas) {
        const trimmedNama = String(item.nama || "").trim();
        if (!trimmedNama) continue;
        const lower = trimmedNama.toLowerCase();
        if (seenNames.has(lower)) {
          return res.status(422).json({
            status: status.GAGAL,
            message: `Nama fasilitas '${trimmedNama}' duplikat. Setiap fasilitas harus unik.`,
            datetime: formatDateSystem(),
          });
        }
        seenNames.add(lower);
        cleanFasilitas.push({
          nama: trimmedNama,
          icon: String(item.icon || "✨").trim(),
        });
      }
    }

    // Format jam buka & tutup standar HH:mm:ss
    const formatTimeSql = (t) => {
      const parts = String(t).split(":");
      const h = parts[0].padStart(2, "0");
      const m = (parts[1] || "00").padStart(2, "0");
      const s = (parts[2] || "00").padStart(2, "0");
      return `${h}:${m}:${s}`;
    };

    const updateData = {
      nama_cabang: value.nama_cabang.trim(),
      alamat: value.alamat.trim(),
      no_telp: value.no_telp.trim(),
      email: value.email ? value.email.trim() : null,
      pj_manager: value.pj_manager ? value.pj_manager.trim() : null,
      jam_buka: formatTimeSql(value.jam_buka),
      jam_tutup: formatTimeSql(value.jam_tutup),
      hari_operasional: cleanHariOperasional,
      fasilitas: JSON.stringify(cleanFasilitas),
      updated_by: authUser.username || authUser.fullname || "SYSTEM",
      updated_at: DB.fn.now(),
    };

    // Eksekusi update ke database menggunakan parameterized query knex
    await DB("mst_cabang")
      .where("kode_cabang", targetKodeCabang)
      .update(updateData);

    // Ambil data terbaru sesudah update
    const newCabang = await DB("mst_cabang")
      .where("kode_cabang", targetKodeCabang)
      .first();

    // Catat log perubahan
    try {
      await ChangesLog({
        nama_tabel: "mst_cabang",
        kode_referensi: targetKodeCabang,
        aksi: "UPDATE",
        keterangan: `Update Informasi Cabang ${targetKodeCabang} (${updateData.nama_cabang}) oleh ${authUser.username}`,
        dataBefore: oldCabang,
        dataAfter: newCabang,
        user: authUser.username,
        tz: oldCabang.tz || "Asia/Jakarta",
      });
    } catch (logErr) {
      console.error("Gagal mencatat log perubahan cabang:", logErr.message);
    }

    return res.status(200).json({
      status: status.SUKSES,
      message: `Informasi cabang ${updateData.nama_cabang} (${targetKodeCabang}) berhasil diperbarui.`,
      datetime: formatDateSystem(),
      data: {
        ...newCabang,
        fasilitas: cleanFasilitas,
      },
    });
  } catch (error) {
    Logging(error, {
      file: "routes/v1/setup/cabang_profil.js",
      func: "handlePutProfil",
      user: authUser?.username,
    });

    return res.status(500).json({
      status: status.BAD_REQUEST,
      message: "Gagal memperbarui profil cabang: " + error.message,
      datetime: formatDateSystem(),
    });
  }
};

// Route handlers
router.get("/profil", handleGetProfil);
router.put("/profil", handlePutProfil);
router.post("/profil", (req, res) => {
  // Jika client memanggil POST, cek apakah berniat GET atau UPDATE
  if (req.body && Object.keys(req.body).length > 0 && req.body.nama_cabang) {
    return handlePutProfil(req, res);
  }
  return handleGetProfil(req, res);
});

export default router;
