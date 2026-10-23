import DB from '../core/config/knex.js';

async function seed() {
  console.log('Seeding trx_pemakaian_paket_layanan...');

  const records = [
    // 1. DKPL-20261014-002-01 (haisbatara / RM-000002, KPL-20261014-002, LAY-003 Laser Brightening)
    {
      kode_pemakaian_paket_layanan: 'PPL-20261014-001',
      kode_detail_kepemilikan_paket_layanan: 'DKPL-20261014-002-01',
      sesi_ke: 1,
      kode_kunjungan: 'KJ-20261014-003',
      kode_booking: null,
      tanggal_pakai: '2026-10-14',
      status_pemakaian: 'hadir',
      keterangan: 'Laser Brightening (Klaim Sesi 1 Paket)',
      kode_cabang: 'CBG-001',
      tz: 'Asia/Jakarta',
      created_by: 'manager@klinik.com',
      created_at: '2026-10-14 03:00:28',
      updated_by: 'manager@klinik.com',
      updated_at: '2026-10-14 03:00:28',
    },
    {
      kode_pemakaian_paket_layanan: 'PPL-20261014-002',
      kode_detail_kepemilikan_paket_layanan: 'DKPL-20261014-002-01',
      sesi_ke: 2,
      kode_kunjungan: 'KJ-20261014-007',
      kode_booking: null,
      tanggal_pakai: '2026-10-14',
      status_pemakaian: 'hadir',
      keterangan: 'Laser Brightening (Klaim Sesi 2 Paket)',
      kode_cabang: 'CBG-001',
      tz: 'Asia/Jakarta',
      created_by: 'manager@klinik.com',
      created_at: '2026-10-14 13:38:29',
      updated_by: 'manager@klinik.com',
      updated_at: '2026-10-14 13:38:29',
    },
    {
      kode_pemakaian_paket_layanan: 'PPL-20261014-003',
      kode_detail_kepemilikan_paket_layanan: 'DKPL-20261014-002-01',
      sesi_ke: 3,
      kode_kunjungan: 'KJ-20261014-008',
      kode_booking: null,
      tanggal_pakai: '2026-10-14',
      status_pemakaian: 'hadir',
      keterangan: 'Laser Brightening (Klaim Sesi 3 Paket)',
      kode_cabang: 'CBG-001',
      tz: 'Asia/Jakarta',
      created_by: 'manager@klinik.com',
      created_at: '2026-10-14 14:29:39',
      updated_by: 'manager@klinik.com',
      updated_at: '2026-10-14 14:29:39',
    },

    // 2. DKPL-20261014-001-01 (RM-000007, KPL-20261014-001, LAY-003 Laser Brightening)
    {
      kode_pemakaian_paket_layanan: 'PPL-20261014-004',
      kode_detail_kepemilikan_paket_layanan: 'DKPL-20261014-001-01',
      sesi_ke: 1,
      kode_kunjungan: 'KJ-20261014-002',
      kode_booking: null,
      tanggal_pakai: '2026-10-14',
      status_pemakaian: 'hadir',
      keterangan: 'Laser Brightening (Klaim Sesi 1 Paket)',
      kode_cabang: 'CBG-001',
      tz: 'Asia/Jakarta',
      created_by: 'manager@klinik.com',
      created_at: '2026-10-14 02:58:35',
      updated_by: 'manager@klinik.com',
      updated_at: '2026-10-14 02:58:35',
    },
    {
      kode_pemakaian_paket_layanan: 'PPL-20261014-005',
      kode_detail_kepemilikan_paket_layanan: 'DKPL-20261014-001-01',
      sesi_ke: 2,
      kode_kunjungan: 'KJ-20261014-004',
      kode_booking: null,
      tanggal_pakai: '2026-10-14',
      status_pemakaian: 'hadir',
      keterangan: 'Laser Brightening (Klaim Sesi 2 Paket)',
      kode_cabang: 'CBG-001',
      tz: 'Asia/Jakarta',
      created_by: 'manager@klinik.com',
      created_at: '2026-10-14 08:30:00',
      updated_by: 'manager@klinik.com',
      updated_at: '2026-10-14 08:30:00',
    },
    {
      kode_pemakaian_paket_layanan: 'PPL-20261014-006',
      kode_detail_kepemilikan_paket_layanan: 'DKPL-20261014-001-01',
      sesi_ke: 3,
      kode_kunjungan: 'KJ-20261014-005',
      kode_booking: null,
      tanggal_pakai: '2026-10-14',
      status_pemakaian: 'hadir',
      keterangan: 'Laser Brightening (Klaim Sesi 3 Paket)',
      kode_cabang: 'CBG-001',
      tz: 'Asia/Jakarta',
      created_by: 'manager@klinik.com',
      created_at: '2026-10-14 13:11:43',
      updated_by: 'manager@klinik.com',
      updated_at: '2026-10-14 13:11:43',
    },

    // 3. DKPL-20260918-002-01 (RM-000002 haisbatara, KPL-20260918-002, LAY-003 Laser Brightening - 2 sesi terpakai)
    {
      kode_pemakaian_paket_layanan: 'PPL-20260918-001',
      kode_detail_kepemilikan_paket_layanan: 'DKPL-20260918-002-01',
      sesi_ke: 1,
      kode_kunjungan: 'KJ-20260918-001',
      kode_booking: null,
      tanggal_pakai: '2026-09-18',
      status_pemakaian: 'hadir',
      keterangan: 'Laser Brightening (Klaim Sesi 1 Paket)',
      kode_cabang: 'CBG-001',
      tz: 'Asia/Jakarta',
      created_by: 'manager@klinik.com',
      created_at: '2026-09-18 08:03:11',
      updated_by: 'manager@klinik.com',
      updated_at: '2026-09-18 08:03:11',
    },
    {
      kode_pemakaian_paket_layanan: 'PPL-20260918-002',
      kode_detail_kepemilikan_paket_layanan: 'DKPL-20260918-002-01',
      sesi_ke: 2,
      kode_kunjungan: 'KJ-20260918-003',
      kode_booking: null,
      tanggal_pakai: '2026-09-18',
      status_pemakaian: 'hadir',
      keterangan: 'Laser Brightening (Klaim Sesi 2 Paket)',
      kode_cabang: 'CBG-001',
      tz: 'Asia/Jakarta',
      created_by: 'manager@klinik.com',
      created_at: '2026-09-18 08:44:45',
      updated_by: 'manager@klinik.com',
      updated_at: '2026-09-18 08:44:45',
    },

    // 4. DKPL-20260929-001-01 (RM-000016, KPL-20260929-001, LAY-005 Body Scrub - 1 sesi terpakai)
    {
      kode_pemakaian_paket_layanan: 'PPL-20260929-001',
      kode_detail_kepemilikan_paket_layanan: 'DKPL-20260929-001-01',
      sesi_ke: 1,
      kode_kunjungan: 'KJ-20260929-016',
      kode_booking: null,
      tanggal_pakai: '2026-09-29',
      status_pemakaian: 'hadir',
      keterangan: 'Body Scrub & Massage (Klaim Sesi 1 Paket)',
      kode_cabang: 'CBG-001',
      tz: 'Asia/Jakarta',
      created_by: 'manager@klinik.com',
      created_at: '2026-09-29 08:16:19',
      updated_by: 'manager@klinik.com',
      updated_at: '2026-09-29 08:16:19',
    },

    // 5. DKPL-20260916-001-01 (RM-000007, KPL-20260916-001, LAY-005 Body Scrub - 3 sesi terpakai)
    {
      kode_pemakaian_paket_layanan: 'PPL-20260916-001',
      kode_detail_kepemilikan_paket_layanan: 'DKPL-20260916-001-01',
      sesi_ke: 1,
      kode_kunjungan: 'KJ-20260916-002',
      kode_booking: null,
      tanggal_pakai: '2026-09-16',
      status_pemakaian: 'hadir',
      keterangan: 'Body Scrub & Massage (Klaim Sesi 1 Paket)',
      kode_cabang: 'CBG-001',
      tz: 'Asia/Jakarta',
      created_by: 'superadmin@admin.com',
      created_at: '2026-09-16 03:07:29',
      updated_by: 'superadmin@admin.com',
      updated_at: '2026-09-16 03:07:29',
    },
    {
      kode_pemakaian_paket_layanan: 'PPL-20260916-002',
      kode_detail_kepemilikan_paket_layanan: 'DKPL-20260916-001-01',
      sesi_ke: 2,
      kode_kunjungan: 'KJ-20260916-003',
      kode_booking: null,
      tanggal_pakai: '2026-09-16',
      status_pemakaian: 'hadir',
      keterangan: 'Body Scrub & Massage (Klaim Sesi 2 Paket)',
      kode_cabang: 'CBG-001',
      tz: 'Asia/Jakarta',
      created_by: 'superadmin@admin.com',
      created_at: '2026-09-16 05:15:00',
      updated_by: 'superadmin@admin.com',
      updated_at: '2026-09-16 05:15:00',
    },
    {
      kode_pemakaian_paket_layanan: 'PPL-20260917-001',
      kode_detail_kepemilikan_paket_layanan: 'DKPL-20260916-001-01',
      sesi_ke: 3,
      kode_kunjungan: 'KJ-20260917-001',
      kode_booking: null,
      tanggal_pakai: '2026-09-17',
      status_pemakaian: 'hadir',
      keterangan: 'Body Scrub & Massage (Klaim Sesi 3 Paket)',
      kode_cabang: 'CBG-001',
      tz: 'Asia/Jakarta',
      created_by: 'superadmin@admin.com',
      created_at: '2026-09-17 02:43:31',
      updated_by: 'superadmin@admin.com',
      updated_at: '2026-09-17 02:43:31',
    },

    // 6. DKPL-20260910-001-01 (RM-000006, KPL-20260910-001, LAY-003 Laser Brightening - 3 sesi terpakai)
    {
      kode_pemakaian_paket_layanan: 'PPL-20260910-001',
      kode_detail_kepemilikan_paket_layanan: 'DKPL-20260910-001-01',
      sesi_ke: 1,
      kode_kunjungan: 'KJ-20260910-001',
      kode_booking: 'BKG-20260910-001',
      tanggal_pakai: '2026-09-10',
      status_pemakaian: 'hadir',
      keterangan: 'Laser Brightening (Check-in Booking)',
      kode_cabang: 'CBG-001',
      tz: 'Asia/Jakarta',
      created_by: 'superadmin@admin.com',
      created_at: '2026-09-10 02:43:22',
      updated_by: 'superadmin@admin.com',
      updated_at: '2026-09-10 02:43:22',
    },
    {
      kode_pemakaian_paket_layanan: 'PPL-20260910-002',
      kode_detail_kepemilikan_paket_layanan: 'DKPL-20260910-001-01',
      sesi_ke: 2,
      kode_kunjungan: 'KJ-20260910-004',
      kode_booking: null,
      tanggal_pakai: '2026-09-10',
      status_pemakaian: 'hadir',
      keterangan: 'Laser Brightening (Klaim Sesi 2 Paket)',
      kode_cabang: 'CBG-001',
      tz: 'Asia/Jakarta',
      created_by: 'superadmin@admin.com',
      created_at: '2026-09-10 07:15:00',
      updated_by: 'superadmin@admin.com',
      updated_at: '2026-09-10 07:15:00',
    },
    {
      kode_pemakaian_paket_layanan: 'PPL-20260914-001',
      kode_detail_kepemilikan_paket_layanan: 'DKPL-20260910-001-01',
      sesi_ke: 3,
      kode_kunjungan: 'KJ-20260914-001',
      kode_booking: 'BKG-20260914-002',
      tanggal_pakai: '2026-09-14',
      status_pemakaian: 'hadir',
      keterangan: 'Laser Brightening (Check-in Booking)',
      kode_cabang: 'CBG-001',
      tz: 'Asia/Jakarta',
      created_by: 'superadmin@admin.com',
      created_at: '2026-09-18 09:17:55',
      updated_by: 'superadmin@admin.com',
      updated_at: '2026-09-18 09:17:55',
    },
  ];

  for (const rec of records) {
    const exists = await DB('trx_pemakaian_paket_layanan')
      .where('kode_pemakaian_paket_layanan', rec.kode_pemakaian_paket_layanan)
      .first();

    if (!exists) {
      await DB('trx_pemakaian_paket_layanan').insert(rec);
      console.log(`Inserted ${rec.kode_pemakaian_paket_layanan} (Sesi ${rec.sesi_ke} for ${rec.kode_detail_kepemilikan_paket_layanan})`);
    } else {
      console.log(`Already exists: ${rec.kode_pemakaian_paket_layanan}`);
    }
  }

  const count = await DB('trx_pemakaian_paket_layanan').count('id as cnt');
  console.log(`Total rows in trx_pemakaian_paket_layanan: ${count[0].cnt}`);
  process.exit(0);
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
