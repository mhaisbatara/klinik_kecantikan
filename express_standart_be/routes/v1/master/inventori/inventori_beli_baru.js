import express from "express";
import Joi from "joi";
import DB from "../../../../core/config/knex.js";
import { formatDateSystem } from "../../components/tools/date_tools.js";
import { Logging, ChangesLog, validatePayload } from "../../components/tools/servertool.js";
import { status } from "../../components/tools/general.js";
import { getBranchScope } from "../../components/tools/branch_scope.js";
import { syncProdukBatch } from "./batch_helper.js";

const router = express.Router();

router.post("/", async (req, res) => {
  const oPayload = req.body;
  const username = req?.auth?.username || "system";
  const branchCode = getBranchScope(req, oPayload.kode_cabang) || req?.auth?.kode_cabang || "CBG-001";

  try {
    const cValidation = await validatePayload(
      {
        kode_supplier: Joi.string().required().label("Supplier"),
        kode_kategori_produk: Joi.string().required().label("Kategori Produk"),
        nama: Joi.string().max(100).required().label("Nama Produk"),
        satuan: Joi.string().max(20).required().label("Satuan"),
        harga_beli: Joi.number().min(0).required().label("Harga Beli Satuan"),
        harga_jual: Joi.number().min(0).required().label("Harga Jual Satuan"),
        stok_minimum: Joi.number().integer().min(0).optional().default(5).label("Stok Minimum"),
        qty_beli: Joi.number().integer().min(1).required().label("Jumlah Pembelian (Qty)"),
        no_batch: Joi.string().max(50).required().label("No. Batch"),
        tanggal_kadaluarsa: Joi.string().required().label("Tanggal Kadaluarsa"),
        tanggal: Joi.string().optional().label("Tanggal Pembelian"),
      },
      { "any.required": "{#label} wajib diisi", "string.empty": "{#label} tidak boleh kosong" },
      oPayload,
      { uniqueField: ["nama"], table: "mst_produk", allowUnknown: true }
    );

    if (cValidation) {
      return res.status(422).json({ status: status.BAD_REQUEST, message: cValidation, datetime: formatDateSystem() });
    }

    let resultData = {};

    await DB.transaction(async (trx) => {
      // 1. Verifikasi Supplier
      let qSup = trx("mst_supplier").where("kode_supplier", oPayload.kode_supplier);
      if (branchCode) qSup = qSup.andWhere("kode_cabang", branchCode);
      const supplier = await qSup.first();
      if (!supplier) {
        const err = new Error("Data supplier tidak ditemukan");
        err.statusCode = 404;
        throw err;
      }

      // 2. Generate kode_produk unik (PRD-XXX)
      const allPrd = await trx("mst_produk").where("kode_produk", "like", "PRD-%").select("kode_produk");
      let maxNum = 0;
      for (const p of allPrd) {
        const num = parseInt(p.kode_produk.replace("PRD-", ""), 10);
        if (!isNaN(num) && num > maxNum) maxNum = num;
      }
      const kodeProduk = `PRD-${String(maxNum + 1).padStart(3, "0")}`;

      const qtyBeli = parseInt(oPayload.qty_beli, 10);
      const hargaBeli = parseFloat(oPayload.harga_beli);
      const hargaJual = parseFloat(oPayload.harga_jual);
      const stokMin = parseInt(oPayload.stok_minimum ?? 5, 10);
      const totalPo = qtyBeli * hargaBeli;
      const tglPo = oPayload.tanggal || new Date().toISOString().slice(0, 10);
      const tglExp = String(oPayload.tanggal_kadaluarsa).slice(0, 10);
      const noBatch = oPayload.no_batch.trim();

      // 3. Simpan produk baru ke mst_produk
      const oProduk = {
        kode_cabang: branchCode,
        kode_produk: kodeProduk,
        kode_kategori_produk: oPayload.kode_kategori_produk,
        kode_supplier: oPayload.kode_supplier,
        nama: oPayload.nama,
        satuan: oPayload.satuan,
        harga_beli: hargaBeli,
        harga_jual: hargaJual,
        stok_minimum: stokMin,
        stok_tersedia: qtyBeli,
        no_batch: noBatch,
        tanggal_kadaluarsa: tglExp,
        status: "aktif",
        tz: oPayload.tz || "UTC",
        created_by: username,
        created_at: formatDateSystem(),
        updated_by: username,
        updated_at: formatDateSystem(),
      };
      await trx("mst_produk").insert(oProduk);

      // 4. Generate kode_po unik (PO-YYYYMMDD-XXXX)
      const todayStr = tglPo.replace(/-/g, "");
      const existingPos = await trx("trx_purchase_order").where("kode_po", "like", `PO-${todayStr}-%`).select("kode_po");
      let maxPoNum = 0;
      for (const p of existingPos) {
        const parts = p.kode_po.split("-");
        const n = parseInt(parts[parts.length - 1], 10);
        if (!isNaN(n) && n > maxPoNum) maxPoNum = n;
      }
      const nextPoNum = maxPoNum + 1;
      const kodePo = `PO-${todayStr}-${String(nextPoNum).padStart(3, "0")}`;

      // 5. Simpan transaksi purchase order
      const oPo = {
        kode_cabang: branchCode,
        kode_po: kodePo,
        kode_supplier: oPayload.kode_supplier,
        tanggal_po: tglPo,
        total_po: totalPo,
        status: "diterima",
        tz: oPayload.tz || "UTC",
        created_by: username,
        created_at: formatDateSystem(),
        updated_by: username,
        updated_at: formatDateSystem(),
      };
      await trx("trx_purchase_order").insert(oPo);

      // 6. Generate kode_batch unik & Simpan ke mst_produk_batch
      const existingBatches = await trx("mst_produk_batch").where("kode_batch", "like", `BTC-${todayStr}-%`).select("kode_batch");
      let maxBatchNum = 0;
      for (const b of existingBatches) {
        const parts = b.kode_batch.split("-");
        const n = parseInt(parts[parts.length - 1], 10);
        if (!isNaN(n) && n > maxBatchNum) maxBatchNum = n;
      }
      const nextBatchNum = maxBatchNum + 1;
      const kodeBatch = `BTC-${todayStr}-${String(nextBatchNum).padStart(3, "0")}`;

      const oBatch = {
        kode_batch: kodeBatch,
        kode_produk: kodeProduk,
        no_batch: noBatch,
        tanggal_kadaluarsa: tglExp,
        stok_masuk: qtyBeli,
        stok_sisa: qtyBeli,
        harga_beli_satuan: hargaBeli,
        kode_supplier: oPayload.kode_supplier,
        kode_po: kodePo,
        is_legacy_estimate: 0,
        status: "aktif",
        catatan: `Batch pengadaan awal (${kodePo})`,
        tz: oPayload.tz || "UTC",
        created_by: username,
        created_at: formatDateSystem(),
        updated_by: username,
        updated_at: formatDateSystem(),
        kode_cabang: branchCode,
      };
      await trx("mst_produk_batch").insert(oBatch);

      // 7. Simpan detail purchase order
      const kodeDetailPo = `DPO-${todayStr}-${String(nextPoNum).padStart(3, "0")}-1`;
      const oDetailPo = {
        kode_detail_po: kodeDetailPo,
        kode_po: kodePo,
        kode_produk: kodeProduk,
        kode_batch: kodeBatch,
        no_batch: noBatch,
        tanggal_kadaluarsa: tglExp,
        qty: qtyBeli,
        harga_satuan: hargaBeli,
        subtotal: totalPo,
        tz: oPayload.tz || "UTC",
        created_by: username,
        created_at: formatDateSystem(),
        updated_by: username,
        updated_at: formatDateSystem(),
      };
      await trx("trx_detail_purchase_order").insert(oDetailPo);

      // 8. Simpan log mutasi stok masuk (trx_stok_movement)
      const existingMovs = await trx("trx_stok_movement").where("kode_stok_movement", "like", `MOV-${todayStr}-%`).select("kode_stok_movement");
      let maxMovNum = 0;
      for (const m of existingMovs) {
        const parts = m.kode_stok_movement.split("-");
        const n = parseInt(parts[parts.length - 1], 10);
        if (!isNaN(n) && n > maxMovNum) maxMovNum = n;
      }
      const nextMovNum = maxMovNum + 1;
      const kodeMovement = `MOV-${todayStr}-${String(nextMovNum).padStart(3, "0")}`;

      const oMovement = {
        kode_cabang: branchCode,
        kode_stok_movement: kodeMovement,
        kode_produk: kodeProduk,
        kode_batch: kodeBatch,
        jenis_movement: "masuk",
        referensi: kodePo,
        qty: qtyBeli,
        stok_sebelum: 0,
        stok_sesudah: qtyBeli,
        tanggal: formatDateSystem(),
        tz: oPayload.tz || "UTC",
        created_by: username,
        created_at: formatDateSystem(),
        updated_by: username,
        updated_at: formatDateSystem(),
      };
      await trx("trx_stok_movement").insert(oMovement);

      // 9. Sinkronisasi status & data master
      await syncProdukBatch(kodeProduk, trx);

      // 10. Catat ChangesLog
      await ChangesLog(
        {
          description: `Pengadaan Produk Baru ${kodeProduk} dari Supplier ${oPayload.kode_supplier} (${kodePo} - Batch: ${noBatch})`,
          tableName: "mst_produk",
          referenceCode: kodeProduk,
          action: "CREATE",
          dataBefore: null,
          dataAfter: { ...oProduk, batch: oBatch, po: oPo, detail: oDetailPo, movement: oMovement },
          user: username,
          tz: oPayload.tz || "UTC",
        },
        trx
      );

      resultData = {
        kode_produk: kodeProduk,
        kode_batch: kodeBatch,
        no_batch: noBatch,
        tanggal_kadaluarsa: tglExp,
        kode_po: kodePo,
        nama_produk: oPayload.nama,
        stok_tersedia: qtyBeli,
        total_po: totalPo,
      };
    });

    return res.status(200).json({
      status: status.SUKSES,
      message: `Produk baru "${oPayload.nama}" berhasil dibeli (Batch: ${resultData.no_batch}, Exp: ${resultData.tanggal_kadaluarsa}) dan masuk ke inventori.`,
      datetime: formatDateSystem(),
      data: resultData,
    });
  } catch (error) {
    if (error.statusCode === 404) {
      return res.status(404).json({ status: status.NOT_FOUND, message: error.message, datetime: formatDateSystem() });
    }
    const oResult = { status: status.BAD_REQUEST, message: error.message || "Sistem sedang maintenance", datetime: formatDateSystem() };
    Logging(error, { file: "/master/inventori/inventori_beli_baru.js", func: "beli_baru", request: oPayload, response: oResult, user: username });
    return res.status(500).json(oResult);
  }
});

export default router;
