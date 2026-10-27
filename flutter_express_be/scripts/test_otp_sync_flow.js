import DB from "../core/config/knex.js";

const BASE_URL = "http://127.0.0.1:8008/api/v1";

async function runOtpSyncFlowTests() {
  console.log("==================================================================");
  console.log("📲 TESTING OTP 6 DIGIT VIA WHATSAPP/HP FOR PATIENT SYNC");
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

  const TEST_PHONE_A = "081299991111";
  const TEST_EMAIL_A = "otp_test_user_a@klinik.com";
  const TEST_NIK_A = "3201888877776666";
  const TEST_RM_A = "RM-777701";

  const TEST_PHONE_B = "081299992222";
  const TEST_EMAIL_B = "otp_test_user_b@klinik.com";

  // Cleanup data uji
  await DB("user_credential").whereIn("username", [TEST_EMAIL_A, TEST_EMAIL_B]).delete();
  await DB("user_credential").whereIn("telp", [TEST_PHONE_A, TEST_PHONE_B]).delete();
  await DB("mst_pasien").where("no_rm", TEST_RM_A).orWhere("nik", TEST_NIK_A).delete();

  try {
    // 1. Setup pasien di mst_pasien
    await DB("mst_pasien").insert({
      kode_cabang: "CBG-001",
      no_rm: TEST_RM_A,
      nama: "Anisa Rahma",
      nik: TEST_NIK_A,
      tempat_lahir: "Bandung",
      tanggal_lahir: "1996-03-25",
      jenis_kelamin: "P",
      no_hp: TEST_PHONE_A,
      patokan: "Jl. Dago Atas No. 50",
      status: "aktif",
      tz: "Asia/Jakarta",
      created_by: "resepsionis",
    });

    // 2. User A mendaftar akun mobile (no_rm = null)
    const regResA = await fetch(`${BASE_URL}/auth/register`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        fullname: "Anisa Rahma",
        telp: TEST_PHONE_A,
        email: TEST_EMAIL_A,
        password: "Password123!",
      }),
    });
    const regJsonA = await regResA.json();
    assert(regResA.status === 201, `Register akun A sukses 201`);
    assert(regJsonA.data.user_info.no_rm === null, `no_rm awal harus NULL`);

    const tokenA = regJsonA.data.access_token;
    const userCodeA = regJsonA.data.user_info.user_code;

    // -------------------------------------------------------------------------
    // TEST 1: Request OTP dengan data salah -> Ditolak 422
    // -------------------------------------------------------------------------
    console.log("\n▶ [TEST 1] Request OTP dengan Data Salah (Generic Anti-Enumeration 422)");
    const reqOtpWrong = await fetch(`${BASE_URL}/profile/request-claim-otp`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${tokenA}`,
      },
      body: JSON.stringify({
        nik: "1111222233334444",
        tanggal_lahir: "1990-01-01",
        no_hp: TEST_PHONE_A,
      }),
    });
    const reqOtpWrongJson = await reqOtpWrong.json();
    assert(reqOtpWrong.status === 422, `Request OTP data salah harus 422 (got ${reqOtpWrong.status})`);
    assert(
      reqOtpWrongJson.message.includes("Data verifikasi tidak sesuai"),
      `Pesan error generic anti-enumeration`
    );

    // -------------------------------------------------------------------------
    // TEST 2: Request OTP dengan data valid -> 200 OK (Kirim OTP Simulasi/WA)
    // -------------------------------------------------------------------------
    console.log("\n▶ [TEST 2] Request OTP dengan Data Valid -> 200 OK & Diterima Kode 6 Digit");
    const reqOtpValid = await fetch(`${BASE_URL}/profile/request-claim-otp`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${tokenA}`,
      },
      body: JSON.stringify({
        nik: TEST_NIK_A,
        tanggal_lahir: "1996-03-25",
        no_hp: TEST_PHONE_A,
      }),
    });
    const reqOtpValidJson = await reqOtpValid.json();
    assert(reqOtpValid.status === 200, `Request OTP valid harus 200 OK (got ${reqOtpValid.status})`);
    assert(reqOtpValidJson.data.masked_phone != null, `masked_phone harus tersedia`);
    assert(reqOtpValidJson.data.masked_phone.includes("****"), `masked_phone harus disamarkan`);
    assert(reqOtpValidJson.data.expires_in === 300, `expires_in harus 300 detik (5 menit)`);
    assert(reqOtpValidJson.data.dev_otp_code != null, `dev_otp_code harus ada di mode lokal`);
    assert(reqOtpValidJson.data.dev_otp_code.length === 6, `dev_otp_code harus 6 digit angka`);

    const validOtpCode = reqOtpValidJson.data.dev_otp_code;
    console.log("   🔑 Kode OTP yang diterima:", validOtpCode);

    // -------------------------------------------------------------------------
    // TEST 3: Salah Input OTP 3 Kali berturut-turut -> OTP Hangus
    // -------------------------------------------------------------------------
    console.log("\n▶ [TEST 3] Proteksi Brute-Force OTP (3 Kali Salah Input OTP -> Hangus)");
    // Salah ke-1
    const verifyWrong1 = await fetch(`${BASE_URL}/profile/verify-claim-otp`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${tokenA}` },
      body: JSON.stringify({ otp_code: "000001" }),
    });
    const verifyWrong1Json = await verifyWrong1.json();
    assert(verifyWrong1.status === 422, `Salah OTP ke-1 harus 422`);
    assert(verifyWrong1Json.message.includes("Sisa kesempatan"), `Pesan menunjukkan sisa kesempatan`);

    // Salah ke-2
    const verifyWrong2 = await fetch(`${BASE_URL}/profile/verify-claim-otp`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${tokenA}` },
      body: JSON.stringify({ otp_code: "000002" }),
    });
    assert(verifyWrong2.status === 422, `Salah OTP ke-2 harus 422`);

    // Salah ke-3 -> Kode hangus
    const verifyWrong3 = await fetch(`${BASE_URL}/profile/verify-claim-otp`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${tokenA}` },
      body: JSON.stringify({ otp_code: "000003" }),
    });
    const verifyWrong3Json = await verifyWrong3.json();
    assert(verifyWrong3.status === 422, `Salah OTP ke-3 harus 422`);
    assert(verifyWrong3Json.message.includes("hangus"), `Pesan menyatakan kode hangus`);

    // Coba masukkan kode asli yang sebelumnya setelah hangus -> Ditolak karena sesi telah dihapus
    const verifyAfterBurned = await fetch(`${BASE_URL}/profile/verify-claim-otp`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${tokenA}` },
      body: JSON.stringify({ otp_code: validOtpCode }),
    });
    assert(verifyAfterBurned.status === 400, `OTP yang sudah hangus harus ditolak 400 (sesi tiada)`);

    // -------------------------------------------------------------------------
    // TEST 4: Minta Ulang OTP & Verifikasi Berhasil -> no_rm Tertaut
    // -------------------------------------------------------------------------
    console.log("\n▶ [TEST 4] Request Ulang OTP & Verifikasi Sukses -> no_rm Tertaut");
    const reqOtpAgain = await fetch(`${BASE_URL}/profile/request-claim-otp`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${tokenA}` },
      body: JSON.stringify({
        nik: TEST_NIK_A,
        tanggal_lahir: "1996-03-25",
        no_hp: TEST_PHONE_A,
      }),
    });
    const reqOtpAgainJson = await reqOtpAgain.json();
    assert(reqOtpAgain.status === 200, `Request ulang OTP harus 200 OK`);
    const newOtpCode = reqOtpAgainJson.data.dev_otp_code;
    console.log("   🔑 Kode OTP baru yang diterima:", newOtpCode);

    // Verifikasi dengan kode yang baru
    const verifySuccess = await fetch(`${BASE_URL}/profile/verify-claim-otp`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${tokenA}` },
      body: JSON.stringify({ otp_code: newOtpCode }),
    });
    const verifySuccessJson = await verifySuccess.json();
    assert(verifySuccess.status === 200, `Verifikasi OTP sukses harus 200 OK (got ${verifySuccess.status})`);
    assert(verifySuccessJson.data.user_info.no_rm === TEST_RM_A, `no_rm di user_info harus ${TEST_RM_A}`);
    assert(verifySuccessJson.data.user_info.is_patient === true, `is_patient harus true`);

    // Verifikasi di database
    const credRowA = await DB("user_credential").where("user_code", userCodeA).first();
    assert(credRowA.no_rm === TEST_RM_A, `user_credential.no_rm di DB harus terisi ${TEST_RM_A}`);

    // -------------------------------------------------------------------------
    // TEST 5: User B Mencoba Klaim no_rm yang Sudah Tertaut ke User A -> 409 Conflict
    // -------------------------------------------------------------------------
    console.log("\n▶ [TEST 5] Anti-Hijacking saat Request OTP untuk Rekam Medis yang Sudah Tertaut");
    const regResB = await fetch(`${BASE_URL}/auth/register`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        fullname: "User B",
        telp: TEST_PHONE_B,
        email: TEST_EMAIL_B,
        password: "Password123!",
      }),
    });
    const regJsonB = await regResB.json();
    const tokenB = regJsonB.data.access_token;

    const hijackOtpReq = await fetch(`${BASE_URL}/profile/request-claim-otp`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${tokenB}` },
      body: JSON.stringify({
        nik: TEST_NIK_A,
        tanggal_lahir: "1996-03-25",
        no_hp: TEST_PHONE_A,
      }),
    });
    assert(hijackOtpReq.status === 409, `Request OTP untuk RM yang sudah terhubung user lain harus 409 (got ${hijackOtpReq.status})`);

    console.log("\n==================================================================");
    console.log(`🎉 SELURUH PENGUJIAN OTP 6 DIGIT BERHASIL 100%! (${passedTests}/${totalTests} ASSERTS)`);
    console.log("==================================================================");
  } finally {
    // Cleanup
    await DB("user_credential").whereIn("username", [TEST_EMAIL_A, TEST_EMAIL_B]).delete();
    await DB("user_credential").whereIn("telp", [TEST_PHONE_A, TEST_PHONE_B]).delete();
    await DB("mst_pasien").where("no_rm", TEST_RM_A).orWhere("nik", TEST_NIK_A).delete();
    await DB.destroy();
  }
}

runOtpSyncFlowTests().catch((e) => {
  console.error("❌ FAILED:", e);
  process.exit(1);
});
