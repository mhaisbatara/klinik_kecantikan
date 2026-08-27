/**
 * @project Sistem Klinik Kecantikan
 * @file kasir_options.js
 * @description Endpoint opsi untuk kasir: pasien (kunjungan hari ini), layanan aktif, produk aktif, promo aktif
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
    // Pasien dengan kunjungan aktif hari ini
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

    // Layanan aktif
    const vaLayanan = await DB("mst_layanan as l")
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

    // Produk aktif
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

    // Promo aktif hari ini
    const vaPromo = await DB("mst_promo as p")
      .join("mst_detail_promo as dp", "p.kode_promo", "dp.kode_promo")
      .where("p.status", "aktif")
      .where("dp.status", "aktif")
      .whereRaw("DATE(p.tanggal_mulai) <= ?", [todayStr])
      .whereRaw("DATE(p.tanggal_selesai) >= ?", [todayStr])
      .select(
        "p.kode_promo",
        "p.nama as nama_promo",
        "p.jenis_diskon",
        "p.nilai_diskon",
        "dp.jenis_item",
        "dp.kode_item"
      );

    // Build promoMap: best discount per item
    const promoMap = {};
    vaPromo.forEach((pr) => {
      const jenisClean = (pr.jenis_item || "").toLowerCase();
      const normJenis = jenisClean.includes("layanan")
        ? jenisClean.includes("paket") ? "paket_layanan" : "layanan"
        : jenisClean.includes("produk") ? jenisClean.includes("paket") ? "paket_produk" : "produk" : jenisClean;
      const keys = [`${normJenis}_${pr.kode_item}`, `${jenisClean}_${pr.kode_item}`];
      keys.forEach((key) => {
        if (!promoMap[key]) {
          promoMap[key] = pr;
        } else {
          if (parseFloat(pr.nilai_diskon) > parseFloat(promoMap[key].nilai_diskon)) {
            promoMap[key] = pr;
          }
        }
      });
    });

    const applyPromoToItem = (jenis, kode, harga) => {
      const key = `${jenis}_${kode}`;
      const promo = promoMap[key];
      if (!promo) return { is_promo: false, harga_asal: harga, harga_promo: null, kode_promo: null, nama_promo: null, jenis_diskon: null, nilai_diskon: null };
      const diskon = parseFloat(promo.nilai_diskon || 0);
      const hargaPromo = promo.jenis_diskon === "persen"
        ? Math.max(0, harga - (harga * diskon) / 100)
        : Math.max(0, harga - diskon);
      return {
        is_promo: true,
        harga_asal: harga,
        harga_promo: hargaPromo,
        kode_promo: promo.kode_promo,
        nama_promo: promo.nama_promo,
        jenis_diskon: promo.jenis_diskon,
        nilai_diskon: diskon,
      };
    };

    const listLayanan = vaLayanan.map((item) => ({
      jenis: "layanan",
      kode: item.kode_layanan,
      nama: item.nama,
      nama_kategori: item.nama_kategori || "Layanan",
      nama_ruangan: item.nama_ruangan || item.kode_ruangan || "-",
      harga: parseFloat(item.harga || 0),
      ...applyPromoToItem("layanan", item.kode_layanan, parseFloat(item.harga || 0)),
    }));

    const listProduk = vaProduk.map((item) => ({
      jenis: "produk",
      kode: item.kode_produk,
      nama: item.nama,
      nama_kategori: item.nama_kategori || "Produk",
      satuan: item.satuan || "pcs",
      harga: parseFloat(item.harga || 0),
      ...applyPromoToItem("produk", item.kode_produk, parseFloat(item.harga || 0)),
    }));

    return res.status(200).json({
      status: status.SUKSES,
      message: "Data opsi kasir berhasil dimuat",
      datetime: formatDateSystem(),
      data: {
        kunjungan: vaKunjungan,
        layanan: listLayanan,
        produk: listProduk,
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
