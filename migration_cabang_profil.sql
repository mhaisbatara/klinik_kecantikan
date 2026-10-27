-- Migration: Tambah kolom profil operasional cabang ke tabel mst_cabang
-- Sesuai dengan fitur Informasi & Profil Cabang (Commit: 6e78e16)

ALTER TABLE `mst_cabang`
  ADD COLUMN `jam_buka` TIME DEFAULT '09:00:00' AFTER `pj_manager`,
  ADD COLUMN `jam_tutup` TIME DEFAULT '20:00:00' AFTER `jam_buka`,
  ADD COLUMN `hari_operasional` VARCHAR(100) DEFAULT '1,2,3,4,5,6,7' AFTER `jam_tutup`,
  ADD COLUMN `fasilitas` TEXT NULL AFTER `hari_operasional`;
