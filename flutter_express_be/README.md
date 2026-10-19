# 🌸 Klinik Kecantikan Mobile RESTful API (flutter_express_be)

Backend RESTful API berbasis **Express.js** yang disesuaikan secara khusus untuk aplikasi mobile **Flutter** (`flutter_standart_fe`). Backend ini terhubung ke database klinik yang sama (`db_klinik_kecantikan`) dengan backend web (`express_standart_be`), sehingga data pasien, dokter, layanan, produk, booking, antrean, dan rekam medis terintegrasi secara real-time.

---

## 🚀 Fitur Utama untuk Aplikasi Flutter Mobile

1. **Autentikasi & Registrasi Pasien Mandiri**:
   - Pasien baru dapat mendaftar langsung dari aplikasi Flutter.
   - Otomatis membuat No RM (`RM-XXXXXX`) dan akun login (`user_credential` dengan role `pasien`).
   - Login mendukung email, nomor HP, atau No RM dengan enkripsi password yang konsisten dengan sistem web backend.
   - Dukungan sesi mobile dengan Access Token & Refresh Token.
2. **Dashboard Home Aggregate**:
   - Endpoint tunggal `GET /api/v1/dashboard/home` untuk memuat semua data layar beranda (banner promo carousel, layanan terpopuler, produk skincare, rekomendasi dokter, booking terdekat, dan antrean aktif).
3. **Katalog Layanan & Treatment Kecantikan**:
   - Daftar treatment estetika dengan filter kategori, harga, durasi pengerjaan, dan foto.
4. **Katalog Produk Skincare**:
   - Produk perawatan kulit dengan info stok, harga, dan deskripsi pemakaian.
5. **Promo & Banner**:
   - Kampanye diskon dan promo berjalan untuk carousel mobile.
6. **Dokter & Jadwal Praktek**:
   - Profil dokter spesialis kulit / estetika dan jadwal hari & jam per cabang.
7. **Reservasi & Booking Appointment**:
   - Pengecekan slot waktu dokter & kuota yang tersedia per tanggal.
   - Pembuatan booking langsung dari aplikasi mobile pasien.
   - Riwayat status booking (menunggu, terkonfirmasi, selesai, batal).
8. **Live Antrean Klinik**:
   - Status antrean pribadi pasien hari ini, estimasi waktu tunggu, dan nomor yang sedang dipanggil.
   - Live antrean seluruh poli/ruangan klinik.
9. **Rekam Medis & Riwayat Treatment**:
   - Pasien dapat melihat riwayat kunjungan medis, saran dokter, dan foto before-after perawatan.
10. **Profil & Pengaturan Akun**:
    - Update data diri dan upload foto profil pasien.

---

## 🛠️ Instalasi & Menjalankan Server

### 1. Masuk ke folder backend mobile
```bash
cd flutter_express_be
```

### 2. Install dependensi
```bash
npm install
```

### 3. Konfigurasi Environment (`.env`)
Pastikan file `.env` sudah sesuai (sudah dikonfigurasi default):
```env
APP_NAME="Klinik Kecantikan Mobile API"
APP_PORT=8008
APP_TZ="Asia/Jakarta"

DB_DBMS=mysql2
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=
DB_DATABASE=db_klinik_kecantikan

USER_KEY=random
USER_SECRET=random
```

> **Catatan Port:** Backend mobile berjalan di port **`8008`** agar tidak bentrok dengan backend web (`8000` / `8010`).

### 4. Jalankan Server
```bash
# Mode pengembangan (auto-reload dengan nodemon)
npm run dev

# Mode produksi
npm start
```

---

## 📱 Panduan URL untuk Flutter Mobile (`flutter_standart_fe`)

Saat menghubungkan aplikasi Flutter ke backend ini:

| Target Platform | Base URL API |
| :--- | :--- |
| **Android Emulator** | `http://10.0.2.2:8008/api/v1` |
| **iOS Simulator** | `http://localhost:8008/api/v1` |
| **Flutter Web / Chrome** | `http://localhost:8008/api/v1` |
| **HP Fisik (USB Debugging / Wi-Fi)** | `http://<IP_KOMPUTER_ANDA>:8008/api/v1` (contoh: `http://192.168.1.10:8008/api/v1`) |

---

## 📋 Ringkasan Endpoint API

### 🔐 1. Autentikasi (`/api/v1/auth`)
| Method | Endpoint | Deskripsi | Auth |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/v1/auth/login` | Login Pasien / Tenaga Medis | Tidak |
| `POST` | `/api/v1/auth/register` | Registrasi Pasien Baru | Tidak |
| `GET` | `/api/v1/auth/me` | Cek info user yang sedang login | `Bearer Token` |
| `POST` | `/api/v1/auth/change-password` | Ganti password akun | `Bearer Token` |

#### Contoh Body `POST /api/v1/auth/login`:
```json
{
  "username": "081234567890",
  "password": "password123",
  "remember_me": true
}
```

#### Contoh Body `POST /api/v1/auth/register`:
```json
{
  "nama": "Batara Dewa",
  "no_hp": "081234567890",
  "email": "batara@example.com",
  "password": "password123",
  "nik": "3509012345670001",
  "tanggal_lahir": "2000-05-15",
  "jenis_kelamin": "L",
  "alamat": "Jl. Mawar No. 10, Jember"
}
```

---

### 🏠 2. Dashboard Beranda Mobile (`/api/v1/dashboard`)
| Method | Endpoint | Deskripsi | Auth |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/v1/dashboard/home` | Aggregate data beranda (promo, layanan populer, produk, dokter, booking & antrean terdekat) | Opsional |

