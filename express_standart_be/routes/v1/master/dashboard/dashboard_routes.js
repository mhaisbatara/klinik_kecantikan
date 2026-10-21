import express from "express";
import DB from "../../../../core/config/knex.js";
import { formatDateSystem } from "../../components/tools/date_tools.js";
import { Logging } from "../../components/tools/servertool.js";
import { status } from "../../components/tools/general.js";
import { getBranchScope } from "../../components/tools/branch_scope.js";

const router = express.Router();

/**
 * POST /master/dashboard/role-data
 * Mengambil agregasi metrik data real-time untuk 5 role dashboard:
 * owner, dokter, beautician, kasir, warehouse
 */
router.post("/role-data", async (req, res) => {
  const { body } = req;
  const role = (body.role || "owner").toLowerCase();
  const username = req?.auth?.username || body.username || "";
  const userCode = req?.auth?.user_code || body.user_code || "";
  const branchCode = getBranchScope(req, body.kode_cabang);

  try {
    const todayStr = formatDateSystem(new Date(), "yyyy-MM-dd");

    // ── 1. METRIK OWNER / MANAGER ──
    // Kunjungan hari ini & total pasien
    const qKunjunganToday = DB("trx_kunjungan").whereRaw("DATE(tanggal_kunjungan) = ?", [todayStr]);
    if (branchCode) qKunjunganToday.where("kode_cabang", branchCode);
    const kunjunganToday = await qKunjunganToday.count("id as count").first();

    const qTotalPasien = DB("mst_pasien");
    if (branchCode) qTotalPasien.where("kode_cabang", branchCode);
    const totalPasien = await qTotalPasien.count("id as count").first();

    const qTotalLayanan = DB("mst_layanan").where("status", "aktif");
    if (branchCode) qTotalLayanan.where("kode_cabang", branchCode);
    const totalLayanan = await qTotalLayanan.count("id as count").first();

    const tanggalDari = body.tanggal_dari || null;
    const tanggalSampai = body.tanggal_sampai || null;

    // Omzet hari ini (Pelunasan hari ini + DP booking diterima hari ini)
    const qPelunasanToday = DB("trx_transaksi")
      .whereRaw("DATE(tanggal_transaksi) = ?", [todayStr])
      .whereIn("status", ["lunas", "selesai"]);
    if (branchCode) qPelunasanToday.where("kode_cabang", branchCode);
    const pelunasanToday = await qPelunasanToday
      .select(DB.raw("SUM(COALESCE(sisa_bayar, total_bayar)) as total"))
      .first();

    const qDpReceivedToday = DB("trx_booking")
      .whereRaw("DATE(COALESCE(dp_dibayar_at, created_at)) = ?", [todayStr])
      .whereIn("dp_status", ["sudah_bayar", "dipotong_treatment", "hangus"]);
    if (branchCode) qDpReceivedToday.where("kode_cabang", branchCode);
    const dpReceivedToday = await qDpReceivedToday
      .sum("dp_nominal as total")
      .first();

    const omzetTodayVal = parseFloat(pelunasanToday?.total || 0) + parseFloat(dpReceivedToday?.total || 0);

    // Total omzet keseluruhan (Nilai transaksi tindakan lunas + DP hangus)
    const qOmzetTrxTotal = DB("trx_transaksi")
      .whereIn("status", ["lunas", "selesai"]);
    if (branchCode) qOmzetTrxTotal.where("kode_cabang", branchCode);
    const omzetTrxTotal = await qOmzetTrxTotal
      .sum("total_bayar as total")
      .first();

    const qDpHangusTotal = DB("trx_booking")
      .where("status", "tidak_hadir")
      .where("dp_status", "hangus");
    if (branchCode) qDpHangusTotal.where("kode_cabang", branchCode);
    const dpHangusTotal = await qDpHangusTotal
      .sum("dp_nominal as total")
      .first();

    const omzetTotalVal = parseFloat(omzetTrxTotal?.total || 0) + parseFloat(dpHangusTotal?.total || 0);

    // ── Breakdown metode bayar akurat (UNION Pelunasan Kasir + DP Booking Terlaksana + DP Hangus) ──
    let qPelunasanWhere = "status IN ('lunas', 'selesai') AND COALESCE(sisa_bayar, total_bayar) > 0";
    let qDpBookingWhere = "t.status IN ('lunas', 'selesai') AND t.dp_nominal > 0 AND t.metode_pembayaran_dp IS NOT NULL";
    let qDpHangusWhere = "b.status = 'tidak_hadir' AND b.dp_status = 'hangus' AND b.dp_nominal > 0 AND b.metode_pembayaran_dp IS NOT NULL";

    const pelunasanBindings = [];
    const dpBookingBindings = [];
    const dpHangusBindings = [];

    if (tanggalDari) {
      qPelunasanWhere += " AND DATE(tanggal_transaksi) >= ?";
      pelunasanBindings.push(tanggalDari);

      qDpBookingWhere += " AND DATE(COALESCE(b.dp_dibayar_at, b.created_at)) >= ?";
      dpBookingBindings.push(tanggalDari);

      qDpHangusWhere += " AND DATE(COALESCE(b.dp_dibayar_at, b.created_at)) >= ?";
      dpHangusBindings.push(tanggalDari);
    }
    if (tanggalSampai) {
      qPelunasanWhere += " AND DATE(tanggal_transaksi) <= ?";
      pelunasanBindings.push(tanggalSampai);

      qDpBookingWhere += " AND DATE(COALESCE(b.dp_dibayar_at, b.created_at)) <= ?";
      dpBookingBindings.push(tanggalSampai);

      qDpHangusWhere += " AND DATE(COALESCE(b.dp_dibayar_at, b.created_at)) <= ?";
      dpHangusBindings.push(tanggalSampai);
    }

    const unionSql = `
      SELECT
        CASE
          WHEN LOWER(TRIM(metode)) IN ('tunai', 'cash') THEN 'Tunai'
          WHEN LOWER(TRIM(metode)) IN ('debit', 'transfer') THEN 'Debit'
          WHEN LOWER(TRIM(metode)) LIKE '%qris%' THEN 'QRIS'
          ELSE UPPER(TRIM(metode))
        END as metode_bayar,
        COUNT(id) as jumlah_trx,
        SUM(nominal) as nominal
      FROM (
        SELECT
          id,
          metode_bayar as metode,
          COALESCE(sisa_bayar, total_bayar) as nominal
        FROM trx_transaksi
        WHERE ${qPelunasanWhere}

        UNION ALL

        SELECT
          t.id,
          t.metode_pembayaran_dp as metode,
          t.dp_nominal as nominal
        FROM trx_transaksi as t
        JOIN trx_kunjungan as k ON t.kode_kunjungan = k.kode_kunjungan
        JOIN trx_booking as b ON k.kode_booking = b.kode_booking
        WHERE ${qDpBookingWhere}

        UNION ALL

        SELECT
          b.id,
          b.metode_pembayaran_dp as metode,
          b.dp_nominal as nominal
        FROM trx_booking as b
        WHERE ${qDpHangusWhere}
      ) as combined
      GROUP BY 1
    `;

    const allBindings = [...pelunasanBindings, ...dpBookingBindings, ...dpHangusBindings];
    const metodeBreakdownRaw = await DB.raw(unionSql, allBindings);
    const metodeBreakdown = (metodeBreakdownRaw[0] || []).map((row) => ({
      metode_bayar: row.metode_bayar,
      jumlah_trx: parseInt(row.jumlah_trx || 0, 10),
      nominal: parseFloat(row.nominal || 0),
    }));

    // Top Treatment
    const qTopTreatments = DB("trx_detail_antrian_layanan as dal")
      .select("dal.nama_layanan", "dal.kode_layanan")
      .count("dal.id as total_sesi")
      .whereNotNull("dal.nama_layanan");
    if (branchCode) {
      qTopTreatments.join("trx_antrian_layanan as al_top", "dal.kode_antrian_layanan", "al_top.kode_antrian_layanan")
        .where("al_top.kode_cabang", branchCode);
    }
    const topTreatments = await qTopTreatments
      .groupBy("dal.kode_layanan", "dal.nama_layanan")
      .orderBy("total_sesi", "desc")
      .limit(5);

    // Inventory status ringkas
    const qInventory = DB("mst_produk")
      .select(
        DB.raw("COUNT(id) as total_sku"),
        DB.raw("COALESCE(SUM(harga_beli * stok_tersedia), 0) as total_aset"),
        DB.raw("COALESCE(SUM(CASE WHEN stok_tersedia <= stok_minimum THEN 1 ELSE 0 END), 0) as stok_menipis"),
        DB.raw("COALESCE(SUM(CASE WHEN stok_tersedia <= 0 THEN 1 ELSE 0 END), 0) as stok_habis")
      );
    if (branchCode) qInventory.where("kode_cabang", branchCode);
    const inventorySummary = await qInventory.first();

    // Performa SDM (Dokter & Beautician)
    const qDokter = DB("mst_karyawan as k")
      .leftJoin("trx_rekam_medis as rm", "k.kode_karyawan", "rm.kode_karyawan")
      .where("k.jabatan", "dokter");
    if (branchCode) qDokter.where("k.kode_cabang", branchCode);
    const dokterPerforma = await qDokter
      .select("k.nama", "k.kode_karyawan")
      .count("rm.id as total_konsul")
      .groupBy("k.kode_karyawan", "k.nama")
      .limit(5);

    const qBeautician = DB("mst_karyawan as k")
      .leftJoin("trx_antrian_layanan as al", "k.kode_karyawan", "al.kode_karyawan")
      .whereIn("k.jabatan", ["perawat", "terapis", "beautician"]);
    if (branchCode) qBeautician.where("k.kode_cabang", branchCode);
    const beauticianPerforma = await qBeautician
      .select("k.nama", "k.jabatan", "k.kode_karyawan")
      .count("al.id as total_tindakan")
      .groupBy("k.kode_karyawan", "k.nama", "k.jabatan")
      .limit(5);

    // ── 2. METRIK DOKTER ──
    const qAntreanDokter = DB("trx_antrian_layanan as al")
      .leftJoin("trx_kunjungan as k", "al.kode_kunjungan", "k.kode_kunjungan")
      .leftJoin("mst_pasien as p", "k.no_rm", "p.no_rm")
      .leftJoin("trx_detail_antrian_layanan as dal", "al.kode_antrian_layanan", "dal.kode_antrian_layanan")
      .select(
        "al.id",
        "al.kode_antrian_layanan",
        "p.nama as nama_pasien",
        "p.no_rm",
        "dal.nama_layanan",
        "al.nama_ruangan",
        "al.status",
        "al.created_at"
      );
    if (branchCode) qAntreanDokter.where("al.kode_cabang", branchCode);
    const antreanDokter = await qAntreanDokter
      .orderBy("al.created_at", "desc")
      .limit(8);

    const qRekamMedis = DB("trx_rekam_medis as rm")
      .leftJoin("mst_pasien as p", "rm.no_rm", "p.no_rm")
      .leftJoin("mst_karyawan as d", "rm.kode_karyawan", "d.kode_karyawan")
      .select(
        "rm.id",
        "rm.kode_rekam_medis",
        "p.nama as nama_pasien",
        "rm.no_rm",
        "rm.diagnosis",
        "rm.keluhan",
        "rm.plan",
        "rm.created_at as tanggal_pemeriksaan",
        "d.nama as nama_dokter"
      );
    if (branchCode) qRekamMedis.where("rm.kode_cabang", branchCode);
    const rekamMedisTerbaru = await qRekamMedis
      .orderBy("rm.created_at", "desc")
      .limit(6);

    // ── 3. METRIK BEAUTICIAN ──
    const qTreatmentBeautician = DB("trx_antrian_layanan as al")
      .leftJoin("trx_detail_antrian_layanan as dal", "al.kode_antrian_layanan", "dal.kode_antrian_layanan")
      .leftJoin("trx_kunjungan as k", "al.kode_kunjungan", "k.kode_kunjungan")
      .leftJoin("mst_pasien as p", "k.no_rm", "p.no_rm")
      .select(
        "al.kode_antrian_layanan",
        "dal.nama_layanan",
        "p.nama as nama_pasien",
        "al.nama_ruangan",
        "al.status",
        "al.created_at"
      );
    if (branchCode) qTreatmentBeautician.where("al.kode_cabang", branchCode);
    const treatmentBeautician = await qTreatmentBeautician
      .orderBy("al.created_at", "desc")
      .limit(8);

    // Foto Before After terbaru
    const qFoto = DB("trx_rekam_medis_foto as f")
      .leftJoin("trx_rekam_medis as rm", "f.id_rekam_medis", "rm.id")
      .leftJoin("mst_pasien as p", "rm.no_rm", "p.no_rm")
      .select("f.id", "f.url_foto", "f.tipe", "p.nama as nama_pasien", "f.created_at");
    if (branchCode) qFoto.where("rm.kode_cabang", branchCode);
    const fotoBeforeAfter = await qFoto
      .orderBy("f.created_at", "desc")
      .limit(6);

    // ── 4. METRIK KASIR ──
    const qTrxKasir = DB("trx_transaksi as t")
      .leftJoin("mst_pasien as p", "t.no_rm", "p.no_rm")
      .select(
        "t.id",
        "t.kode_transaksi",
        "p.nama as nama_pasien",
        "t.no_rm",
        "t.tanggal_transaksi",
        "t.metode_bayar",
        "t.total_harga",
        "t.total_diskon",
        "t.total_bayar",
        "t.status"
      );
    if (branchCode) qTrxKasir.where("t.kode_cabang", branchCode);
    if (role === "kasir") {
      qTrxKasir.where(function () {
        if (username) this.where("t.updated_by", username).orWhere("t.created_by", username);
        if (userCode) this.orWhere("t.updated_by", userCode).orWhere("t.created_by", userCode);
      });
    }
    const transaksiKasir = await qTrxKasir
      .orderBy("t.created_at", "desc")
      .limit(10);

    const qTotalKasir = DB("trx_transaksi as t")
      .whereIn("t.status", ["lunas", "selesai"]);
    if (branchCode) qTotalKasir.where("t.kode_cabang", branchCode);
    if (role === "kasir") {
      qTotalKasir.where(function () {
        if (username) this.where("t.updated_by", username).orWhere("t.created_by", username);
        if (userCode) this.orWhere("t.updated_by", userCode).orWhere("t.created_by", userCode);
      });
    }
    const totalTrxKasirToday = await qTotalKasir
      .count("t.id as total_trx")
      .sum("t.total_bayar as total_bayar")
      .sum("t.total_diskon as total_diskon")
      .first();

    let kasirMetodeBreakdown = [];
    let kasirWeeklyTrend = { labels: [], values: [] };
    let kasirActiveShift = null;

    if (role === "kasir") {
      // Breakdown metode bayar khusus kasir ini
      const qMetode = DB("trx_transaksi as t")
        .select("t.metode_bayar")
        .count("t.id as jumlah_trx")
        .sum("t.total_bayar as nominal")
        .whereIn("t.status", ["lunas", "selesai"]);
      if (branchCode) qMetode.where("t.kode_cabang", branchCode);
      qMetode.where(function () {
        if (username) this.where("t.updated_by", username).orWhere("t.created_by", username);
        if (userCode) this.orWhere("t.updated_by", userCode).orWhere("t.created_by", userCode);
      });
      qMetode.groupBy("t.metode_bayar");
      kasirMetodeBreakdown = (await qMetode).map((r) => ({
        metode_bayar: (r.metode_bayar || "TUNAI").toUpperCase(),
        jumlah_trx: parseInt(r.jumlah_trx || 0, 10),
        nominal: parseFloat(r.nominal || 0),
      }));

      // Tren 7 Hari Terakhir untuk kasir ini
      const dayNames = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"];
      const labels = [];
      const dateKeys = [];
      for (let i = 6; i >= 0; i--) {
        const d = new Date();
        d.setDate(d.getDate() - i);
        const ymd = formatDateSystem(d, "yyyy-MM-dd");
        labels.push(dayNames[d.getDay()]);
        dateKeys.push(ymd);
      }

      const qWeekly = DB("trx_transaksi as t")
        .select(DB.raw("DATE(t.tanggal_transaksi) as tgl"))
        .sum("t.total_bayar as total")
        .whereIn("t.status", ["lunas", "selesai"])
        .whereRaw("DATE(t.tanggal_transaksi) >= ?", [dateKeys[0]])
        .whereRaw("DATE(t.tanggal_transaksi) <= ?", [dateKeys[dateKeys.length - 1]]);
      if (branchCode) qWeekly.where("t.kode_cabang", branchCode);
      qWeekly.where(function () {
        if (username) this.where("t.updated_by", username).orWhere("t.created_by", username);
        if (userCode) this.orWhere("t.updated_by", userCode).orWhere("t.created_by", userCode);
      });
      qWeekly.groupByRaw("DATE(t.tanggal_transaksi)");
      const weeklyRows = await qWeekly;
      const mapVal = {};
      for (const row of weeklyRows) {
        const key = formatDateSystem(new Date(row.tgl), "yyyy-MM-dd");
        mapVal[key] = parseFloat(row.total || 0) / 1000000;
      }
      const values = dateKeys.map((dk) => parseFloat((mapVal[dk] || 0).toFixed(2)));
      kasirWeeklyTrend = { labels, values };

      // Sesi shift aktif kasir jika ada
      kasirActiveShift = await DB("trx_kasir_shift")
        .where(function () {
          if (userCode) this.where("user_code", userCode);
          if (username) this.orWhere("created_by", username);
        })
        .where("status", "open")
        .orderBy("id", "desc")
        .first();
    }

    // ── 5. METRIK WAREHOUSE ──
    const qStock = DB("mst_produk as p")
      .leftJoin("mst_kategori_produk as kp", "p.kode_kategori_produk", "kp.kode_kategori_produk")
      .select(
        "p.kode_produk",
        "p.nama",
        "kp.nama as kategori",
        "p.satuan",
        "p.stok_tersedia",
        "p.stok_minimum",
        "p.harga_beli",
        "p.harga_jual",
        "p.status"
      );
    if (branchCode) qStock.where("p.kode_cabang", branchCode);
    const stockList = await qStock
      .orderBy("p.stok_tersedia", "asc")
      .limit(10);

    const qPO = DB("trx_purchase_order as po")
      .leftJoin("mst_supplier as s", "po.kode_supplier", "s.kode_supplier")
      .select(
        "po.id",
        "po.kode_po",
        "s.nama as nama_supplier",
        "po.tanggal_po",
        "po.total_po",
        "po.status"
      );
    if (branchCode) qPO.where("po.kode_cabang", branchCode);
    const purchaseOrders = await qPO
      .orderBy("po.tanggal_po", "desc")
      .limit(6);

    // ── 6. METRIK ADMIN (PENDAFTARAN & ANTREAN) ──
    const qPasienBaruToday = DB("mst_pasien").whereRaw("DATE(created_at) = ?", [todayStr]);
    if (branchCode) qPasienBaruToday.where("kode_cabang", branchCode);
    const pasienBaruToday = await qPasienBaruToday.count("id as count").first();

    const qAntreanPendaftaranToday = DB("trx_antrian_layanan as al")
      .whereRaw("DATE(al.created_at) = ?", [todayStr]);
    if (branchCode) qAntreanPendaftaranToday.where("al.kode_cabang", branchCode);
    const antreanPendaftaranToday = await qAntreanPendaftaranToday.count("id as count").first();

    const qRecentKunjungan = DB("trx_kunjungan as k")
      .leftJoin("mst_pasien as p", "k.no_rm", "p.no_rm")
      .select("k.id", "k.kode_kunjungan", "k.no_rm", "p.nama as nama_pasien", "k.tanggal_kunjungan", "k.status")
      .orderBy("k.created_at", "desc")
      .limit(8);
    if (branchCode) qRecentKunjungan.where("k.kode_cabang", branchCode);
    const recentKunjunganList = await qRecentKunjungan;

    const allBranches = await DB("mst_cabang")
      .select("kode_cabang", "nama_cabang", "alamat", "no_telp", "status")
      .orderBy("id", "asc");

    return res.status(200).json({
      status: status.SUKSES,
      message: "Data Dashboard Role-Based berhasil dimuat",
      datetime: formatDateSystem(),
      data: {
        active_role: role,
        all_cabang: allBranches,
        owner: {
          kpi: {
            kunjungan_hari_ini: parseInt(kunjunganToday?.count || 0, 10),
            total_pasien: parseInt(totalPasien?.count || 0, 10),
            total_layanan: parseInt(totalLayanan?.count || 0, 10),
            omzet_hari_ini: omzetTodayVal,
            omzet_total: omzetTotalVal,
          },
          metode_bayar: metodeBreakdown || [],
          top_treatment: topTreatments || [],
          inventory: {
            total_sku: parseInt(inventorySummary?.total_sku || 0, 10),
            total_aset: parseFloat(inventorySummary?.total_aset || 0),
            stok_menipis: parseInt(inventorySummary?.stok_menipis || 0, 10),
            stok_habis: parseInt(inventorySummary?.stok_habis || 0, 10),
          },
          sdm: {
            dokter: dokterPerforma || [],
            beautician: beauticianPerforma || [],
          },
        },
        dokter: {
          antrean: antreanDokter || [],
          rekam_medis: rekamMedisTerbaru || [],
          total_antrean_hari_ini: antreanDokter.length,
          total_konsul_selesai: rekamMedisTerbaru.length,
        },
        beautician: {
          antrean: treatmentBeautician || [],
          foto_before_after: fotoBeforeAfter || [],
          total_tindakan: treatmentBeautician.length,
        },
        kasir: {
          transaksi: transaksiKasir || [],
          summary: {
            total_transaksi: parseInt(totalTrxKasirToday?.total_trx || 0, 10),
            total_bayar: parseFloat(totalTrxKasirToday?.total_bayar || 0),
            total_diskon: parseFloat(totalTrxKasirToday?.total_diskon || 0),
          },
          metode_bayar: role === "kasir" && kasirMetodeBreakdown.length > 0 ? kasirMetodeBreakdown : (metodeBreakdown || []),
          weekly_trend: kasirWeeklyTrend,
          active_shift: kasirActiveShift || null,
        },
        warehouse: {
          stock: stockList || [],
          purchase_orders: purchaseOrders || [],
          summary: {
            total_sku: parseInt(inventorySummary?.total_sku || 0, 10),
            total_aset: parseFloat(inventorySummary?.total_aset || 0),
            stok_menipis: parseInt(inventorySummary?.stok_menipis || 0, 10),
            stok_habis: parseInt(inventorySummary?.stok_habis || 0, 10),
          },
        },
        admin: {
          summary: {
            kunjungan_hari_ini: parseInt(kunjunganToday?.count || 0, 10),
            total_pasien: parseInt(totalPasien?.count || 0, 10),
            pasien_baru_hari_ini: parseInt(pasienBaruToday?.count || 0, 10),
            antrean_hari_ini: parseInt(antreanPendaftaranToday?.count || 0, 10),
          },
          kunjungan_terbaru: recentKunjunganList || [],
        },
      },
    });
  } catch (err) {
    Logging(err, { file: "dashboard_routes.js", func: "role-data", request: body });
    return res.status(500).json({ status: status.BAD_REQUEST, message: err.message });
  }
});

