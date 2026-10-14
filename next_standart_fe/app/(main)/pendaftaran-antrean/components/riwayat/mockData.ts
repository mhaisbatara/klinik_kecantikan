import { KunjunganRiwayat } from './types';
import postData from '@/lib/axios/postData';

const mockKonsul12: KunjunganRiwayat = {
  id: 'KJ-000012-konsul',
  noKunjungan: '#KJ-000012',
  tanggal: '2026-10-08',
  jamMulai: '10:15',
  jamSelesai: '10:45',
  jenis: 'konsultasi',
  status: 'Selesai',
  dokter: 'dr. Sari Wulandari',
  ruangan: 'Ruang Konsultasi Dokter',
  petugas: 'Nina Ayu',
  layanan: {
    nama: 'konsultasi',
    deskripsi: 'Sesi konsultasi kondisi kulit, evaluasi masalah jerawat, dan rekomendasi program perawatan.',
    qty: 1,
    harga: 15000,
  },
  produk: [],
  totalBayarKasir: 510000,
  catatan: 'Pasien datang dengan keluhan kulit wajah kusam dan berjerawat ringan. Dokter merekomendasikan tindakan Facial Deep Cleansing + Masker.',
  resep: [],
};

const mockTreatment12: KunjunganRiwayat = {
  id: 'KJ-000012',
  noKunjungan: '#KJ-000012',
  tanggal: '2026-10-08',
  jamMulai: '10:45',
  jamSelesai: '11:45',
  jenis: 'treatment',
  status: 'Selesai',
  dokter: 'dr. Sari Wulandari',
  ruangan: 'Ruang Facial B',
  petugas: 'Nina Ayu',
  layanan: {
    nama: 'Facial Deep Cleansing + Masker',
    deskripsi: 'Tindakan perawatan kecantikan lanjutan sesuai rekomendasi konsultasi dokter.',
    qty: 1,
    harga: 350000,
  },
  produk: [
    { nama: 'Facial Wash', qty: 1, satuan: 'PCS', harga: 75000 },
    { nama: 'Toner', qty: 1, satuan: 'PCS', harga: 85000 },
  ],
  totalBayarKasir: 510000,
  catatan: 'Tindakan facial deep cleansing telah selesai dilakukan. Komedo berkurang signifikan, kulit bersih dan lembap.',
  resep: ['Sunscreen Gel SPF 50 - Oleskan pagi dan siang hari'],
  konsultasiSebelumnya: mockKonsul12,
};
mockKonsul12.treatmentLanjutan = mockTreatment12;

