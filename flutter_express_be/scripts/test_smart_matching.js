import DB from "../core/config/knex.js";

const BASE_URL = "http://127.0.0.1:8008/api/v1";

async function runStrictSecuritySyncTests() {
  console.log("==================================================================");
  console.log("🛡️ TESTING STRICT SECURITY HARDENING FOR PATIENT SYNC");
  console.log("==================================================================");

  let totalTests = 0;
  let passedTests = 0;

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

  const TEST_PHONE_1 = "081288889999";
  const TEST_PHONE_1_INTL = "+6281288889999";
  const TEST_EMAIL_1 = "strict_sec_test_1@klinik.com";
  const TEST_NIK_1 = "3201998877665544";
  const TEST_RM_1 = "RM-888801";

  const TEST_PHONE_2 = "081277776666";
  const TEST_EMAIL_2 = "strict_sec_test_2@klinik.com";
  const TEST_RM_2 = "RM-888802";

  const TEST_PHONE_3 = "081266665555";
  const TEST_EMAIL_3 = "strict_sec_test_3@klinik.com";

  // Cleanup data uji
  await DB("user_credential").whereIn("username", [TEST_EMAIL_1, TEST_EMAIL_2, TEST_EMAIL_3]).delete();
  await DB("user_credential").whereIn("telp", [TEST_PHONE_1, TEST_PHONE_2, TEST_PHONE_3]).delete();
  await DB("mst_pasien").whereIn("no_rm", [TEST_RM_1, TEST_RM_2]).delete();
  await DB("mst_pasien").where("nik", TEST_NIK_1).delete();

  try {
    // -------------------------------------------------------------------------
    // 1. Setup pasien di mst_pasien
    // -------------------------------------------------------------------------
    await DB("mst_pasien").insert({
      kode_cabang: "CBG-001",
      no_rm: TEST_RM_1,
      nama: "Siti Rahmawati",
      nik: TEST_NIK_1,
      tempat_lahir: "Jakarta",
      tanggal_lahir: "1997-04-15",
      jenis_kelamin: "P",
      no_hp: TEST_PHONE_1,
      patokan: "Jl. Sudirman No. 10",
      status: "aktif",
      tz: "Asia/Jakarta",
      created_by: "resepsionis",
    });

    // -------------------------------------------------------------------------
    // TEST 1: Registrasi Akun Mobile TIDAK BOLEH auto-sync no_rm
    // -------------------------------------------------------------------------
    console.log("\n▶ [TEST 1] Registrasi Akun: Auto-Sync Wajib Nonaktif (no_rm harus NULL)");
    const regRes = await fetch(`${BASE_URL}/auth/register`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        fullname: "Siti Rahma",
        telp: TEST_PHONE_1,
        email: TEST_EMAIL_1,
        password: "Password123!",
        nik: TEST_NIK_1,
        tanggal_lahir: "1997-04-15",
      }),
    });
    const regJson = await regRes.json();
    assert(regRes.status === 201, `Status register harus 201`);
    assert(regJson.data.user_info.no_rm === null, `no_rm di user_info harus NULL saat register awal`);
    assert(regJson.data.user_info.is_patient === false, `is_patient harus false`);

    const token1 = regJson.data.access_token;
    const userCode1 = regJson.data.user_info.user_code;

    // -------------------------------------------------------------------------
    // TEST 2: Strict 3-Factor Match (NIK 16 Digit + Tanggal Lahir + No HP Intl Format)
    // -------------------------------------------------------------------------
    console.log("\n▶ [TEST 2] Strict 3-Factor Match (NIK + Tanggal Lahir + No HP Normalisasi)");
    const claimRes1 = await fetch(`${BASE_URL}/profile/claim-patient`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token1}`,
      },
      body: JSON.stringify({
        nik: TEST_NIK_1,
        tanggal_lahir: "1997-04-15",
        no_hp: TEST_PHONE_1_INTL, // Menguji normalisasi +628 vs 08
      }),
    });
    const claimJson1 = await claimRes1.json();
    assert(claimRes1.status === 200, `Klaim 3 faktor harus sukses 200 OK (got ${claimRes1.status})`);
    assert(claimJson1.data.user_info.no_rm === TEST_RM_1, `no_rm tertaut harus ${TEST_RM_1}`);
    assert(claimJson1.data.user_info.is_patient === true, `is_patient harus true`);

    // -------------------------------------------------------------------------
    // TEST 3: Hapus Layer 2 (Klaim Nama + HP + Tanggal Lahir tanpa NIK & RM Harus Ditolak 422)
    // -------------------------------------------------------------------------
    console.log("\n▶ [TEST 3] Penolakan Layer 2 (Tanpa NIK & Tanpa RM Wajib Ditolak 422 Generic Error)");
    const regRes2 = await fetch(`${BASE_URL}/auth/register`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        fullname: "Budi Santoso",
        telp: TEST_PHONE_2,
        email: TEST_EMAIL_2,
        password: "Password123!",
      }),
    });
    const regJson2 = await regRes2.json();
    const token2 = regJson2.data.access_token;

    // Masukkan data pasien di klinik
    await DB("mst_pasien").insert({
      kode_cabang: "CBG-001",
      no_rm: TEST_RM_2,
      nama: "Budi Santoso",
      nik: null, // Pasien klinik tanpa KTP
      tempat_lahir: "Surabaya",
      tanggal_lahir: "1993-08-20",
      jenis_kelamin: "L",
      no_hp: TEST_PHONE_2,
      patokan: "Jl. Pemuda No. 20",
      status: "aktif",
      tz: "Asia/Jakarta",
      created_by: "resepsionis",
    });

    // Coba klaim hanya dengan Nama + HP + Tanggal Lahir (Layer 2 lama yang dihapus)
    const claimLoose = await fetch(`${BASE_URL}/profile/claim-patient`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token2}`,
      },
      body: JSON.stringify({
        nama: "Budi Santoso",
        no_hp: TEST_PHONE_2,
        tanggal_lahir: "1993-08-20",
      }),
    });
    const claimLooseJson = await claimLoose.json();
    assert(
      claimLoose.status === 422,
      `Klaim tanpa NIK dan tanpa RM harus ditolak 422 (got ${claimLoose.status})`
    );
    assert(
      claimLooseJson.message && claimLooseJson.message.includes("Data verifikasi tidak sesuai"),
      `Pesan error harus generic anti-enumeration: "${claimLooseJson.message}"`
    );

    // -------------------------------------------------------------------------
    // TEST 4: Pasien Tanpa NIK di DB Klinik Klaim dengan No. RM + No. HP + Tanggal Lahir -> Berhasil
    // -------------------------------------------------------------------------
    console.log("\n▶ [TEST 4] Pasien Tanpa NIK Klinik Klaim dengan No. RM + HP + Tanggal Lahir");
    const claimWithRm = await fetch(`${BASE_URL}/profile/claim-patient`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token2}`,
      },
      body: JSON.stringify({
        no_rm: TEST_RM_2,
        no_hp: TEST_PHONE_2,
        tanggal_lahir: "1993-08-20",
      }),
    });
    const claimWithRmJson = await claimWithRm.json();
    assert(claimWithRm.status === 200, `Klaim via No. RM + HP + Tanggal Lahir harus sukses 200 OK (got ${claimWithRm.status})`);
    assert(claimWithRmJson.data.user_info.no_rm === TEST_RM_2, `no_rm tertaut harus ${TEST_RM_2}`);

    // -------------------------------------------------------------------------
    // TEST 5: Rate Limiting Anti Brute-Force (3 kali gagal -> 429 Too Many Requests)
    // -------------------------------------------------------------------------
    console.log("\n▶ [TEST 5] Rate Limiting Anti Brute-Force (3 Gagal Klaim -> HTTP 429)");
    const regRes3 = await fetch(`${BASE_URL}/auth/register`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        fullname: "Attacker Test",
        telp: TEST_PHONE_3,
        email: TEST_EMAIL_3,
        password: "Password123!",
      }),
    });
    const regJson3 = await regRes3.json();
    const token3 = regJson3.data.access_token;

    // Percobaan gagal ke-1
    const fail1 = await fetch(`${BASE_URL}/profile/claim-patient`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${token3}` },
      body: JSON.stringify({ nik: "1111222233334444", tanggal_lahir: "2000-01-01", no_hp: TEST_PHONE_3 }),
    });
    assert(fail1.status === 422, `Percobaan gagal 1 harus 422 (got ${fail1.status})`);

    // Percobaan gagal ke-2
    const fail2 = await fetch(`${BASE_URL}/profile/claim-patient`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${token3}` },
      body: JSON.stringify({ nik: "1111222233334445", tanggal_lahir: "2000-01-01", no_hp: TEST_PHONE_3 }),
    });
    assert(fail2.status === 422, `Percobaan gagal 2 harus 422 (got ${fail2.status})`);

    // Percobaan gagal ke-3 -> Harus langsung terkunci HTTP 429
    const fail3 = await fetch(`${BASE_URL}/profile/claim-patient`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${token3}` },
      body: JSON.stringify({ nik: "1111222233334446", tanggal_lahir: "2000-01-01", no_hp: TEST_PHONE_3 }),
    });
    const fail3Json = await fail3.json();
    assert(fail3.status === 429, `Percobaan gagal 3 harus langsung terkunci HTTP 429 (got ${fail3.status})`);
    assert(
      fail3Json.message && fail3Json.message.includes("15 menit"),
      `Pesan harus menyebutkan batas waktu 15 menit: "${fail3Json.message}"`
    );

    // Percobaan ke-4 (saat terkunci) -> Tetap 429
    const fail4 = await fetch(`${BASE_URL}/profile/claim-patient`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${token3}` },
      body: JSON.stringify({ nik: TEST_NIK_1, tanggal_lahir: "1997-04-15", no_hp: TEST_PHONE_1 }),
    });
    assert(fail4.status === 429, `Request selanjutnya saat terkunci harus ditolak HTTP 429 (got ${fail4.status})`);

    console.log("\n==================================================================");
    console.log(`🎉 SELURUH PENGUJIAN STRICT SECURITY HARDENING BERHASIL 100%! (${passedTests}/${totalTests} ASSERTS)`);
    console.log("==================================================================");
  } finally {
    // Cleanup
    await DB("user_credential").whereIn("username", [TEST_EMAIL_1, TEST_EMAIL_2, TEST_EMAIL_3]).delete();
    await DB("user_credential").whereIn("telp", [TEST_PHONE_1, TEST_PHONE_2, TEST_PHONE_3]).delete();
    await DB("mst_pasien").whereIn("no_rm", [TEST_RM_1, TEST_RM_2]).delete();
    await DB("mst_pasien").where("nik", TEST_NIK_1).delete();
    await DB.destroy();
  }
}

runStrictSecuritySyncTests().catch((e) => {
  console.error("❌ FAILED:", e);
  process.exit(1);
});