/**
 * POST /master/dashboard/cabang-detail
 * Khusus Superadmin: Mengambil detail tracking aktivitas & metrik operasional cabang tertentu
 */
router.post("/cabang-detail", async (req, res) => {
  const { body } = req;
  const username = req?.auth?.username || body.username || "";
  const role = (req?.auth?.role || body.role || "").toLowerCase();
  const isSuperAdmin = role === "superadmin" || role === "admin_pusat" || req?.auth?.is_superadmin;

  if (!isSuperAdmin) {
    return res.status(403).json({
      status: status.GAGAL,
      message: "Akses ditolak: Dashboard Cabang hanya dapat diakses oleh Superadmin.",
    });
  }

  const kodeCabang = body.kode_cabang || "CBG-001";
  try {
    const today = formatDateSystem(new Date(), "yyyy-MM-dd");

    // 1. Profil Cabang
    const cabang = await DB("mst_cabang").where("kode_cabang", kodeCabang).first();
    if (!cabang) {
      return res.status(404).json({
        status: status.NOT_FOUND,
        message: `Cabang dengan kode ${kodeCabang} tidak ditemukan.`,
      });
    }

    // 2. Daftar seluruh cabang untuk switcher cepat
    const allBranches = await DB("mst_cabang").select("kode_cabang", "nama_cabang", "status").orderBy("id", "asc");

    // 3. User Manager di cabang ini
    const managers = await DB("user_credential")
      .where("kode_cabang", kodeCabang)
      .whereIn("role", ["owner", "manager"])
      .select("user_code", "fullname", "username", "telp", "status");

    // 4. Omzet Hari Ini & Total
    const omzetTrxTotal = await DB("trx_transaksi")
      .where("kode_cabang", kodeCabang)
      .whereIn("status", ["lunas", "selesai"])
      .sum("total_bayar as total")
      .first();

    const omzetToday = await DB("trx_transaksi")
      .where("kode_cabang", kodeCabang)
      .whereIn("status", ["lunas", "selesai"])
      .whereRaw("DATE(tanggal_transaksi) = ?", [today])
      .sum("total_bayar as total")
      .first();

    const dpReceivedToday = await DB("trx_booking")
      .where("kode_cabang", kodeCabang)
      .whereRaw("DATE(COALESCE(dp_dibayar_at, created_at)) = ?", [today])
      .whereIn("dp_status", ["sudah_bayar", "dipotong_treatment", "hangus"])
      .sum("dp_nominal as total")
      .first();

    const totalOmzetVal = parseFloat(omzetTrxTotal?.total || 0);
    const omzetHariIniVal = parseFloat(omzetToday?.total || 0) + parseFloat(dpReceivedToday?.total || 0);

    // Total Transaksi
    const trxCountTotal = await DB("trx_transaksi")
      .where("kode_cabang", kodeCabang)
      .whereIn("status", ["lunas", "selesai"])
      .count("id as total")
      .first();

    const trxCountToday = await DB("trx_transaksi")
      .where("kode_cabang", kodeCabang)
      .whereIn("status", ["lunas", "selesai"])
      .whereRaw("DATE(tanggal_transaksi) = ?", [today])
      .count("id as total")
      .first();

    // 5. Kunjungan Hari Ini & Total
    const kunjunganToday = await DB("trx_kunjungan")
      .where("kode_cabang", kodeCabang)
      .whereRaw("DATE(tanggal_kunjungan) = ?", [today])
      .count("id as total")
      .first();

    const kunjunganTotal = await DB("trx_kunjungan")
      .where("kode_cabang", kodeCabang)
      .count("id as total")
      .first();

    // 6. Total Pasien Terdaftar
    const totalPasien = await DB("mst_pasien")
      .where("kode_cabang", kodeCabang)
      .count("id as total")
      .first();

    const pasienBaruToday = await DB("mst_pasien")
      .where("kode_cabang", kodeCabang)
      .whereRaw("DATE(created_at) = ?", [today])
      .count("id as total")
      .first();

    // 7. Karyawan & Dokter di Cabang Ini
    const stafList = await DB("mst_karyawan")
      .where("kode_cabang", kodeCabang)
      .select("id", "kode_karyawan", "nama", "jabatan", "no_hp", "email", "status", "no_sip")
      .orderBy("nama", "asc");

    const dokterCount = stafList.filter(s => (s.jabatan || "").toLowerCase().includes("dokter")).length;
    const beauticianCount = stafList.filter(s => (s.jabatan || "").toLowerCase().includes("terapis") || (s.jabatan || "").toLowerCase().includes("beautician")).length;

    // 8. Ruangan di Cabang Ini
    const ruanganList = await DB("mst_ruangan")
      .where("kode_cabang", kodeCabang)
      .select("id", "kode_ruangan", "nama_ruangan", "is_konsultasi", "status")
      .orderBy("id", "asc");

    // 9. Metode Pembayaran Breakdown di Cabang Ini
    const metodeBreakdown = await DB("trx_transaksi")
      .where("kode_cabang", kodeCabang)
      .whereIn("status", ["lunas", "selesai"])
      .select("metode_bayar")
      .sum("total_bayar as total")
      .count("id as count")
      .groupBy("metode_bayar");

    // 10. Shift Kasir Aktif di Cabang Ini
    const activeShift = await DB("trx_kasir_shift")
      .where("kode_cabang", kodeCabang)
      .where("status", "open")
      .orderBy("id", "desc")
      .first();

    // 11. Top Treatments di Cabang Ini
    const topTreatments = await DB("trx_detail_transaksi as dt")
      .leftJoin("mst_layanan as l", "dt.kode_layanan", "l.kode_layanan")
      .where("dt.kode_cabang", kodeCabang)
      .whereNotNull("dt.kode_layanan")
      .select(DB.raw("COALESCE(l.nama, dt.kode_layanan) as nama"))
      .count("dt.id as count")
      .sum("dt.subtotal as total_omzet")
      .groupBy(DB.raw("COALESCE(l.nama, dt.kode_layanan)"))
      .orderBy("count", "desc")
      .limit(5);

    // 12. Trend 7 Hari Terakhir
    const dailyTrend = await DB("trx_transaksi")
      .where("kode_cabang", kodeCabang)
      .whereIn("status", ["lunas", "selesai"])
      .select(DB.raw("DATE(tanggal_transaksi) as tanggal"))
      .sum("total_bayar as omzet")
      .count("id as transaksi")
      .groupBy(DB.raw("DATE(tanggal_transaksi)"))
      .orderBy("tanggal", "desc")
      .limit(7);

    // 13. LIVE ACTIVITY FEED (Kunjungan, Transaksi, Booking, Shift Kasir)
    // a. Kunjungan terbaru
    const recentKunjungan = await DB("trx_kunjungan as k")
      .leftJoin("mst_pasien as p", "k.no_rm", "p.no_rm")
      .where("k.kode_cabang", kodeCabang)
      .select(
        "k.kode_kunjungan as kode",
        "k.status",
        "k.jam_datang",
        "k.tanggal_kunjungan",
        "k.created_at",
        "p.nama as nama_pasien",
        "k.no_rm"
      )
      .orderBy("k.id", "desc")
      .limit(20);

    // b. Transaksi terbaru
    const recentTransaksi = await DB("trx_transaksi as t")
      .leftJoin("mst_pasien as p", "t.no_rm", "p.no_rm")
      .where("t.kode_cabang", kodeCabang)
      .select(
        "t.kode_transaksi as kode",
        "t.total_bayar",
        "t.metode_bayar",
        "t.status",
        "t.tanggal_transaksi",
        "t.created_at",
        "p.nama as nama_pasien",
        "t.no_rm"
      )
      .orderBy("t.id", "desc")
      .limit(20);

    // c. Booking terbaru
    const recentBooking = await DB("trx_booking as b")
      .leftJoin("mst_pasien as p", "b.no_rm", "p.no_rm")
      .where("b.kode_cabang", kodeCabang)
      .select(
        "b.kode_booking as kode",
        "b.jenis_layanan",
        "b.status",
        "b.tanggal_booking",
        "b.jam_booking",
        "b.total_biaya",
        "b.created_at",
        "p.nama as nama_pasien",
        "b.no_rm"
      )
      .orderBy("b.id", "desc")
      .limit(20);

    // Gabungkan menjadi satu activity timeline yang rapi
    const activities = [
      ...recentTransaksi.map(t => ({
        id: `trx-${t.kode}`,
        kategori: "transaksi",
        judul: `Transaksi Pembayaran ${t.kode}`,
        deskripsi: `${t.nama_pasien || 'Pasien Umum'} (${t.no_rm || '-'}) — Pembayaran Rp ${Number(t.total_bayar || 0).toLocaleString('id-ID')} via ${(t.metode_bayar || 'Tunai').toUpperCase()}`,
        status: t.status,
        waktu: t.created_at || t.tanggal_transaksi,
        badge: "TRANSAKSI",
        badgeSeverity: t.status === "lunas" ? "success" : "warning",
      })),
      ...recentKunjungan.map(k => ({
        id: `kj-${k.kode}`,
        kategori: "kunjungan",
        judul: `Kunjungan Pasien ${k.kode}`,
        deskripsi: `${k.nama_pasien || 'Pasien'} (${k.no_rm || '-'}) — Jam Datang: ${k.jam_datang || '-'}`,
        status: k.status,
        waktu: k.created_at || k.tanggal_kunjungan,
        badge: "KUNJUNGAN",
        badgeSeverity: k.status === "selesai" ? "info" : "warning",
      })),
      ...recentBooking.map(b => ({
        id: `bk-${b.kode}`,
        kategori: "booking",
        judul: `Reservasi Booking ${b.kode}`,
        deskripsi: `${b.nama_pasien || 'Pasien'} (${b.no_rm || '-'}) — Layanan: ${b.jenis_layanan || 'Treatment'} (Jadwal: ${b.tanggal_booking ? String(b.tanggal_booking).slice(0, 10) : '-'} ${b.jam_booking || ''})`,
        status: b.status,
        waktu: b.created_at || b.tanggal_booking,
        badge: "BOOKING",
        badgeSeverity: "primary",
      })),
    ];

    // Urutkan dari yang paling baru
    activities.sort((a, b) => new Date(b.waktu).getTime() - new Date(a.waktu).getTime());

    return res.status(200).json({
      status: status.SUKSES,
      message: "Data detail aktivitas cabang berhasil dimuat",
      data: {
        cabang,
        all_cabang: allBranches,
        managers,
        kpi: {
          total_omzet: totalOmzetVal,
          omzet_hari_ini: omzetHariIniVal,
          total_transaksi: parseInt(trxCountTotal?.total || 0, 10),
          transaksi_hari_ini: parseInt(trxCountToday?.total || 0, 10),
          total_kunjungan: parseInt(kunjunganTotal?.total || 0, 10),
          kunjungan_hari_ini: parseInt(kunjunganToday?.total || 0, 10),
          total_pasien: parseInt(totalPasien?.total || 0, 10),
          pasien_baru_hari_ini: parseInt(pasienBaruToday?.total || 0, 10),
          total_staf: stafList.length,
          total_dokter: dokterCount,
          total_beautician: beauticianCount,
          total_ruangan: ruanganList.length,
        },
        metode_bayar: metodeBreakdown || [],
        top_treatment: topTreatments || [],
        daily_trend: dailyTrend || [],
        active_shift: activeShift || null,
        staf_list: stafList || [],
        ruangan_list: ruanganList || [],
        activities: activities.slice(0, 40),
      },
    });
  } catch (err) {
    console.error("CABANG_DETAIL_ERR:", err);
    Logging(err, { file: "dashboard_routes.js", func: "cabang-detail", request: body });
    return res.status(500).json({ status: status.BAD_REQUEST, message: err.message });
  }
});

