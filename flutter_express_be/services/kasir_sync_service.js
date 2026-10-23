import { formatDateSystem } from "../utils/date_tools.js";

/**
 * Sinkronisasi Booking ber-DP ke Draf Transaksi Kasir (trx_transaksi & trx_detail_transaksi).
 * Dijalankan saat booking baru ber-DP dibuat dari mobile atau saat nominal DP diperbarui.
 *
 * @param {import('knex').Knex | import('knex').Knex.Transaction} trx
 * @param {Object} params
 * @param {string} params.kodeBooking
 * @param {string} [params.noRm=""]
 * @param {string} [params.kodeCabang="CBG-001"]
 * @param {number} [params.dpNominal=0]
 * @param {string} [params.metodePembayaranDp=null]
 * @param {string} [params.username="mobile_app"]
 * @param {string} [params.tz="Asia/Jakarta"]
 * @returns {Promise<Object|null>} Object { kode_transaksi, total_harga, dp_nominal, sisa_bayar } atau null jika skip
 */
export const syncBookingToKasirDraft = async (trx, {
  kodeBooking,
  noRm = "",
  kodeCabang = "CBG-001",
  dpNominal = 0,
  metodePembayaranDp = null,
  kodeMetodePembayaran = null,
  username = "mobile_app",
  tz = "Asia/Jakarta",
}) => {
  if (!kodeBooking) return null;

  const todayYmd = new Date().toISOString().slice(0, 10);
  const todayStr = todayYmd.replace(/-/g, "");
  const prefixTrx = `TRX-${todayStr}-`;
  const prefixDetail = `DT-${todayStr}-`;

  // 1. Guard: Jika sudah ada transaksi 'lunas' untuk booking ini, skip
  const lunasTrx = await trx("trx_transaksi")
    .where("kode_booking", kodeBooking)
    .where("status", "lunas")
    .first();

  if (lunasTrx) {
    console.log(`[SYNC_BOOKING_KASIR] Skip: booking ${kodeBooking} sudah memiliki transaksi lunas (${lunasTrx.kode_transaksi}).`);
    return lunasTrx;
  }

  // 2. Ambil data booking untuk validasi
  const bookingRow = await trx("trx_booking")
    .where("kode_booking", kodeBooking)
    .first();

  if (!bookingRow) {
    console.warn(`[SYNC_BOOKING_KASIR] Booking ${kodeBooking} tidak ditemukan. Sinkronisasi dibatalkan.`);
    return null;
  }

  // 3. Ambil detail item booking (layanan/paket)
  let detailBooking = [];
  const hasDetailTable = await trx.schema.hasTable("trx_detail_booking");
  if (hasDetailTable) {
    detailBooking = await trx("trx_detail_booking").where("kode_booking", kodeBooking);
  }

  // 4. Cek apakah draf kasir sudah ada untuk booking ini
  let draftTrx = await trx("trx_transaksi")
    .where("kode_booking", kodeBooking)
    .where("status", "draft")
    .first();

  let createdTransaksiKode = "";
  const resolvedCabang = kodeCabang || bookingRow.kode_cabang || "CBG-001";
  const resolvedNoRm = noRm || bookingRow.no_rm || "";

  if (draftTrx) {
    // Draf sudah ada — hanya update DP & sisa_bayar
    createdTransaksiKode = draftTrx.kode_transaksi;
    await trx("trx_transaksi").where("id", draftTrx.id).update({
      kode_metode_pembayaran: kodeMetodePembayaran || bookingRow.kode_metode_pembayaran || draftTrx.kode_metode_pembayaran,
      updated_at: formatDateSystem(),
    });
  } else {
    // Buat draf baru
    const lastTrx = await trx("trx_transaksi")
      .where("kode_transaksi", "like", `${prefixTrx}%`)
      .orderBy("id", "desc")
      .first();

    let nextTrxSeq = 1;
    if (lastTrx?.kode_transaksi) {
      const parts = lastTrx.kode_transaksi.split("-");
      const num = parseInt(parts[parts.length - 1], 10);
      if (!isNaN(num)) nextTrxSeq = num + 1;
    }
    createdTransaksiKode = `${prefixTrx}${String(nextTrxSeq).padStart(3, "0")}`;

    // Hitung nominal DP dari parameter atau data booking
    const resolvedDp = parseFloat(dpNominal || bookingRow.dp_nominal || 0);

    // Helper normalisasi metode bayar agar sesuai enum('tunai','debit','kredit','qris','transfer')
    const normalizeMetode = (m) => {
      if (!m) return "transfer";
      const s = String(m).toLowerCase().trim();
      if (s === "cash") return "tunai";
      if (["tunai", "debit", "kredit", "qris", "transfer"].includes(s)) return s;
      return "transfer";
    };
    const resolvedMetodeBayar = normalizeMetode(metodePembayaranDp || bookingRow.metode_pembayaran_dp);

    // Ambil nama layanan yang dibooking untuk label item DP
    const bookedServiceNames = detailBooking
      .map((d) => d.nama_layanan)
      .filter(Boolean)
      .join(", ");
    const dpLabel = bookedServiceNames
      ? `Uang Muka (DP) - ${bookedServiceNames}`
      : `Uang Muka Booking (${kodeBooking})`;

    await trx("trx_transaksi").insert({
      kode_cabang: resolvedCabang,
      kode_transaksi: createdTransaksiKode,
      kode_booking: kodeBooking,
      kode_kunjungan: null,
      no_rm: resolvedNoRm,
      kode_rekam_medis: null,
      tanggal_transaksi: todayYmd,
      total_harga: resolvedDp,
      total_diskon: 0,
      total_bayar: resolvedDp,
      dp_nominal: 0,
      metode_pembayaran_dp: metodePembayaranDp || bookingRow.metode_pembayaran_dp || null,
      kode_metode_pembayaran: kodeMetodePembayaran || bookingRow.kode_metode_pembayaran || null,
      sisa_bayar: resolvedDp,
      metode_bayar: resolvedMetodeBayar,
      status: "draft",
      tz: tz || "Asia/Jakarta",
      created_by: username,
      created_at: formatDateSystem(),
      updated_by: username,
      updated_at: formatDateSystem(),
    });

    // 5. Insert 1 baris item Uang Muka (DP) ke trx_detail_transaksi
    const hasDiscountCols = await trx.schema.hasColumn("trx_detail_transaksi", "kode_promo");

    const lastDetail = await trx("trx_detail_transaksi")
      .where("kode_detail_transaksi", "like", `${prefixDetail}%`)
      .orderBy("id", "desc")
      .first();

    let nextDetailSeq = 1;
    if (lastDetail?.kode_detail_transaksi) {
      const parts = lastDetail.kode_detail_transaksi.split("-");
      const num = parseInt(parts[parts.length - 1], 10);
      if (!isNaN(num)) nextDetailSeq = num + 1;
    }

    const firstItem = detailBooking[0] || {};
    const cKodeDetail = `${prefixDetail}${String(nextDetailSeq).padStart(3, "0")}`;

    const insertPayload = {
      kode_cabang: resolvedCabang,
      kode_detail_transaksi: cKodeDetail,
      kode_transaksi: createdTransaksiKode,
      kode_layanan: firstItem.kode_layanan || null,
      kode_produk: null,
      qty: 1,
      harga_satuan: resolvedDp,
      subtotal: resolvedDp,
      is_from_pendaftaran: 1,
      tz: tz || "Asia/Jakarta",
      created_by: username,
      created_at: formatDateSystem(),
      updated_by: username,
      updated_at: formatDateSystem(),
    };

    if (hasDiscountCols) {
      insertPayload.kode_promo = null;
      insertPayload.nama_promo = dpLabel;
      insertPayload.jenis_diskon = "dp_booking";
      insertPayload.nilai_diskon = null;
      insertPayload.diskon = 0;
      insertPayload.subtotal_setelah_diskon = resolvedDp;
    }

    await trx("trx_detail_transaksi").insert(insertPayload);

    return {
      kode_transaksi: createdTransaksiKode,
      total_harga: resolvedDp,
      total_diskon: 0,
      total_bayar: resolvedDp,
      dp_nominal: 0,
      metode_pembayaran_dp: metodePembayaranDp || bookingRow.metode_pembayaran_dp || null,
      sisa_bayar: resolvedDp,
    };
  }

  // Draf sudah ada — sinkronisasi ulang nominal DP
  const resolvedDp = parseFloat(dpNominal || bookingRow.dp_nominal || 0);

  const normalizeMetode = (m) => {
    if (!m) return "transfer";
    const s = String(m).toLowerCase().trim();
    if (s === "cash") return "tunai";
    if (["tunai", "debit", "kredit", "qris", "transfer"].includes(s)) return s;
    return "transfer";
  };
  const resolvedMetodeBayar = normalizeMetode(metodePembayaranDp || bookingRow.metode_pembayaran_dp);

  await trx("trx_transaksi")
    .where("kode_transaksi", createdTransaksiKode)
    .update({
      dp_nominal: 0,
      metode_pembayaran_dp: metodePembayaranDp || draftTrx?.metode_pembayaran_dp || bookingRow.metode_pembayaran_dp || null,
      metode_bayar: resolvedMetodeBayar,
      total_harga: resolvedDp,
      total_diskon: 0,
      total_bayar: resolvedDp,
      sisa_bayar: resolvedDp,
      updated_by: username,
      updated_at: formatDateSystem(),
    });

  const existingDetail = await trx("trx_detail_transaksi")
    .where("kode_transaksi", createdTransaksiKode)
    .first();

  if (existingDetail) {
    const bookedServiceNames = detailBooking
      .map((d) => d.nama_layanan)
      .filter(Boolean)
      .join(", ");
    const dpLabel = bookedServiceNames
      ? `Uang Muka (DP) - ${bookedServiceNames}`
      : `Uang Muka Booking (${kodeBooking})`;

    await trx("trx_detail_transaksi")
      .where("id", existingDetail.id)
      .update({
        harga_satuan: resolvedDp,
        subtotal: resolvedDp,
        nama_promo: dpLabel,
        jenis_diskon: "dp_booking",
        subtotal_setelah_diskon: resolvedDp,
        updated_by: username,
        updated_at: formatDateSystem(),
      });
  }

  return {
    kode_transaksi: createdTransaksiKode,
    total_harga: resolvedDp,
    total_diskon: 0,
    total_bayar: resolvedDp,
    dp_nominal: 0,
    metode_pembayaran_dp: metodePembayaranDp || null,
    sisa_bayar: resolvedDp,
  };
};

/**
 * Batalkan draf kasir jika booking dibatalkan
 */
export const cancelKasirDraftByBooking = async (trx, kodeBooking, username = "mobile_app") => {
  if (!kodeBooking) return null;
  const draftTrx = await trx("trx_transaksi")
    .where("kode_booking", kodeBooking)
    .where("status", "draft")
    .first();

  if (!draftTrx) return null;

  await trx("trx_transaksi")
    .where("id", draftTrx.id)
    .update({
      status: "batal",
      updated_by: username,
      updated_at: formatDateSystem(),
    });

  return draftTrx.kode_transaksi;
};
