import DB from "../../../../core/config/knex.js";
import { formatDateSystem } from "../../components/tools/date_tools.js";

/**
 * Sinkronisasi total stok dan info batch terdekat ke tabel mst_produk
 * @param {string} kodeProduk
 * @param {object} trx Knex transaction instance (optional)
 */
export async function syncProdukBatch(kodeProduk, trx = null) {
  const db = trx || DB;

  // 1. Hitung total sisa stok dari seluruh batch aktif
  const sumRes = await db("mst_produk_batch")
    .where("kode_produk", kodeProduk)
    .where("status", "aktif")
    .sum("stok_sisa as total_stok")
    .first();

  const totalStok = parseInt(sumRes?.total_stok || 0, 10);

  // 2. Cari batch aktif terdekat yang akan kadaluarsa (FEFO summary)
  const nearestBatch = await db("mst_produk_batch")
    .where("kode_produk", kodeProduk)
    .where("status", "aktif")
    .where("stok_sisa", ">", 0)
    .orderBy("tanggal_kadaluarsa", "asc")
    .orderBy("created_at", "asc")
    .first();

  const updateData = {
    stok_tersedia: totalStok,
    no_batch: nearestBatch ? nearestBatch.no_batch : null,
    tanggal_kadaluarsa: nearestBatch ? nearestBatch.tanggal_kadaluarsa : null,
    updated_at: formatDateSystem(),
  };

  await db("mst_produk").where("kode_produk", kodeProduk).update(updateData);

  return {
    totalStok,
    nearestBatch,
  };
}

/**
 * Validasi awal ketersediaan stok produk sebelum simpan draft/bayar
 * @param {Array} items List item transaksi [{ kode, qty, nama, jenis }]
 * @param {string} branchCode Kode cabang
 * @param {object} trx Knex transaction instance (optional)
 */
export async function validateStockAvailability(items, branchCode = null, trx = null) {
  const db = trx || DB;

  if (!items || !Array.isArray(items) || items.length === 0) {
    return { valid: true };
  }

  // Agregasi kebutuhan qty per kode_produk
  const productReqMap = {};
  for (const it of items) {
    const isProduct = it.jenis === "produk" || (!it.is_from_pendaftaran && !it.jenis && it.kode_produk);
    const prodCode = it.kode || it.kode_produk;

    if (isProduct && prodCode && !prodCode.startsWith("CUSTOM-") && !prodCode.startsWith("CST-")) {
      const qty = parseInt(it.qty || 1, 10);
      if (!productReqMap[prodCode]) {
        productReqMap[prodCode] = {
          qty: 0,
          nama: it.nama || it.nama_produk || prodCode,
        };
      }
      productReqMap[prodCode].qty += qty;
    }
  }

  // Periksa ketersediaan setiap produk dari mst_produk_batch
  for (const [prodCode, req] of Object.entries(productReqMap)) {
    let qBatch = db("mst_produk_batch")
      .where("kode_produk", prodCode)
      .where("status", "aktif")
      .where("stok_sisa", ">", 0);

    if (branchCode) {
      qBatch = qBatch.andWhere("kode_cabang", branchCode);
    }

    const sumRes = await qBatch.sum("stok_sisa as total_sisa").first();
    const availableStock = parseInt(sumRes?.total_sisa || 0, 10);

    if (availableStock < req.qty) {
      return {
        valid: false,
        kode_produk: prodCode,
        nama_produk: req.nama,
        stok_tersedia: availableStock,
        stok_diminta: req.qty,
        message: `Stok produk "${req.nama}" tidak mencukupi. Tersedia: ${availableStock}, Diminta: ${req.qty}.`,
      };
    }
  }

  return { valid: true };
}

/**
 * Potong stok produk menggunakan algoritma FEFO (First Expired First Out)
 * @param {object} params
 * @param {string} params.kode_produk
 * @param {number} params.qty
 * @param {string} params.kode_transaksi
 * @param {string} params.username
 * @param {string} params.branchCode
 * @param {string} params.tz
 * @param {object} params.trx Knex transaction instance (REQUIRED)
 */