/**
 * GET & POST /master/dashboard/perbandingan-cabang
 * Khusus Superadmin: Mengambil komparasi performa dan metrik seluruh cabang
 * Params/Body: periode = 'today' | '7d' | '30d' | 'this_month' | 'all'
 */
const perbandinganCabangHandler = async (req, res) => {
  const oPayload = { ...req.query, ...req.body };
  const role = (req?.auth?.role || oPayload.role || "").toLowerCase();
  const isSuperAdmin = role === "superadmin" || role === "admin_pusat" || role === "dev" || req?.auth?.is_superadmin;

  if (!isSuperAdmin) {
    return res.status(403).json({
      status: status.GAGAL,
      message: "Akses ditolak: Data perbandingan cabang hanya dapat diakses oleh Superadmin.",
    });
  }

  const periode = oPayload.periode || "today";
  try {
    const todayStr = formatDateSystem(new Date(), "yyyy-MM-dd");
    let startDate = null;
    let endDate = todayStr;

    if (periode === "today") {
      startDate = todayStr;
      endDate = todayStr;
    } else if (periode === "7d") {
      const d = new Date();
      d.setDate(d.getDate() - 6);
      startDate = formatDateSystem(d, "yyyy-MM-dd");
    } else if (periode === "30d") {
      const d = new Date();
      d.setDate(d.getDate() - 29);
      startDate = formatDateSystem(d, "yyyy-MM-dd");
    } else if (periode === "this_month") {
      startDate = `${todayStr.slice(0, 7)}-01`;
    } else if (periode === "all") {
      startDate = null;
      endDate = null;
    }

    // 1. Ambil seluruh cabang
    const allBranches = await DB("mst_cabang")
      .select("id", "kode_cabang", "nama_cabang", "alamat", "no_telp", "status")
      .orderBy("id", "asc");
    const branchCodes = allBranches.map((b) => b.kode_cabang);

    // 2. Omzet & Transaksi Pelunasan Kasir
    let qTrx = DB("trx_transaksi")
      .whereIn("kode_cabang", branchCodes)
      .whereIn("status", ["lunas", "selesai"]);
    if (startDate) qTrx.whereRaw("DATE(tanggal_transaksi) >= ?", [startDate]);
    if (endDate) qTrx.whereRaw("DATE(tanggal_transaksi) <= ?", [endDate]);

    const trxByBranch = await qTrx
      .select("kode_cabang")
      .sum("total_bayar as omzet")
      .count("id as total_transaksi")
      .groupBy("kode_cabang");

    const trxMap = {};
    trxByBranch.forEach((r) => {
      trxMap[r.kode_cabang] = {
        omzet: parseFloat(r.omzet || 0),
        transaksi: parseInt(r.total_transaksi || 0, 10),
      };
    });

    // 3. Omzet DP Booking (bila ada)
    let qDp = DB("trx_booking")
      .whereIn("kode_cabang", branchCodes)
      .whereIn("dp_status", ["sudah_bayar", "dipotong_treatment", "hangus"]);
    if (startDate) qDp.whereRaw("DATE(COALESCE(dp_dibayar_at, created_at)) >= ?", [startDate]);
    if (endDate) qDp.whereRaw("DATE(COALESCE(dp_dibayar_at, created_at)) <= ?", [endDate]);

    const dpByBranch = await qDp
      .select("kode_cabang")
      .sum("dp_nominal as omzet")
      .groupBy("kode_cabang");

    const dpMap = {};
    dpByBranch.forEach((r) => {
      dpMap[r.kode_cabang] = parseFloat(r.omzet || 0);
    });

    // 4. Total Pasien Terdaftar
    const pasienByBranch = await DB("mst_pasien")
      .whereIn("kode_cabang", branchCodes)
      .select("kode_cabang")
      .count("no_rm as total_pasien")
      .groupBy("kode_cabang");

    const pasienMap = {};
    pasienByBranch.forEach((p) => {
      pasienMap[p.kode_cabang] = parseInt(p.total_pasien || 0, 10);
    });

    // 5. Kunjungan Hari Ini & Kunjungan Periode
    const kunjunganTodayByBranch = await DB("trx_kunjungan")
      .whereIn("kode_cabang", branchCodes)
      .whereRaw("DATE(tanggal_kunjungan) = ?", [todayStr])
      .select("kode_cabang")
      .count("id as total")
      .groupBy("kode_cabang");

    const kunjunganTodayMap = {};
    kunjunganTodayByBranch.forEach((k) => {
      kunjunganTodayMap[k.kode_cabang] = parseInt(k.total || 0, 10);
    });

    // 6. Staf Aktif (Dokter & Beautician/Terapis)
    const stafByBranch = await DB("mst_karyawan")
      .whereIn("kode_cabang", branchCodes)
      .where("status", "aktif")
      .select(
        "kode_cabang",
        DB.raw("COUNT(id) as total_staf"),
        DB.raw("SUM(CASE WHEN LOWER(jabatan) LIKE '%dokter%' THEN 1 ELSE 0 END) as total_dokter"),
        DB.raw("SUM(CASE WHEN LOWER(jabatan) LIKE '%terapis%' OR LOWER(jabatan) LIKE '%beautician%' THEN 1 ELSE 0 END) as total_beautician")
      )
      .groupBy("kode_cabang");

    const stafMap = {};
    stafByBranch.forEach((s) => {
      stafMap[s.kode_cabang] = {
        total_staf: parseInt(s.total_staf || 0, 10),
        total_dokter: parseInt(s.total_dokter || 0, 10),
        total_beautician: parseInt(s.total_beautician || 0, 10),
      };
    });

    // 7. Status Shift Kasir Hari Ini
    const openShifts = await DB("trx_kasir_shift")
      .where("status", "open")
      .whereIn("kode_cabang", branchCodes)
      .select("kode_cabang", "user_code", "created_at");

    const shiftMap = {};
    openShifts.forEach((s) => {
      shiftMap[s.kode_cabang] = true;
    });

    // 8. Komposisi Metode Pembayaran (Tunai, QRIS, Debit)
    let qMetodeTrx = DB("trx_transaksi")
      .whereIn("kode_cabang", branchCodes)
      .whereIn("status", ["lunas", "selesai"]);
    if (startDate) qMetodeTrx.whereRaw("DATE(tanggal_transaksi) >= ?", [startDate]);
    if (endDate) qMetodeTrx.whereRaw("DATE(tanggal_transaksi) <= ?", [endDate]);

    const metodeTrxRows = await qMetodeTrx
      .select("kode_cabang", DB.raw("LOWER(TRIM(metode_bayar)) as metode"))
      .sum("total_bayar as nominal")
      .groupBy("kode_cabang", DB.raw("LOWER(TRIM(metode_bayar))"));

    let qMetodeDp = DB("trx_booking")
      .whereIn("kode_cabang", branchCodes)
      .whereIn("dp_status", ["sudah_bayar", "dipotong_treatment", "hangus"]);
    if (startDate) qMetodeDp.whereRaw("DATE(COALESCE(dp_dibayar_at, created_at)) >= ?", [startDate]);
    if (endDate) qMetodeDp.whereRaw("DATE(COALESCE(dp_dibayar_at, created_at)) <= ?", [endDate]);

    const metodeDpRows = await qMetodeDp
      .select("kode_cabang", DB.raw("LOWER(TRIM(metode_pembayaran_dp)) as metode"))
      .sum("dp_nominal as nominal")
      .groupBy("kode_cabang", DB.raw("LOWER(TRIM(metode_pembayaran_dp))"));

    const normalizeMethodName = (m) => {
      const s = (m || "").toLowerCase();
      if (s.includes("qris")) return "QRIS";
      if (s.includes("tunai") || s.includes("cash")) return "Tunai";
      if (s.includes("debit") || s.includes("transfer") || s.includes("bank")) return "Debit";
      return "Lainnya";
    };

    const branchMetodeMap = {};
    branchCodes.forEach((code) => {
      branchMetodeMap[code] = { Tunai: 0, QRIS: 0, Debit: 0, Lainnya: 0 };
    });

    [...metodeTrxRows, ...metodeDpRows].forEach((row) => {
      const code = row.kode_cabang;
      if (branchMetodeMap[code]) {
        const cat = normalizeMethodName(row.metode);
        branchMetodeMap[code][cat] = (branchMetodeMap[code][cat] || 0) + parseFloat(row.nominal || 0);
      }
    });

    // 9. Top 5 Treatment per Cabang
    let qTreatment = DB("trx_detail_antrian_layanan as dal")
      .join("trx_antrian_layanan as al", "dal.kode_antrian_layanan", "al.kode_antrian_layanan")
      .whereIn("al.kode_cabang", branchCodes)
      .whereNotNull("dal.nama_layanan")
      .where("dal.nama_layanan", "!=", "");
    if (startDate) qTreatment.whereRaw("DATE(al.created_at) >= ?", [startDate]);
    if (endDate) qTreatment.whereRaw("DATE(al.created_at) <= ?", [endDate]);

    const treatmentRows = await qTreatment
      .select("al.kode_cabang", "dal.nama_layanan")
      .count("dal.id as total_sesi")
      .groupBy("al.kode_cabang", "dal.nama_layanan")
      .orderBy(DB.raw("COUNT(dal.id)"), "desc");

    const branchTreatmentMap = {};
    branchCodes.forEach((code) => {
      branchTreatmentMap[code] = [];
    });
    treatmentRows.forEach((tr) => {
      const code = tr.kode_cabang;
      if (branchTreatmentMap[code] && branchTreatmentMap[code].length < 5) {
        branchTreatmentMap[code].push({
          nama_layanan: tr.nama_layanan,
          total_sesi: parseInt(tr.total_sesi || 0, 10),
        });
      }
    });

    // 10. Agregasi Total & Perankingan
    let totalOmzetAll = 0;
    let totalPasienAll = 0;
    let totalKunjunganTodayAll = 0;
    let totalTransaksiAll = 0;
    let totalStafAll = 0;

    const branchResults = allBranches.map((b) => {
      const omzetTrx = trxMap[b.kode_cabang]?.omzet || 0;
      const omzetDp = dpMap[b.kode_cabang] || 0;
      const totalOmzet = omzetTrx + omzetDp;
      const transaksi = trxMap[b.kode_cabang]?.transaksi || 0;
      const pasien = pasienMap[b.kode_cabang] || 0;
      const kunjunganToday = kunjunganTodayMap[b.kode_cabang] || 0;
      const stafInfo = stafMap[b.kode_cabang] || { total_staf: 0, total_dokter: 0, total_beautician: 0 };
      const hasShift = !!shiftMap[b.kode_cabang];

      totalOmzetAll += totalOmzet;
      totalPasienAll += pasien;
      totalKunjunganTodayAll += kunjunganToday;
      totalTransaksiAll += transaksi;
      totalStafAll += stafInfo.total_staf;

      return {
        id: b.id,
        kode_cabang: b.kode_cabang,
        nama_cabang: b.nama_cabang,
        alamat: b.alamat,
        no_telp: b.no_telp,
        status: b.status,
        total_omzet: totalOmzet,
        total_transaksi: transaksi,
        total_pasien: pasien,
        kunjungan_hari_ini: kunjunganToday,
        total_staf: stafInfo.total_staf,
        total_dokter: stafInfo.total_dokter,
        total_beautician: stafInfo.total_beautician,
        status_shift: hasShift ? "Shift Aktif" : "Tutup",
        has_active_shift: hasShift,
        metode_komposisi: branchMetodeMap[b.kode_cabang] || { Tunai: 0, QRIS: 0, Debit: 0 },
        top_treatments: branchTreatmentMap[b.kode_cabang] || [],
      };
    });

    // Hitung persentase kontribusi & perankingan
    const sortedForRank = [...branchResults].sort((a, b) => b.total_omzet - a.total_omzet);
    const rankMap = {};
    sortedForRank.forEach((item, idx) => {
      rankMap[item.kode_cabang] = idx + 1;
    });

    const enrichedBranches = branchResults.map((b) => {
      const pct = totalOmzetAll > 0 ? parseFloat(((b.total_omzet / totalOmzetAll) * 100).toFixed(1)) : 0;
      const rank = rankMap[b.kode_cabang] || 1;
      return {
        ...b,
        persentase_kontribusi: pct,
        rank,
        is_top_performer: rank === 1 && b.total_omzet > 0,
      };
    });

    const topBranchObj = enrichedBranches.find((b) => b.is_top_performer) || enrichedBranches[0] || null;
    const topBranch = topBranchObj?.nama_cabang || "-";

    // Chart Data Preparation
    const chartLabels = enrichedBranches.map((b) => b.nama_cabang.replace(/^Klinik\s+/i, ""));
    const chartOmzet = {
      labels: chartLabels,
      values: enrichedBranches.map((b) => b.total_omzet),
    };

    const chartMetode = {
      labels: chartLabels,
      datasets: [
        {
          label: "Tunai",
          data: enrichedBranches.map((b) => b.metode_komposisi.Tunai || 0),
          backgroundColor: "#34d399",
          borderRadius: 6,
        },
        {
          label: "QRIS",
          data: enrichedBranches.map((b) => b.metode_komposisi.QRIS || 0),
          backgroundColor: "#10b981",
          borderRadius: 6,
        },
        {
          label: "Debit",
          data: enrichedBranches.map((b) => b.metode_komposisi.Debit || 0),
          backgroundColor: "#B3873F",
          borderRadius: 6,
        },
      ],
    };

    return res.status(200).json({
      status: status.SUKSES,
      message: "Data perbandingan semua cabang berhasil dimuat",
      datetime: formatDateSystem(),
      data: {
        periode,
        tanggal_mulai: startDate,
        tanggal_akhir: endDate,
        branches: enrichedBranches,
        cabang: enrichedBranches,
        summary: {
          total_cabang: enrichedBranches.length,
          total_omzet: totalOmzetAll,
          total_pasien: totalPasienAll,
          total_kunjungan_hari_ini: totalKunjunganTodayAll,
          total_transaksi: totalTransaksiAll,
          total_staf: totalStafAll,
          top_cabang: topBranchObj ? {
            kode_cabang: topBranchObj.kode_cabang,
            nama_cabang: topBranchObj.nama_cabang,
            omzet: topBranchObj.total_omzet,
          } : null,
          top_cabang_nama: topBranch,
        },
        chart_omzet: chartOmzet,
        chart_metode: chartMetode,
      },
    });
  } catch (err) {
    console.error("PERBANDINGAN_CABANG_ERR:", err);
    Logging(err, { file: "dashboard_routes.js", func: "perbandingan-cabang", request: oPayload });
    return res.status(500).json({ status: status.BAD_REQUEST, message: err.message });
  }
};

router.get("/perbandingan-cabang", perbandinganCabangHandler);
router.post("/perbandingan-cabang", perbandinganCabangHandler);

export default router;
