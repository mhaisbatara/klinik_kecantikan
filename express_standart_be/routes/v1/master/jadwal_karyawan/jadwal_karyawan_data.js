import express from "express";
import DB from "../../../../core/config/knex.js";
import { formatDateSystem } from "../../components/tools/date_tools.js";
import { Logging } from "../../components/tools/servertool.js";
import { status } from "../../components/tools/general.js";

const router = express.Router();

router.post("/", async (req, res) => {
  const oPayload = req.body;
  const username = req?.auth?.username || "";
  const keyword = oPayload.keyword || "";
  const filterHari = oPayload.hari || null;
  const filterStatus = oPayload.status || null;
  const page = parseInt(oPayload.page) || 1;
  const perPage = parseInt(oPayload.perPage) || 10;
  const hasPagination = oPayload.page !== undefined || oPayload.perPage !== undefined;

  try {
    const baseQuery = DB("mst_jadwal_karyawan as j")
      .leftJoin("mst_karyawan as k", "j.no_sip", "k.no_sip")
      .modify((qb) => {
        if (keyword) {
          const lower = keyword.toLowerCase();
          qb.where(function () {
            this.whereRaw("LOWER(j.kode_jadwal) LIKE ?", [`%${lower}%`])
              .orWhereRaw("LOWER(j.no_sip) LIKE ?", [`%${lower}%`])
              .orWhereRaw("LOWER(k.nama) LIKE ?", [`%${lower}%`]);
          });
        }
        if (filterHari) qb.where("j.hari", filterHari);
        if (filterStatus) qb.where("j.status", filterStatus);
      });

    const selectFields = [
      "j.id",
      "j.kode_jadwal",
      "j.no_sip",
      "k.nama as nama_karyawan",
      "k.jabatan",
      "j.hari",
      "j.jam_mulai",
      "j.jam_selesai",
      "j.kuota",
      "j.status",
      "j.created_by",
      "j.created_at",
      "j.updated_by",
      "j.updated_at"
    ];

    let totalRecords = 0, vaData = [];
    if (hasPagination) {
      const offset = (page - 1) * perPage;
      const countResult = await baseQuery.clone().count("j.id as total").first();
      totalRecords = parseInt(countResult.total || 0);
      vaData = await baseQuery.clone().select(selectFields).orderBy("j.created_at", "desc").limit(perPage).offset(offset);
    } else {
      vaData = await baseQuery.clone().select(selectFields).orderBy("j.created_at", "desc");
      totalRecords = vaData.length;
    }

    return res.status(200).json({
      status: status.SUKSES,
      message: "Data ditemukan",
      datetime: formatDateSystem(),
      data: vaData,
      total_data: totalRecords
    });
  } catch (error) {
    const oResult = { status: status.BAD_REQUEST, message: "Sistem sedang maintenance", datetime: formatDateSystem() };
    Logging(error, { file: "/master/jadwal_karyawan/jadwal_karyawan_data.js", func: "data", request: oPayload, response: oResult, user: username });
    return res.status(500).json(oResult);
  }
});

export default router;
