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

      // C. Alokasi 1 trx_antrian_awal status 'tersedia' terkecil (Auto-generate jika belum ada)
      let antrianAwalTersedia = await trx("trx_antrian_awal")
        .where("status", "tersedia")
        .orderBy("id", "asc")
        .first();

      if (!antrianAwalTersedia) {
        const lastRecord = await trx("trx_antrian_awal")
          .where("created_at", ">=", todayYmd + " 00:00:00")
          .orderBy("id", "desc")
          .first();

        let nextNum = 1;
        if (lastRecord && lastRecord.nomor_antrian) {
          const parsed = parseInt(lastRecord.nomor_antrian, 10);
          if (!isNaN(parsed)) nextNum = parsed + 1;
        }

        const cNoAntrianAwal = String(nextNum).padStart(2, "0");
        const prefixAntrianAwal = `A-${todayStr}-`;
        const cKodeAntrianAwal = `${prefixAntrianAwal}${String(nextNum).padStart(3, "0")}`;

        const [newAntrianAwalId] = await trx("trx_antrian_awal").insert({
          kode_antrian_awal: cKodeAntrianAwal,
          nomor_antrian: cNoAntrianAwal,
          status: "terpakai",
          diambil_at: formatDateSystem(),
          no_rm: pasien.no_rm,
          kode_kunjungan: cKodeKunjungan,
          tz: oPayload.tz || "Asia/Jakarta",
          created_by: username,
          created_at: formatDateSystem(),
          updated_by: username,
          updated_at: formatDateSystem(),
        });

        antrianAwalTersedia = {
          id: newAntrianAwalId,
          kode_antrian_awal: cKodeAntrianAwal,
          nomor_antrian: cNoAntrianAwal,
        };
      } else {
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
      }

      // D. Insert trx_antrian_layanan (jika ada items, diproses & dikelompokkan per ruangan)
      if (items.length > 0) {
        const prefixAntrianLayanan = `AL-${todayStr}-`;

        // Ambil promo aktif hari ini untuk referensi kasir
        const activePromos = await trx("mst_promo as p")
          .join("mst_detail_promo as dp", "p.kode_promo", "dp.kode_promo")
          .where("p.status", "aktif")
          .where("dp.status", "aktif")
          .whereRaw("DATE(p.tanggal_mulai) <= ?", [todayYmd])
          .whereRaw("DATE(p.tanggal_selesai) >= ?", [todayYmd])
          .select(
            "p.kode_promo",
            "p.nama as nama_promo",
            "p.jenis_diskon",
            "p.nilai_diskon",
            "dp.jenis_item",
            "dp.kode_item"
          );

        // Bangun promoMap: key = `{jenis}_{kode_item}`
        const promoMap = {};
        for (const pr of activePromos) {
          const jenisClean = (pr.jenis_item || "").toLowerCase();
          const normJenis = jenisClean.includes("layanan")
            ? jenisClean.includes("paket") ? "paket" : "layanan"
            : jenisClean.includes("produk") ? jenisClean.includes("paket") ? "paket" : "produk" : jenisClean;
          const keys = [`${normJenis}_${pr.kode_item}`, `${jenisClean}_${pr.kode_item}`];
          for (const key of keys) {
            if (!promoMap[key]) {
              promoMap[key] = pr;
            } else {
              if (parseFloat(pr.nilai_diskon || 0) > parseFloat(promoMap[key].nilai_diskon || 0)) {
                promoMap[key] = pr;
              }
            }
          }
        }

        // 1. Validasi & Ambil Detail Semua Item (harga ASLI dari master, promo disimpan sebagai referensi)
        const processedItems = [];
        for (const item of items) {
          const jenis = (item.jenis_layanan || item.jenis || "layanan").toLowerCase();
          const kodeLayanan = (item.kode_layanan || item.kode || "").trim();

          if (!["layanan", "paket"].includes(jenis) || !kodeLayanan) {
            continue;
          }

          let namaLayanan = "";
          let hargaLayanan = 0; // Selalu harga ASLI dari master
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
            hargaLayanan = parseFloat(lay.harga || 0); // harga ASLI
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
            hargaLayanan = parseFloat(pkt.harga_paket || 0); // harga ASLI
            kodeRuangan = pkt.kode_ruangan || "";
            namaRuangan = pkt.nama_ruangan || pkt.kode_ruangan || "Ruang Treatment";
          }

          // Cari promo aktif untuk item ini (disimpan sebagai referensi kasir, tidak mengubah harga)
          const promoKey1 = `${jenis}_${kodeLayanan}`;
          const promoItem = promoMap[promoKey1] || null;

          processedItems.push({
            jenis_layanan: jenis,
            kode_layanan: kodeLayanan,
            nama_layanan: namaLayanan,
            harga: hargaLayanan,         // harga ASLI — diskon diterapkan di kasir
            kode_promo: promoItem?.kode_promo || null,
            nama_promo: promoItem?.nama_promo || null,
            jenis_diskon: promoItem?.jenis_diskon || null,
            nilai_diskon: promoItem ? parseFloat(promoItem.nilai_diskon || 0) : null,
            kode_ruangan: kodeRuangan,
            nama_ruangan: namaRuangan,
          });
        }

        // 2. Kelompokkan item berdasarkan kode_ruangan agar tiap ruangan mendapat nomor antrean tersendiri
        const groupsByRuangan = {};
        for (const pi of processedItems) {
          const key = pi.kode_ruangan || "UNASSIGNED";
          if (!groupsByRuangan[key]) {
            groupsByRuangan[key] = {
              kode_ruangan: pi.kode_ruangan,
              nama_ruangan: pi.nama_ruangan,
              items: [],
            };
          }
          groupsByRuangan[key].items.push(pi);
        }

        // 3. Insert trx_antrian_layanan per kelompok ruangan
        for (const key of Object.keys(groupsByRuangan)) {
          const group = groupsByRuangan[key];
          const groupItems = group.items;

          // Dapatkan urutan kode_antrian_layanan (global)
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
          const seqPadded = String(nextSeq).padStart(3, "0");
          const cKodeAntrianLayanan = `${prefixAntrianLayanan}${seqPadded}`;

          // Hitung nomor_antrian KHUSUS PER RUANGAN HARI INI
          let lastNoQuery = trx("trx_antrian_layanan")
            .where("created_at", ">=", todayYmd + " 00:00:00");

          if (group.kode_ruangan) {
            lastNoQuery = lastNoQuery.where("kode_ruangan", group.kode_ruangan);
          } else {
            lastNoQuery = lastNoQuery.where(function () {
              this.whereNull("kode_ruangan").orWhere("kode_ruangan", "");
            });
          }

          const lastNoAntrian = await lastNoQuery.orderBy("id", "desc").first();

          let nextNo = 1;
          if (lastNoAntrian && lastNoAntrian.nomor_antrian) {
            const num = parseInt(lastNoAntrian.nomor_antrian, 10);
            if (!isNaN(num)) {
              nextNo = num + 1;
            }
          }
          const cNomorAntrianSesi = String(nextNo).padStart(2, "0");

          const combinedNamaLayanan = groupItems.map((d) => d.nama_layanan).join(", ");
          const combinedKodeLayanan = groupItems.map((d) => d.kode_layanan).join(", ");
          const totalHargaGroup = groupItems.reduce((sum, d) => sum + d.harga, 0);

          const oInsertLayanan = {
            kode_antrian_layanan: cKodeAntrianLayanan,
            kode_kunjungan: cKodeKunjungan,
            nomor_antrian: cNomorAntrianSesi,
            kode_ruangan: group.kode_ruangan,
            nama_ruangan: group.nama_ruangan,
            status: "menunggu",
            tz: oPayload.tz || "Asia/Jakarta",
            created_by: username,
            created_at: formatDateSystem(),
            updated_by: username,
            updated_at: formatDateSystem(),
          };

          await trx("trx_antrian_layanan").insert(oInsertLayanan);

          // Insert detail rows into trx_detail_antrian_layanan for each selected service
          let dSeq = 1;
          const vaInsertDetail = [];
          for (const item of groupItems) {
            const cKodeDetailAntrian = `DAL-${todayStr}-${seqPadded}-${String(dSeq).padStart(2, "0")}`;
            dSeq++;
            vaInsertDetail.push({
              kode_detail_antrian_layanan: cKodeDetailAntrian,
              kode_antrian_layanan: cKodeAntrianLayanan,
              kode_kunjungan: cKodeKunjungan,
              jenis_layanan: item.jenis_layanan || "layanan",
              kode_layanan: item.kode_layanan,
              nama_layanan: item.nama_layanan,
              harga: item.harga || 0,         // harga ASLI — diskon diterapkan di kasir
              kode_promo: item.kode_promo || null,
              nama_promo: item.nama_promo || null,
              jenis_diskon: item.jenis_diskon || null,
              nilai_diskon: item.nilai_diskon ?? null,
              kode_ruangan: group.kode_ruangan,
              nama_ruangan: group.nama_ruangan,
              tz: oPayload.tz || "Asia/Jakarta",
              created_by: username,
              created_at: formatDateSystem(),
              updated_by: username,
              updated_at: formatDateSystem(),
            });
          }
          if (vaInsertDetail.length > 0) {
            await trx("trx_detail_antrian_layanan").insert(vaInsertDetail);
          }

          vaCreatedAntrianLayanan.push({
            ...oInsertLayanan,
            nama_layanan: combinedNamaLayanan,
            harga: totalHargaGroup,
            detail_items: groupItems,
            details: vaInsertDetail,
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
