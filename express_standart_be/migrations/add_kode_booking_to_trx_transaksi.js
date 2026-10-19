/**
 * @project Sistem Klinik Kecantikan
 * @file add_kode_booking_to_trx_transaksi.js
 * @description Migrasi penambahan kolom kode_booking ke tabel trx_transaksi
 */
import DB from "../core/config/knex.js";

async function runMigration() {
  try {
    console.log("Starting migration: add kode_booking to trx_transaksi...");

    const hasKodeBooking = await DB.schema.hasColumn("trx_transaksi", "kode_booking");
    if (!hasKodeBooking) {
      await DB.schema.table("trx_transaksi", (table) => {
        table.string("kode_booking", 20).nullable().after("kode_kunjungan");
        table.index("kode_booking", "idx_trx_transaksi_kode_booking");
      });
      console.log("Column 'kode_booking' and index added successfully to trx_transaksi.");
    } else {
      console.log("Column 'kode_booking' already exists in trx_transaksi.");
    }

    // Backfill kode_booking dari trx_kunjungan untuk data lama jika ada
    await DB.raw(`
      UPDATE trx_transaksi t 
      JOIN trx_kunjungan k ON t.kode_kunjungan = k.kode_kunjungan 
      SET t.kode_booking = k.kode_booking 
      WHERE k.kode_booking IS NOT NULL AND t.kode_booking IS NULL
    `);
    console.log("Backfill kode_booking from trx_kunjungan completed.");

    console.log("Migration finished successfully.");
    process.exit(0);
  } catch (error) {
    console.error("Migration ERROR:", error);
    process.exit(1);
  } finally {
    await DB.destroy();
  }
}

runMigration();
