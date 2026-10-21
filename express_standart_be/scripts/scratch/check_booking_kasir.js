import DB from "../../core/config/knex.js";

async function main() {
  const bkg = await DB("trx_booking as b")
    .join("mst_pasien as p", "b.no_rm", "p.no_rm")
    .where("b.kode_booking", "BKG-20261024-0001")
    .select("b.*", "p.nama as nama_pasien")
    .first();

  console.log("=== BOOKING DETAIL ===");
  console.log(bkg);

  // Cek apakah ada di trx_transaksi
  const trxRow = await DB("trx_transaksi")
    .where("kode_booking", "BKG-20261024-0001")
    .first();
  console.log("=== TRX TRANSAKSI ROW ===");
  console.log(trxRow);

  // Cek apakah ada di trx_detail_booking
  const details = await DB("trx_detail_booking")
    .where("kode_booking", "BKG-20261024-0001");
  console.log("=== TRX DETAIL BOOKING ===");
  console.log(details);

  process.exit(0);
}

main().catch(console.error);
