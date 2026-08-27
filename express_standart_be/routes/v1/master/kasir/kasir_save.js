/**
 * @project Sistem Klinik Kecantikan
 * @file kasir_save.js
 * @description Endpoint simpan draft transaksi kasir (create atau update)
 */
import express from "express";
import DB from "../../../../core/config/knex.js";
import { formatDateSystem } from "../../components/tools/date_tools.js";
import { Logging } from "../../components/tools/servertool.js";
import { status } from "../../components/tools/general.js";

const router = express.Router();

// Helper generate kode
const generateKode = async (prefix, table, column) => {
  const today = new Date();
  const ymd = today.toISOString().slice(0, 10).replace(/-/g, "");
  const pattern = `${prefix}-${ymd}-%`;
  const last = await DB(table)
    .where(column, "like", pattern)
    .orderBy(column, "desc")
    .select(column)
    .first();
  let seq = 1;
  if (last) {
    const parts = last[column].split("-");
    seq = parseInt(parts[parts.length - 1]) + 1;
  }
  return `${prefix}-${ymd}-${String(seq).padStart(3, "0")}`;
};

router.post("/", async (req, res) => {
  const { body } = req;
  const username = req?.auth?.username || "";
  const tz = body.tz || "Asia/Jakarta";

  const {
    kode_transaksi,       // jika ada = update, jika tidak = create baru
    kode_kunjungan,
    no_rm,
    items = [],           // [{ jenis, kode, nama, qty, harga_satuan, is_from_pendaftaran }]
    kode_promo,           // promo level transaksi (opsional)
    metode_bayar = "tunai",
  } = body;

  if (!no_rm) {
    return res.status(400).json({ status: status.BAD_REQUEST, message: "no_rm pasien wajib diisi", datetime: formatDateSystem() });
  }

  if (!items || items.length === 0) {
    return res.status(400).json({ status: status.BAD_REQUEST, message: "Minimal 1 item transaksi", datetime: formatDateSystem() });
  }

  const trx = await DB.transaction();
  try {
    // 1. Hitung total_harga
    let total_harga = 0;
    items.forEach((item) => {
      total_harga += parseFloat(item.harga_satuan || 0) * parseInt(item.qty || 1);
    });

    // 2. Hitung diskon level transaksi dari promo (mst_promo sederhana)
    let total_diskon = 0;
    let validKodePromo = null;

    if (kode_promo) {
      const promoData = await trx("mst_promo")
        .where("kode_promo", kode_promo)
        .where("status", "aktif")
        .first();

      if (promoData) {
        validKodePromo = promoData.kode_promo;
        const diskon = parseFloat(promoData.nilai_diskon || 0);
        total_diskon = promoData.jenis_diskon === "persen"
          ? (total_harga * diskon) / 100
          : diskon;
        total_diskon = Math.min(total_diskon, total_harga);
      }
    }

    const total_bayar = Math.max(0, total_harga - total_diskon);
    const tanggal_transaksi = new Date().toISOString().slice(0, 10);

    let kode_trx = kode_transaksi;

    if (kode_trx) {
      // UPDATE existing draft
      const existing = await trx("trx_transaksi").where("kode_transaksi", kode_trx).first();
      if (!existing) {
        await trx.rollback();
        return res.status(404).json({ status: status.BAD_REQUEST, message: "Transaksi tidak ditemukan", datetime: formatDateSystem() });
      }
      if (existing.status === "lunas") {
        await trx.rollback();
        return res.status(400).json({ status: status.BAD_REQUEST, message: "Transaksi sudah lunas, tidak bisa diubah", datetime: formatDateSystem() });
      }

      await trx("trx_transaksi").where("kode_transaksi", kode_trx).update({
        kode_kunjungan: kode_kunjungan || existing.kode_kunjungan,
        kode_promo: validKodePromo,
        total_harga,
        total_diskon,
        total_bayar,
        metode_bayar,
        updated_by: username,
        updated_at: DB.fn.now(),
      });

      // Hapus detail lama lalu insert baru
      await trx("trx_detail_transaksi").where("kode_transaksi", kode_trx).delete();
    } else {
      // CREATE baru
      kode_trx = await generateKode("TRX", "trx_transaksi", "kode_transaksi");
      await trx("trx_transaksi").insert({
        kode_transaksi: kode_trx,
        kode_kunjungan: kode_kunjungan || null,
        no_rm,
        kode_promo: validKodePromo,
        tanggal_transaksi,
        total_harga,
        total_diskon,
        total_bayar,
        metode_bayar,
        status: "draft",
        tz,
        created_by: username,
        created_at: DB.fn.now(),
        updated_by: username,
        updated_at: DB.fn.now(),
      });
    }

    // Insert detail items
    const today = new Date().toISOString().slice(0, 10).replace(/-/g, "");

    // Get last DT kode
    const lastDT = await trx("trx_detail_transaksi")
      .where("kode_detail_transaksi", "like", `DT-${today}-%`)
      .orderBy("kode_detail_transaksi", "desc")
      .select("kode_detail_transaksi")
      .first();
    let dtSeq = lastDT ? parseInt(lastDT.kode_detail_transaksi.split("-").pop()) + 1 : 1;

    for (const item of items) {
      const qty = parseInt(item.qty || 1);
      const harga_satuan = parseFloat(item.harga_satuan || 0);
      const subtotal = qty * harga_satuan;
      const kode_detail = `DT-${today}-${String(dtSeq).padStart(3, "0")}`;
      dtSeq++;

      await trx("trx_detail_transaksi").insert({
        kode_detail_transaksi: kode_detail,
        kode_transaksi: kode_trx,
        kode_layanan: item.jenis === "layanan" ? item.kode : null,
        kode_produk: item.jenis === "produk" ? item.kode : null,
        qty,
        harga_satuan,
        subtotal,
        is_from_pendaftaran: item.is_from_pendaftaran ? 1 : 0,
        tz,
        created_by: username,
        created_at: DB.fn.now(),
        updated_by: username,
        updated_at: DB.fn.now(),
      });
    }

    await trx.commit();

    return res.status(200).json({
      status: status.SUKSES,
      message: kode_transaksi ? "Draft transaksi berhasil diperbarui" : "Draft transaksi berhasil dibuat",
      datetime: formatDateSystem(),
      data: {
        kode_transaksi: kode_trx,
        total_harga,
        total_diskon,
        total_bayar,
      },
    });
  } catch (error) {
    await trx.rollback();
    const oResult = {
      status: status.BAD_REQUEST,
      message: "Sistem sedang maintenance harap tunggu sebentar",
      datetime: formatDateSystem(),
    };
    Logging(error, { file: "/master/kasir/kasir_save.js", user: username });
    return res.status(500).json(oResult);
  }
});

export default router;