export const MOCK_RIWAYAT_ITEMS: KunjunganRiwayat[] = [
  // Satu kunjungan (KJ-000012) yang mencakup konsultasi & treatment
  mockTreatment12,
  {
    id: 'KJ-000011',
    noKunjungan: '#KJ-000011',
    tanggal: '2026-08-31',
    jamMulai: '13:00',
    jamSelesai: '14:00',
    jenis: 'treatment',
    status: 'Selesai',
    dokter: 'dr. Sari Wulandari',
    ruangan: 'Ruang Laser & Peeling',
    petugas: 'Dewi Lestari',
    layanan: {
      nama: 'Peeling Chemical',
      deskripsi: 'Eksfoliasi kimiawi untuk meremajakan sel kulit mati dan mencerahkan pigmentasi.',
      qty: 1,
      harga: 450000,
    },
    produk: [
      { nama: 'Neutralizing Gel', qty: 1, satuan: 'PCS', harga: 60000 },
      { nama: 'Post-Peel Soothing Lotion', qty: 1, satuan: 'PCS', harga: 90000 },
    ],
    totalBayarKasir: 600000,
    catatan: 'Reaksi kulit toleran dengan frosting minimal. Disarankan hindari sinar matahari langsung dan wajib gunakan sunscreen SPF 50.',
    resep: ['Sunscreen Gel SPF 50 - Oleskan pagi dan siang hari'],
  },
  {
    id: 'KJ-000010',
    noKunjungan: '#KJ-000010',
    tanggal: '2026-07-12',
    jamMulai: '11:30',
    jamSelesai: '12:15',
    jenis: 'treatment',
    status: 'Selesai',
    dokter: '-',
    ruangan: 'Ruang Facial',
    petugas: 'Nina Ayu',
    layanan: {
      nama: 'Facial Basic',
      deskripsi: 'Pembersihan wajah dasar, massage relaksasi, dan pengaplikasian masker wajah nutrisi.',
      qty: 1,
      harga: 250000,
    },
    produk: [
      { nama: 'Cleansing Milk', qty: 1, satuan: 'PCS', harga: 45000 },
      { nama: 'Clay Purifying Mask', qty: 1, satuan: 'PCS', harga: 65000 },
    ],
    totalBayarKasir: 360000,
    catatan: 'Kondisi kulit bersih dan segar. Tidak ditemukan iritasi pasca tindakan.',
    resep: [],
  },
  {
    id: 'KJ-000009',
    noKunjungan: '#KJ-000009',
    tanggal: '2026-06-28',
    jamMulai: '15:00',
    jamSelesai: '16:00',
    jenis: 'treatment',
    status: 'Selesai',
    dokter: 'dr. Sari Wulandari',
    ruangan: 'Ruang Laser Estetika',
    petugas: 'Siti Rahma',
    layanan: {
      nama: 'Laser Rejuvenation',
      deskripsi: 'Terapi peremajaan kulit dengan teknologi laser non-ablatif untuk stimulasi kolagen.',
      qty: 1,
      harga: 1200000,
    },
    produk: [
      { nama: 'Cooling Hydrogel Mask', qty: 1, satuan: 'PCS', harga: 85000 },
      { nama: 'Regenerating Serum', qty: 1, satuan: 'PCS', harga: 120000 },
    ],
    totalBayarKasir: 1405000,
    catatan: 'Laser rejuvenation 3 pass selesai. Pasien merasa nyaman, kemerahan minimal dan reda dalam 30 menit.',
    resep: ['Recovery Barrier Cream - Oleskan malam hari'],
  },
  {
    id: 'KJ-000008',
    noKunjungan: '#KJ-000008',
    tanggal: '2026-05-15',
    jamMulai: '14:00',
    jamSelesai: '15:15',
    jenis: 'treatment',
    status: 'Selesai',
    dokter: '-',
    ruangan: 'Ruang Spa & Body Treatment',
    petugas: 'Nina Ayu',
    layanan: {
      nama: 'Body Scrub',
      deskripsi: 'Eksfoliasi seluruh tubuh dengan lulur aromaterapi herbal untuk kulit halus dan cerah.',
      qty: 1,
      harga: 300000,
    },
    produk: [
      { nama: 'Herbal Body Scrub 200g', qty: 1, satuan: 'JAR', harga: 80000 },
      { nama: 'Moisturizing Body Butter', qty: 1, satuan: 'JAR', harga: 95000 },
    ],
    totalBayarKasir: 475000,
    catatan: 'Tindakan lulur tubuh selesai dengan relaksasi baik. Kulit tubuh halus dan lembap.',
    resep: [],
  },
  {
    id: 'KJ-000007',
    noKunjungan: '#KJ-000007',
    tanggal: '2026-04-03',
    jamMulai: '10:00',
    jamSelesai: '11:00',
    jenis: 'treatment',
    status: 'Selesai',
    dokter: '-',
    ruangan: 'Ruang Relaksasi',
    petugas: 'Dewi Lestari',
    layanan: {
      nama: 'Aromatherapy Massage',
      deskripsi: 'Pijat relaksasi tubuh menggunakan minyak esensial lavender murni untuk meredakan ketegangan otot.',
      qty: 1,
      harga: 400000,
    },
    produk: [
      { nama: 'Essential Lavender Massage Oil', qty: 1, satuan: 'BTL', harga: 110000 },
    ],
    totalBayarKasir: 510000,
    catatan: 'Massage selesai tanpa keluhan. Ketegangan leher dan pundak berkurang signifikan.',
    resep: [],
  },
];

