/**
 * E2E TEST: Pemisahan Registrasi Akun Mobile (User Auth) vs Pendaftaran/Sinkronisasi Rekam Medis (mst_pasien)
 *
 * Menguji:
 * 1. Test 1 (Register Akun Murni): user_credential terbentuk (no_rm = null), TIDAK ADA baris di mst_pasien.
 * 2. Test 2 (Booking Gate Backend): User no_rm = null ditolak HTTP 422 saat hit create booking.
 * 3. Test 3 (Opsi A - Daftar Pasien Baru): mst_pasien terbit RM-xxxxxx baru, user_credential.no_rm terisi, JWT terupdate.
 * 4. Test 4 (Opsi B - Klaim Pasien Lama & Anti-Hijacking):
 *    - Klaim dengan tanggal lahir / No HP salah ditolak 422.
 *    - Klaim no_rm yang sudah dimiliki akun lain ditolak 409 (Anti-Hijacking).
 *    - Klaim no_rm valid yang belum diklaim berhasil tertaut.
 */

import DB from "../core/config/knex.js";

const BASE_URL = "http://127.0.0.1:8008/api/v1";

async function runTests() {
  console.log("==================================================================");
  console.log("🧪 MEMULAI TEST SUITE E2E: ARSITEKTUR REKAM MEDIS MOBILE KLINIK   ");
  console.log("==================================================================");

  let passedTests = 0;
  let totalTests = 0;

  function assert(condition, message) {
    totalTests++;
    if (!condition) {
      console.error(`❌ FAILED: ${message}`);
      throw new Error(`Test assertion failed: ${message}`);
    } else {
      passedTests++;
      console.log(`  ✅ PASS: ${message}`);
    }
  }

  // Cleanup test data jika ada sisa uji sebelumnya
  const TEST_PHONE_A = "089911223344";
  const TEST_EMAIL_A = "test_user_a@klinik.com";
  const TEST_PHONE_B = "089955667788";
  const TEST_EMAIL_B = "test_user_b@klinik.com";
  const TEST_NIK_A = "3510998877665544";
  const TEST_NIK_B = "3510112233445566";
  const DUMMY_UNCLAIMED_RM = "RM-999901";

  await DB("user_credential").whereIn("telp", [TEST_PHONE_A, TEST_PHONE_B]).delete();
  await DB("user_credential").whereIn("username", [TEST_EMAIL_A, TEST_EMAIL_B]).delete();
  await DB("mst_pasien").whereIn("nik", [TEST_NIK_A, TEST_NIK_B]).delete();
  await DB("mst_pasien").where("no_rm", DUMMY_UNCLAIMED_RM).delete();

  let tokenA = null;
  let userCodeA = null;
  let generatedNoRmA = null;

  try {
    // ────────────────────────────────────────────────────────────────
    // TEST 1: Register Akun Murni (User Auth Only)
    // ────────────────────────────────────────────────────────────────
    console.log("\n▶ [TEST 1] Register Akun Murni (User Auth Only)");
    {
      const regRes = await fetch(`${BASE_URL}/auth/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          fullname: "User Uji Murni A",
          telp: TEST_PHONE_A,
          email: TEST_EMAIL_A,
          password: "Password123!",
          kode_cabang: "CBG-001",
        }),
      });

      const regJson = await regRes.json();
      assert(regRes.status === 201, `Status code registrasi harus 201 (got ${regRes.status})`);
      assert(regJson.status === "00", `Response status harus '00'`);
      assert(regJson.data.access_token != null, `Harus mengembalikan access_token JWT`);

      tokenA = regJson.data.access_token;
      userCodeA = regJson.data.user_info.user_code;

      assert(regJson.data.user_info.no_rm === null, `no_rm di user_info harus NULL`);
      assert(regJson.data.user_info.is_patient === false, `is_patient harus false`);
      assert(regJson.data.user_info.pasien_profile === null, `pasien_profile harus NULL`);

      // Cek ke Database: user_credential ada, mst_pasien TIDAK ADA baris
      const credRow = await DB("user_credential").where("user_code", userCodeA).first();
      assert(credRow != null, `user_credential harus ada di database`);
      assert(credRow.no_rm === null, `user_credential.no_rm di database harus NULL`);

      const pasienRow = await DB("mst_pasien").where("no_hp", TEST_PHONE_A).first();
      assert(pasienRow == null, `TIDAK BOLEH ada baris baru di mst_pasien saat registrasi akun awal!`);
    }

    // ────────────────────────────────────────────────────────────────
    // TEST 2: Booking Gate Backend (Tolak user yang no_rm == null)
    // ────────────────────────────────────────────────────────────────
    console.log("\n▶ [TEST 2] Booking Gate Backend");
    {
      const bookRes = await fetch(`${BASE_URL}/booking/create`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${tokenA}`,
        },
        body: JSON.stringify({
          kode_jadwal: "JAD-001",
          tanggal_booking: "2026-10-25",
          jam_booking: "10:00",
          kode_layanan: "LAY-001",
          items: [{ kode_layanan: "LAY-001", nama_layanan: "Facial Treatment", harga: 150000 }],
        }),
      });

      const bookJson = await bookRes.json();
      assert(
        bookRes.status === 422,
        `Booking tanpa no_rm harus ditolak HTTP 422 oleh backend (got ${bookRes.status})`
      );
      assert(
        bookJson.message && bookJson.message.toLowerCase().includes("rekam medis"),
        `Pesan penolakan harus menyebutkan rekam medis (got: "${bookJson.message}")`
      );
    }

    // ────────────────────────────────────────────────────────────────
    // TEST 3: Opsi A - Daftar Pasien Baru Mandiri dari Profil
    // ────────────────────────────────────────────────────────────────
    console.log("\n▶ [TEST 3] Opsi A - Daftar Pasien Baru Mandiri dari Profil");
    {
      const patRes = await fetch(`${BASE_URL}/profile/register-patient`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${tokenA}`,
        },
        body: JSON.stringify({
          nama: "Pasien Uji Coba A",
          nik: TEST_NIK_A,
          tempat_lahir: "Surabaya",
          tanggal_lahir: "1998-07-20",
          jenis_kelamin: "P",
          golongan_darah: "O",
          agama: "Islam",
          status_perkawinan: "belum_menikah",
          kewarganegaraan: "WNI",
          pekerjaan: "Wiraswasta",
          provinsi: "JAWA TIMUR",
          kota_kabupaten: "KOTA SURABAYA",
          kecamatan: "WONOKROMO",
          kelurahan_desa: "DARMO",
          kode_pos: "60241",
          patokan: "Sebelah minimarket",
          alamat: "Jl. Darmo Permai No. 45, Surabaya",
          no_hp: TEST_PHONE_A,
          email: TEST_EMAIL_A,
          nama_kontak_darurat: "Ibu Kandung",
          no_hp_kontak_darurat: "081299990001",
          hubungan_kontak_darurat: "Orang Tua",
          alergi: "Alergi Kacang & Debu",
        }),
      });

      const patJson = await patRes.json();
      if (patRes.status !== 200) console.log("patJson error:", patJson);
      assert(patRes.status === 200, `Pendaftaran pasien baru harus 200 OK (got ${patRes.status})`);
      assert(patJson.status === "00", `Response status harus '00'`);
      assert(patJson.data.user_info.no_rm != null, `no_rm harus terbit dan tidak null`);
      assert(patJson.data.user_info.no_rm.startsWith("RM-"), `Format no_rm harus RM-XXXXXX`);
      assert(patJson.data.user_info.is_patient === true, `is_patient harus bernilai true`);
      assert(patJson.data.user_info.pasien_profile != null, `pasien_profile harus terlampir lengkap`);
      assert(patJson.data.user_info.pasien_profile.nik === TEST_NIK_A, `NIK di pasien_profile harus sesuai`);

      generatedNoRmA = patJson.data.user_info.no_rm;
      tokenA = patJson.data.access_token; // Perbarui token dengan no_rm baru

      // Verifikasi di Database
      const credUpdated = await DB("user_credential").where("user_code", userCodeA).first();
      assert(
        credUpdated.no_rm === generatedNoRmA,
        `user_credential.no_rm di DB harus terisi ${generatedNoRmA}`
      );

      const pasienCreated = await DB("mst_pasien").where("no_rm", generatedNoRmA).first();
      assert(pasienCreated != null, `mst_pasien dengan no_rm ${generatedNoRmA} harus ada di DB`);
      assert(pasienCreated.nik === TEST_NIK_A, `mst_pasien.nik harus ${TEST_NIK_A}`);

      // Coba daftar ulang dengan akun yang sama -> Harus Ditolak 400
      const patDuplicateRes = await fetch(`${BASE_URL}/profile/register-patient`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${tokenA}`,
        },
        body: JSON.stringify({
          nik: "3510999999999999",
          tempat_lahir: "Malang",
          tanggal_lahir: "2000-01-01",
          jenis_kelamin: "L",
          alamat: "Jl. Ijen",
        }),
      });
      assert(
        patDuplicateRes.status === 400,
        `Akun yang sudah punya no_rm tidak boleh mendaftar ulang (got ${patDuplicateRes.status})`
      );
    }

    // ────────────────────────────────────────────────────────────────
    // TEST 4: Opsi B - Klaim Pasien Lama & Anti-Hijacking Protection
    // ────────────────────────────────────────────────────────────────
    console.log("\n▶ [TEST 4] Opsi B - Klaim Pasien Lama & Anti-Hijacking Protection");
    {
      // 1. Buat Akun Kedua (User B) yang murni User Auth
      const regBRes = await fetch(`${BASE_URL}/auth/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          fullname: "User Uji Murni B",
          telp: TEST_PHONE_B,
          email: TEST_EMAIL_B,
          password: "Password123!",
          kode_cabang: "CBG-001",
        }),
      });
      const regBJson = await regBRes.json();
      assert(regBRes.status === 201, `Registrasi User B harus 201`);
      const tokenB = regBJson.data.access_token;
      const userCodeB = regBJson.data.user_info.user_code;

      // 2. Buat Rekam Medis Dummy di mst_pasien yang belum terhubung ke user mana pun
      await DB("mst_pasien").insert({
        kode_cabang: "CBG-001",
        no_rm: DUMMY_UNCLAIMED_RM,
        nama: "Pasien Lama Belum Berakun",
        nik: TEST_NIK_B,
        tempat_lahir: "Bandung",
        tanggal_lahir: "1995-12-10",
        jenis_kelamin: "L",
        no_hp: "081299990001",
        patokan: "Jl. Dago No. 100",
        status: "aktif",
        tz: "Asia/Jakarta",
        created_by: "system_test",
      });

      // 3. User B mencoba klaim dengan Tanggal Lahir Salah -> Ditolak 422
      const claimWrongDob = await fetch(`${BASE_URL}/profile/claim-patient`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${tokenB}`,
        },
        body: JSON.stringify({
          no_rm: DUMMY_UNCLAIMED_RM,
          tanggal_lahir: "1990-01-01", // Salah
          no_hp: "081299990001",
        }),
      });
      assert(claimWrongDob.status === 422, `Klaim tanggal lahir salah harus ditolak 422`);

      // 4. User B mencoba klaim dengan Nomor HP / NIK Salah -> Ditolak 422
      const claimWrongPhone = await fetch(`${BASE_URL}/profile/claim-patient`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${tokenB}`,
        },
        body: JSON.stringify({
          no_rm: DUMMY_UNCLAIMED_RM,
          tanggal_lahir: "1995-12-10", // Benar
          no_hp: "087777777777", // Salah
          nik: "1111222233334444", // Salah
        }),
      });
      assert(claimWrongPhone.status === 422, `Klaim nomor HP / NIK salah harus ditolak 422`);

      // 5. ANTI-HIJACKING TEST:
      // User B mencoba mengklaim generatedNoRmA (milik User A) dengan data tanggal lahir, NIK, dan No HP yang cocok
      const hijackAttempt = await fetch(`${BASE_URL}/profile/claim-patient`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${tokenB}`,
        },
        body: JSON.stringify({
          no_rm: generatedNoRmA,
          tanggal_lahir: "1998-07-20",
          no_hp: TEST_PHONE_A,
          nik: TEST_NIK_A,
        }),
      });
      const hijackJson = await hijackAttempt.json();
      assert(
        hijackAttempt.status === 409,
        `Anti-Hijacking: Klaim no_rm yang sudah dimiliki akun lain harus ditolak 409 Conflict (got ${hijackAttempt.status})`
      );
      assert(
        hijackJson.message && hijackJson.message.includes("sudah terhubung dengan akun lain"),
        `Pesan Anti-Hijacking harus jelas melarang pembajakan rekam medis`
      );

      // 6. User B mengklaim DUMMY_UNCLAIMED_RM dengan Seluruh Kunci yang Benar -> Berhasil!
      const validClaim = await fetch(`${BASE_URL}/profile/claim-patient`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${tokenB}`,
        },
        body: JSON.stringify({
          no_rm: DUMMY_UNCLAIMED_RM,
          tanggal_lahir: "1995-12-10",
          no_hp: "081299990001",
          nik: TEST_NIK_B,
        }),
      });

      const validClaimJson = await validClaim.json();
      assert(validClaim.status === 200, `Klaim 3 kunci valid harus sukses 200 OK`);
      assert(validClaimJson.data.user_info.no_rm === DUMMY_UNCLAIMED_RM, `User B berhasil tertaut ke ${DUMMY_UNCLAIMED_RM}`);
      assert(validClaimJson.data.user_info.is_patient === true, `User B sekarang berstatus is_patient = true`);

      // Cek di DB: user_credential User B sekarang terisi DUMMY_UNCLAIMED_RM
      const credBRow = await DB("user_credential").where("user_code", userCodeB).first();
      assert(credBRow.no_rm === DUMMY_UNCLAIMED_RM, `user_credential User B di DB harus tertaut ${DUMMY_UNCLAIMED_RM}`);
    }

    console.log("\n==================================================================");
    console.log(`🎉 SELURUH PENGUJIAN END-TO-END BERHASIL 100% PASS (${passedTests}/${totalTests} ASSERTS)`);
    console.log("==================================================================");
  } catch (err) {
    console.error("\n💥 TEST ERROR OCCURRED:\n", err);
    throw err;
  } finally {
    // Bersihkan data uji agar database tetap rapi
    console.log("🧹 Membersihkan data pengujian...");
    try {
      await DB("user_credential").whereIn("telp", [TEST_PHONE_A, TEST_PHONE_B]).delete();
      await DB("user_credential").whereIn("username", [TEST_EMAIL_A, TEST_EMAIL_B]).delete();
      await DB("mst_pasien").whereIn("nik", [TEST_NIK_A, TEST_NIK_B]).delete();
      if (generatedNoRmA) {
        await DB("mst_pasien").where("no_rm", generatedNoRmA).delete();
      }
      await DB("mst_pasien").where("no_rm", DUMMY_UNCLAIMED_RM).delete();
      console.log("✨ Pembersihan data uji selesai!");
    } catch (cleanupErr) {
      console.error("Cleanup error:", cleanupErr);
    }
  }
}

runTests().catch((err) => {
  process.exit(1);
});
