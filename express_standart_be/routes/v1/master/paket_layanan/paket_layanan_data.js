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
  const filterStatus = oPayload.status || null;
  const page = parseInt(oPayload.page) || 1;
  const perPage = parseInt(oPayload.perPage) || 10;
  const hasPagination = oPayload.page !== undefined || oPayload.perPage !== undefined;

  try {
    const hasTglMulai = await DB.schema.hasColumn("mst_paket_layanan", "tanggal_mulai");
    if (!hasTglMulai) {
      await DB.schema.table("mst_paket_layanan", (table) => {
        table.date("tanggal_mulai").nullable();
        table.date("tanggal_selesai").nullable();
      });
    }

    // Auto nonaktifkan paket yang sudah melewati masa berlaku (sisa hari <= 0)
    const todayStr = formatDateSystem(new Date(), "yyyy-MM-dd");
    await DB("mst_paket_layanan")
      .where("status", "aktif")
      .whereRaw(
        "DATE(COALESCE(tanggal_selesai, DATE_ADD(COALESCE(tanggal_mulai, created_at), INTERVAL masa_berlaku_hari DAY))) < ?",
        [todayStr]
      )
      .update({
        status: "nonaktif",
        updated_at: formatDateSystem(),
      });

    const baseQuery = DB("mst_paket_layanan as p")
      .leftJoin("mst_ruangan as r", "p.kode_ruangan", "r.kode_ruangan")
      .modify((qb) => {
        if (keyword) {
          const lower = keyword.toLowerCase();
          qb.where(function () {
            this.whereRaw("LOWER(p.kode_paket_layanan) LIKE ?", [`%${lower}%`])
              .orWhereRaw("LOWER(p.nama) LIKE ?", [`%${lower}%`])
              .orWhereRaw("LOWER(r.nama_ruangan) LIKE ?", [`%${lower}%`]);
          });
        }
        if (filterStatus) qb.where("p.status", filterStatus);
      });

    const selectFields = [
      "p.kode_paket_layanan",
      "p.nama",
      "p.harga_paket",
      "p.masa_berlaku_hari",
      DB.raw("COALESCE(DATE_FORMAT(p.tanggal_mulai, '%Y-%m-%d'), DATE_FORMAT(p.created_at, '%Y-%m-%d')) as tanggal_mulai"),
      DB.raw("COALESCE(DATE_FORMAT(p.tanggal_selesai, '%Y-%m-%d'), DATE_FORMAT(DATE_ADD(COALESCE(p.tanggal_mulai, p.created_at), INTERVAL p.masa_berlaku_hari DAY), '%Y-%m-%d')) as tanggal_selesai"),
      DB.raw("GREATEST(0, DATEDIFF(COALESCE(p.tanggal_selesai, DATE_ADD(COALESCE(p.tanggal_mulai, p.created_at), INTERVAL p.masa_berlaku_hari DAY)), CURDATE())) as sisa_hari"),
      "p.kode_ruangan",
      "r.nama_ruangan as nama_ruangan",
      "p.status",
      "p.created_by",
      "p.created_at",
      "p.updated_at",
    ];

    let totalRecords = 0;
    let vaData = [];

    if (hasPagination) {
      const offset = (page - 1) * perPage;
      const countResult = await baseQuery.clone().count("* as total").first();
      totalRecords = parseInt(countResult.total || 0);
      vaData = await baseQuery.clone().select(selectFields).orderBy("p.created_at", "desc").limit(perPage).offset(offset);
    } else {
      vaData = await baseQuery.clone().select(selectFields).orderBy("p.created_at", "desc");
      totalRecords = vaData.length;
    }

    // Load detail items for each paket
    for (const item of vaData) {
      const details = await DB("mst_detail_paket_layanan as d")
        .leftJoin("mst_layanan as l", "d.kode_layanan", "l.kode_layanan")
        .where("d.kode_paket_layanan", item.kode_paket_layanan)
        .select("d.kode_detail_paket_layanan", "d.kode_layanan", "l.nama as nama_layanan", "d.jumlah_sesi");
      item.details = details;
    }

    return res.status(200).json({ status: status.SUKSES, message: "Data ditemukan", datetime: formatDateSystem(), data: vaData, total_data: totalRecords });
  } catch (error) {
    const oResult = { status: status.BAD_REQUEST, message: "Sistem sedang maintenance", datetime: formatDateSystem() };
    Logging(error, { file: "/master/paket_layanan/paket_layanan_data.js", func: "data", request: oPayload, response: oResult, user: username });
    return res.status(500).json(oResult);
  }
});

export default router;
