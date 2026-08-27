/**
 * @copyright (c) 2026 PT Marstech Global (info@marstech.co.id)
 * @project Sistem Klinik
 * @file antrian_layanan_data.js
 * @description Endpoint untuk mengambil data antrian layanan hari ini + JOIN trx_kunjungan, mst_pasien, mst_layanan, mst_paket_layanan, mst_detail_paket_layanan
 *
 * @author Antigravity
 * @created 2026-08-21
 */

import express from "express";
import DB from "../../../../core/config/knex.js";
import { formatDateSystem } from "../../components/tools/date_tools.js";
import { Logging } from "../../components/tools/servertool.js";
import { status } from "../../components/tools/general.js";

const router = express.Router();

const handleGetData = async (req, res) => {
  const oPayload = { ...req.query, ...req.body };
  const username = req?.auth?.username || "";

  const hasPagination = oPayload.page !== undefined || oPayload.perPage !== undefined;
  const keyword = (oPayload.keyword || "").trim();
  const filterStatus = oPayload.status || null; // menunggu, dipanggil, selesai, batal
  const filterJenis = oPayload.jenis_layanan || oPayload.jenis || null; // layanan, paket
  const filterKodeRuangan = oPayload.kode_ruangan || null;
  const filterTanggal = oPayload.tanggal || new Date().toISOString().slice(0, 10);
  const sortField = oPayload.sortField || "al.nomor_antrian";
  const sortOrder = oPayload.sortOrder || "asc";

  try {
    const baseQuery = DB("trx_antrian_layanan as al")
      .leftJoin("trx_kunjungan as k", "al.kode_kunjungan", "k.kode_kunjungan")
      .leftJoin("mst_pasien as p", "k.no_rm", "p.no_rm")
      .leftJoin("trx_detail_antrian_layanan as dal", "al.kode_antrian_layanan", "dal.kode_antrian_layanan")
      .leftJoin("mst_ruangan as ral", "al.kode_ruangan", "ral.kode_ruangan")
      .groupBy("al.id", "k.id", "p.id", "ral.id")
      .modify((qb) => {
        if (filterTanggal) {
          qb.whereRaw("DATE(al.created_at) = ?", [filterTanggal]);
        }
        if (filterStatus) {
          qb.where("al.status", filterStatus);
        }
        if (filterKodeRuangan) {
          qb.where("al.kode_ruangan", filterKodeRuangan);
        }
        if (keyword) {
          const lower = keyword.toLowerCase();
          qb.where(function () {
            this.whereRaw("LOWER(al.nomor_antrian) LIKE ?", [`%${lower}%`])
              .orWhereRaw("LOWER(al.kode_antrian_layanan) LIKE ?", [`%${lower}%`])
              .orWhereRaw("LOWER(al.kode_kunjungan) LIKE ?", [`%${lower}%`])
              .orWhereRaw("LOWER(k.no_rm) LIKE ?", [`%${lower}%`])
              .orWhereRaw("LOWER(p.nama) LIKE ?", [`%${lower}%`])
              .orWhereRaw("LOWER(dal.nama_layanan) LIKE ?", [`%${lower}%`]);
          });
        }
      });

    let totalRecords = 0;
    let vaData = [];

    const selectFields = [
      "al.id",
      "al.kode_antrian_layanan",
      "al.kode_kunjungan",
      "al.nomor_antrian",
      "al.status",
      "al.dipanggil_at",
      "al.selesai_at",
      "al.created_at",
      "k.no_rm",
      "k.jam_datang",
      "p.nama as nama_pasien",
      "p.no_hp",
      DB.raw("COALESCE(al.kode_ruangan, 'RG-01') as kode_ruangan"),
      DB.raw("COALESCE(ral.nama_ruangan, al.nama_ruangan, 'Ruang Treatment') as nama_ruangan"),
      DB.raw("GROUP_CONCAT(DISTINCT dal.jenis_layanan ORDER BY dal.id ASC SEPARATOR ', ') as jenis_layanan"),
      DB.raw("GROUP_CONCAT(DISTINCT dal.kode_layanan ORDER BY dal.id ASC SEPARATOR ', ') as kode_layanan"),
      DB.raw("GROUP_CONCAT(DISTINCT dal.nama_layanan ORDER BY dal.id ASC SEPARATOR ', ') as nama_layanan"),
    ];

    if (hasPagination) {
      const countResult = await baseQuery.clone().count("al.id as total").first();
      totalRecords = parseInt(countResult?.total || 0, 10);

      const page = Math.max(1, parseInt(oPayload.page || 1, 10));
      const perPage = Math.max(1, Math.min(100, parseInt(oPayload.perPage || 10, 10)));
      const offset = (page - 1) * perPage;

      vaData = await baseQuery
        .clone()
        .select(selectFields)
        .orderBy(sortField, sortOrder)
        .offset(offset)
        .limit(perPage);
    } else {
      vaData = await baseQuery
        .clone()
        .select(selectFields)
        .orderBy("al.nomor_antrian", "asc");

      totalRecords = vaData.length;
    }

    // Attach details from trx_detail_antrian_layanan
    const kodeAntrianList = vaData.map((d) => d.kode_antrian_layanan).filter(Boolean);
    if (kodeAntrianList.length > 0) {
      const detailsList = await DB("trx_detail_antrian_layanan")
        .whereIn("kode_antrian_layanan", kodeAntrianList);

      const detailMap = {};
      for (const det of detailsList) {
        if (!detailMap[det.kode_antrian_layanan]) {
          detailMap[det.kode_antrian_layanan] = [];
        }
        detailMap[det.kode_antrian_layanan].push(det);
      }

      vaData = vaData.map((item) => ({
        ...item,
        details: detailMap[item.kode_antrian_layanan] || [],
      }));
    }

    return res.status(200).json({
      status: status.SUKSES,
      message: "OK",
      datetime: formatDateSystem(),
      total_data: totalRecords,
      data: vaData,
    });
  } catch (error) {
    Logging(error, { file: "/master/antrian_layanan/antrian_layanan_data.js", func: "getData", request: oPayload, response: {}, user: username });
    return res.status(500).json({
      status: status.BAD_REQUEST,
      message: "Gagal memuat data antrian layanan",
      datetime: formatDateSystem(),
    });
  }
};

router.post("/", handleGetData);
router.get("/", handleGetData);
export default router;
