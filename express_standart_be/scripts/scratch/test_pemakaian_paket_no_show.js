/**
 * @file test_pemakaian_paket_no_show.js
 * @description Script verifikasi otomatis untuk alur klaim paket:
 *   1. Klaim paket HADIR (Check-in) -> sesi_terpakai +1, status_pemakaian = 'hadir'
 *   2. Klaim paket TIDAK HADIR (No-Show) -> sesi_terpakai +1, status_pemakaian = 'hangus_no_show', kode_kunjungan = null
 *   3. Pengujian IDEMPOTENSI No-Show ganda -> sesi TIDAK terpotong dua kali
 *   4. Verifikasi Buku Log riwayat pemakaian pada endpoint kepemilikan paket
 */

import 'dotenv/config';
import DB from '../../core/config/knex.js';
import { SignJWT } from 'jose';
import app from '../../app.js';

async function runTest() {
  console.log('================================================================');
  console.log('  TEST VERIFIKASI PEMAKAIAN PAKET MULTI-SESI & NO-SHOW AUDIT    ');
  console.log('================================================================\n');

  // Jalankan test server pada ephemeral port agar 100% menggunakan kode terbaru
  const testServer = await new Promise((resolve) => {
    const s = app.listen(0, '127.0.0.1', () => resolve(s));
  });
  const port = testServer.address().port;
  const baseUrl = `http://127.0.0.1:${port}`;
  console.log(`🚀 Test server aktif pada ${baseUrl}\n`);

  const KODE_KPL_TEST = 'KPL-TEST-001';
  const KODE_DKPL_TEST = 'DKPL-TEST-001';
  const KODE_BKG_HADIR = 'BKG-TEST-HDR-001';
  const KODE_BKG_NOSHOW = 'BKG-TEST-NSW-001';

  try {
    // 0. Ambil user kredensial & buat JWT token
    const user = await DB('user_credential').first();
    const secretKey = new TextEncoder().encode(process.env.USER_SECRET || "random");
    const token = await new SignJWT({
      user_code: user.user_code,
      username: user.username,
      role: user.role,
      kode_cabang: user.kode_cabang || 'CBG-001',
      nama_cabang: user.nama_cabang || 'Kantor Pusat',
    })
      .setProtectedHeader({ alg: "HS256" })
      .setIssuedAt()
      .setExpirationTime("2h")
      .sign(secretKey);

    const headers = {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
      'timestamp': new Date().toISOString(),
      'x-timestamp': new Date().toISOString(),
    };

    // Ambil 1 pasien & layanan aktif dari database
    const pasien = await DB('mst_pasien').where('status', 'aktif').first() || await DB('mst_pasien').first();
    const layanan = await DB('mst_layanan').where('status', 'aktif').first();
    const ruangan = await DB('mst_ruangan').where('status', 'aktif').first();
    const jadwal = await DB('mst_jadwal_karyawan').where('status', 'aktif').first();

    console.log(`Menggunakan Pasien: ${pasien.nama} (${pasien.no_rm})`);
    console.log(`Menggunakan Layanan: ${layanan.nama} (${layanan.kode_layanan})`);

    // 1. Bersihkan data test lama jika ada
    await DB('trx_pemakaian_paket_layanan')
      .whereIn('kode_detail_kepemilikan_paket_layanan', [KODE_DKPL_TEST])
      .delete();
    await DB('trx_detail_antrian_layanan')
      .whereIn('kode_layanan', [layanan.kode_layanan])
      .where('created_by', 'system_test')
      .delete();
    await DB('trx_detail_booking')
      .whereIn('kode_booking', [KODE_BKG_HADIR, KODE_BKG_NOSHOW])
      .delete();
    await DB('trx_booking')
      .whereIn('kode_booking', [KODE_BKG_HADIR, KODE_BKG_NOSHOW])
      .delete();
    await DB('trx_detail_kepemilikan_paket_layanan')
      .where('kode_detail_kepemilikan_paket_layanan', KODE_DKPL_TEST)
      .delete();
    await DB('trx_kepemilikan_paket_layanan')
      .where('kode_kepemilikan_paket_layanan', KODE_KPL_TEST)
      .delete();

    // 2. Setup Kepemilikan Paket Baru (Paket 5x Sesi, Sesi Terpakai Awal = 0)
    await DB('trx_kepemilikan_paket_layanan').insert({
      kode_cabang: 'CBG-001',
      kode_kepemilikan_paket_layanan: KODE_KPL_TEST,
      no_rm: pasien.no_rm,
      kode_paket_layanan: 'PKT-TEST',
      tanggal_beli: '2026-10-15',
      tanggal_expired: '2026-12-31',
      status: 'aktif',
      tz: 'Asia/Jakarta',
      created_by: 'system_test',
    });

    await DB('trx_detail_kepemilikan_paket_layanan').insert({
      kode_detail_kepemilikan_paket_layanan: KODE_DKPL_TEST,
      kode_kepemilikan_paket_layanan: KODE_KPL_TEST,
      kode_layanan: layanan.kode_layanan,
      sesi_total: 5,
      sesi_terpakai: 0,
      tz: 'Asia/Jakarta',
      created_by: 'system_test',
    });

    console.log('✅ Setup data awal paket 5 sesi berhasil (sesi_terpakai = 0, sisa_sesi = 5).\n');

    // =========================================================================
    // SKENARIO 1: Pasien Hadir Treatment (Check-In Booking Klaim Paket)
    // =========================================================================
    console.log('--- SKENARIO 1: Pasien HADIR Treatment (Check-in Klaim Paket) ---');
    // Buat booking klaim paket
    await DB('trx_booking').insert({
      kode_cabang: 'CBG-001',
      kode_booking: KODE_BKG_HADIR,
      no_rm: pasien.no_rm,
      kode_ruangan: ruangan.kode_ruangan,
      jenis_layanan: 'klaim_paket',
      kode_layanan: layanan.kode_layanan,
      kode_jadwal: jadwal?.kode_jadwal || 'JAD-001',
      tanggal_booking: '2026-10-15',
      jam_booking: '10:00:00',
      total_biaya: 0,
      status: 'dikonfirmasi',
      dp_nominal: 0,
      dp_status: 'sudah_bayar',
      tz: 'Asia/Jakarta',
      created_by: 'system_test',
    });

    await DB('trx_detail_booking').insert({
      kode_detail_booking: 'DBKG-TEST-HDR-01',
      kode_booking: KODE_BKG_HADIR,
      jenis_layanan: 'klaim_paket',
      jenis_item: 'klaim_paket',
      kode_layanan: layanan.kode_layanan,
      kode_kepemilikan_paket_layanan: KODE_KPL_TEST,
      kode_detail_kepemilikan_paket_layanan: KODE_DKPL_TEST,
      nama_layanan: `${layanan.nama} (Klaim Paket)`,
      harga: 0,
      durasi_menit: 30,
      tz: 'Asia/Jakarta',
      created_by: 'system_test',
    });

    // Panggil API checkin pada test server
    const resCheckin = await fetch(`${baseUrl}/api/v1/master/booking-checkin`, {
      method: 'POST',
      headers,
      body: JSON.stringify({ kode_booking: KODE_BKG_HADIR }),
    });

    const jsonCheckin = await resCheckin.json();
    console.log('Respon Check-in:', jsonCheckin.message);

    // Verifikasi pemotongan sesi & log pemakaian
    const dkplAfterHadir = await DB('trx_detail_kepemilikan_paket_layanan')
      .where('kode_detail_kepemilikan_paket_layanan', KODE_DKPL_TEST)
      .first();

    const logHadir = await DB('trx_pemakaian_paket_layanan')
      .where('kode_detail_kepemilikan_paket_layanan', KODE_DKPL_TEST)
      .where('kode_booking', KODE_BKG_HADIR)
      .first();

    console.log(`- sesi_terpakai setelah Hadir: ${dkplAfterHadir.sesi_terpakai} (Ekspektasi: 1)`);
    console.log(`- Log Pemakaian: sesi_ke=${logHadir?.sesi_ke}, status=${logHadir?.status_pemakaian}, kunjungan=${logHadir?.kode_kunjungan}`);

    const isTest1Pass =
      dkplAfterHadir.sesi_terpakai === 1 &&
      logHadir?.sesi_ke === 1 &&
      logHadir?.status_pemakaian === 'hadir' &&
      Boolean(logHadir?.kode_kunjungan);

    console.log(`HASIL SKENARIO 1: ${isTest1Pass ? '✅ PASS' : '❌ FAIL'}\n`);

    // =========================================================================
    // SKENARIO 2: Pasien TIDAK HADIR (No-Show Booking Klaim Paket)
    // =========================================================================
    console.log('--- SKENARIO 2: Pasien TIDAK HADIR (No-Show Klaim Paket) ---');
    // Buat booking kedua
    await DB('trx_booking').insert({
      kode_cabang: 'CBG-001',
      kode_booking: KODE_BKG_NOSHOW,
      no_rm: pasien.no_rm,
      kode_ruangan: ruangan.kode_ruangan,
      jenis_layanan: 'klaim_paket',
      kode_layanan: layanan.kode_layanan,
      kode_jadwal: jadwal?.kode_jadwal || 'JAD-001',
      tanggal_booking: '2026-10-15',
      jam_booking: '14:00:00',
      total_biaya: 0,
      status: 'dikonfirmasi',
      dp_nominal: 0,
      dp_status: 'sudah_bayar',
      tz: 'Asia/Jakarta',
      created_by: 'system_test',
    });

    await DB('trx_detail_booking').insert({
      kode_detail_booking: 'DBKG-TEST-NSW-01',
      kode_booking: KODE_BKG_NOSHOW,
      jenis_layanan: 'klaim_paket',
      jenis_item: 'klaim_paket',
      kode_layanan: layanan.kode_layanan,
      kode_kepemilikan_paket_layanan: KODE_KPL_TEST,
      kode_detail_kepemilikan_paket_layanan: KODE_DKPL_TEST,
      nama_layanan: `${layanan.nama} (Klaim Paket)`,
      harga: 0,
      durasi_menit: 30,
      tz: 'Asia/Jakarta',
      created_by: 'system_test',
    });

    // Panggil API booking-tidak-hadir pada test server
    const resNoShow1 = await fetch(`${baseUrl}/api/v1/master/booking-tidak-hadir`, {
      method: 'POST',
      headers,
      body: JSON.stringify({ kode_booking: KODE_BKG_NOSHOW }),
    });

    const jsonNoShow1 = await resNoShow1.json();
    console.log('Respon No-Show Pertama:', jsonNoShow1.message);

    // Verifikasi pemotongan sesi & log pemakaian no-show
    const dkplAfterNoShow1 = await DB('trx_detail_kepemilikan_paket_layanan')
      .where('kode_detail_kepemilikan_paket_layanan', KODE_DKPL_TEST)
      .first();

    const logNoShow1 = await DB('trx_pemakaian_paket_layanan')
      .where('kode_detail_kepemilikan_paket_layanan', KODE_DKPL_TEST)
      .where('kode_booking', KODE_BKG_NOSHOW)
      .first();

    console.log(`- sesi_terpakai setelah No-Show: ${dkplAfterNoShow1.sesi_terpakai} (Ekspektasi: 2)`);
    console.log(`- Log Pemakaian No-Show: sesi_ke=${logNoShow1?.sesi_ke}, status=${logNoShow1?.status_pemakaian}, kunjungan=${logNoShow1?.kode_kunjungan}`);

    const isTest2Pass =
      dkplAfterNoShow1.sesi_terpakai === 2 &&
      logNoShow1?.sesi_ke === 2 &&
      logNoShow1?.status_pemakaian === 'hangus_no_show' &&
      logNoShow1?.kode_kunjungan === null;

    console.log(`HASIL SKENARIO 2: ${isTest2Pass ? '✅ PASS' : '❌ FAIL'}\n`);

    // =========================================================================
    // SKENARIO 3: UJI IDEMPOTENSI (Panggilan No-Show Kedua Kali pada Booking Sama)
    // =========================================================================
    console.log('--- SKENARIO 3: Uji IDEMPOTENSI (Tandai No-Show Dua Kali) ---');
    const resNoShow2 = await fetch(`${baseUrl}/api/v1/master/booking-tidak-hadir`, {
      method: 'POST',
      headers,
      body: JSON.stringify({ kode_booking: KODE_BKG_NOSHOW }),
    });

    const jsonNoShow2 = await resNoShow2.json();
    console.log('Respon No-Show Kedua:', jsonNoShow2.message);

    const dkplAfterNoShow2 = await DB('trx_detail_kepemilikan_paket_layanan')
      .where('kode_detail_kepemilikan_paket_layanan', KODE_DKPL_TEST)
      .first();

    const totalLogsForNoShow = await DB('trx_pemakaian_paket_layanan')
      .where('kode_detail_kepemilikan_paket_layanan', KODE_DKPL_TEST)
      .where('kode_booking', KODE_BKG_NOSHOW)
      .count('* as count');

    const totalLogCount = totalLogsForNoShow[0]?.count || 0;
    console.log(`- sesi_terpakai setelah panggilan kedua: ${dkplAfterNoShow2.sesi_terpakai} (Harus TETAP: 2)`);
    console.log(`- Total baris log no-show untuk booking ini: ${totalLogCount} (Harus TETAP: 1)`);

    const isTest3Pass =
      dkplAfterNoShow2.sesi_terpakai === 2 &&
      Number(totalLogCount) === 1;

    console.log(`HASIL SKENARIO 3: ${isTest3Pass ? '✅ PASS (TIDAK ADA DOUBLE DEDUCTION)' : '❌ FAIL'}\n`);

    // =========================================================================
    // SKENARIO 4: Verifikasi Endpoint Kepemilikan Paket Pasien & Riwayat Buku Log
    // =========================================================================
    console.log('--- SKENARIO 4: Verifikasi Payload Endpoint Kepemilikan Paket ---');
    const resPaket = await fetch(`${baseUrl}/api/v1/master/pendaftaran-pasien-kepemilikan-paket`, {
      method: 'POST',
      headers,
      body: JSON.stringify({ no_rm: pasien.no_rm }),
    });

    const jsonPaket = await resPaket.json();
    const targetPaket = (jsonPaket.data || []).find((k) => k.kode_kepemilikan_paket_layanan === KODE_KPL_TEST);
    const targetDetail = (targetPaket?.details || []).find((d) => d.kode_detail_kepemilikan_paket_layanan === KODE_DKPL_TEST);

    console.log(`- Paket Ditemukan: ${targetPaket?.kode_kepemilikan_paket_layanan}`);
    console.log(`- Sisa Sesi Terhitung: ${targetDetail?.sisa_sesi} (Ekspektasi: 3)`);
    console.log(`- Total Riwayat Pemakaian Terlampir: ${targetDetail?.riwayat_pemakaian?.length} entri`);

    if (targetDetail?.riwayat_pemakaian?.length > 0) {
      targetDetail.riwayat_pemakaian.forEach((rw) => {
        console.log(`   * Sesi ke-${rw.sesi_ke} | Status: ${rw.status_pemakaian} | Tgl: ${rw.tanggal_pakai} | Ket: ${rw.keterangan}`);
      });
    }

    const isTest4Pass =
      targetDetail?.sisa_sesi === 3 &&
      targetDetail?.riwayat_pemakaian?.length === 2 &&
      targetDetail.riwayat_pemakaian[0].status_pemakaian === 'hadir' &&
      targetDetail.riwayat_pemakaian[1].status_pemakaian === 'hangus_no_show';

    console.log(`HASIL SKENARIO 4: ${isTest4Pass ? '✅ PASS' : '❌ FAIL'}\n`);

    // =========================================================================
    // KESIMPULAN AKHIR & CLEANUP
    // =========================================================================
    // Bersihkan data dummy test
    await DB('trx_pemakaian_paket_layanan')
      .whereIn('kode_detail_kepemilikan_paket_layanan', [KODE_DKPL_TEST])
      .delete();
    await DB('trx_detail_booking')
      .whereIn('kode_booking', [KODE_BKG_HADIR, KODE_BKG_NOSHOW])
      .delete();
    await DB('trx_booking')
      .whereIn('kode_booking', [KODE_BKG_HADIR, KODE_BKG_NOSHOW])
      .delete();
    await DB('trx_detail_kepemilikan_paket_layanan')
      .where('kode_detail_kepemilikan_paket_layanan', KODE_DKPL_TEST)
      .delete();
    await DB('trx_kepemilikan_paket_layanan')
      .where('kode_kepemilikan_paket_layanan', KODE_KPL_TEST)
      .delete();

    testServer.close();

    console.log('🧹 Data test otomatis berhasil dibersihkan.');
    console.log('================================================================');
    if (isTest1Pass && isTest2Pass && isTest3Pass && isTest4Pass) {
      console.log('  🎉 SEMUA 4 SKENARIO PENGUJIAN OTOMATIS SUKSES 100% (ALL PASS)  ');
    } else {
      console.log('  ⚠️ ADA SKENARIO YANG GAGAL, PERIKSA LOG DI ATAS!               ');
    }
    console.log('================================================================');

    process.exit(isTest1Pass && isTest2Pass && isTest3Pass && isTest4Pass ? 0 : 1);
  } catch (err) {
    console.error('Error saat menjalankan test:', err);
    testServer.close();
    process.exit(1);
  }
}

runTest();
