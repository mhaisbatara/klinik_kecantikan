/**
 * @project Sistem Klinik Kecantikan
 * @file transaksi_pasien.js
 * @description Endpoint laporan list transaksi pembayaran pasien dari database (trx_transaksi)
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
  const keyword = body.keyword || "";
  const filterStatus = body.status || null;
  const tanggal_dari = body.tanggal_dari || null;
  const tanggal_sampai = body.tanggal_sampai || null;
  const page = parseInt(body.page) || 1;
  const perPage = parseInt(body.perPage) || 10;
  const offset = (page - 1) * perPage;

  try {
    const baseQuery = DB("trx_transaksi as t")
      .leftJoin("mst_pasien as p", "t.no_rm", "p.no_rm")
      .modify((qb) => {
        if (tanggal_dari) {
          qb.whereRaw("DATE(t.tanggal_transaksi) >= ?", [tanggal_dari]);
        }
        if (tanggal_sampai) {
          qb.whereRaw("DATE(t.tanggal_transaksi) <= ?", [tanggal_sampai]);
        }
        if (filterStatus) {
          qb.where("t.status", filterStatus);
        }
        if (keyword) {
          const lower = keyword.toLowerCase();
          qb.where(function () {
            this.whereRaw("LOWER(t.kode_transaksi) LIKE ?", [`%${lower}%`])
              .orWhereRaw("LOWER(t.no_rm) LIKE ?", [`%${lower}%`])
              .orWhereRaw("LOWER(p.nama) LIKE ?", [`%${lower}%`])
              .orWhereRaw("LOWER(p.nik) LIKE ?", [`%${lower}%`])
              .orWhereRaw("LOWER(t.kode_kunjungan) LIKE ?", [`%${lower}%`])
              .orWhereRaw("LOWER(t.metode_bayar) LIKE ?", [`%${lower}%`]);
          });
        }
      });

    const countResult = await baseQuery.clone().count("t.id as total").first();
    const totalData = parseInt(countResult?.total || 0, 10);

    const vaTransaksi = await baseQuery.clone()
      .select(
        "t.id",
        "t.kode_transaksi",
        "t.kode_kunjungan",
        "t.kode_rekam_medis",
        "t.no_rm",
        "p.nama as nama_pasien",
        "p.no_hp",
        "t.kode_promo",
        "t.tanggal_transaksi",
        "t.total_harga",
        "t.total_diskon",
        "t.total_bayar",
        "t.metode_bayar",
        "t.status",
        "t.created_at",
        "t.updated_at"
      )
      .orderBy("t.tanggal_transaksi", "desc")
      .orderBy("t.created_at", "desc")
      .orderBy("t.id", "desc")
      .limit(perPage)
      .offset(offset);

    const kodeTrxList = vaTransaksi.map((tr) => tr.kode_transaksi).filter(Boolean);

    let detailsMap = {};
    if (kodeTrxList.length > 0) {
      const allDetails = await DB("trx_detail_transaksi as dt")
        .leftJoin("mst_layanan as l", "dt.kode_layanan", "l.kode_layanan")
        .leftJoin("mst_paket_layanan as pl", "dt.kode_layanan", "pl.kode_paket_layanan")
        .leftJoin("mst_produk as prod", "dt.kode_produk", "prod.kode_produk")
        .whereIn("dt.kode_transaksi", kodeTrxList)
        .select(
          "dt.kode_transaksi",
          "dt.kode_detail_transaksi",
          "dt.kode_layanan",
          "dt.kode_produk",
          "l.nama as nama_layanan_single",
          "l.harga as master_harga_layanan",
          "pl.nama as nama_paket_layanan",
          "pl.harga as master_harga_paket",
          "prod.nama as nama_produk",
          "prod.satuan",
          "dt.qty",
          "dt.harga_satuan",
          "dt.subtotal",
          "dt.kode_promo",
          "dt.nama_promo",
          "dt.jenis_diskon",
          "dt.nilai_diskon",
          DB.raw("COALESCE(dt.diskon, 0) as diskon"),
          DB.raw("COALESCE(dt.subtotal_setelah_diskon, dt.subtotal) as subtotal_setelah_diskon")
        )
        .orderBy("dt.id", "asc");

      allDetails.forEach((d) => {
        if (!detailsMap[d.kode_transaksi]) {
          detailsMap[d.kode_transaksi] = [];
        }
        const netSubtotal =
          d.subtotal_setelah_diskon !== undefined && d.subtotal_setelah_diskon !== null
            ? parseFloat(d.subtotal_setelah_diskon)
            : parseFloat(d.subtotal || 0);

        const qty = parseInt(d.qty || 1, 10);
        let hargaSatuan = parseFloat(d.harga_satuan || 0);
        let diskonNominal = parseFloat(d.diskon || 0);
        let nilaiDiskon = d.nilai_diskon != null ? parseFloat(d.nilai_diskon) : null;
        let jenisDiskon = d.jenis_diskon || null;
        const isIncludeTreatment = jenisDiskon === 'include_treatment' || (d.nama_promo || '').toLowerCase().includes('include');

        // Harga asli sebelum diskon
        let hargaAsli = hargaSatuan * qty;
        if (isIncludeTreatment) {
          const nominalKonsul = parseFloat(d.master_harga_layanan || d.harga_satuan || 0) || (diskonNominal > 0 ? diskonNominal : 0);
          hargaAsli = nominalKonsul > 0 ? nominalKonsul : (hargaSatuan > 0 ? hargaSatuan : 30000);
          diskonNominal = hargaAsli;
          nilaiDiskon = 100;
          jenisDiskon = 'persen';
        } else if (nilaiDiskon && jenisDiskon === 'persen' && nilaiDiskon > 0 && nilaiDiskon < 100) {
          hargaAsli = Math.round(netSubtotal / (1 - nilaiDiskon / 100));
        } else if (diskonNominal > 0 && hargaAsli <= netSubtotal) {
          hargaAsli = netSubtotal + diskonNominal;
        }

        // Teks diskon
        let diskonText = null;
        if (isIncludeTreatment || (nilaiDiskon === 100 && netSubtotal === 0)) {
          diskonText = '100%';
        } else if (nilaiDiskon && nilaiDiskon > 0) {
          diskonText = jenisDiskon === 'nominal' ? `-${diskonNominal}` : `${Math.round(nilaiDiskon)}%`;
        } else if (diskonNominal > 0 && hargaAsli > netSubtotal) {
          const pct = Math.round((diskonNominal / hargaAsli) * 100);
          diskonText = pct > 0 ? `${pct}%` : null;
        }

        detailsMap[d.kode_transaksi].push({
          kode_detail_transaksi: d.kode_detail_transaksi,
          jenis: d.kode_layanan ? "layanan" : "produk",
          kode: d.kode_layanan || d.kode_produk,
          nama: d.nama_layanan_single || d.nama_paket_layanan || d.nama_produk || "-",
          satuan: d.satuan || (d.kode_layanan ? "tindakan" : "pcs"),
          qty,
          harga_satuan: hargaSatuan,
          harga_asli: hargaAsli,
          diskon: diskonNominal,
          nilai_diskon: nilaiDiskon,
          jenis_diskon: jenisDiskon,
          diskon_text: diskonText,
          nama_promo: d.nama_promo || null,
          subtotal: netSubtotal,
          subtotal_setelah_diskon: netSubtotal,
        });
      });
    }

    const dataFormatted = vaTransaksi.map((tr) => ({
      ...tr,
      total_harga: parseFloat(tr.total_harga || 0),
      total_diskon: parseFloat(tr.total_diskon || 0),
      total_bayar: parseFloat(tr.total_bayar || 0),
      details: detailsMap[tr.kode_transaksi] || [],
    }));

    return res.status(200).json({
      status: status.SUKSES,
      message: "Data laporan transaksi berhasil diambil",
      datetime: formatDateSystem(),
      data: dataFormatted,
      total_data: totalData,
    });
  } catch (error) {
    const oResult = {
      status: status.BAD_REQUEST,
      message: "Gagal mengambil data laporan transaksi",
      datetime: formatDateSystem(),
    };
    Logging(error, { file: "/master/rekam_medis/transaksi_pasien.js", func: "laporan_transaksi", user: username });
    return res.status(500).json(oResult);
  }
});

export default router;
