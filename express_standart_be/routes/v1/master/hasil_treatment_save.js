/**
 * @copyright (c) 2026 PT Marstech Global (info@marstech.co.id)
 * @project Sistem Klinik Kecantikan
 * @file hasil_treatment_save.js
 * @description Endpoint dokter untuk menyimpan hasil treatment (foto after, catatan, dan daftar produk)
 *              Append foto after & catatan ke rekam medis dan buat/update draft transaksi kasir.
 *              Draft transaksi mencakup:
 *              - Layanan/paket yang dipilih saat pendaftaran (dari trx_detail_antrian_layanan)
 *              - Produk tambahan yang direkomendasikan dokter di ruangan
 *
 * @author Antigravity
 * @created 2026-08-27
 */

import express from "express";
import DB from "../../../core/config/knex.js";
import { formatDateSystem } from "../components/tools/date_tools.js";
import { Logging } from "../components/tools/servertool.js";
import { status } from "../components/tools/general.js";
import { syncRekamMedisPerKunjungan } from "./ruangan/rekam_medis_service.js";

const router = express.Router();

const handleHasilTreatmentSave = async (req, res) => {
  const oPayload = req.body || {};
  const username = req?.auth?.username || "system";

  const {
    kode_kunjungan,
    no_rm,
    kode_rekam_medis,
    kode_ruangan = "",
    nama_ruangan = "Ruangan Treatment",
    foto_after = "",
    catatan = "",
    produk_items = [], // [{ kode_produk, qty }] — produk tambahan dari dokter
    tz = "Asia/Jakarta",
  } = oPayload;

  if (!kode_kunjungan) {
    return res.status(422).json({
      status: status.BAD_REQUEST,
      message: "kode_kunjungan wajib diisi",
      datetime: formatDateSystem(),
    });
  }

  const produkItems = Array.isArray(produk_items) ? produk_items : [];

  try {
    let createdTransaksiKode = "";
    let grandTotal = 0;

    await DB.transaction(async (trx) => {
      const now = new Date();
      const todayYmd = now.toISOString().slice(0, 10);
      const todayStr = todayYmd.replace(/-/g, "");

      // ─── 1. APPEND FOTO AFTER & CATATAN KE REKAM MEDIS ───────────────────────
      let formattedNote = foto_after ? `Foto: After: ${foto_after}` : "";
      if (catatan) {
        formattedNote = formattedNote ? `${formattedNote}\nCatatan: ${catatan}` : `Catatan: ${catatan}`;
      }

      let rmRecord = null;
      if (kode_rekam_medis) {
        rmRecord = await trx("trx_rekam_medis")
          .where("id", kode_rekam_medis)
          .orWhere("kode_kunjungan", kode_kunjungan)
          .first();
      } else {
        rmRecord = await trx("trx_rekam_medis")
          .where("kode_kunjungan", kode_kunjungan)
          .first();
      }

      let mergedCatatan = formattedNote;
      if (rmRecord && rmRecord.catatan_petugas && rmRecord.catatan_petugas.trim()) {
        mergedCatatan = `${rmRecord.catatan_petugas}\n${formattedNote}`;
      }

      await syncRekamMedisPerKunjungan({
        kode_kunjungan,
        kode_ruangan,
        nama_ruangan,
        hasil_form: { foto_after },
        catatan_petugas: mergedCatatan,
        username,
      });

      let resolvedKodeRM = kode_rekam_medis || (rmRecord ? String(rmRecord.id) : null);

      // ─── 2. AMBIL LAYANAN DARI PENDAFTARAN (trx_detail_antrian_layanan) ──────
      // Ambil semua layanan/paket yang terdaftar untuk kunjungan ini
      const layananPendaftaran = await trx("trx_detail_antrian_layanan as dal")
        .join("trx_antrian_layanan as al", "dal.kode_antrian_layanan", "al.kode_antrian_layanan")
        .where("dal.kode_kunjungan", kode_kunjungan)
        .select(
          "dal.kode_layanan",
          "dal.nama_layanan",
          "dal.harga",
          "dal.jenis_layanan"
        );

      // ─── 3. GABUNGKAN LAYANAN PENDAFTARAN + PRODUK DOKTER ────────────────────
      // Buat/update draft transaksi jika ada item (layanan pendaftaran atau produk dokter)
      const hasItems = layananPendaftaran.length > 0 || produkItems.length > 0;

      if (hasItems) {
        // Cek apakah sudah ada transaksi draft untuk kunjungan ini
        let existingTrx = await trx("trx_transaksi")
          .where("kode_kunjungan", kode_kunjungan)
          .where("status", "draft")
          .first();

        if (existingTrx) {
          createdTransaksiKode = existingTrx.kode_transaksi;
          // Update kode_rekam_medis bila ada
          if (resolvedKodeRM) {
            await trx("trx_transaksi")
              .where("kode_transaksi", createdTransaksiKode)
              .update({
                kode_rekam_medis: resolvedKodeRM,
                updated_by: username,
                updated_at: formatDateSystem(),
              });
          }
        } else {
          // Generate kode_transaksi baru
          const prefixTrx = `TRX-${todayStr}-`;
          const lastTrx = await trx("trx_transaksi")
            .where("kode_transaksi", "like", `${prefixTrx}%`)
            .orderBy("id", "desc")
            .first();

          let nextTrxSeq = 1;
          if (lastTrx && lastTrx.kode_transaksi) {
            const parts = lastTrx.kode_transaksi.split("-");
            const num = parseInt(parts[parts.length - 1], 10);
            if (!isNaN(num)) nextTrxSeq = num + 1;
          }
          createdTransaksiKode = `${prefixTrx}${String(nextTrxSeq).padStart(3, "0")}`;

          // Dapatkan no_rm dari kunjungan jika tidak tersedia
          const kunjunganData = await trx("trx_kunjungan")
            .where("kode_kunjungan", kode_kunjungan)
            .select("no_rm")
            .first();
          const resolvedNoRm = no_rm || (kunjunganData ? kunjunganData.no_rm : null);

          const newTrx = {
            kode_transaksi: createdTransaksiKode,
            kode_kunjungan: kode_kunjungan,
            no_rm: resolvedNoRm,
            kode_rekam_medis: resolvedKodeRM || null,
            tanggal_transaksi: todayYmd,
            total_harga: 0,
            total_diskon: 0,
            total_bayar: 0,
            metode_bayar: "tunai",
            status: "draft",
            tz: tz,
            created_by: username,
            created_at: formatDateSystem(),
            updated_by: username,
            updated_at: formatDateSystem(),
          };

          await trx("trx_transaksi").insert(newTrx);
        }

        // ─── 4. HAPUS DETAIL LAMA LALU INSERT ULANG (SYNC PENUH) ─────────────
        // Hapus semua detail lama agar tidak duplikat saat sync ulang
        await trx("trx_detail_transaksi")
          .where("kode_transaksi", createdTransaksiKode)
          .delete();

        // Generate prefix kode detail
        const prefixDetail = `DT-${todayStr}-`;
        const lastDetail = await trx("trx_detail_transaksi")
          .where("kode_detail_transaksi", "like", `${prefixDetail}%`)
          .orderBy("id", "desc")
          .first();

        let nextDetailSeq = 1;
        if (lastDetail && lastDetail.kode_detail_transaksi) {
          const parts = lastDetail.kode_detail_transaksi.split("-");
          const num = parseInt(parts[parts.length - 1], 10);
          if (!isNaN(num)) nextDetailSeq = num + 1;
        }

        // ─── 4a. INSERT LAYANAN DARI PENDAFTARAN ─────────────────────────────
        for (const layanan of layananPendaftaran) {
          const cKodeDetail = `${prefixDetail}${String(nextDetailSeq).padStart(3, "0")}`;
          nextDetailSeq++;

          const hargaSatuan = parseFloat(layanan.harga || 0);

          await trx("trx_detail_transaksi").insert({
            kode_detail_transaksi: cKodeDetail,
            kode_transaksi: createdTransaksiKode,
            kode_layanan: layanan.kode_layanan,
            kode_produk: null,
            qty: 1,
            harga_satuan: hargaSatuan,
            subtotal: hargaSatuan,
            // Tandai bahwa item ini berasal dari pendaftaran (tidak bisa diubah kasir)
            is_from_pendaftaran: 1,
            tz: tz,
            created_by: username,
            created_at: formatDateSystem(),
            updated_by: username,
            updated_at: formatDateSystem(),
          });
        }

        // ─── 4b. INSERT PRODUK DARI DOKTER/TREATMENT ─────────────────────────
        // Fetch harga produk terkini dari mst_produk
        const kodeProdukList = produkItems.map((i) => i.kode_produk).filter(Boolean);
        let produkPriceMap = {};
        if (kodeProdukList.length > 0) {
          const mstProdukList = await trx("mst_produk")
            .whereIn("kode_produk", kodeProdukList)
            .select("kode_produk", "nama", "harga_jual");
          mstProdukList.forEach((p) => {
            produkPriceMap[p.kode_produk] = parseFloat(p.harga_jual || 0);
          });
        }

        for (const item of produkItems) {
          const cKodeDetail = `${prefixDetail}${String(nextDetailSeq).padStart(3, "0")}`;
          nextDetailSeq++;

          const qty = Math.max(1, parseInt(item.qty || 1, 10));
          const hargaSatuan = produkPriceMap[item.kode_produk] !== undefined
            ? produkPriceMap[item.kode_produk]
            : parseFloat(item.harga_jual || item.harga_satuan || 0);
          const subtotal = qty * hargaSatuan;

          await trx("trx_detail_transaksi").insert({
            kode_detail_transaksi: cKodeDetail,
            kode_transaksi: createdTransaksiKode,
            kode_layanan: null,
            kode_produk: item.kode_produk,
            qty: qty,
            harga_satuan: hargaSatuan,
            subtotal: subtotal,
            is_from_pendaftaran: 0,
            tz: tz,
            created_by: username,
            created_at: formatDateSystem(),
            updated_by: username,
            updated_at: formatDateSystem(),
          });
        }

        // ─── 5. RECALCULATE TOTAL ─────────────────────────────────────────────
        const allDetails = await trx("trx_detail_transaksi")
          .where("kode_transaksi", createdTransaksiKode)
          .sum("subtotal as total");

        grandTotal = parseFloat(allDetails[0]?.total || 0);

        await trx("trx_transaksi")
          .where("kode_transaksi", createdTransaksiKode)
          .update({
            total_harga: grandTotal,
            total_bayar: grandTotal,
            updated_by: username,
            updated_at: formatDateSystem(),
          });
      }
    });

    return res.status(200).json({
      status: status.SUKSES,
      message: "Hasil treatment berhasil disimpan dan transaksi draft kasir siap diproses",
      datetime: formatDateSystem(),
      data: {
        kode_kunjungan,
        kode_transaksi: createdTransaksiKode,
        total_bayar: grandTotal,
      },
    });
  } catch (error) {
    Logging(error, {
      file: "/master/hasil_treatment_save.js",
      func: "handleHasilTreatmentSave",
      request: oPayload,
      user: username,
    });
    return res.status(500).json({
      status: status.BAD_REQUEST,
      message: error.message || "Gagal menyimpan hasil treatment",
      datetime: formatDateSystem(),
    });
  }
};

router.post("/", handleHasilTreatmentSave);

export default router;
