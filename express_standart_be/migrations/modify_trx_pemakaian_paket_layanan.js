import DB from "../core/config/knex.js";

export async function up() {
  try {
    console.log("Starting migration: modify_trx_pemakaian_paket_layanan...");

    // 1. Ubah kode_kunjungan menjadi NULLABLE
    await DB.schema.raw(`
      ALTER TABLE trx_pemakaian_paket_layanan 
      MODIFY COLUMN kode_kunjungan VARCHAR(20) NULL DEFAULT NULL;
    `);
    console.log("Migration SUCCESS: Altered kode_kunjungan to NULLABLE in trx_pemakaian_paket_layanan.");

    // 2. Tambahkan kolom jika belum ada
    const hasKodeCabang = await DB.schema.hasColumn("trx_pemakaian_paket_layanan", "kode_cabang");
    if (!hasKodeCabang) {
      await DB.schema.raw(`
        ALTER TABLE trx_pemakaian_paket_layanan
        ADD COLUMN kode_cabang VARCHAR(50) NULL DEFAULT NULL AFTER id;
      `);
      console.log("Migration SUCCESS: Added kode_cabang.");
    }

    const hasSesiKe = await DB.schema.hasColumn("trx_pemakaian_paket_layanan", "sesi_ke");
    if (!hasSesiKe) {
      await DB.schema.raw(`
        ALTER TABLE trx_pemakaian_paket_layanan
        ADD COLUMN sesi_ke INT NOT NULL DEFAULT 1 AFTER kode_detail_kepemilikan_paket_layanan;
      `);
      console.log("Migration SUCCESS: Added sesi_ke.");
    }

    const hasKodeBooking = await DB.schema.hasColumn("trx_pemakaian_paket_layanan", "kode_booking");
    if (!hasKodeBooking) {
      await DB.schema.raw(`
        ALTER TABLE trx_pemakaian_paket_layanan
        ADD COLUMN kode_booking VARCHAR(20) NULL DEFAULT NULL AFTER kode_kunjungan,
        ADD INDEX idx_ppl_booking (kode_booking);
      `);
      console.log("Migration SUCCESS: Added kode_booking and index.");
    }

    const hasStatusPemakaian = await DB.schema.hasColumn("trx_pemakaian_paket_layanan", "status_pemakaian");
    if (!hasStatusPemakaian) {
      await DB.schema.raw(`
        ALTER TABLE trx_pemakaian_paket_layanan
        ADD COLUMN status_pemakaian ENUM('hadir', 'hangus_no_show') NOT NULL DEFAULT 'hadir' AFTER tanggal_pakai;
      `);
      console.log("Migration SUCCESS: Added status_pemakaian.");
    }

    const hasKeterangan = await DB.schema.hasColumn("trx_pemakaian_paket_layanan", "keterangan");
    if (!hasKeterangan) {
      await DB.schema.raw(`
        ALTER TABLE trx_pemakaian_paket_layanan
        ADD COLUMN keterangan VARCHAR(255) NULL DEFAULT NULL AFTER status_pemakaian;
      `);
      console.log("Migration SUCCESS: Added keterangan.");
    }

    console.log("All modifications to trx_pemakaian_paket_layanan applied successfully!");
  } catch (err) {
    console.error("Migration UP ERROR:", err);
    throw err;
  }
}

export async function down() {
  try {
    console.log("Starting rollback: modify_trx_pemakaian_paket_layanan...");

    const hasKeterangan = await DB.schema.hasColumn("trx_pemakaian_paket_layanan", "keterangan");
    if (hasKeterangan) {
      await DB.schema.raw(`ALTER TABLE trx_pemakaian_paket_layanan DROP COLUMN keterangan;`);
    }

    const hasStatusPemakaian = await DB.schema.hasColumn("trx_pemakaian_paket_layanan", "status_pemakaian");
    if (hasStatusPemakaian) {
      await DB.schema.raw(`ALTER TABLE trx_pemakaian_paket_layanan DROP COLUMN status_pemakaian;`);
    }

    const hasKodeBooking = await DB.schema.hasColumn("trx_pemakaian_paket_layanan", "kode_booking");
    if (hasKodeBooking) {
      await DB.schema.raw(`ALTER TABLE trx_pemakaian_paket_layanan DROP COLUMN kode_booking;`);
    }

    const hasSesiKe = await DB.schema.hasColumn("trx_pemakaian_paket_layanan", "sesi_ke");
    if (hasSesiKe) {
      await DB.schema.raw(`ALTER TABLE trx_pemakaian_paket_layanan DROP COLUMN sesi_ke;`);
    }

    const hasKodeCabang = await DB.schema.hasColumn("trx_pemakaian_paket_layanan", "kode_cabang");
    if (hasKodeCabang) {
      await DB.schema.raw(`ALTER TABLE trx_pemakaian_paket_layanan DROP COLUMN kode_cabang;`);
    }

    await DB.schema.raw(`
      ALTER TABLE trx_pemakaian_paket_layanan 
      MODIFY COLUMN kode_kunjungan VARCHAR(20) NOT NULL;
    `);

    console.log("Rollback completed successfully!");
  } catch (err) {
    console.error("Migration DOWN ERROR:", err);
    throw err;
  }
}

// Jalankan otomatis jika dipanggil langsung via CLI
if (process.argv[1]?.endsWith("modify_trx_pemakaian_paket_layanan.js")) {
  up()
    .then(() => process.exit(0))
    .catch(() => process.exit(1));
}
