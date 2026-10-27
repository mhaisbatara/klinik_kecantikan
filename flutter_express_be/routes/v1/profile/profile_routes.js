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

const router = express.Router();

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

    // 2. Validasi input
    const schema = Joi.object({
      nik: Joi.string()
        .pattern(/^[0-9]{16}$/)
        .required()
        .messages({
          "string.pattern.base": "NIK harus berisi tepat 16 digit angka",
          "any.required": "NIK wajib diisi",
        }),
      tempat_lahir: Joi.string().trim().min(2).max(100).required().label("Tempat Lahir"),
      tanggal_lahir: Joi.string()
        .pattern(/^\d{4}-\d{2}-\d{2}$/)
        .required()
        .messages({
          "string.pattern.base": "Format tanggal lahir harus YYYY-MM-DD",
          "any.required": "Tanggal lahir wajib diisi",
        }),
      jenis_kelamin: Joi.string().valid("L", "P").required().label("Jenis Kelamin"),
      alamat: Joi.string().trim().min(3).max(255).required().label("Alamat Domisili"),
      alergi: Joi.string().allow("", null).optional().label("Riwayat Alergi"),
      nama: Joi.string().trim().min(2).max(100).optional().label("Nama Lengkap"),
      no_hp: Joi.string().pattern(/^[0-9+]+$/).min(10).max(15).optional().label("Nomor HP"),
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

    const cleanNama = value.nama || cred.fullname || "Pasien";
    const cleanPhone = (value.no_hp || cred.telp || "").replace(/[\s-]/g, "");
    const branchCode = cred.kode_cabang || "CBG-001";
    const namaCabang = cred.nama_cabang || "Klinik Utama";

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
        tempat_lahir: value.tempat_lahir,
        tanggal_lahir: value.tanggal_lahir,
        jenis_kelamin: value.jenis_kelamin,
        patokan: value.alamat,
        no_hp: cleanPhone,
        email: cred.username && cred.username.includes("@") ? cred.username : null,
        alergi: value.alergi || null,
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
 * POST /api/v1/profile/claim-patient
 * Opsi B: Klaim / Sinkronisasi Pasien Lama (Verifikasi 3 Kunci + Anti-Hijacking)
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

    // 2. Validasi input
    const schema = Joi.object({
      no_rm: Joi.string().trim().required().label("Nomor Rekam Medis"),
      tanggal_lahir: Joi.string()
        .pattern(/^\d{4}-\d{2}-\d{2}$/)
        .required()
        .messages({
          "string.pattern.base": "Format tanggal lahir harus YYYY-MM-DD",
          "any.required": "Tanggal lahir wajib diisi",
        }),
      no_hp: Joi.string().allow("", null).optional().label("Nomor HP"),
      nik: Joi.string().allow("", null).optional().label("NIK"),
    });

    const { error, value } = schema.validate(body);
    if (error) {
      return sendError(res, error.details[0].message, 422, status.BAD_REQUEST);
    }

    if (!value.no_hp && !value.nik) {
      return sendError(
        res,
        "Mohon masukkan Nomor HP atau NIK untuk verifikasi Rekam Medis Anda",
        422,
        status.BAD_REQUEST
      );
    }

    // 3. Normalisasi no_rm (misal 'RM-000001' atau '1'/'000001')
    let cleanNoRm = value.no_rm.trim().toUpperCase();
    if (!cleanNoRm.startsWith("RM-")) {
      const numOnly = cleanNoRm.replace(/[^0-9]/g, "");
      if (numOnly.length > 0) {
        cleanNoRm = `RM-${numOnly.padStart(6, "0")}`;
      }
    }

    // 4. Cari data pasien di mst_pasien
    const pasien = await DB("mst_pasien").where("no_rm", cleanNoRm).first();
    if (!pasien) {
      return sendError(
        res,
        "Data verifikasi tidak cocok dengan Rekam Medis klinik",
        422,
        status.GAGAL
      );
    }

    // 5. Verifikasi Tanggal Lahir (Kunci 2)
    let dbDob = "";
    if (pasien.tanggal_lahir instanceof Date) {
      dbDob = pasien.tanggal_lahir.toISOString().slice(0, 10);
    } else if (typeof pasien.tanggal_lahir === "string") {
      dbDob = pasien.tanggal_lahir.slice(0, 10);
    }
    const inputDob = value.tanggal_lahir.slice(0, 10);
    if (dbDob !== inputDob) {
      return sendError(
        res,
        "Data verifikasi tidak cocok dengan Rekam Medis klinik",
        422,
        status.GAGAL
      );
    }

    // 6. Verifikasi No HP atau NIK (Kunci 3)
    const cleanInputPhone = value.no_hp ? String(value.no_hp).replace(/[\s-]/g, "") : "";
    const cleanDbPhone = pasien.no_hp ? String(pasien.no_hp).replace(/[\s-]/g, "") : "";
    const cleanInputNik = value.nik ? String(value.nik).replace(/[\s-]/g, "") : "";
    const cleanDbNik = pasien.nik ? String(pasien.nik).replace(/[\s-]/g, "") : "";

    const phoneMatch = Boolean(cleanInputPhone && cleanDbPhone && cleanInputPhone === cleanDbPhone);
    const nikMatch = Boolean(cleanInputNik && cleanDbNik && cleanInputNik === cleanDbNik);

    if (!phoneMatch && !nikMatch) {
      return sendError(
        res,
        "Data verifikasi tidak cocok dengan Rekam Medis klinik (Nomor HP atau NIK tidak sesuai)",
        422,
        status.GAGAL
      );
    }

    // 7. Anti-Hijacking Check: Pastikan no_rm belum pernah ditautkan ke akun user lain
    const existingClaim = await DB("user_credential")
      .where("no_rm", cleanNoRm)
      .whereNot("user_code", cred.user_code)
      .first();

    if (existingClaim) {
      return sendError(
        res,
        "Nomor Rekam Medis ini sudah terhubung dengan akun lain. Hubungi resepsionis klinik jika ini adalah milik Anda.",
        409,
        status.GAGAL
      );
    }

    // 8. Tautkan akun user_credential ke no_rm
    const branchCode = pasien.kode_cabang || cred.kode_cabang || "CBG-001";
    const namaCabang = cred.nama_cabang || "Klinik Utama";

    await DB("user_credential")
      .where("user_code", cred.user_code)
      .update({
        no_rm: cleanNoRm,
        fullname: cred.fullname || pasien.nama,
        telp: cred.telp || pasien.no_hp,
        kode_cabang: branchCode,
        updated_at: formatDateSystem(),
      });

    // 9. Generate Token Baru yang sudah memuat no_rm
    const tokenPayload = {
      user_code: cred.user_code,
      username: cred.username,
      role: cred.role || "pasien",
      fullname: cred.fullname || pasien.nama,
      nama: cred.fullname || pasien.nama,
      no_rm: cleanNoRm,
      kode_cabang: branchCode,
      nama_cabang: namaCabang,
    };

    const tokens = await generateMobileTokens(tokenPayload, true);

    return sendSuccess(
      res,
      "Rekam Medis berhasil ditautkan ke akun Anda!",
      {
        access_token: tokens.access_token,
        refresh_token: tokens.refresh_token,
        user_info: {
          user_code: cred.user_code,
          username: cred.username,
          fullname: cred.fullname || pasien.nama,
          role: cred.role || "pasien",
          telp: cred.telp || pasien.no_hp,
          no_rm: cleanNoRm,
          is_patient: true,
          foto: pasien.foto || null,
          kode_cabang: branchCode,
          nama_cabang: namaCabang,
          pasien_profile: pasien,
        },
      }
    );
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * PUT /api/v1/profile
 * Update Informasi Profil Pasien
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
    nama_kontak_darurat,
    no_hp_kontak_darurat,
  } = req.body || {};

  try {
    // Ambil no_rm dari user_credential
    const cred = await DB("user_credential").where("user_code", user.user_code).first();
    const noRm = cred?.no_rm || user.no_rm;

    if (noRm) {
      const updateData = {};
      if (nama) updateData.nama = nama;
      if (no_hp) updateData.no_hp = no_hp;
      if (alamat) updateData.patokan = alamat;
      if (tempat_lahir) updateData.tempat_lahir = tempat_lahir;
      if (tanggal_lahir) updateData.tanggal_lahir = tanggal_lahir;
      if (jenis_kelamin) updateData.jenis_kelamin = jenis_kelamin;
      if (alergi !== undefined) updateData.alergi = alergi;
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
