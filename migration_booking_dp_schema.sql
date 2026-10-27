-- Migration untuk menambahkan kolom kode_metode_pembayaran dan update ENUM status/dp_status pada trx_booking
ALTER TABLE `trx_booking` 
  ADD COLUMN IF NOT EXISTS `kode_metode_pembayaran` VARCHAR(50) DEFAULT NULL AFTER `metode_pembayaran_dp`;

ALTER TABLE `trx_booking` 
  MODIFY COLUMN `status` ENUM('menunggu','dikonfirmasi','dibatalkan','selesai','tidak_hadir') NOT NULL DEFAULT 'menunggu';

ALTER TABLE `trx_booking` 
  MODIFY COLUMN `dp_status` ENUM('belum_bayar','sudah_bayar','hangus','dipotong_treatment','bebas_dp') NOT NULL DEFAULT 'belum_bayar';
