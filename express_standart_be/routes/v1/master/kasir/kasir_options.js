/**
 * @project Sistem Klinik Kecantikan
 * @file kasir_options.js
 * @description Endpoint opsi untuk kasir: pasien (kunjungan hari ini + layanan pendaftaran), semua layanan & paket aktif, produk aktif, promo aktif
 */
import express from "express";
import DB from "../../../../core/config/knex.js";
import { formatDateSystem } from "../../components/tools/date_tools.js";
import { Logging } from "../../components/tools/servertool.js";
import { status } from "../../components/tools/general.js";

const router = express.Router();

router.post("/", async (req, res) => {
  const { body } = req;
  const username = req?.auth?.username || "";
  const todayStr = new Date().toISOString().slice(0, 10);

  try {
    // 1. Pasien dengan kunjungan aktif hari ini
    const vaKunjungan = await DB("trx_kunjungan as k")
      .join("mst_pasien as p", "k.no_rm", "p.no_rm")
      .where("k.tanggal_kunjungan", todayStr)
      .where("k.status", "berlangsung")
      .select(
        "k.kode_kunjungan",
        "k.no_rm",
        "p.nama as nama_pasien",
        "p.no_hp",
        "k.jam_datang",
        "k.status as status_kunjungan"
      )
      .orderBy("k.jam_datang", "asc");

    // Ambil layanan/paket dari pendaftaran (trx_detail_antrian_layanan)
    const kodeKunjunganList = vaKunjungan.map((k) => k.kode_kunjungan).filter(Boolean);
    let vaLayananPendaftaran = [];
    if (kodeKunjunganList.length > 0) {
      vaLayananPendaftaran = await DB("trx_detail_antrian_layanan as dal")
        .whereIn("dal.kode_kunjungan", kodeKunjunganList)
        .select(
          "dal.kode_kunjungan",
          "dal.jenis_layanan",
          "dal.kode_layanan",
          "dal.nama_layanan",
          "dal.harga"
        );
    }

    const kunjunganMapped = vaKunjungan.map((k) => {
      const items = vaLayananPendaftaran
        .filter((l) => l.kode_kunjungan === k.kode_kunjungan)
        .map((l) => ({
          jenis: "layanan",
          kode: l.kode_layanan,
          nama: l.nama_layanan,
          satuan: "tindakan",
          qty: 1,
          harga_satuan: parseFloat(l.harga || 0),
          subtotal: parseFloat(l.harga || 0),
          is_from_pendaftaran: true,
        }));
      return {
        ...k,
        layanan_pendaftaran: items,
      };
    });

    // 2a. Layanan Single Aktif
    const vaLayananSingle = await DB("mst_layanan as l")
      .leftJoin("mst_kategori_layanan as k", "l.kode_kategori_layanan", "k.kode_kategori_layanan")
      .leftJoin("mst_ruangan as r", "l.kode_ruangan", "r.kode_ruangan")
      .where("l.status", "aktif")
      .select(
        "l.kode_layanan",
        "l.nama",
        "l.harga",
        "l.durasi_menit",
        "l.kode_ruangan",
        "r.nama_ruangan",
        "k.nama as nama_kategori"
      )
      .orderBy("l.nama", "asc");

    // 2b. Paket Layanan Aktif
    const vaPaketLayanan = await DB("mst_paket_layanan as pl")
      .leftJoin("mst_ruangan as r", "pl.kode_ruangan", "r.kode_ruangan")
      .where("pl.status", "aktif")
      .select(
        "pl.kode_paket_layanan",
        "pl.nama",
        "pl.harga_paket as harga",
        "pl.kode_ruangan",
        "r.nama_ruangan"
      )
      .orderBy("pl.nama", "asc");

    // Gabungkan Single Layanan + Paket Layanan di tab Layanan
    const listLayanan = [
      ...vaLayananSingle.map((item) => ({
        jenis: "layanan",
        kode: item.kode_layanan,
        nama: item.nama,
        nama_kategori: item.nama_kategori || "Layanan",
        nama_ruangan: item.nama_ruangan || item.kode_ruangan || "-",
        harga: parseFloat(item.harga || 0),
      })),
      ...vaPaketLayanan.map((item) => ({
        jenis: "layanan",
        kode: item.kode_paket_layanan,
        nama: item.nama,
        nama_kategori: "Paket Layanan",
        nama_ruangan: item.nama_ruangan || item.kode_ruangan || "-",
        harga: parseFloat(item.harga || 0),
      })),
    ].sort((a, b) => a.nama.localeCompare(b.nama));

    // 3. Produk aktif
    const vaProduk = await DB("mst_produk as p")
      .leftJoin("mst_kategori_produk as k", "p.kode_kategori_produk", "k.kode_kategori_produk")
      .where("p.status", "aktif")
      .select(
        "p.kode_produk",
        "p.nama",
        "p.harga_jual as harga",
        "p.satuan",
        "k.nama as nama_kategori"
      )
      .orderBy("p.nama", "asc");

    const listProduk = vaProduk.map((item) => ({
      jenis: "produk",
      kode: item.kode_produk,
      nama: item.nama,
      nama_kategori: item.nama_kategori || "Produk",
      satuan: item.satuan || "pcs",
      harga: parseFloat(item.harga || 0),
    }));

    // 4. Promo aktif hari ini (Sederhana — level total transaksi)
    const vaPromo = await DB("mst_promo as p")
      .where("p.status", "aktif")
      .whereRaw("CURDATE() BETWEEN DATE(p.tanggal_mulai) AND DATE(p.tanggal_selesai)")
      .select(
        "p.kode_promo",
        "p.nama as nama_promo",
        "p.jenis_diskon",
        "p.nilai_diskon",
        "p.tanggal_mulai",
        "p.tanggal_selesai"
      )
      .orderBy("p.nama", "asc");

    const listPromo = vaPromo.map((p) => ({
      kode_promo: p.kode_promo,
      nama_promo: p.nama_promo,
      jenis_diskon: p.jenis_diskon,
      nilai_diskon: parseFloat(p.nilai_diskon || 0),
      tanggal_mulai: p.tanggal_mulai,
      tanggal_selesai: p.tanggal_selesai,
    }));

    return res.status(200).json({
      status: status.SUKSES,
      message: "Data opsi kasir berhasil dimuat",
      datetime: formatDateSystem(),
      data: {
        kunjungan: kunjunganMapped,
        layanan: listLayanan,
        produk: listProduk,
        promo: listPromo,
      },
    });
  } catch (error) {
    const oResult = {
      status: status.BAD_REQUEST,
      message: "Sistem sedang maintenance harap tunggu sebentar",
      datetime: formatDateSystem(),
    };
    Logging(error, { file: "/master/kasir/kasir_options.js", func: "options", user: username });
    return res.status(500).json(oResult);
  }
});

export default router;
