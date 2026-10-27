import express from "express";
import DB from "../../../core/config/knex.js";
import { sendSuccess, sendError } from "../../../utils/response.js";
import { authenticateMobile } from "../../../middleware/auth_middleware.js";

const router = express.Router();

/**
 * Helper membersihkan nama cabang (menghapus kata "Klinik" jika ada di depan)
 */
function cleanNamaCabang(nama) {
  if (!nama) return "Cabang Utama";
  return nama.replace(/^Klinik\s+/i, "").trim();
}

/**
 * GET /api/v1/kunjungan/history
 * Riwayat Kehadiran Kunjungan Pasien Nyata (Datang Langsung / Booking)
 * STRICT: TIDAK MEMUAT DATA REKAM MEDIS KLINIS (Anamnesis, Diagnosa, Foto Tindakan)
 */
router.get("/history", authenticateMobile, async (req, res) => {
  const user = req.auth;
  const noRm = user.no_rm;

  if (!noRm) {
    return sendSuccess(res, "Riwayat kunjungan pasien", {
      items: [],
      total: 0,
      page: 1,
      limit: 15,
      hasMore: false,
    });
  }

  try {
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.max(1, Math.min(50, parseInt(req.query.limit) || 15));
    const offset = (page - 1) * limit;
    const { status_filter } = req.query;

    // 1. Hitung Total Kunjungan Pasien
    const totalCountQuery = DB("trx_kunjungan as k")
      .where("k.no_rm", noRm)
      .modify((qb) => {
        if (status_filter && status_filter !== "semua") {
          qb.where("k.status", status_filter);
        }
      })
      .count("k.id as total")
      .first();

    const totalResult = await totalCountQuery;
    const total = parseInt(totalResult?.total || 0);

    // 2. Ambil Data Kunjungan dengan Join Aman (Collate Match)
    const kunjunganRows = await DB("trx_kunjungan as k")
      .leftJoin(
        "mst_cabang as c",
        DB.raw("k.kode_cabang = c.kode_cabang COLLATE utf8mb4_0900_ai_ci")
      )
      .where("k.no_rm", noRm)
      .modify((qb) => {
        if (status_filter && status_filter !== "semua") {
          qb.where("k.status", status_filter);
        }
      })
      .orderBy("k.tanggal_kunjungan", "desc")
      .orderBy("k.jam_datang", "desc")
      .orderBy("k.id", "desc")
      .offset(offset)
      .limit(limit)
      .select(
        "k.id",
        "k.kode_kunjungan",
        "k.no_rm",
        "k.kode_booking",
        "k.tanggal_kunjungan",
        "k.jam_datang",
        "k.status",
        "k.kode_cabang",
        "c.nama_cabang",
        "k.created_at"
      );

    // 3. Lengkapi Setiap Kunjungan dengan Layanan, Ruangan/Petugas, & Sesi Paket
    const items = [];
    for (const k of kunjunganRows) {
      const kodeKunjungan = k.kode_kunjungan;

      // A. Layanan yang Dikerjakan (dari trx_detail_antrian_layanan)
      let layananList = await DB("trx_detail_antrian_layanan")
        .where("kode_kunjungan", kodeKunjungan)
        .select("nama_layanan", "durasi_menit", "nama_ruangan");

      // Fallback jika detail antrian kosong tetapi ada kode_booking
      if (layananList.length === 0 && k.kode_booking) {
        layananList = await DB("trx_detail_booking")
          .where("kode_booking", k.kode_booking)
          .select("nama_layanan", "durasi_menit");
      }

      // B. Ruangan & Petugas/Dokter (dari trx_antrian_layanan)
      const antrianInfo = await DB("trx_antrian_layanan as al")
        .leftJoin("mst_karyawan as kry", function () {
          this.on("al.kode_karyawan", "=", "kry.kode_karyawan").orOn(
            "al.kode_karyawan",
            "=",
            "kry.no_sip"
          );
        })
        .where("al.kode_kunjungan", kodeKunjungan)
        .select("al.nama_ruangan", "kry.nama as nama_petugas")
        .first();

      // C. Pemakaian Sesi Paket jika ada (dari trx_pemakaian_paket_layanan)
      const pemakaianPaket = await DB("trx_pemakaian_paket_layanan as ppl")
        .leftJoin(
          "trx_detail_kepemilikan_paket_layanan as dkpl",
          "ppl.kode_detail_kepemilikan_paket_layanan",
          "dkpl.kode_detail_kepemilikan_paket_layanan"
        )
        .leftJoin("mst_layanan as l", "dkpl.kode_layanan", "l.kode_layanan")
        .where("ppl.kode_kunjungan", kodeKunjungan)
        .select(
          "ppl.sesi_ke",
          "dkpl.sesi_total",
          "l.nama as nama_layanan_paket",
          "ppl.status_pemakaian"
        )
        .first();

      let paketInfo = null;
      if (pemakaianPaket) {
        paketInfo = {
          nama_layanan: pemakaianPaket.nama_layanan_paket || "Layanan Paket",
          sesi_ke: pemakaianPaket.sesi_ke,
          sesi_total: pemakaianPaket.sesi_total,
          label: `Sesi ${pemakaianPaket.sesi_ke} dari ${pemakaianPaket.sesi_total}`,
        };
      }

      items.push({
        id: k.id,
        kode_kunjungan: k.kode_kunjungan,
        tanggal_kunjungan: k.tanggal_kunjungan,
        jam_datang: k.jam_datang,
        status: k.status || "selesai",
        kode_cabang: k.kode_cabang || "CBG-001",
        nama_cabang: cleanNamaCabang(k.nama_cabang),
        sumber: k.kode_booking ? "booking" : "walk_in",
        kode_booking: k.kode_booking,
        nama_ruangan: antrianInfo?.nama_ruangan || layananList[0]?.nama_ruangan || null,
        nama_petugas: antrianInfo?.nama_petugas || null,
        layanan: layananList.map((l) => ({
          nama_layanan: l.nama_layanan,
          durasi_menit: l.durasi_menit || 30,
        })),
        paket_terpakai: paketInfo,
      });
    }

    const hasMore = offset + items.length < total;

    return sendSuccess(res, "Riwayat kunjungan berhasil dimuat", {
      items,
      total,
      page,
      limit,
      hasMore,
    });
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

export default router;