---

### 💆 3. Layanan / Treatment (`/api/v1/layanan`)
| Method | Endpoint | Deskripsi | Auth |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/v1/layanan` | Daftar layanan (search, kategori, pagination) | Tidak |
| `GET` | `/api/v1/layanan/kategori` | Daftar kategori layanan treatment | Tidak |
| `GET` | `/api/v1/layanan/:kode` | Detail spesifik treatment | Tidak |

---

### 🧴 4. Produk Skincare (`/api/v1/produk`)
| Method | Endpoint | Deskripsi | Auth |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/v1/produk` | Daftar produk skincare (search, kategori, pagination) | Tidak |
| `GET` | `/api/v1/produk/kategori` | Kategori produk skincare | Tidak |
| `GET` | `/api/v1/produk/:kode` | Detail spesifik produk | Tidak |

---

### 🎁 5. Promo & Diskon (`/api/v1/promo`)
| Method | Endpoint | Deskripsi | Auth |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/v1/promo` | Daftar promo aktif | Tidak |
| `GET` | `/api/v1/promo/:kode` | Detail promo & benefit | Tidak |

---

### 📦 6. Paket Perawatan (`/api/v1/paket`)
| Method | Endpoint | Deskripsi | Auth |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/v1/paket` | Daftar paket bundling perawatan | Tidak |
| `GET` | `/api/v1/paket/saya` | Paket aktif yang dimiliki pasien (sisa kuota sesi) | `Bearer Token` |

---

### 🩺 7. Dokter & Jadwal (`/api/v1/dokter`)
| Method | Endpoint | Deskripsi | Auth |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/v1/dokter` | Daftar dokter spesialis & estetika | Tidak |
| `GET` | `/api/v1/dokter/:no_sip/jadwal` | Jadwal praktek dokter tertentu | Tidak |

---

### 🏢 8. Cabang Klinik (`/api/v1/cabang`)
| Method | Endpoint | Deskripsi | Auth |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/v1/cabang` | Daftar cabang klinik kecantikan | Tidak |

---

### 📅 9. Booking & Reservasi (`/api/v1/booking`)
| Method | Endpoint | Deskripsi | Auth |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/v1/booking/slots?tanggal_booking=YYYY-MM-DD` | Cek ketersediaan slot jam & kuota dokter | Tidak |
| `POST` | `/api/v1/booking/create` | Buat janji reservasi treatment | `Bearer Token` |
| `GET` | `/api/v1/booking/history` | Riwayat booking pasien | `Bearer Token` |
| `GET` | `/api/v1/booking/:kode` | Detail booking spesifik | `Bearer Token` |
| `POST` | `/api/v1/booking/:kode/cancel` | Batalkan reservasi | `Bearer Token` |

#### Contoh Body `POST /api/v1/booking/create`:
```json
{
  "kode_jadwal": "JAD001",
  "tanggal_booking": "2026-10-25",
  "jam_booking": "10:00",
  "kode_layanan": "LAY001",
  "catatan_pasien": "Konsultasi jerawat dan facial glowing",
  "metode_pembayaran_dp": "transfer"
}
```

---

### ⏱️ 10. Antrean Klinik (`/api/v1/antrean`)
| Method | Endpoint | Deskripsi | Auth |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/v1/antrean/status` | Cek status antrean pasien hari ini & estimasi menit | `Bearer Token` |
| `GET` | `/api/v1/antrean/live` | Live antrean klinik per poli/ruangan | Tidak |

---

### 📋 11. Rekam Medis Pasien (`/api/v1/rekam-medis`)
| Method | Endpoint | Deskripsi | Auth |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/v1/rekam-medis` | Riwayat kunjungan medis pasien | `Bearer Token` |
| `GET` | `/api/v1/rekam-medis/:id` | Detail tindakan rekam medis & foto before-after | `Bearer Token` |

---

### 👤 12. Profil Pengguna (`/api/v1/profile`)
| Method | Endpoint | Deskripsi | Auth |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/v1/profile` | Ambil data profil lengkap | `Bearer Token` |
| `PUT` | `/api/v1/profile` | Update data diri (alamat, kontak darurat, alergi) | `Bearer Token` |
| `POST` | `/api/v1/profile/foto` | Upload foto profil (multipart `foto`) | `Bearer Token` |

---

## 💡 Contoh Implementasi di Flutter (Dio / Http)

```dart
import 'package:dio/dio.dart';

class ApiService {
  // Ganti IP sesuai device (gunakan 10.0.2.2 untuk emulator Android)
  static const String baseUrl = 'http://10.0.2.2:8008/api/v1';
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Simpan token setelah login
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // 1. Login
  Future<Response> login(String username, String password) async {
    return await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
  }

  // 2. Load Home Screen Data
  Future<Response> getHomeScreenData() async {
    return await _dio.get('/dashboard/home');
  }

  // 3. Create Booking
  Future<Response> createBooking(Map<String, dynamic> bookingData) async {
    return await _dio.post('/booking/create', data: bookingData);
  }
}
```