export async function deductStockFEFO({ kode_produk, qty, kode_transaksi, username, branchCode, tz = "UTC", trx }) {
  if (!trx) {
    throw new Error("deductStockFEFO memerlukan transaksi database aktif (trx)");
  }

  if (kode_produk.startsWith("CUSTOM-") || kode_produk.startsWith("CST-")) {
    return []; // Item custom tidak memiliki stok fisik
  }

  const reqQty = parseInt(qty, 10);
  if (reqQty <= 0) return [];

  // 1. Ambil semua batch aktif yang masih punya sisa stok, urutkan FEFO (tanggal_kadaluarsa ASC)
  let qBatches = trx("mst_produk_batch")
    .where("kode_produk", kode_produk)
    .where("status", "aktif")
    .where("stok_sisa", ">", 0);

  if (branchCode) {
    qBatches = qBatches.andWhere("kode_cabang", branchCode);
  }

  const activeBatches = await qBatches
    .orderBy("tanggal_kadaluarsa", "asc")
    .orderBy("created_at", "asc")
    .forUpdate();

  const totalAvailable = activeBatches.reduce((acc, b) => acc + parseInt(b.stok_sisa || 0, 10), 0);
  if (totalAvailable < reqQty) {
    const prod = await trx("mst_produk").where("kode_produk", kode_produk).first();
    const prodName = prod?.nama || kode_produk;
    throw new Error(`Stok produk "${prodName}" tidak mencukupi untuk pembayaran. Tersedia: ${totalAvailable}, Dibutuhkan: ${reqQty}.`);
  }

  let remainingToDeduct = reqQty;
  const deductedLogs = [];
  const todayStr = new Date().toISOString().slice(0, 10).replace(/-/g, "");

  // Ambil sequence mutasi terakhir hari ini
  const lastMov = await trx("trx_stok_movement")
    .where("kode_stok_movement", "like", `MOV-${todayStr}-%`)
    .orderBy("kode_stok_movement", "desc")
    .select("kode_stok_movement")
    .first();

  let movSeq = lastMov ? parseInt(lastMov.kode_stok_movement.split("-").pop(), 10) + 1 : 1;

  for (const batch of activeBatches) {
    if (remainingToDeduct <= 0) break;

    const currentBatchSisa = parseInt(batch.stok_sisa, 10);
    const deductAmount = Math.min(currentBatchSisa, remainingToDeduct);
    const newBatchSisa = currentBatchSisa - deductAmount;
    const newBatchStatus = newBatchSisa <= 0 ? "habis" : "aktif";

    // Update batch sisa stok & status
    await trx("mst_produk_batch")
      .where("id", batch.id)
      .update({
        stok_sisa: newBatchSisa,
        status: newBatchStatus,
        updated_by: username,
        updated_at: DB.fn.now(),
      });

    // Generate kode mutasi
    const kodeMovement = `MOV-${todayStr}-${String(movSeq).padStart(3, "0")}`;
    movSeq++;

    // Catat kartu stok / log mutasi keluar
    const movementRow = {
      kode_cabang: branchCode || batch.kode_cabang || "CBG-001",
      kode_stok_movement: kodeMovement,
      kode_produk: kode_produk,
      kode_batch: batch.kode_batch,
      jenis_movement: "keluar",
      referensi: kode_transaksi,
      qty: deductAmount,
      stok_sebelum: currentBatchSisa,
      stok_sesudah: newBatchSisa,
      tanggal: formatDateSystem(),
      tz: tz,
      created_by: username,
      created_at: formatDateSystem(),
      updated_by: username,
      updated_at: formatDateSystem(),
    };

    await trx("trx_stok_movement").insert(movementRow);

    deductedLogs.push({
      kode_batch: batch.kode_batch,
      no_batch: batch.no_batch,
      tanggal_kadaluarsa: batch.tanggal_kadaluarsa,
      qty_potong: deductAmount,
      sisa_setelah_potong: newBatchSisa,
    });

    remainingToDeduct -= deductAmount;
  }

  // Sinkronkan ke master produk
  await syncProdukBatch(kode_produk, trx);

  return deductedLogs;
}

/**
 * Kembalikan stok yang sebelumnya dipotong jika transaksi dibatalkan / void
 * @param {string} kodeTransaksi
 * @param {string} username
 * @param {object} trx Knex transaction instance (REQUIRED)
 */
export async function restoreStockFEFO({ kodeTransaksi, username, trx }) {
  if (!trx) {
    throw new Error("restoreStockFEFO memerlukan transaksi database aktif (trx)");
  }

  const movements = await trx("trx_stok_movement")
    .where("referensi", kodeTransaksi)
    .where("jenis_movement", "keluar");

  const affectedProducts = new Set();
  const todayStr = new Date().toISOString().slice(0, 10).replace(/-/g, "");

  const lastMov = await trx("trx_stok_movement")
    .where("kode_stok_movement", "like", `MOV-${todayStr}-%`)
    .orderBy("kode_stok_movement", "desc")
    .select("kode_stok_movement")
    .first();

  let movSeq = lastMov ? parseInt(lastMov.kode_stok_movement.split("-").pop(), 10) + 1 : 1;

  for (const mov of movements) {
    if (mov.kode_batch) {
      const batch = await trx("mst_produk_batch").where("kode_batch", mov.kode_batch).first();
      if (batch) {
        const restoreQty = parseInt(mov.qty, 10);
        const newSisa = parseInt(batch.stok_sisa, 10) + restoreQty;

        await trx("mst_produk_batch")
          .where("id", batch.id)
          .update({
            stok_sisa: newSisa,
            status: "aktif",
            updated_by: username,
            updated_at: DB.fn.now(),
          });

        const kodeMovement = `MOV-${todayStr}-${String(movSeq).padStart(3, "0")}`;
        movSeq++;

        await trx("trx_stok_movement").insert({
          kode_cabang: mov.kode_cabang,
          kode_stok_movement: kodeMovement,
          kode_produk: mov.kode_produk,
          kode_batch: mov.kode_batch,
          jenis_movement: "penyesuaian",
          referensi: `VOID-${kodeTransaksi}`,
          qty: restoreQty,
          stok_sebelum: batch.stok_sisa,
          stok_sesudah: newSisa,
          tanggal: formatDateSystem(),
          tz: mov.tz || "UTC",
          created_by: username,
          created_at: formatDateSystem(),
          updated_by: username,
          updated_at: formatDateSystem(),
        });

        affectedProducts.add(mov.kode_produk);
      }
    }
  }

  for (const kodeProd of affectedProducts) {
    await syncProdukBatch(kodeProd, trx);
  }
}