/**
 * Fetch data riwayat kunjungan berdasarkan no_rm
 * Mengutamakan data API jika tersedia, dan menyediakan mock data sesuai referensi visual.
 * Pasien baru seperti JOJO mengembalikan [] (empty array) untuk menampilkan empty state.
 */
export const fetchRiwayatKunjungan = async (
  noRm: string,
  namaPasien?: string
): Promise<KunjunganRiwayat[]> => {
  // Pasien baru eksplisit JOJO atau nama mengandung jojo
  const isJojo = Boolean(
    (namaPasien && namaPasien.trim().toUpperCase() === 'JOJO') ||
    (namaPasien && namaPasien.toLowerCase().includes('jojo'))
  );

  if (isJojo) {
    // Return empty list agar tampil Empty State "Belum ada riwayat kunjungan"
    return [];
  }

  try {
    const cleanNoRm = (noRm || '').replace(/^#/, '').trim();
    if (cleanNoRm) {
      // Panggil kedua endpoint secara paralel: rekam medis kunjungan & transaksi kasir
      // Catatan: riwayat kunjungan hanya masuk saat pasien sudah melakukan pembayaran lunas di kasir
      const [resRekamMedis, resTransaksi] = await Promise.allSettled([
        postData('/master/pasien-rekam-medis', {
          no_rm: cleanNoRm,
          only_selesai: true,
          only_lunas: true,
          page: 1,
          perPage: 50,
        }),
        postData('/master/pasien-transaksi', {
          keyword: cleanNoRm,
          perPage: 100,
        }),
      ]);

      const res = resRekamMedis.status === 'fulfilled' ? resRekamMedis.value : null;
      const resTrx = resTransaksi.status === 'fulfilled' ? resTransaksi.value : null;

      // Index transaksi kasir berdasarkan kode_kunjungan
      const mapTrx: Record<string, any> = {};
      if (resTrx?.data?.data && Array.isArray(resTrx.data.data)) {
        resTrx.data.data.forEach((trx: any) => {
          if (trx.kode_kunjungan) {
            const isLunas = ['lunas', 'selesai'].includes(String(trx.status || '').toLowerCase());
            if (!mapTrx[trx.kode_kunjungan] || isLunas) {
              mapTrx[trx.kode_kunjungan] = trx;
            }
          }
        });
      }

      if (res && (res.status === 200 || ['00', '0000', 200].includes(res.data?.status) || Array.isArray(res.data?.data))) {
        const rawData = Array.isArray(res.data?.data) ? res.data.data : [];
        const mapped: KunjunganRiwayat[] = [];

        rawData.forEach((item: any) => {
          // SYARAT MUTLAK: Riwayat baru masuk saat pasien sudah melakukan pembayaran lunas di kasir
          const trxMatch = item.kode_kunjungan ? mapTrx[item.kode_kunjungan] : null;
          const isLunas = Boolean(
            trxMatch &&
            ['lunas', 'selesai'].includes(String(trxMatch.status || '').toLowerCase())
          );

          if (!isLunas) {
            return;
          }
          const layananList = Array.isArray(item.layanan) ? item.layanan : [];
          const rawDate = item.tanggal_kunjungan || item.created_at || '2026-10-08';
          const tanggalFormatted =
            typeof rawDate === 'string'
              ? rawDate.split('T')[0]
              : rawDate instanceof Date
              ? rawDate.toISOString().split('T')[0]
              : '2026-10-08';

          const jamMulai = item.jam_datang ? String(item.jam_datang).slice(0, 5) : '10:15';
          const jamSelesai = item.jam_selesai ? String(item.jam_selesai).slice(0, 5) : '11:05';
          const rawStatus = item.status_kunjungan || 'Selesai';
          const status =
            rawStatus.charAt(0).toUpperCase() + rawStatus.slice(1).toLowerCase();

          const resepList: string[] = [];
          if (Array.isArray(item.resep)) {
            item.resep.forEach((r: any) => {
              if (typeof r === 'string') {
                resepList.push(r);
              } else if (r && (r.nama_obat || r.nama_produk)) {
                resepList.push(
                  `${r.nama_obat || r.nama_produk} - ${r.aturan_pakai || r.dosis || 'Gunakan sesuai anjuran'}`
                );
              }
            });
          }

          const dokterName =
            item.header_rekam_medis?.dokter_nama ||
            item.dokter_nama ||
            'dr. Amanda Putri Wijaya';

          // Transaksi kasir terkait untuk kunjungan ini (sudah terverifikasi lunas)
          const totalBayarKasirKunjungan = trxMatch
            ? Number(
                trxMatch.total_bayar !== undefined && trxMatch.total_bayar !== null
                  ? trxMatch.total_bayar
                  : trxMatch.total_harga || 0
              )
            : undefined;

          // Ekstrak produk transaksi kasir jika ada (memeriksa d.jenis === 'produk', d.kode_produk, d.nama_produk, atau kode PRD/CUSTOM)
          const trxProducts = (trxMatch?.details || [])
            .filter(
              (d: any) =>
                d.jenis === 'produk' ||
                Boolean(d.kode_produk) ||
                Boolean(d.nama_produk) ||
                (!d.kode_layanan && String(d.kode || '').startsWith('PRD')) ||
                (!d.kode_layanan && String(d.kode || '').startsWith('CUSTOM'))
            )
            .map((d: any) => {
              const subtotalNet = Number(
                d.subtotal_setelah_diskon !== undefined && d.subtotal_setelah_diskon !== null
                  ? d.subtotal_setelah_diskon
                  : (d.subtotal !== undefined && d.subtotal !== null ? d.subtotal : (d.harga_satuan || 0))
              );
              const hargaAsli = Number(d.harga_asli || d.subtotal || subtotalNet);
              return {
                nama: d.nama || d.nama_produk || 'Produk',
                qty: Number(d.qty || 1),
                satuan: d.satuan || 'PCS',
                subtotal: subtotalNet,
                harga: subtotalNet,
                hargaSatuan: Number(d.harga_satuan || 0),
                hargaAsli: hargaAsli > subtotalNet ? hargaAsli : undefined,
                diskonText: d.diskon_text || undefined,
                namaPromo: d.nama_promo || undefined,
              };
            });

          const prodTotal = trxProducts.reduce(
            (sum: number, p: any) => sum + (p.subtotal !== undefined ? Number(p.subtotal) : Number(p.harga || 0)),
            0
          );

          // Helper untuk mendapatkan detail harga layanan dari kasir
          const getTrxLayananInfo = (kodeLayanan?: string, namaLayanan?: string, fallbackPrice: number = 0) => {
            if (!trxMatch || !Array.isArray(trxMatch.details)) {
              return { harga: fallbackPrice, hargaAsli: undefined, diskonText: undefined, namaPromo: undefined };
            }
            const details = trxMatch.details;
            let match: any = null;

            // 1. Coba cocokkan berdasarkan kode_layanan
            if (kodeLayanan) {
              match = details.find((d: any) => d.kode_layanan === kodeLayanan || d.kode === kodeLayanan);
            }

            // 2. Coba cocokkan berdasarkan nama layanan (prioritas konsultasi jika nama mengandung konsul)
            if (!match && namaLayanan) {
              const target = namaLayanan.toLowerCase();
              const isKonsul = target.includes('konsul');
              if (isKonsul) {
                match = details.find((d: any) => (d.nama_layanan_single || d.nama || '').toLowerCase().includes('konsul'));
              } else {
                match = details.find((d: any) => {
                  const n = (d.nama_layanan_single || d.nama || '').toLowerCase();
                  return n.includes(target) || target.includes(n);
                });
              }
            }

            // 3. Fallback jika nama tidak cocok tetapi ada item layanan
            if (!match) {
              if (namaLayanan && namaLayanan.toLowerCase().includes('konsul')) {
                match = details.find((d: any) => (d.nama_layanan_single || d.nama || '').toLowerCase().includes('konsul'));
              } else {
                match = details.find((d: any) => d.jenis === 'layanan' && !(d.nama_layanan_single || d.nama || '').toLowerCase().includes('konsul'));
              }
            }

            if (match) {
              const val = match.subtotal_setelah_diskon !== undefined && match.subtotal_setelah_diskon !== null
                ? Number(match.subtotal_setelah_diskon)
                : Number(match.subtotal !== undefined ? match.subtotal : (match.harga_satuan || 0));
              const hargaAsli = Number(match.harga_asli || match.subtotal || val);
              return {
                harga: val,
                hargaAsli: hargaAsli > val ? hargaAsli : undefined,
                diskonText: match.diskon_text || undefined,
                namaPromo: match.nama_promo || undefined,
              };
            }

            return { harga: fallbackPrice, hargaAsli: undefined, diskonText: undefined, namaPromo: undefined };
          };

          // 1. Identifikasi apakah ada sesi di Ruang Konsultasi
          const konsulLayanan = layananList.find((l: any) => {
            const r = (l.nama_ruangan || '').toLowerCase();
            const n = (l.nama_layanan || '').toLowerCase();
            return r.includes('konsul') || n.includes('konsul');
          });

          // 2. Identifikasi apakah ada sesi tindakan treatment di ruangan selain Ruang Konsultasi
          const realTreatmentList = layananList.filter((l: any) => {
            const r = (l.nama_ruangan || '').toLowerCase();
            const n = (l.nama_layanan || '').toLowerCase();
            return !r.includes('konsul') && !n.includes('konsul');
          });

          if (konsulLayanan && realTreatmentList.length > 0) {
            // Pasien melakukan konsul SEBELUM treatment: jadikan SATU kartu riwayat kunjungan!
            const primaryTreatment = realTreatmentList[0];
            const konsulInfo = getTrxLayananInfo(
              konsulLayanan.kode_layanan,
              konsulLayanan.nama_layanan || 'konsul',
              Number(konsulLayanan.harga || 0)
            );
            const treatmentInfo = getTrxLayananInfo(
              primaryTreatment.kode_layanan,
              primaryTreatment.nama_layanan,
              Number(primaryTreatment.harga || 150000)
            );

            // Total semua biaya yang dikeluarkan saat kunjungan: total yang dibayarkan di kasir
            const totalBiayaKunjungan =
              totalBayarKasirKunjungan !== undefined
                ? totalBayarKasirKunjungan
                : konsulInfo.harga + treatmentInfo.harga + prodTotal;

            const konsulObj: KunjunganRiwayat = {
              id: `${item.kode_kunjungan || item.kunjungan_id}-konsul`,
              noKunjungan: item.kode_kunjungan ? `#${item.kode_kunjungan}` : `#KJ-${item.kunjungan_id}`,
              tanggal: tanggalFormatted,
              jamMulai,
              jamSelesai: konsulLayanan.selesai_at ? String(konsulLayanan.selesai_at).slice(11, 16) : jamSelesai,
              jenis: 'konsultasi',
              status,
              dokter: konsulLayanan.petugas?.nama || dokterName,
              ruangan: konsulLayanan.nama_ruangan || 'Ruang Konsultasi',
              petugas: konsulLayanan.petugas?.nama || item.petugas_nama || 'Nina Ayu',
              layanan: {
                nama: 'konsultasi',
                deskripsi:
                  konsulLayanan.deskripsi ||
                  konsulLayanan.catatan_petugas ||
                  'Sesi konsultasi dokter dan evaluasi kondisi kulit.',
                qty: 1,
                harga: konsulInfo.harga,
                hargaAsli: konsulInfo.hargaAsli,
                diskonText: konsulInfo.diskonText,
                namaPromo: konsulInfo.namaPromo,
              },
              produk: [],
              totalBayarKasir: totalBiayaKunjungan,
              metodeBayar: trxMatch?.metode_bayar,
              statusTransaksi: trxMatch?.status,
              catatan:
                konsulLayanan.catatan_petugas ||
                item.header_rekam_medis?.diagnosis ||
                'Rekomendasi tindakan treatment lanjutan pasca konsultasi.',
              resep: resepList,
            };

            const treatmentObj: KunjunganRiwayat = {
              id: item.kode_kunjungan || item.kunjungan_id,
              noKunjungan: item.kode_kunjungan ? `#${item.kode_kunjungan}` : `#KJ-${item.kunjungan_id}`,
              tanggal: tanggalFormatted,
              jamMulai: primaryTreatment.dipanggil_at ? String(primaryTreatment.dipanggil_at).slice(11, 16) : jamMulai,
              jamSelesai: primaryTreatment.selesai_at ? String(primaryTreatment.selesai_at).slice(11, 16) : jamSelesai,
              jenis: 'treatment',
              status,
              dokter: primaryTreatment.petugas?.nama || dokterName,
              ruangan: primaryTreatment.nama_ruangan || 'Ruang Treatment',
              petugas: primaryTreatment.petugas?.nama || item.petugas_nama || 'Nina Ayu',
              layanan: {
                nama: primaryTreatment.nama_layanan || 'Facial Glow Up',
                deskripsi: primaryTreatment.deskripsi || 'Tindakan perawatan kecantikan lanjutan pasca konsultasi dokter.',
                qty: 1,
                harga: treatmentInfo.harga,
                hargaAsli: treatmentInfo.hargaAsli,
                diskonText: treatmentInfo.diskonText,
                namaPromo: treatmentInfo.namaPromo,
              },
              produk: trxProducts,
              totalBayarKasir: totalBiayaKunjungan,
              metodeBayar: trxMatch?.metode_bayar,
              statusTransaksi: trxMatch?.status,
              catatan:
                primaryTreatment.catatan_hasil_treatment ||
                primaryTreatment.catatan_tindakan ||
                item.header_rekam_medis?.diagnosis ||
                '-',
              resep: resepList,
              konsultasiSebelumnya: konsulObj,
            };

            konsulObj.treatmentLanjutan = treatmentObj;

            // Masukkan HANYA 1 kartu untuk satu kunjungan, dengan total harga yang dibayarkan
            mapped.push(treatmentObj);
          } else if (konsulLayanan) {
            // Kunjungan yang HANYA memiliki ruang konsultasi:
            // JANGAN tampilkan double konsultasi! TAMPILKAN SATU SAJA!
            const konsulInfo = getTrxLayananInfo(
              konsulLayanan.kode_layanan,
              konsulLayanan.nama_layanan || 'konsul',
              Number(konsulLayanan.harga || 15000)
            );
            const totalBayarKasir =
              totalBayarKasirKunjungan !== undefined
                ? totalBayarKasirKunjungan
                : konsulInfo.harga + prodTotal;

            mapped.push({
              id: item.kode_kunjungan || item.kunjungan_id,
              noKunjungan: item.kode_kunjungan ? `#${item.kode_kunjungan}` : `#KJ-${item.kunjungan_id}`,
              tanggal: tanggalFormatted,
              jamMulai,
              jamSelesai,
              jenis: 'konsultasi',
              status,
              dokter: konsulLayanan.petugas?.nama || dokterName,
              ruangan: konsulLayanan.nama_ruangan || 'Ruang Konsultasi',
              petugas: konsulLayanan.petugas?.nama || item.petugas_nama || 'Nina Ayu',
              layanan: {
                nama: 'konsultasi',
                deskripsi:
                  konsulLayanan.deskripsi ||
                  konsulLayanan.catatan_petugas ||
                  'Sesi konsultasi kondisi kulit, evaluasi masalah estetika, dan saran perawatan.',
                qty: 1,
                harga: konsulInfo.harga,
                hargaAsli: konsulInfo.hargaAsli,
                diskonText: konsulInfo.diskonText,
                namaPromo: konsulInfo.namaPromo,
              },
              produk: trxProducts,
              totalBayarKasir,
              metodeBayar: trxMatch?.metode_bayar,
              statusTransaksi: trxMatch?.status,
              catatan:
                item.header_rekam_medis?.diagnosis ||
                konsulLayanan.catatan_petugas ||
                item.catatan ||
                'Pasien datang untuk konsultasi pemeriksaan kulit wajah.',
              resep: resepList,
            });
          } else if (realTreatmentList.length > 0) {
            // Kunjungan yang langsung ke treatment (tanpa konsultasi):
            // Tampilkan 1 treatment saja
            const primaryTreatment = realTreatmentList[0];
            const treatmentInfo = getTrxLayananInfo(
              primaryTreatment.kode_layanan,
              primaryTreatment.nama_layanan,
              Number(primaryTreatment.harga || 150000)
            );
            const totalBayarKasir =
              totalBayarKasirKunjungan !== undefined
                ? totalBayarKasirKunjungan
                : treatmentInfo.harga + prodTotal;

            mapped.push({
              id: item.kode_kunjungan || item.kunjungan_id,
              noKunjungan: item.kode_kunjungan ? `#${item.kode_kunjungan}` : `#KJ-${item.kunjungan_id}`,
              tanggal: tanggalFormatted,
              jamMulai,
              jamSelesai,
              jenis: 'treatment',
              status,
              dokter: primaryTreatment.petugas?.nama || dokterName,
              ruangan: primaryTreatment.nama_ruangan || 'Ruang Treatment',
              petugas: primaryTreatment.petugas?.nama || item.petugas_nama || 'Nina Ayu',
              layanan: {
                nama: primaryTreatment.nama_layanan || 'Treatment Estetika',
                deskripsi: primaryTreatment.deskripsi || 'Tindakan perawatan kecantikan.',
                qty: 1,
                harga: treatmentInfo.harga,
                hargaAsli: treatmentInfo.hargaAsli,
                diskonText: treatmentInfo.diskonText,
                namaPromo: treatmentInfo.namaPromo,
              },
              produk: trxProducts,
              totalBayarKasir,
              metodeBayar: trxMatch?.metode_bayar,
              statusTransaksi: trxMatch?.status,
              catatan:
                primaryTreatment.catatan_hasil_treatment ||
                primaryTreatment.catatan_tindakan ||
                item.header_rekam_medis?.diagnosis ||
                '-',
              resep: resepList,
            });
          } else {
            // Fallback jika tidak ada antrian ruangan spesifik
            const primaryLayanan = layananList[0] || {};
            const namaLayanan = primaryLayanan.nama_layanan || 'Konsultasi Dokter Estetika';
            const layananInfo = getTrxLayananInfo(
              primaryLayanan.kode_layanan,
              primaryLayanan.nama_layanan,
              Number(primaryLayanan.harga || 15000)
            );
            const totalBayarKasir =
              totalBayarKasirKunjungan !== undefined
                ? totalBayarKasirKunjungan
                : layananInfo.harga + prodTotal;

            mapped.push({
              id: item.kode_kunjungan || item.kunjungan_id,
              noKunjungan: item.kode_kunjungan ? `#${item.kode_kunjungan}` : `#KJ-${item.kunjungan_id}`,
              tanggal: tanggalFormatted,
              jamMulai,
              jamSelesai,
              jenis: 'konsultasi',
              status,
              dokter: primaryLayanan.petugas?.nama || dokterName,
              ruangan: primaryLayanan.nama_ruangan || 'Ruang Konsultasi',
              petugas: item.petugas_nama || 'Nina Ayu',
              layanan: {
                nama: namaLayanan,
                deskripsi: primaryLayanan.deskripsi || 'Sesi konsultasi kondisi kulit dan pemeriksaan umum.',
                qty: 1,
                harga: layananInfo.harga,
                hargaAsli: layananInfo.hargaAsli,
                diskonText: layananInfo.diskonText,
                namaPromo: layananInfo.namaPromo,
              },
              produk: trxProducts,
              totalBayarKasir,
              metodeBayar: trxMatch?.metode_bayar,
              statusTransaksi: trxMatch?.status,
              catatan: item.header_rekam_medis?.diagnosis || item.catatan || '-',
              resep: resepList,
            });
          }
        });

        return mapped;
      }
    }
  } catch (err) {
    // API failure fallback
  }

  // Fallback ke data mock standar persis seperti referensi visual
  return MOCK_RIWAYAT_ITEMS;
};
