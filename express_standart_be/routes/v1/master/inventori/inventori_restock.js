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
        kode_produk: Joi.string().required().label("Produk"),
        qty_masuk: Joi.number().integer().min(1).required().label("Jumlah Restock (Qty)"),
        harga_beli: Joi.number().min(0).required().label("Harga Beli Satuan"),
        no_batch: Joi.string().max(50).required().label("No. Batch"),
        tanggal_kadaluarsa: Joi.string().required().label("Tanggal Kadaluarsa"),
        update_harga_beli_master: Joi.boolean().optional().default(true).label("Perbarui Harga Master"),
        tanggal: Joi.string().optional().label("Tanggal Restock"),
      },
      { "any.required": "{#label} wajib diisi", "string.empty": "{#label} tidak boleh kosong" },
      oPayload,
      { allowUnknown: true }
    );

    if (cValidation) {
      return res.status(422).json({ status: status.BAD_REQUEST, message: cValidation, datetime: formatDateSystem() });
    }

    let resultData = {};

    await DB.transaction(async (trx) => {
      // 1. Cek Produk
      let qProd = trx("mst_produk").where("kode_produk", oPayload.kode_produk);
      if (branchCode) qProd = qProd.andWhere("kode_cabang", branchCode);
      const produk = await qProd.forUpdate().first();
      if (!produk) {
        const err = new Error("Data produk tidak ditemukan");
        err.statusCode = 404;
        throw err;
      }

      // 2. Cek Supplier
      let qSup = trx("mst_supplier").where("kode_supplier", oPayload.kode_supplier);
      if (branchCode) qSup = qSup.andWhere("kode_cabang", branchCode);
      const supplier = await qSup.first();
      if (!supplier) {
        const err = new Error("Data supplier tidak ditemukan");
        err.statusCode = 404;
        throw err;
      }

      const qtyMasuk = parseInt(oPayload.qty_masuk, 10);
      const hargaBeli = parseFloat(oPayload.harga_beli);
      const stokSebelum = parseInt(produk.stok_tersedia || 0, 10);
      const stokSesudah = stokSebelum + qtyMasuk;
      const totalPo = qtyMasuk * hargaBeli;
      const tglPo = oPayload.tanggal || new Date().toISOString().slice(0, 10);
      const tglExp = String(oPayload.tanggal_kadaluarsa).slice(0, 10);
      const noBatch = oPayload.no_batch.trim();

      // 3. Generate kode_po (PO-YYYYMMDD-XXXX)
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

      // 4. Simpan ke trx_purchase_order
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

      // 5. Generate kode_batch unik & Simpan ke mst_produk_batch
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
        kode_produk: oPayload.kode_produk,
        no_batch: noBatch,
        tanggal_kadaluarsa: tglExp,
        stok_masuk: qtyMasuk,
        stok_sisa: qtyMasuk,
        harga_beli_satuan: hargaBeli,
        kode_supplier: oPayload.kode_supplier,
        kode_po: kodePo,
        is_legacy_estimate: 0,
        status: "aktif",
        catatan: `Restock produk (${kodePo})`,
        tz: oPayload.tz || "UTC",
        created_by: username,
        created_at: formatDateSystem(),
        updated_by: username,
        updated_at: formatDateSystem(),
        kode_cabang: branchCode,
      };
      await trx("mst_produk_batch").insert(oBatch);

      // 6. Simpan detail PO
      const kodeDetailPo = `DPO-${todayStr}-${String(nextPoNum).padStart(3, "0")}-1`;
      const oDetailPo = {
        kode_detail_po: kodeDetailPo,
        kode_po: kodePo,
        kode_produk: oPayload.kode_produk,
        kode_batch: kodeBatch,
        no_batch: noBatch,
        tanggal_kadaluarsa: tglExp,
        qty: qtyMasuk,
        harga_satuan: hargaBeli,
        subtotal: totalPo,
        tz: oPayload.tz || "UTC",
        created_by: username,
        created_at: formatDateSystem(),
        updated_by: username,
        updated_at: formatDateSystem(),
      };
      await trx("trx_detail_purchase_order").insert(oDetailPo);

      // 7. Simpan log mutasi stok masuk (trx_stok_movement)
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
        kode_produk: oPayload.kode_produk,
        kode_batch: kodeBatch,
        jenis_movement: "masuk",
        referensi: kodePo,
        qty: qtyMasuk,
        stok_sebelum: stokSebelum,
        stok_sesudah: stokSesudah,
        tanggal: formatDateSystem(),
        tz: oPayload.tz || "UTC",
        created_by: username,
        created_at: formatDateSystem(),
        updated_by: username,
        updated_at: formatDateSystem(),
      };
      await trx("trx_stok_movement").insert(oMovement);

      // 8. Update harga beli master & sinkronisasi batch summary
      if (oPayload.update_harga_beli_master !== false) {
        await trx("mst_produk").where("kode_produk", oPayload.kode_produk).update({
          harga_beli: hargaBeli,
          kode_supplier: oPayload.kode_supplier,
          updated_by: username,
          updated_at: formatDateSystem(),
        });
      }

      await syncProdukBatch(oPayload.kode_produk, trx);

      // 9. Log perubahan
      await ChangesLog(
        {
          description: `Restock Produk ${oPayload.kode_produk} (+${qtyMasuk} - Batch: ${noBatch}) dari Supplier ${oPayload.kode_supplier} (${kodePo})`,
          tableName: "mst_produk",
          referenceCode: oPayload.kode_produk,
          action: "UPDATE",
          dataBefore: { stok_tersedia: stokSebelum, harga_beli: produk.harga_beli },
          dataAfter: { stok_tersedia: stokSesudah, harga_beli: hargaBeli, batch: oBatch, po: oPo },
          user: username,
          tz: oPayload.tz || "UTC",
        },
        trx
      );

      resultData = {
        kode_produk: oPayload.kode_produk,
        nama_produk: produk.nama,
        kode_batch: kodeBatch,
        no_batch: noBatch,
        tanggal_kadaluarsa: tglExp,
        kode_po: kodePo,
        stok_sebelum: stokSebelum,
        stok_sesudah: stokSesudah,
        qty_masuk: qtyMasuk,
        total_po: totalPo,
      };
    });

    return res.status(200).json({
      status: status.SUKSES,
      message: `Berhasil merestock ${resultData.qty_masuk} ${resultData.nama_produk} (Batch: ${resultData.no_batch}, Exp: ${resultData.tanggal_kadaluarsa}). Stok kini ${resultData.stok_sesudah}.`,
      datetime: formatDateSystem(),
      data: resultData,
    });
  } catch (error) {
    if (error.statusCode === 404) {
      return res.status(404).json({ status: status.NOT_FOUND, message: error.message, datetime: formatDateSystem() });
    }
    const oResult = { status: status.BAD_REQUEST, message: error.message || "Sistem sedang maintenance", datetime: formatDateSystem() };
    Logging(error, { file: "/master/inventori/inventori_restock.js", func: "restock", request: oPayload, response: oResult, user: username });
    return res.status(500).json(oResult);
  }
});

export default router;
