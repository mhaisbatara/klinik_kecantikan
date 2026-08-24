/**
 * @copyright (c) 2026 PT Marstech Global (info@marstech.co.id)
 * @project Sistem Klinik
 * @file pendaftaran_pasien_ambil_antrian_layanan.js
 * @description Endpoint terpadu untuk menerbitkan trx_kunjungan + trx_antrian_awal + trx_antrian_layanan dalam 1 transaksi DB tunggal
 *
 * @author Antigravity
 * @created 2026-08-21
 */

import express from "express";
import DB from "../../../../core/config/knex.js";
import { formatDateSystem } from "../../components/tools/date_tools.js";
import { Logging, ChangesLog } from "../../components/tools/servertool.js";
import { status } from "../../components/tools/general.js";

const router = express.Router();

router.post("/", async (req, res) => {
  const { body } = req;
  const oPayload = body || {};
  const username = req?.auth?.username || "system";

  try {
    const no_rm = (oPayload.no_rm || "").trim();
    const items = Array.isArray(oPayload.items) ? oPayload.items : [];

    if (!no_rm) {
      return res.status(422).json({
        status: status.BAD_REQUEST,
        message: "Nomor RM pasien wajib diisi",
        datetime: formatDateSystem(),
      });
    }

    // 1. Validasi Pasien Aktif
    const pasien = await DB("mst_pasien")
      .where("no_rm", no_rm)
      .where("status", "aktif")
      .first();

    if (!pasien) {
      return res.status(404).json({
        status: status.BAD_REQUEST,
        message: `Pasien dengan Nomor RM ${no_rm} tidak ditemukan atau tidak aktif`,
        datetime: formatDateSystem(),
      });
    }

    let resultData = null;
    const vaCreatedAntrianLayanan = [];

    // 2. Eksekusi 1 Transaksi DB Atomic
    await DB.transaction(async (trx) => {
      const now = new Date();
      const todayYmd = now.toISOString().slice(0, 10);
      const todayStr = todayYmd.replace(/-/g, "");

      // A. Generate Kode Kunjungan (KJ-YYYYMMDD-001)
      const prefixKunjungan = `KJ-${todayStr}-`;
      const lastKunjungan = await trx("trx_kunjungan")
        .where("kode_kunjungan", "like", `${prefixKunjungan}%`)
        .orderBy("id", "desc")
        .first();

      let nextKjSeq = 1;
      if (lastKunjungan && lastKunjungan.kode_kunjungan) {
        const parts = lastKunjungan.kode_kunjungan.split("-");
        const num = parseInt(parts[parts.length - 1], 10);
        if (!isNaN(num)) {
          nextKjSeq = num + 1;
        }
      }
      const cKodeKunjungan = `${prefixKunjungan}${String(nextKjSeq).padStart(3, "0")}`;
      const jamDatang = now.toTimeString().slice(0, 8);

      // B. Insert trx_kunjungan
      const oKunjunganData = {
        kode_kunjungan: cKodeKunjungan,
        no_rm: pasien.no_rm,
        tanggal_kunjungan: todayYmd,
        jam_datang: jamDatang,
        status: "berlangsung",
        tz: oPayload.tz || "Asia/Jakarta",
        created_by: username,
        created_at: formatDateSystem(),
        updated_by: username,
        updated_at: formatDateSystem(),
      };

      await trx("trx_kunjungan").insert(oKunjunganData);

      // C. Alokasi 1 trx_antrian_awal status 'tersedia' terkecil
      const antrianAwalTersedia = await trx("trx_antrian_awal")
        .where("status", "tersedia")
        .orderBy("id", "asc")
        .first();

      if (!antrianAwalTersedia) {
        const err = new Error("Nomor antrian hari ini tidak tersedia / sudah habis. Silakan buat antrian awal terlebih dahulu pada menu Antrian Awal.");
        err.statusCode = 422;
        throw err;
      }

      await trx("trx_antrian_awal")
        .where("id", antrianAwalTersedia.id)
        .update({
          status: "terpakai",
          diambil_at: formatDateSystem(),
          no_rm: pasien.no_rm,
          kode_kunjungan: cKodeKunjungan,
          updated_by: username,
          updated_at: formatDateSystem(),
        });

      // D. Insert trx_antrian_layanan (jika ada items, 1 record per pendaftaran)
      if (items.length > 0) {
        const prefixAntrianLayanan = `AL-${todayStr}-`;

        const lastAntrianLayanan = await trx("trx_antrian_layanan")
          .where("kode_antrian_layanan", "like", `${prefixAntrianLayanan}%`)
          .orderBy("id", "desc")
          .first();

        let nextSeq = 1;
        if (lastAntrianLayanan && lastAntrianLayanan.kode_antrian_layanan) {
          const parts = lastAntrianLayanan.kode_antrian_layanan.split("-");
          const num = parseInt(parts[parts.length - 1], 10);
          if (!isNaN(num)) {
            nextSeq = num + 1;
          }
        }

        const lastNoAntrian = await trx("trx_antrian_layanan")
          .where("created_at", ">=", todayYmd + " 00:00:00")
          .orderBy("id", "desc")
          .first();

        let nextNo = 1;
        if (lastNoAntrian && lastNoAntrian.nomor_antrian) {
          const num = parseInt(lastNoAntrian.nomor_antrian, 10);
          if (!isNaN(num)) {
            nextNo = num + 1;
          }
        }

        const cNomorAntrianSesi = String(nextNo).padStart(2, "0");

        const detailLayananList = [];
        let totalHarga = 0;
        let mainJenis = "";
        let mainKodeRuangan = "";
        let mainNamaRuangan = "";

        for (const item of items) {
          const jenis = (item.jenis_layanan || item.jenis || "layanan").toLowerCase();
          const kodeLayanan = (item.kode_layanan || item.kode || "").trim();

          if (!["layanan", "paket"].includes(jenis) || !kodeLayanan) {
            continue;
          }

          let namaLayanan = "";
          let hargaLayanan = 0;
          let kodeRuangan = "";
          let namaRuangan = "";

          if (jenis === "layanan") {
            const lay = await trx("mst_layanan as l")
              .leftJoin("mst_ruangan as r", "l.kode_ruangan", "r.kode_ruangan")
              .where("l.kode_layanan", kodeLayanan)
              .where("l.status", "aktif")
              .select("l.nama", "l.harga", "l.kode_ruangan", "r.nama_ruangan as nama_ruangan")
              .first();

            if (!lay) {
              const err = new Error(`Layanan ${kodeLayanan} tidak ditemukan atau nonaktif`);
              err.statusCode = 422;
              throw err;
            }
            namaLayanan = lay.nama;
            hargaLayanan = parseFloat(lay.harga || 0);
            kodeRuangan = lay.kode_ruangan || "";
            namaRuangan = lay.nama_ruangan || lay.kode_ruangan || "Ruang Treatment";
          } else {
            const pkt = await trx("mst_paket_layanan as p")
              .leftJoin("mst_ruangan as r", "p.kode_ruangan", "r.kode_ruangan")
              .where("p.kode_paket_layanan", kodeLayanan)
              .where("p.status", "aktif")
              .select("p.nama", "p.harga_paket", "p.kode_ruangan", "r.nama_ruangan as nama_ruangan")
              .first();

            if (!pkt) {
              const err = new Error(`Paket ${kodeLayanan} tidak ditemukan atau nonaktif`);
              err.statusCode = 422;
              throw err;
            }
            namaLayanan = pkt.nama;
            hargaLayanan = parseFloat(pkt.harga_paket || 0);
            kodeRuangan = pkt.kode_ruangan || "";
            namaRuangan = pkt.nama_ruangan || pkt.kode_ruangan || "Ruang Treatment";
          }

          if (!mainJenis) mainJenis = jenis;
          if (!mainKodeRuangan) mainKodeRuangan = kodeRuangan;
          if (!mainNamaRuangan) mainNamaRuangan = namaRuangan;

          totalHarga += hargaLayanan;
          detailLayananList.push({
            jenis_layanan: jenis,
            kode_layanan: kodeLayanan,
            nama_layanan: namaLayanan,
            harga: hargaLayanan,
            kode_ruangan: kodeRuangan,
            nama_ruangan: namaRuangan,
          });
        }

        if (detailLayananList.length > 0) {
          const seqPadded = String(nextSeq).padStart(3, "0");
          const cKodeAntrianLayanan = `${prefixAntrianLayanan}${seqPadded}`;
          const combinedNamaLayanan = detailLayananList.map((d) => d.nama_layanan).join(", ");
          const combinedKodeLayanan = detailLayananList.map((d) => d.kode_layanan).join(", ");

          const oInsertLayanan = {
            kode_antrian_layanan: cKodeAntrianLayanan,
            kode_kunjungan: cKodeKunjungan,
            jenis_layanan: mainJenis,
            kode_layanan: combinedKodeLayanan.length > 100 ? combinedKodeLayanan.slice(0, 97) + "..." : combinedKodeLayanan,
            nama_layanan: combinedNamaLayanan,
            detail_layanan: JSON.stringify(detailLayananList),
            nomor_antrian: cNomorAntrianSesi,
            kode_ruangan: mainKodeRuangan,
            nama_ruangan: mainNamaRuangan,
            status: "menunggu",
            tz: oPayload.tz || "Asia/Jakarta",
            created_by: username,
            created_at: formatDateSystem(),
            updated_by: username,
            updated_at: formatDateSystem(),
          };

          await trx("trx_antrian_layanan").insert(oInsertLayanan);

          vaCreatedAntrianLayanan.push({
            ...oInsertLayanan,
            nama_layanan: combinedNamaLayanan,
            harga: totalHarga,
            detail_items: detailLayananList,
          });
        }
      }

      // Audit Log
      await ChangesLog(
        {
          description: `Pendaftaran Kunjungan Pasien (${pasien.no_rm} - ${pasien.nama}) Kunjungan (${cKodeKunjungan}) Total ${vaCreatedAntrianLayanan.length} Layanan/Paket`,
          tableName: "trx_kunjungan",
          referenceCode: cKodeKunjungan,
          action: "CREATE",
          dataBefore: null,
          dataAfter: {
            kunjungan: oKunjunganData,
            antrian_awal: antrianAwalTersedia,
            antrian_layanan: vaCreatedAntrianLayanan,
          },
          user: username,
          tz: oPayload.tz || "Asia/Jakarta",
        },
        trx
      );

      resultData = {
        kode_kunjungan: cKodeKunjungan,
        no_rm: pasien.no_rm,
        nama_pasien: pasien.nama,
        nomor_antrian_awal: antrianAwalTersedia.nomor_antrian,
        kode_antrian_awal: antrianAwalTersedia.kode_antrian_awal,
        tanggal_kunjungan: todayYmd,
        jam_datang: jamDatang,
        antrian_layanan: vaCreatedAntrianLayanan,
      };
    });

    const msg = items.length > 0
      ? `Pendaftaran kunjungan & ${vaCreatedAntrianLayanan.length} nomor antrean layanan berhasil diterbitkan`
      : `Pendaftaran kunjungan pasien ${pasien.nama} berhasil diterbitkan (Tanpa Layanan)`;

    return res.status(200).json({
      status: status.SUKSES,
      message: msg,
      datetime: formatDateSystem(),
      data: resultData,
    });
  } catch (error) {
    if (error.statusCode === 422) {
      return res.status(422).json({
        status: status.BAD_REQUEST,
        message: error.message,
        datetime: formatDateSystem(),
      });
    }

    const oResult = {
      status: status.BAD_REQUEST,
      message: error.message || "Sistem sedang maintenance harap tunggu sebentar",
      datetime: formatDateSystem(),
    };

    Logging(error, {
      file: "/master/pendaftaran_pasien/pendaftaran_pasien_ambil_antrian_layanan.js",
      func: "ambil_antrian_layanan_terpadu",
      request: body,
      response: oResult,
      user: username,
    });

    return res.status(500).json(oResult);
  }
});

export default router;
