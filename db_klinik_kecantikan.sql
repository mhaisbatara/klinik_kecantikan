-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Aug 21, 2026 at 02:27 AM
-- Server version: 8.0.30
-- PHP Version: 8.2.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_klinik_kecantikan`
--

-- --------------------------------------------------------

--
-- Table structure for table `access_token`
--

CREATE TABLE `access_token` (
  `id` int NOT NULL,
  `token` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `user_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `expired` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
  `expires_at` datetime DEFAULT NULL,
  `datetime` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `access_token`
--

INSERT INTO `access_token` (`id`, `token`, `user_code`, `expired`, `expires_at`, `datetime`) VALUES
(1, '29f3b86ab89a25ab4bd75688cef2be4215c748be1f16440b7ec34211957b4bac76df5afa84c6a51b', 'USR000000', '1', '2026-08-21 11:30:35', NULL),
(2, '716dd79c99b7b6695c5a38b96840f0bc5a03db1efee8c66c111f8c676f4c406ea58ca214380afa3e', 'USR000000', '1', '2026-08-21 12:16:41', NULL),
(3, '53eb65f83444a231ca40686c131fb1a4ca692cbbd2cf7d6f10607f4d10ad4867bc096d6c8b7ac169', 'USR000000', '1', '2026-08-21 12:16:56', NULL),
(4, '84781a78faa72547737d199f5cc8bdb172b56a0b34c2d420ec8790ab0100629c91390edf17489528', 'USR000000', '1', '2026-08-21 12:22:40', NULL),
(5, 'a84c25d6e8fe638ed59b5940c8f6a5d1148b1b40f1873349aa9372aa99f691cd1eed81128ae6d79c', 'USR000000', '1', '2026-08-21 12:33:35', NULL),
(6, '1c3f9e13986c970a40132e8b257b470017dc1f979c9a355940eca5bf6954253813ce33d0b5eb838b', 'USR000000', '1', '2026-08-21 12:35:52', NULL),
(7, 'fcf6393c3e63f90c6b4576d2f0afad79f78166e648cd54f0e84d9e1b71093cab0af6497e020c881f', 'USR000000', '1', '2026-08-21 12:40:10', NULL),
(8, 'a23a84e857370673745ae306af3787ee33e06653cdc0bb573b3c1ec5ae6b30f067ddf5f626694d5e', 'USR000000', '1', '2026-08-21 12:49:05', NULL),
(9, 'f4491141c883085fdaffdcb2ac88939f196a3a245fea901c0d196e74c8b5522a043b189c3a8f6b9a', 'USR000000', '1', '2026-08-22 02:13:14', NULL),
(10, '4286aa213d7e58100b9ba73c1a119e3bc3372d9cdde8da82e7c25150c26d3dd427d137e3976977ec', 'USR000000', '0', '2026-08-22 02:24:05', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `config`
--

CREATE TABLE `config` (
  `id` int UNSIGNED NOT NULL,
  `kode` varchar(100) NOT NULL,
  `keterangan` text,
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `config`
--

INSERT INTO `config` (`id`, `kode`, `keterangan`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(1, 'msNamaPerusahaan', 'Klinik Kecantikan', 'UTC', NULL, '2026-08-20 12:37:26', NULL, '2026-08-20 12:37:26'),
(2, 'msCatatanKasir', 'Terima kasih atas kunjungan Anda', 'UTC', NULL, '2026-08-20 12:37:26', NULL, '2026-08-20 12:37:26'),
(3, 'msPPN', '11', 'UTC', NULL, '2026-08-20 12:37:26', NULL, '2026-08-20 12:37:26'),
(4, 'nominalPoint', '10000', 'UTC', NULL, '2026-08-20 12:37:26', NULL, '2026-08-20 12:37:26'),
(5, 'msVideoDisplay', '', 'UTC', NULL, '2026-08-20 12:37:26', NULL, '2026-08-20 12:37:26'),
(6, 'msLogoPerusahaan', '', 'UTC', NULL, '2026-08-20 12:37:26', NULL, '2026-08-20 12:37:26');

-- --------------------------------------------------------

--
-- Table structure for table `log`
--

CREATE TABLE `log` (
  `id` bigint NOT NULL,
  `tgl` date DEFAULT NULL,
  `controller` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `function` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `request` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `response` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `stack` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tz` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'UTC',
  `datetime` datetime DEFAULT NULL,
  `datetime_eng` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `log`
--

INSERT INTO `log` (`id`, `tgl`, `controller`, `function`, `request`, `response`, `stack`, `user`, `tz`, `datetime`, `datetime_eng`) VALUES
(1, '2026-08-20', 'info_perusahaan_data.js', 'data', '{\"kode\":[\"msNamaPerusahaan\",\"msSubNamaPerusahaan\",\"msAlamatPerusahaan\",\"msKotaPerusahaan\",\"msTeleponPerusahaan\",\"msNamaPimpinan\",\"msLogoPerusahaan\",\"msCatatanKasir\",\"msPPN\",\"nominalPoint\",\"msVideoDisplay\"]}', '{\"status\":\"99\",\"message\":\"Sistem sedang maintenance harap tunggu sebentar\",\"datetime\":\"2026-08-20 12:17:08\"}', 'Error: select `kode`, `keterangan` from `config` where `kode` in (\'msNamaPerusahaan\', \'msSubNamaPerusahaan\', \'msAlamatPerusahaan\', \'msKotaPerusahaan\', \'msTeleponPerusahaan\', \'msNamaPimpinan\', \'msLogoPerusahaan\', \'msCatatanKasir\', \'msPPN\', \'nominalPoint\', \'msVideoDisplay\') - Table \'db_klinik_kecantikan.config\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-20 12:17:08', NULL),
(2, '2026-08-20', 'info_perusahaan_data.js', 'data', '{\"kode\":[\"msNamaPerusahaan\",\"msSubNamaPerusahaan\",\"msAlamatPerusahaan\",\"msKotaPerusahaan\",\"msTeleponPerusahaan\",\"msNamaPimpinan\",\"msLogoPerusahaan\",\"msCatatanKasir\",\"msPPN\",\"nominalPoint\",\"msVideoDisplay\"]}', '{\"status\":\"99\",\"message\":\"Sistem sedang maintenance harap tunggu sebentar\",\"datetime\":\"2026-08-20 12:17:08\"}', 'Error: select `kode`, `keterangan` from `config` where `kode` in (\'msNamaPerusahaan\', \'msSubNamaPerusahaan\', \'msAlamatPerusahaan\', \'msKotaPerusahaan\', \'msTeleponPerusahaan\', \'msNamaPimpinan\', \'msLogoPerusahaan\', \'msCatatanKasir\', \'msPPN\', \'nominalPoint\', \'msVideoDisplay\') - Table \'db_klinik_kecantikan.config\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-20 12:17:08', NULL),
(3, '2026-08-20', 'info_perusahaan_data.js', 'data', '{\"kode\":[\"msNamaPerusahaan\",\"msSubNamaPerusahaan\",\"msAlamatPerusahaan\",\"msKotaPerusahaan\",\"msTeleponPerusahaan\",\"msNamaPimpinan\",\"msLogoPerusahaan\",\"msCatatanKasir\",\"msPPN\",\"nominalPoint\",\"msVideoDisplay\"]}', '{\"status\":\"99\",\"message\":\"Sistem sedang maintenance harap tunggu sebentar\",\"datetime\":\"2026-08-20 12:22:03\"}', 'Error: select `kode`, `keterangan` from `config` where `kode` in (\'msNamaPerusahaan\', \'msSubNamaPerusahaan\', \'msAlamatPerusahaan\', \'msKotaPerusahaan\', \'msTeleponPerusahaan\', \'msNamaPimpinan\', \'msLogoPerusahaan\', \'msCatatanKasir\', \'msPPN\', \'nominalPoint\', \'msVideoDisplay\') - Table \'db_klinik_kecantikan.config\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-20 12:22:03', NULL),
(4, '2026-08-20', 'info_perusahaan_data.js', 'data', '{\"kode\":[\"msNamaPerusahaan\",\"msSubNamaPerusahaan\",\"msAlamatPerusahaan\",\"msKotaPerusahaan\",\"msTeleponPerusahaan\",\"msNamaPimpinan\",\"msLogoPerusahaan\",\"msCatatanKasir\",\"msPPN\",\"nominalPoint\",\"msVideoDisplay\"]}', '{\"status\":\"99\",\"message\":\"Sistem sedang maintenance harap tunggu sebentar\",\"datetime\":\"2026-08-20 12:22:41\"}', 'Error: select `kode`, `keterangan` from `config` where `kode` in (\'msNamaPerusahaan\', \'msSubNamaPerusahaan\', \'msAlamatPerusahaan\', \'msKotaPerusahaan\', \'msTeleponPerusahaan\', \'msNamaPimpinan\', \'msLogoPerusahaan\', \'msCatatanKasir\', \'msPPN\', \'nominalPoint\', \'msVideoDisplay\') - Table \'db_klinik_kecantikan.config\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-20 12:22:41', NULL),
(5, '2026-08-20', 'info_perusahaan_data.js', 'data', '{\"kode\":[\"msNamaPerusahaan\",\"msSubNamaPerusahaan\",\"msAlamatPerusahaan\",\"msKotaPerusahaan\",\"msTeleponPerusahaan\",\"msNamaPimpinan\",\"msLogoPerusahaan\",\"msCatatanKasir\",\"msPPN\",\"nominalPoint\",\"msVideoDisplay\"]}', '{\"status\":\"99\",\"message\":\"Sistem sedang maintenance harap tunggu sebentar\",\"datetime\":\"2026-08-20 12:22:41\"}', 'Error: select `kode`, `keterangan` from `config` where `kode` in (\'msNamaPerusahaan\', \'msSubNamaPerusahaan\', \'msAlamatPerusahaan\', \'msKotaPerusahaan\', \'msTeleponPerusahaan\', \'msNamaPimpinan\', \'msLogoPerusahaan\', \'msCatatanKasir\', \'msPPN\', \'nominalPoint\', \'msVideoDisplay\') - Table \'db_klinik_kecantikan.config\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-20 12:22:41', NULL),
(6, '2026-08-20', 'info_perusahaan_data.js', 'data', '{\"kode\":[\"msNamaPerusahaan\",\"msSubNamaPerusahaan\",\"msAlamatPerusahaan\",\"msKotaPerusahaan\",\"msTeleponPerusahaan\",\"msNamaPimpinan\",\"msLogoPerusahaan\",\"msCatatanKasir\",\"msPPN\",\"nominalPoint\",\"msVideoDisplay\"]}', '{\"status\":\"99\",\"message\":\"Sistem sedang maintenance harap tunggu sebentar\",\"datetime\":\"2026-08-20 12:32:13\"}', 'Error: select `kode`, `keterangan` from `config` where `kode` in (\'msNamaPerusahaan\', \'msSubNamaPerusahaan\', \'msAlamatPerusahaan\', \'msKotaPerusahaan\', \'msTeleponPerusahaan\', \'msNamaPimpinan\', \'msLogoPerusahaan\', \'msCatatanKasir\', \'msPPN\', \'nominalPoint\', \'msVideoDisplay\') - Table \'db_klinik_kecantikan.config\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-20 12:32:13', NULL),
(7, '2026-08-20', 'info_perusahaan_data.js', 'data', '{\"kode\":[\"msNamaPerusahaan\",\"msSubNamaPerusahaan\",\"msAlamatPerusahaan\",\"msKotaPerusahaan\",\"msTeleponPerusahaan\",\"msNamaPimpinan\",\"msLogoPerusahaan\",\"msCatatanKasir\",\"msPPN\",\"nominalPoint\",\"msVideoDisplay\"]}', '{\"status\":\"99\",\"message\":\"Sistem sedang maintenance harap tunggu sebentar\",\"datetime\":\"2026-08-20 12:32:45\"}', 'Error: select `kode`, `keterangan` from `config` where `kode` in (\'msNamaPerusahaan\', \'msSubNamaPerusahaan\', \'msAlamatPerusahaan\', \'msKotaPerusahaan\', \'msTeleponPerusahaan\', \'msNamaPimpinan\', \'msLogoPerusahaan\', \'msCatatanKasir\', \'msPPN\', \'nominalPoint\', \'msVideoDisplay\') - Table \'db_klinik_kecantikan.config\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-20 12:32:45', NULL),
(8, '2026-08-20', 'info_perusahaan_data.js', 'data', '{\"kode\":[\"msNamaPerusahaan\",\"msSubNamaPerusahaan\",\"msAlamatPerusahaan\",\"msKotaPerusahaan\",\"msTeleponPerusahaan\",\"msNamaPimpinan\",\"msLogoPerusahaan\",\"msCatatanKasir\",\"msPPN\",\"nominalPoint\",\"msVideoDisplay\"]}', '{\"status\":\"99\",\"message\":\"Sistem sedang maintenance harap tunggu sebentar\",\"datetime\":\"2026-08-20 12:33:04\"}', 'Error: select `kode`, `keterangan` from `config` where `kode` in (\'msNamaPerusahaan\', \'msSubNamaPerusahaan\', \'msAlamatPerusahaan\', \'msKotaPerusahaan\', \'msTeleponPerusahaan\', \'msNamaPimpinan\', \'msLogoPerusahaan\', \'msCatatanKasir\', \'msPPN\', \'nominalPoint\', \'msVideoDisplay\') - Table \'db_klinik_kecantikan.config\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-20 12:33:04', NULL),
(9, '2026-08-20', 'info_perusahaan_data.js', 'data', '{\"kode\":[\"msNamaPerusahaan\",\"msSubNamaPerusahaan\",\"msAlamatPerusahaan\",\"msKotaPerusahaan\",\"msTeleponPerusahaan\",\"msNamaPimpinan\",\"msLogoPerusahaan\",\"msCatatanKasir\",\"msPPN\",\"nominalPoint\",\"msVideoDisplay\"]}', '{\"status\":\"99\",\"message\":\"Sistem sedang maintenance harap tunggu sebentar\",\"datetime\":\"2026-08-20 12:33:13\"}', 'Error: select `kode`, `keterangan` from `config` where `kode` in (\'msNamaPerusahaan\', \'msSubNamaPerusahaan\', \'msAlamatPerusahaan\', \'msKotaPerusahaan\', \'msTeleponPerusahaan\', \'msNamaPimpinan\', \'msLogoPerusahaan\', \'msCatatanKasir\', \'msPPN\', \'nominalPoint\', \'msVideoDisplay\') - Table \'db_klinik_kecantikan.config\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-20 12:33:13', NULL),
(10, '2026-08-20', 'info_perusahaan_data.js', 'data', '{\"kode\":[\"msNamaPerusahaan\",\"msSubNamaPerusahaan\",\"msAlamatPerusahaan\",\"msKotaPerusahaan\",\"msTeleponPerusahaan\",\"msNamaPimpinan\",\"msLogoPerusahaan\",\"msCatatanKasir\",\"msPPN\",\"nominalPoint\",\"msVideoDisplay\"]}', '{\"status\":\"99\",\"message\":\"Sistem sedang maintenance harap tunggu sebentar\",\"datetime\":\"2026-08-20 12:33:37\"}', 'Error: select `kode`, `keterangan` from `config` where `kode` in (\'msNamaPerusahaan\', \'msSubNamaPerusahaan\', \'msAlamatPerusahaan\', \'msKotaPerusahaan\', \'msTeleponPerusahaan\', \'msNamaPimpinan\', \'msLogoPerusahaan\', \'msCatatanKasir\', \'msPPN\', \'nominalPoint\', \'msVideoDisplay\') - Table \'db_klinik_kecantikan.config\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-20 12:33:37', NULL),
(11, '2026-08-20', 'info_perusahaan_data.js', 'data', '{\"kode\":[\"msNamaPerusahaan\",\"msSubNamaPerusahaan\",\"msAlamatPerusahaan\",\"msKotaPerusahaan\",\"msTeleponPerusahaan\",\"msNamaPimpinan\",\"msLogoPerusahaan\",\"msCatatanKasir\",\"msPPN\",\"nominalPoint\",\"msVideoDisplay\"]}', '{\"status\":\"99\",\"message\":\"Sistem sedang maintenance harap tunggu sebentar\",\"datetime\":\"2026-08-20 12:33:37\"}', 'Error: select `kode`, `keterangan` from `config` where `kode` in (\'msNamaPerusahaan\', \'msSubNamaPerusahaan\', \'msAlamatPerusahaan\', \'msKotaPerusahaan\', \'msTeleponPerusahaan\', \'msNamaPimpinan\', \'msLogoPerusahaan\', \'msCatatanKasir\', \'msPPN\', \'nominalPoint\', \'msVideoDisplay\') - Table \'db_klinik_kecantikan.config\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-20 12:33:37', NULL),
(12, '2026-08-20', 'info_perusahaan_data.js', 'data', '{\"kode\":[\"msNamaPerusahaan\",\"msSubNamaPerusahaan\",\"msAlamatPerusahaan\",\"msKotaPerusahaan\",\"msTeleponPerusahaan\",\"msNamaPimpinan\",\"msLogoPerusahaan\",\"msCatatanKasir\",\"msPPN\",\"nominalPoint\",\"msVideoDisplay\"]}', '{\"status\":\"99\",\"message\":\"Sistem sedang maintenance harap tunggu sebentar\",\"datetime\":\"2026-08-20 12:35:08\"}', 'Error: select `kode`, `keterangan` from `config` where `kode` in (\'msNamaPerusahaan\', \'msSubNamaPerusahaan\', \'msAlamatPerusahaan\', \'msKotaPerusahaan\', \'msTeleponPerusahaan\', \'msNamaPimpinan\', \'msLogoPerusahaan\', \'msCatatanKasir\', \'msPPN\', \'nominalPoint\', \'msVideoDisplay\') - Table \'db_klinik_kecantikan.config\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-20 12:35:08', NULL),
(13, '2026-08-20', 'info_perusahaan_data.js', 'data', '{\"kode\":[\"msNamaPerusahaan\",\"msSubNamaPerusahaan\",\"msAlamatPerusahaan\",\"msKotaPerusahaan\",\"msTeleponPerusahaan\",\"msNamaPimpinan\",\"msLogoPerusahaan\",\"msCatatanKasir\",\"msPPN\",\"nominalPoint\",\"msVideoDisplay\"]}', '{\"status\":\"99\",\"message\":\"Sistem sedang maintenance harap tunggu sebentar\",\"datetime\":\"2026-08-20 12:35:53\"}', 'Error: select `kode`, `keterangan` from `config` where `kode` in (\'msNamaPerusahaan\', \'msSubNamaPerusahaan\', \'msAlamatPerusahaan\', \'msKotaPerusahaan\', \'msTeleponPerusahaan\', \'msNamaPimpinan\', \'msLogoPerusahaan\', \'msCatatanKasir\', \'msPPN\', \'nominalPoint\', \'msVideoDisplay\') - Table \'db_klinik_kecantikan.config\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-20 12:35:53', NULL),
(14, '2026-08-20', 'info_perusahaan_data.js', 'data', '{\"kode\":[\"msNamaPerusahaan\",\"msSubNamaPerusahaan\",\"msAlamatPerusahaan\",\"msKotaPerusahaan\",\"msTeleponPerusahaan\",\"msNamaPimpinan\",\"msLogoPerusahaan\",\"msCatatanKasir\",\"msPPN\",\"nominalPoint\",\"msVideoDisplay\"]}', '{\"status\":\"99\",\"message\":\"Sistem sedang maintenance harap tunggu sebentar\",\"datetime\":\"2026-08-20 12:35:53\"}', 'Error: select `kode`, `keterangan` from `config` where `kode` in (\'msNamaPerusahaan\', \'msSubNamaPerusahaan\', \'msAlamatPerusahaan\', \'msKotaPerusahaan\', \'msTeleponPerusahaan\', \'msNamaPimpinan\', \'msLogoPerusahaan\', \'msCatatanKasir\', \'msPPN\', \'nominalPoint\', \'msVideoDisplay\') - Table \'db_klinik_kecantikan.config\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-20 12:35:53', NULL),
(15, '2026-08-20', '/pendaftaran/pendaftaran_pasien_search.js', 'get', '{\"query\":\"Test Pasien\"}', '{\"status\":\"99\",\"message\":\"Sistem sedang maintenance harap tunggu sebentar\",\"datetime\":\"2026-08-20 14:42:24\"}', 'Error: select `no_rm`, `nama`, `nik`, `tanggal_lahir`, `jenis_kelamin`, `no_hp`, `alamat` from `mst_pasien` where (LOWER(no_rm) LIKE \'%test pasien%\' or LOWER(nama) LIKE \'%test pasien%\' or LOWER(nik) LIKE \'%test pasien%\' or LOWER(no_hp) LIKE \'%test pasien%\') order by `nama` asc limit 20 - Unknown column \'alamat\' in \'field list\'\n    at Packet.asError (c:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (c:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (c:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (c:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (c:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (c:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-20 14:42:24', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `log_perubahan`
--

CREATE TABLE `log_perubahan` (
  `id` bigint NOT NULL,
  `aksi` enum('CREATE','UPDATE','DELETE','RESTORE') CHARACTER SET armscii8 COLLATE armscii8_bin NOT NULL,
  `keterangan` varchar(255) NOT NULL,
  `nama_tabel` varchar(50) NOT NULL,
  `kode_referensi` varchar(36) CHARACTER SET armscii8 COLLATE armscii8_bin NOT NULL,
  `data_sebelum` json DEFAULT NULL,
  `data_sesudah` json DEFAULT NULL,
  `tz` varchar(50) DEFAULT 'UTC',
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `created_at_eng` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `log_perubahan`
--

INSERT INTO `log_perubahan` (`id`, `aksi`, `keterangan`, `nama_tabel`, `kode_referensi`, `data_sebelum`, `data_sesudah`, `tz`, `created_by`, `created_at`, `created_at_eng`) VALUES
(1, 'CREATE', 'Tambah Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-001', NULL, '{\"tz\": \"UTC\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20 11:53:45\", \"created_by\": \"superadmin\", \"diambil_at\": null, \"updated_at\": \"2026-08-20 11:53:45\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"nomor_antrian\": \"001\", \"kode_kunjungan\": \"KJG-20260820-001\", \"kode_antrian_awal\": \"A-20260820-001\"}', 'UTC', 'superadmin', '2026-08-20 11:53:45', '2026-08-20 11:53:45'),
(2, 'CREATE', 'Tambah Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-002', NULL, '{\"tz\": \"UTC\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20 11:53:45\", \"created_by\": \"superadmin\", \"diambil_at\": null, \"updated_at\": \"2026-08-20 11:53:45\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"nomor_antrian\": \"002\", \"kode_kunjungan\": \"KJG-20260820-002\", \"kode_antrian_awal\": \"A-20260820-002\"}', 'UTC', 'superadmin', '2026-08-20 11:53:45', '2026-08-20 11:53:45'),
(3, 'UPDATE', 'Pasien mengambil nomor antrian - Nomor 001', 'trx_antrian_awal', 'A-20260820-001', '{\"id\": 3, \"tz\": \"UTC\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20T11:53:45.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T11:53:45.000Z\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"nomor_antrian\": \"001\", \"kode_kunjungan\": \"KJG-20260820-001\", \"kode_antrian_awal\": \"A-20260820-001\"}', '{\"id\": 3, \"tz\": \"UTC\", \"status\": \"terpakai\", \"created_at\": \"2026-08-20T11:53:45.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": \"2026-08-20 11:53:45\", \"no_antrian\": \"001\", \"updated_at\": \"2026-08-20 11:53:45\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"kode_antrian\": \"A-20260820-001\", \"nomor_antrian\": \"001\", \"kode_kunjungan\": \"KJG-20260820-001\", \"kode_antrian_awal\": \"A-20260820-001\"}', 'UTC', 'superadmin', '2026-08-20 11:53:45', '2026-08-20 11:53:45'),
(4, 'UPDATE', 'Panggil nomor antrian ke loket - Nomor 001', 'trx_antrian_awal', 'A-20260820-001', '{\"id\": 3, \"tz\": \"UTC\", \"status\": \"terpakai\", \"created_at\": \"2026-08-20T11:53:45.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": \"2026-08-20T11:53:45.000Z\", \"updated_at\": \"2026-08-20T11:53:45.000Z\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"nomor_antrian\": \"001\", \"kode_kunjungan\": \"KJG-20260820-001\", \"kode_antrian_awal\": \"A-20260820-001\"}', '{\"id\": 3, \"tz\": \"UTC\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-20T11:53:45.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": \"2026-08-20T11:53:45.000Z\", \"no_antrian\": \"001\", \"updated_at\": \"2026-08-20 11:53:45\", \"updated_by\": \"superadmin\", \"dipanggil_at\": \"2026-08-20 11:53:45\", \"kode_antrian\": \"A-20260820-001\", \"nomor_antrian\": \"001\", \"kode_kunjungan\": \"KJG-20260820-001\", \"kode_antrian_awal\": \"A-20260820-001\"}', 'UTC', 'superadmin', '2026-08-20 11:53:45', '2026-08-20 11:53:45'),
(5, 'UPDATE', 'Antrian selesai dilayani - Nomor 001', 'trx_antrian_awal', 'A-20260820-001', '{\"id\": 3, \"tz\": \"UTC\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-20T11:53:45.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": \"2026-08-20T11:53:45.000Z\", \"updated_at\": \"2026-08-20T11:53:45.000Z\", \"updated_by\": \"superadmin\", \"dipanggil_at\": \"2026-08-20T11:53:45.000Z\", \"nomor_antrian\": \"001\", \"kode_kunjungan\": \"KJG-20260820-001\", \"kode_antrian_awal\": \"A-20260820-001\"}', '{\"id\": 3, \"tz\": \"UTC\", \"status\": \"terpakai\", \"created_at\": \"2026-08-20T11:53:45.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": \"2026-08-20T11:53:45.000Z\", \"no_antrian\": \"001\", \"updated_at\": \"2026-08-20 11:53:45\", \"updated_by\": \"superadmin\", \"dipanggil_at\": \"2026-08-20T11:53:45.000Z\", \"kode_antrian\": \"A-20260820-001\", \"nomor_antrian\": \"001\", \"kode_kunjungan\": \"KJG-20260820-001\", \"kode_antrian_awal\": \"A-20260820-001\"}', 'UTC', 'superadmin', '2026-08-20 11:53:45', '2026-08-20 11:53:45'),
(6, 'UPDATE', 'Edit Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-002', '{\"id\": 4, \"tz\": \"UTC\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20T11:53:45.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T11:53:45.000Z\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"nomor_antrian\": \"002\", \"kode_kunjungan\": \"KJG-20260820-002\", \"kode_antrian_awal\": \"A-20260820-002\"}', '{\"id\": 4, \"tz\": \"UTC\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20T11:53:45.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": null, \"updated_at\": \"2026-08-20 11:53:45\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"nomor_antrian\": \"002-FIX\", \"kode_kunjungan\": \"KJG-20260820-002\", \"kode_antrian_awal\": \"A-20260820-002\"}', 'UTC', 'superadmin', '2026-08-20 11:53:45', '2026-08-20 11:53:45'),
(7, 'UPDATE', 'Reset 1 Nomor Antrian Awal', 'trx_antrian_awal', 'RESET', '[{\"status\": \"terpakai\", \"nomor_antrian\": \"001\", \"kode_antrian_awal\": \"A-20260820-001\"}]', '{\"jumlah\": 1, \"status\": \"tersedia\"}', 'UTC', 'superadmin', '2026-08-20 11:53:45', '2026-08-20 11:53:45'),
(8, 'DELETE', 'Hapus Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-001', '{\"id\": 3, \"tz\": \"UTC\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20T11:53:45.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T11:53:45.000Z\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"nomor_antrian\": \"001\", \"kode_kunjungan\": \"KJG-20260820-001\", \"kode_antrian_awal\": \"A-20260820-001\"}', NULL, 'UTC', 'superadmin', '2026-08-20 11:53:45', '2026-08-20 11:53:45'),
(9, 'DELETE', 'Hapus Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-002', '{\"id\": 4, \"tz\": \"UTC\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20T11:53:45.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T11:53:45.000Z\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"nomor_antrian\": \"002-FIX\", \"kode_kunjungan\": \"KJG-20260820-002\", \"kode_antrian_awal\": \"A-20260820-002\"}', NULL, 'UTC', 'superadmin', '2026-08-20 11:53:45', '2026-08-20 11:53:45'),
(10, 'CREATE', 'Tambah Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-001', NULL, '{\"tz\": \"UTC\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20 12:06:29\", \"created_by\": \"superadmin\", \"diambil_at\": null, \"updated_at\": \"2026-08-20 12:06:29\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"nomor_antrian\": \"001\", \"kode_antrian_awal\": \"A-20260820-001\"}', 'UTC', 'superadmin', '2026-08-20 12:06:29', '2026-08-20 12:06:29'),
(11, 'CREATE', 'Tambah Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-002', NULL, '{\"tz\": \"UTC\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20 12:06:29\", \"created_by\": \"superadmin\", \"diambil_at\": null, \"updated_at\": \"2026-08-20 12:06:29\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"nomor_antrian\": \"002\", \"kode_antrian_awal\": \"A-20260820-002\"}', 'UTC', 'superadmin', '2026-08-20 12:06:29', '2026-08-20 12:06:29'),
(12, 'UPDATE', 'Pasien mengambil nomor antrian - Nomor 001', 'trx_antrian_awal', 'A-20260820-001', '{\"id\": 5, \"tz\": \"UTC\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:06:29.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:06:29.000Z\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"nomor_antrian\": \"001\", \"kode_antrian_awal\": \"A-20260820-001\"}', '{\"id\": 5, \"tz\": \"UTC\", \"status\": \"terpakai\", \"created_at\": \"2026-08-20T12:06:29.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": \"2026-08-20 12:06:29\", \"no_antrian\": \"001\", \"updated_at\": \"2026-08-20 12:06:29\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"kode_antrian\": \"A-20260820-001\", \"nomor_antrian\": \"001\", \"kode_antrian_awal\": \"A-20260820-001\"}', 'UTC', 'superadmin', '2026-08-20 12:06:29', '2026-08-20 12:06:29'),
(13, 'UPDATE', 'Panggil nomor antrian ke loket - Nomor 001', 'trx_antrian_awal', 'A-20260820-001', '{\"id\": 5, \"tz\": \"UTC\", \"status\": \"terpakai\", \"created_at\": \"2026-08-20T12:06:29.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": \"2026-08-20T12:06:29.000Z\", \"updated_at\": \"2026-08-20T12:06:29.000Z\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"nomor_antrian\": \"001\", \"kode_antrian_awal\": \"A-20260820-001\"}', '{\"id\": 5, \"tz\": \"UTC\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-20T12:06:29.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": \"2026-08-20T12:06:29.000Z\", \"no_antrian\": \"001\", \"updated_at\": \"2026-08-20 12:06:29\", \"updated_by\": \"superadmin\", \"dipanggil_at\": \"2026-08-20 12:06:29\", \"kode_antrian\": \"A-20260820-001\", \"nomor_antrian\": \"001\", \"kode_antrian_awal\": \"A-20260820-001\"}', 'UTC', 'superadmin', '2026-08-20 12:06:29', '2026-08-20 12:06:29'),
(14, 'UPDATE', 'Antrian selesai dilayani - Nomor 001', 'trx_antrian_awal', 'A-20260820-001', '{\"id\": 5, \"tz\": \"UTC\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-20T12:06:29.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": \"2026-08-20T12:06:29.000Z\", \"updated_at\": \"2026-08-20T12:06:29.000Z\", \"updated_by\": \"superadmin\", \"dipanggil_at\": \"2026-08-20T12:06:29.000Z\", \"nomor_antrian\": \"001\", \"kode_antrian_awal\": \"A-20260820-001\"}', '{\"id\": 5, \"tz\": \"UTC\", \"status\": \"terpakai\", \"created_at\": \"2026-08-20T12:06:29.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": \"2026-08-20T12:06:29.000Z\", \"no_antrian\": \"001\", \"updated_at\": \"2026-08-20 12:06:29\", \"updated_by\": \"superadmin\", \"dipanggil_at\": \"2026-08-20T12:06:29.000Z\", \"kode_antrian\": \"A-20260820-001\", \"nomor_antrian\": \"001\", \"kode_antrian_awal\": \"A-20260820-001\"}', 'UTC', 'superadmin', '2026-08-20 12:06:29', '2026-08-20 12:06:29'),
(15, 'UPDATE', 'Edit Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-002', '{\"id\": 6, \"tz\": \"UTC\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:06:29.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:06:29.000Z\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"nomor_antrian\": \"002\", \"kode_antrian_awal\": \"A-20260820-002\"}', '{\"id\": 6, \"tz\": \"UTC\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:06:29.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": null, \"updated_at\": \"2026-08-20 12:06:29\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"nomor_antrian\": \"002-FIX\", \"kode_antrian_awal\": \"A-20260820-002\"}', 'UTC', 'superadmin', '2026-08-20 12:06:29', '2026-08-20 12:06:29'),
(16, 'UPDATE', 'Reset 1 Nomor Antrian Awal', 'trx_antrian_awal', 'RESET', '[{\"status\": \"terpakai\", \"nomor_antrian\": \"001\", \"kode_antrian_awal\": \"A-20260820-001\"}]', '{\"jumlah\": 1, \"status\": \"tersedia\"}', 'UTC', 'superadmin', '2026-08-20 12:06:29', '2026-08-20 12:06:29'),
(17, 'DELETE', 'Hapus Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-001', '{\"id\": 5, \"tz\": \"UTC\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:06:29.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:06:29.000Z\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"nomor_antrian\": \"001\", \"kode_antrian_awal\": \"A-20260820-001\"}', NULL, 'UTC', 'superadmin', '2026-08-20 12:06:29', '2026-08-20 12:06:29'),
(18, 'DELETE', 'Hapus Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-002', '{\"id\": 6, \"tz\": \"UTC\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:06:29.000Z\", \"created_by\": \"superadmin\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:06:29.000Z\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"nomor_antrian\": \"002-FIX\", \"kode_antrian_awal\": \"A-20260820-002\"}', NULL, 'UTC', 'superadmin', '2026-08-20 12:06:29', '2026-08-20 12:06:29'),
(19, 'CREATE', 'Tambah Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-001', NULL, '{\"tz\": \"Asia/Jakarta\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20 12:23:11\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20 12:23:11\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"01\", \"kode_antrian_awal\": \"A-20260820-001\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 12:23:11', '2026-08-20 19:23:11'),
(20, 'UPDATE', 'Pasien mengambil nomor antrian - Nomor 01', 'trx_antrian_awal', 'A-20260820-001', '{\"id\": 7, \"tz\": \"Asia/Jakarta\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:23:11.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:23:11.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"01\", \"kode_antrian_awal\": \"A-20260820-001\"}', '{\"id\": 7, \"tz\": \"Asia/Jakarta\", \"status\": \"terpakai\", \"created_at\": \"2026-08-20T12:23:11.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-20 12:23:17\", \"no_antrian\": \"01\", \"updated_at\": \"2026-08-20 12:23:17\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"kode_antrian\": \"A-20260820-001\", \"nomor_antrian\": \"01\", \"kode_antrian_awal\": \"A-20260820-001\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 12:23:17', '2026-08-20 19:23:17'),
(21, 'UPDATE', 'Panggil nomor antrian ke loket - Nomor 01', 'trx_antrian_awal', 'A-20260820-001', '{\"id\": 7, \"tz\": \"Asia/Jakarta\", \"status\": \"terpakai\", \"created_at\": \"2026-08-20T12:23:11.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-20T12:23:17.000Z\", \"updated_at\": \"2026-08-20T12:23:17.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"01\", \"kode_antrian_awal\": \"A-20260820-001\"}', '{\"id\": 7, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-20T12:23:11.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-20T12:23:17.000Z\", \"no_antrian\": \"01\", \"updated_at\": \"2026-08-20 12:23:21\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-20 12:23:21\", \"kode_antrian\": \"A-20260820-001\", \"nomor_antrian\": \"01\", \"kode_antrian_awal\": \"A-20260820-001\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 12:23:21', '2026-08-20 19:23:21'),
(22, 'CREATE', 'Tambah Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-002', NULL, '{\"tz\": \"Asia/Jakarta\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20 12:23:41\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20 12:23:41\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"02\", \"kode_antrian_awal\": \"A-20260820-002\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 12:23:41', '2026-08-20 19:23:41'),
(23, 'CREATE', 'Tambah Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-003', NULL, '{\"tz\": \"Asia/Jakarta\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20 12:23:50\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20 12:23:50\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"02\", \"kode_antrian_awal\": \"A-20260820-003\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 12:23:50', '2026-08-20 19:23:50'),
(24, 'CREATE', 'Tambah Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-004', NULL, '{\"tz\": \"Asia/Jakarta\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20 12:23:50\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20 12:23:50\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"02\", \"kode_antrian_awal\": \"A-20260820-004\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 12:23:50', '2026-08-20 19:23:50'),
(25, 'CREATE', 'Tambah Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-005', NULL, '{\"tz\": \"Asia/Jakarta\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20 12:24:08\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20 12:24:08\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"02\", \"kode_antrian_awal\": \"A-20260820-005\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 12:24:08', '2026-08-20 19:24:08'),
(26, 'DELETE', 'Hapus Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-003', '{\"id\": 9, \"tz\": \"Asia/Jakarta\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:23:50.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:23:50.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"02\", \"kode_antrian_awal\": \"A-20260820-003\"}', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 12:24:21', '2026-08-20 19:24:21'),
(27, 'DELETE', 'Hapus Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-004', '{\"id\": 10, \"tz\": \"Asia/Jakarta\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:23:50.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:23:50.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"02\", \"kode_antrian_awal\": \"A-20260820-004\"}', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 12:24:21', '2026-08-20 19:24:21'),
(28, 'DELETE', 'Hapus Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-005', '{\"id\": 11, \"tz\": \"Asia/Jakarta\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:24:08.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:24:08.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"02\", \"kode_antrian_awal\": \"A-20260820-005\"}', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 12:24:21', '2026-08-20 19:24:21'),
(29, 'CREATE', 'Tambah Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-003', NULL, '{\"tz\": \"Asia/Jakarta\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20 12:24:29\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20 12:24:29\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"03\", \"kode_antrian_awal\": \"A-20260820-003\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 12:24:29', '2026-08-20 19:24:29'),
(30, 'CREATE', 'Tambah Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-004', NULL, '{\"tz\": \"Asia/Jakarta\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20 12:24:41\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20 12:24:41\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"04\", \"kode_antrian_awal\": \"A-20260820-004\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 12:24:41', '2026-08-20 19:24:41'),
(31, 'CREATE', 'Tambah Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-005', NULL, '{\"tz\": \"Asia/Jakarta\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20 12:24:47\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20 12:24:47\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"05\", \"kode_antrian_awal\": \"A-20260820-005\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 12:24:47', '2026-08-20 19:24:47'),
(32, 'CREATE', 'Tambah Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-001', NULL, '{\"tz\": \"UTC\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20 12:31:20\", \"created_by\": \"superadmin\", \"diambil_at\": null, \"updated_at\": \"2026-08-20 12:31:20\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"nomor_antrian\": \"01\", \"kode_antrian_awal\": \"A-20260820-001\"}', 'UTC', 'superadmin', '2026-08-20 12:31:20', '2026-08-20 12:31:20'),
(33, 'CREATE', 'Tambah Cepat Nomor Antrian (2 - 10) total 9 data', 'trx_antrian_awal', 'BULK-2-10', NULL, '{\"total_created\": 9, \"total_skipped\": 0}', 'UTC', 'superadmin', '2026-08-20 12:31:20', '2026-08-20 12:31:20'),
(34, 'CREATE', 'Tambah Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-001', NULL, '{\"tz\": \"UTC\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20 12:46:06\", \"created_by\": \"superadmin\", \"diambil_at\": null, \"updated_at\": \"2026-08-20 12:46:06\", \"updated_by\": \"superadmin\", \"dipanggil_at\": null, \"nomor_antrian\": \"01\", \"kode_antrian_awal\": \"A-20260820-001\"}', 'UTC', 'superadmin', '2026-08-20 12:46:06', '2026-08-20 12:46:06'),
(35, 'CREATE', 'Tambah Cepat Nomor Antrian (2 - 10) total 9 data', 'trx_antrian_awal', 'BULK-2-10', NULL, '{\"total_created\": 9, \"total_skipped\": 0}', 'UTC', 'superadmin', '2026-08-20 12:46:06', '2026-08-20 12:46:06'),
(36, 'CREATE', 'Tambah Cepat Nomor Antrian (1 - 50) total 50 data', 'trx_antrian_awal', 'BULK-1-50', NULL, '{\"total_created\": 50, \"total_skipped\": 0}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 12:51:00', '2026-08-20 19:51:00'),
(37, 'UPDATE', 'Pasien mengambil nomor antrian - Nomor 02', 'trx_antrian_awal', 'A-20260820-002', '{\"id\": 36, \"tz\": \"Asia/Jakarta\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:51:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"02\", \"kode_antrian_awal\": \"A-20260820-002\"}', '{\"id\": 36, \"tz\": \"Asia/Jakarta\", \"status\": \"terpakai\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-20 12:51:17\", \"no_antrian\": \"02\", \"updated_at\": \"2026-08-20 12:51:17\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"kode_antrian\": \"A-20260820-002\", \"nomor_antrian\": \"02\", \"kode_antrian_awal\": \"A-20260820-002\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 12:51:17', '2026-08-20 19:51:17'),
(38, 'UPDATE', 'Panggil nomor antrian ke loket - Nomor 02', 'trx_antrian_awal', 'A-20260820-002', '{\"id\": 36, \"tz\": \"Asia/Jakarta\", \"status\": \"terpakai\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-20T12:51:17.000Z\", \"updated_at\": \"2026-08-20T12:51:17.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"02\", \"kode_antrian_awal\": \"A-20260820-002\"}', '{\"id\": 36, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-20T12:51:17.000Z\", \"no_antrian\": \"02\", \"updated_at\": \"2026-08-20 12:51:21\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-20 12:51:21\", \"kode_antrian\": \"A-20260820-002\", \"nomor_antrian\": \"02\", \"kode_antrian_awal\": \"A-20260820-002\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 12:51:21', '2026-08-20 19:51:21'),
(39, 'CREATE', 'Tambah Cepat Nomor Antrian (1 - 51) total 1 data', 'trx_antrian_awal', 'BULK-1-51', NULL, '{\"total_created\": 1, \"total_skipped\": 50}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 13:36:20', '2026-08-20 20:36:20'),
(40, 'UPDATE', 'Antrian selesai dilayani - Nomor 02', 'trx_antrian_awal', 'A-20260820-002', '{\"id\": 36, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-20T12:51:17.000Z\", \"updated_at\": \"2026-08-20T12:51:21.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-20T12:51:21.000Z\", \"nomor_antrian\": \"02\", \"kode_antrian_awal\": \"A-20260820-002\"}', '{\"id\": 36, \"tz\": \"Asia/Jakarta\", \"status\": \"terpakai\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-20T12:51:17.000Z\", \"no_antrian\": \"02\", \"updated_at\": \"2026-08-20 13:36:33\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-20T12:51:21.000Z\", \"kode_antrian\": \"A-20260820-002\", \"nomor_antrian\": \"02\", \"kode_antrian_awal\": \"A-20260820-002\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 13:36:33', '2026-08-20 20:36:33'),
(41, 'UPDATE', 'Pasien mengambil nomor antrian - Nomor 01', 'trx_antrian_awal', 'A-20260820-001', '{\"id\": 35, \"tz\": \"Asia/Jakarta\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:51:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"01\", \"kode_antrian_awal\": \"A-20260820-001\"}', '{\"id\": 35, \"tz\": \"Asia/Jakarta\", \"status\": \"terpakai\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-20 13:36:36\", \"no_antrian\": \"01\", \"updated_at\": \"2026-08-20 13:36:36\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"kode_antrian\": \"A-20260820-001\", \"nomor_antrian\": \"01\", \"kode_antrian_awal\": \"A-20260820-001\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 13:36:36', '2026-08-20 20:36:36'),
(42, 'UPDATE', 'Panggil nomor antrian ke loket - Nomor 01', 'trx_antrian_awal', 'A-20260820-001', '{\"id\": 35, \"tz\": \"Asia/Jakarta\", \"status\": \"terpakai\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-20T13:36:36.000Z\", \"updated_at\": \"2026-08-20T13:36:36.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"01\", \"kode_antrian_awal\": \"A-20260820-001\"}', '{\"id\": 35, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-20T13:36:36.000Z\", \"no_antrian\": \"01\", \"updated_at\": \"2026-08-20 13:36:41\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-20 13:36:41\", \"kode_antrian\": \"A-20260820-001\", \"nomor_antrian\": \"01\", \"kode_antrian_awal\": \"A-20260820-001\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 13:36:41', '2026-08-20 20:36:41'),
(43, 'UPDATE', 'Antrian selesai dilayani - Nomor 01', 'trx_antrian_awal', 'A-20260820-001', '{\"id\": 35, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-20T13:36:36.000Z\", \"updated_at\": \"2026-08-20T13:36:41.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-20T13:36:41.000Z\", \"nomor_antrian\": \"01\", \"kode_antrian_awal\": \"A-20260820-001\"}', '{\"id\": 35, \"tz\": \"Asia/Jakarta\", \"status\": \"terpakai\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-20T13:36:36.000Z\", \"no_antrian\": \"01\", \"updated_at\": \"2026-08-20 13:40:08\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-20T13:36:41.000Z\", \"kode_antrian\": \"A-20260820-001\", \"nomor_antrian\": \"01\", \"kode_antrian_awal\": \"A-20260820-001\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 13:40:08', '2026-08-20 20:40:08'),
(44, 'UPDATE', 'Pasien mengambil nomor antrian - Nomor 03', 'trx_antrian_awal', 'A-20260820-003', '{\"id\": 37, \"tz\": \"Asia/Jakarta\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:51:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"03\", \"kode_antrian_awal\": \"A-20260820-003\"}', '{\"id\": 37, \"tz\": \"Asia/Jakarta\", \"status\": \"terpakai\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-20 13:40:12\", \"no_antrian\": \"03\", \"updated_at\": \"2026-08-20 13:40:12\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"kode_antrian\": \"A-20260820-003\", \"nomor_antrian\": \"03\", \"kode_antrian_awal\": \"A-20260820-003\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 13:40:12', '2026-08-20 20:40:12'),
(45, 'UPDATE', 'Panggil nomor antrian ke loket - Nomor 03', 'trx_antrian_awal', 'A-20260820-003', '{\"id\": 37, \"tz\": \"Asia/Jakarta\", \"status\": \"terpakai\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-20T13:40:12.000Z\", \"updated_at\": \"2026-08-20T13:40:12.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"03\", \"kode_antrian_awal\": \"A-20260820-003\"}', '{\"id\": 37, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-20T13:40:12.000Z\", \"no_antrian\": \"03\", \"updated_at\": \"2026-08-20 13:40:16\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-20 13:40:16\", \"kode_antrian\": \"A-20260820-003\", \"nomor_antrian\": \"03\", \"kode_antrian_awal\": \"A-20260820-003\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 13:40:16', '2026-08-20 20:40:16'),
(46, 'DELETE', 'Hapus Nomor Antrian Awal', 'trx_antrian_awal', 'A-20260820-051', '{\"id\": 85, \"tz\": \"Asia/Jakarta\", \"status\": \"tersedia\", \"created_at\": \"2026-08-20T13:36:20.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T13:36:20.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"51\", \"kode_antrian_awal\": \"A-20260820-051\"}', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 13:40:47', '2026-08-20 20:40:47'),
(47, 'CREATE', 'Tambah Pasien Baru RM-000001 (Test Pasien Baru 1)', 'mst_pasien', 'RM-000001', NULL, '{\"tz\": \"UTC\", \"nik\": \"3515000000000001\", \"nama\": \"Test Pasien Baru 1\", \"email\": null, \"no_hp\": \"081234567890\", \"no_rm\": \"RM-000001\", \"status\": \"aktif\", \"patokan\": \"Jl. Test No. 123\", \"pekerjaan\": null, \"created_at\": \"2026-08-20 14:42:24\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20 14:42:24\", \"updated_by\": \"superadmin@admin.com\", \"tempat_lahir\": null, \"jenis_kelamin\": \"P\", \"tanggal_lahir\": \"1995-05-15\", \"golongan_darah\": null}', 'UTC', 'superadmin@admin.com', '2026-08-20 14:42:24', '2026-08-20 14:42:24'),
(48, 'CREATE', 'Tambah Kunjungan KJ-20260820-001 untuk RM RM-000001', 'trx_kunjungan', 'KJ-20260820-001', NULL, '{\"tz\": \"UTC\", \"no_rm\": \"RM-000001\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-20 14:42:24\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"21:42:24\", \"updated_at\": \"2026-08-20 14:42:24\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260820-001\", \"tanggal_kunjungan\": \"2026-08-20\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 14:42:24', '2026-08-20 14:42:24'),
(49, 'CREATE', 'Tambah Antrian Layanan AL-20260820-001 (01)', 'trx_antrian_layanan', 'AL-20260820-001', NULL, '{\"tz\": \"UTC\", \"status\": \"menunggu\", \"created_at\": \"2026-08-20 14:42:24\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20 14:42:24\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-002\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260820-001\", \"kode_antrian_layanan\": \"AL-20260820-001\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 14:42:24', '2026-08-20 14:42:24'),
(50, 'CREATE', 'Tambah Kunjungan KJ-20260820-002 untuk RM RM-000001', 'trx_kunjungan', 'KJ-20260820-002', NULL, '{\"tz\": \"UTC\", \"no_rm\": \"RM-000001\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-20 14:42:24\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"21:42:24\", \"updated_at\": \"2026-08-20 14:42:24\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260820-002\", \"tanggal_kunjungan\": \"2026-08-20\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 14:42:24', '2026-08-20 14:42:24'),
(51, 'CREATE', 'Tambah Antrian Layanan AL-20260820-002 (02)', 'trx_antrian_layanan', 'AL-20260820-002', NULL, '{\"tz\": \"UTC\", \"status\": \"menunggu\", \"created_at\": \"2026-08-20 14:42:24\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20 14:42:24\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-002\", \"nomor_antrian\": \"02\", \"kode_kunjungan\": \"KJ-20260820-002\", \"kode_antrian_layanan\": \"AL-20260820-002\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 14:42:24', '2026-08-20 14:42:24'),
(52, 'UPDATE', 'Update Status Antrian Layanan AL-20260820-001 -> dipanggil', 'trx_antrian_layanan', 'AL-20260820-001', '{\"id\": 1, \"tz\": \"UTC\", \"status\": \"menunggu\", \"created_at\": \"2026-08-20T14:42:24.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-20T14:42:24.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"kode_layanan\": \"LAY-002\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260820-001\", \"kode_antrian_layanan\": \"AL-20260820-001\"}', '{\"id\": 1, \"tz\": \"UTC\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-20T14:42:24.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-20 14:42:24\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-20 14:42:24\", \"kode_layanan\": \"LAY-002\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260820-001\", \"kode_antrian_layanan\": \"AL-20260820-001\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 14:42:24', '2026-08-20 14:42:24'),
(53, 'DELETE', 'Hapus Antrian Layanan & Kunjungan AL-20260820-001, AL-20260820-002', 'trx_antrian_layanan', 'AL-20260820-001, AL-20260820-002', '[{\"kode_kunjungan\": \"KJ-20260820-001\", \"kode_antrian_layanan\": \"AL-20260820-001\"}, {\"kode_kunjungan\": \"KJ-20260820-002\", \"kode_antrian_layanan\": \"AL-20260820-002\"}]', NULL, 'UTC', 'superadmin@admin.com', '2026-08-20 14:42:24', '2026-08-20 14:42:24'),
(54, 'CREATE', 'Tambah Pasien Baru RM-000001 (Test Pasien Baru 1)', 'mst_pasien', 'RM-000001', NULL, '{\"tz\": \"UTC\", \"nik\": \"3515000000000001\", \"nama\": \"Test Pasien Baru 1\", \"email\": null, \"no_hp\": \"081234567890\", \"no_rm\": \"RM-000001\", \"status\": \"aktif\", \"patokan\": \"Jl. Test No. 123\", \"pekerjaan\": null, \"created_at\": \"2026-08-20 14:42:36\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20 14:42:36\", \"updated_by\": \"superadmin@admin.com\", \"tempat_lahir\": null, \"jenis_kelamin\": \"P\", \"tanggal_lahir\": \"1995-05-15\", \"golongan_darah\": null}', 'UTC', 'superadmin@admin.com', '2026-08-20 14:42:36', '2026-08-20 14:42:36'),
(55, 'CREATE', 'Tambah Kunjungan KJ-20260820-001 untuk RM RM-000001', 'trx_kunjungan', 'KJ-20260820-001', NULL, '{\"tz\": \"UTC\", \"no_rm\": \"RM-000001\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-20 14:42:36\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"21:42:36\", \"updated_at\": \"2026-08-20 14:42:36\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260820-001\", \"tanggal_kunjungan\": \"2026-08-20\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 14:42:36', '2026-08-20 14:42:36'),
(56, 'CREATE', 'Tambah Antrian Layanan AL-20260820-001 (01)', 'trx_antrian_layanan', 'AL-20260820-001', NULL, '{\"tz\": \"UTC\", \"status\": \"menunggu\", \"created_at\": \"2026-08-20 14:42:36\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20 14:42:36\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-002\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260820-001\", \"kode_antrian_layanan\": \"AL-20260820-001\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 14:42:36', '2026-08-20 14:42:36'),
(57, 'CREATE', 'Tambah Kunjungan KJ-20260820-002 untuk RM RM-000001', 'trx_kunjungan', 'KJ-20260820-002', NULL, '{\"tz\": \"UTC\", \"no_rm\": \"RM-000001\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-20 14:42:36\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"21:42:36\", \"updated_at\": \"2026-08-20 14:42:36\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260820-002\", \"tanggal_kunjungan\": \"2026-08-20\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 14:42:36', '2026-08-20 14:42:36'),
(58, 'CREATE', 'Tambah Antrian Layanan AL-20260820-002 (02)', 'trx_antrian_layanan', 'AL-20260820-002', NULL, '{\"tz\": \"UTC\", \"status\": \"menunggu\", \"created_at\": \"2026-08-20 14:42:36\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20 14:42:36\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-002\", \"nomor_antrian\": \"02\", \"kode_kunjungan\": \"KJ-20260820-002\", \"kode_antrian_layanan\": \"AL-20260820-002\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 14:42:36', '2026-08-20 14:42:36'),
(59, 'UPDATE', 'Update Status Antrian Layanan AL-20260820-001 -> dipanggil', 'trx_antrian_layanan', 'AL-20260820-001', '{\"id\": 3, \"tz\": \"UTC\", \"status\": \"menunggu\", \"created_at\": \"2026-08-20T14:42:36.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-20T14:42:36.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"kode_layanan\": \"LAY-002\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260820-001\", \"kode_antrian_layanan\": \"AL-20260820-001\"}', '{\"id\": 3, \"tz\": \"UTC\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-20T14:42:36.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-20 14:42:36\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-20 14:42:36\", \"kode_layanan\": \"LAY-002\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260820-001\", \"kode_antrian_layanan\": \"AL-20260820-001\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 14:42:36', '2026-08-20 14:42:36'),
(60, 'DELETE', 'Hapus Antrian Layanan & Kunjungan AL-20260820-001, AL-20260820-002', 'trx_antrian_layanan', 'AL-20260820-001, AL-20260820-002', '[{\"kode_kunjungan\": \"KJ-20260820-001\", \"kode_antrian_layanan\": \"AL-20260820-001\"}, {\"kode_kunjungan\": \"KJ-20260820-002\", \"kode_antrian_layanan\": \"AL-20260820-002\"}]', NULL, 'UTC', 'superadmin@admin.com', '2026-08-20 14:42:36', '2026-08-20 14:42:36'),
(61, 'CREATE', 'Tambah Kunjungan KJ-20260820-001 untuk RM RM-000000', 'trx_kunjungan', 'KJ-20260820-001', NULL, '{\"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000000\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-20 14:46:41\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"21:46:41\", \"updated_at\": \"2026-08-20 14:46:41\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260820-001\", \"tanggal_kunjungan\": \"2026-08-20\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 14:46:41', '2026-08-20 21:46:41'),
(62, 'CREATE', 'Tambah Antrian Layanan AL-20260820-001 (01)', 'trx_antrian_layanan', 'AL-20260820-001', NULL, '{\"tz\": \"Asia/Jakarta\", \"status\": \"menunggu\", \"created_at\": \"2026-08-20 14:46:41\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20 14:46:41\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-005\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260820-001\", \"kode_antrian_layanan\": \"AL-20260820-001\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 14:46:41', '2026-08-20 21:46:41'),
(63, 'UPDATE', 'Update Status Antrian Layanan AL-20260820-001 -> dipanggil', 'trx_antrian_layanan', 'AL-20260820-001', '{\"id\": 5, \"tz\": \"Asia/Jakarta\", \"status\": \"menunggu\", \"created_at\": \"2026-08-20T14:46:41.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-20T14:46:41.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"kode_layanan\": \"LAY-005\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260820-001\", \"kode_antrian_layanan\": \"AL-20260820-001\"}', '{\"id\": 5, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-20T14:46:41.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-20 15:01:16\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-20 15:01:16\", \"kode_layanan\": \"LAY-005\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260820-001\", \"kode_antrian_layanan\": \"AL-20260820-001\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:01:16', '2026-08-20 15:01:16'),
(64, 'CREATE', 'Tambah Pasien Baru RM-000001 (Test Pasien Full Field)', 'mst_pasien', 'RM-000001', NULL, '{\"tz\": \"UTC\", \"nik\": \"3515999999999999\", \"nama\": \"Test Pasien Full Field\", \"agama\": \"Islam\", \"email\": \"pasien.test@gmail.com\", \"no_hp\": \"081999888777\", \"no_rm\": \"RM-000001\", \"alergi\": \"Alergi Parasetamol\", \"status\": \"aktif\", \"patokan\": \"Jl. Dharmahusada No. 45\", \"kode_pos\": \"60286\", \"provinsi\": \"Jawa Timur\", \"kecamatan\": \"Gubeng\", \"pekerjaan\": \"Pengusaha\", \"created_at\": \"2026-08-20 15:29:45\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20 15:29:45\", \"updated_by\": \"superadmin@admin.com\", \"tempat_lahir\": \"Surabaya\", \"jenis_kelamin\": \"P\", \"tanggal_lahir\": \"1998-08-20\", \"golongan_darah\": \"O\", \"kelurahan_desa\": \"Airlangga\", \"kota_kabupaten\": \"Surabaya\", \"kewarganegaraan\": \"WNI\", \"status_perkawinan\": \"Menikah\", \"nama_kontak_darurat\": \"Budi Santoso\", \"no_hp_kontak_darurat\": \"081222333444\", \"hubungan_kontak_darurat\": \"Suami\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:29:45', '2026-08-20 15:29:45'),
(65, 'CREATE', 'Tambah Kunjungan KJ-20260820-002 untuk RM RM-000001', 'trx_kunjungan', 'KJ-20260820-002', NULL, '{\"tz\": \"UTC\", \"no_rm\": \"RM-000001\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-20 15:29:45\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"22:29:45\", \"updated_at\": \"2026-08-20 15:29:45\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260820-002\", \"tanggal_kunjungan\": \"2026-08-20\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:29:45', '2026-08-20 15:29:45'),
(66, 'CREATE', 'Tambah Antrian Layanan AL-20260820-002 (01)', 'trx_antrian_layanan', 'AL-20260820-002', NULL, '{\"tz\": \"UTC\", \"status\": \"menunggu\", \"created_at\": \"2026-08-20 15:29:45\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20 15:29:45\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"PKT-002\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260820-002\", \"kode_antrian_layanan\": \"AL-20260820-002\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:29:45', '2026-08-20 15:29:45'),
(67, 'CREATE', 'Tambah Kunjungan KJ-20260820-003 untuk RM RM-000001', 'trx_kunjungan', 'KJ-20260820-003', NULL, '{\"tz\": \"UTC\", \"no_rm\": \"RM-000001\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-20 15:29:45\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"22:29:45\", \"updated_at\": \"2026-08-20 15:29:45\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260820-003\", \"tanggal_kunjungan\": \"2026-08-20\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:29:45', '2026-08-20 15:29:45'),
(68, 'CREATE', 'Tambah Antrian Layanan AL-20260820-003 (01)', 'trx_antrian_layanan', 'AL-20260820-003', NULL, '{\"tz\": \"UTC\", \"status\": \"menunggu\", \"created_at\": \"2026-08-20 15:29:45\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20 15:29:45\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-002\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260820-003\", \"kode_antrian_layanan\": \"AL-20260820-003\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:29:45', '2026-08-20 15:29:45'),
(69, 'DELETE', 'Hapus Antrian Layanan & Kunjungan AL-20260820-002, AL-20260820-003', 'trx_antrian_layanan', 'AL-20260820-002, AL-20260820-003', '[{\"kode_kunjungan\": \"KJ-20260820-002\", \"kode_antrian_layanan\": \"AL-20260820-002\"}, {\"kode_kunjungan\": \"KJ-20260820-003\", \"kode_antrian_layanan\": \"AL-20260820-003\"}]', NULL, 'UTC', 'superadmin@admin.com', '2026-08-20 15:29:45', '2026-08-20 15:29:45'),
(70, 'CREATE', 'Tambah Pasien Baru RM-000001 (Test Pasien Full Field)', 'mst_pasien', 'RM-000001', NULL, '{\"tz\": \"UTC\", \"nik\": \"3515999999999999\", \"nama\": \"Test Pasien Full Field\", \"agama\": \"Islam\", \"email\": \"pasien.test@gmail.com\", \"no_hp\": \"081999888777\", \"no_rm\": \"RM-000001\", \"alergi\": \"Alergi Parasetamol\", \"status\": \"aktif\", \"patokan\": \"Jl. Dharmahusada No. 45\", \"kode_pos\": \"60286\", \"provinsi\": \"Jawa Timur\", \"kecamatan\": \"Gubeng\", \"pekerjaan\": \"Pengusaha\", \"created_at\": \"2026-08-20 15:29:46\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20 15:29:46\", \"updated_by\": \"superadmin@admin.com\", \"tempat_lahir\": \"Surabaya\", \"jenis_kelamin\": \"P\", \"tanggal_lahir\": \"1998-08-20\", \"golongan_darah\": \"O\", \"kelurahan_desa\": \"Airlangga\", \"kota_kabupaten\": \"Surabaya\", \"kewarganegaraan\": \"WNI\", \"status_perkawinan\": \"Menikah\", \"nama_kontak_darurat\": \"Budi Santoso\", \"no_hp_kontak_darurat\": \"081222333444\", \"hubungan_kontak_darurat\": \"Suami\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:29:46', '2026-08-20 15:29:46'),
(71, 'CREATE', 'Tambah Kunjungan KJ-20260820-002 untuk RM RM-000001', 'trx_kunjungan', 'KJ-20260820-002', NULL, '{\"tz\": \"UTC\", \"no_rm\": \"RM-000001\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-20 15:29:46\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"22:29:46\", \"updated_at\": \"2026-08-20 15:29:46\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260820-002\", \"tanggal_kunjungan\": \"2026-08-20\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:29:46', '2026-08-20 15:29:46'),
(72, 'CREATE', 'Tambah Antrian Layanan AL-20260820-002 (01)', 'trx_antrian_layanan', 'AL-20260820-002', NULL, '{\"tz\": \"UTC\", \"status\": \"menunggu\", \"created_at\": \"2026-08-20 15:29:46\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20 15:29:46\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"PKT-002\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260820-002\", \"kode_antrian_layanan\": \"AL-20260820-002\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:29:46', '2026-08-20 15:29:46'),
(73, 'CREATE', 'Tambah Kunjungan KJ-20260820-003 untuk RM RM-000001', 'trx_kunjungan', 'KJ-20260820-003', NULL, '{\"tz\": \"UTC\", \"no_rm\": \"RM-000001\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-20 15:29:46\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"22:29:46\", \"updated_at\": \"2026-08-20 15:29:46\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260820-003\", \"tanggal_kunjungan\": \"2026-08-20\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:29:46', '2026-08-20 15:29:46'),
(74, 'CREATE', 'Tambah Antrian Layanan AL-20260820-003 (01)', 'trx_antrian_layanan', 'AL-20260820-003', NULL, '{\"tz\": \"UTC\", \"status\": \"menunggu\", \"created_at\": \"2026-08-20 15:29:46\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20 15:29:46\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-002\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260820-003\", \"kode_antrian_layanan\": \"AL-20260820-003\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:29:46', '2026-08-20 15:29:46'),
(75, 'DELETE', 'Hapus Antrian Layanan & Kunjungan AL-20260820-002, AL-20260820-003', 'trx_antrian_layanan', 'AL-20260820-002, AL-20260820-003', '[{\"kode_kunjungan\": \"KJ-20260820-002\", \"kode_antrian_layanan\": \"AL-20260820-002\"}, {\"kode_kunjungan\": \"KJ-20260820-003\", \"kode_antrian_layanan\": \"AL-20260820-003\"}]', NULL, 'UTC', 'superadmin@admin.com', '2026-08-20 15:29:46', '2026-08-20 15:29:46'),
(76, 'UPDATE', 'Update Status Antrian Layanan AL-20260820-001 -> batal', 'trx_antrian_layanan', 'AL-20260820-001', '{\"id\": 5, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-20T14:46:41.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-20T15:01:16.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-20T15:01:16.000Z\", \"kode_layanan\": \"LAY-005\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260820-001\", \"kode_antrian_layanan\": \"AL-20260820-001\"}', '{\"id\": 5, \"tz\": \"Asia/Jakarta\", \"status\": \"batal\", \"created_at\": \"2026-08-20T14:46:41.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-20 15:30:51\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-20T15:01:16.000Z\", \"kode_layanan\": \"LAY-005\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260820-001\", \"kode_antrian_layanan\": \"AL-20260820-001\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:30:51', '2026-08-20 15:30:51');
INSERT INTO `log_perubahan` (`id`, `aksi`, `keterangan`, `nama_tabel`, `kode_referensi`, `data_sebelum`, `data_sesudah`, `tz`, `created_by`, `created_at`, `created_at_eng`) VALUES
(77, 'CREATE', 'Tambah Pasien Baru RM-000001 (Test Pasien Full Field)', 'mst_pasien', 'RM-000001', NULL, '{\"tz\": \"UTC\", \"nik\": \"3515999999999999\", \"nama\": \"Test Pasien Full Field\", \"agama\": \"Islam\", \"email\": \"pasien.test@gmail.com\", \"no_hp\": \"081999888777\", \"no_rm\": \"RM-000001\", \"alergi\": \"Alergi Parasetamol\", \"status\": \"aktif\", \"patokan\": \"Jl. Dharmahusada No. 45\", \"kode_pos\": \"60286\", \"provinsi\": \"Jawa Timur\", \"kecamatan\": \"Gubeng\", \"pekerjaan\": \"Pengusaha\", \"created_at\": \"2026-08-20 15:39:32\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20 15:39:32\", \"updated_by\": \"superadmin@admin.com\", \"tempat_lahir\": \"Surabaya\", \"jenis_kelamin\": \"P\", \"tanggal_lahir\": \"1998-08-20\", \"golongan_darah\": \"O\", \"kelurahan_desa\": \"Airlangga\", \"kota_kabupaten\": \"Surabaya\", \"kewarganegaraan\": \"WNI\", \"status_perkawinan\": \"Menikah\", \"nama_kontak_darurat\": \"Budi Santoso\", \"no_hp_kontak_darurat\": \"081222333444\", \"hubungan_kontak_darurat\": \"Suami\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:39:32', '2026-08-20 15:39:32'),
(78, 'CREATE', 'Tambah Kunjungan KJ-20260820-002 untuk RM RM-000001', 'trx_kunjungan', 'KJ-20260820-002', NULL, '{\"tz\": \"UTC\", \"no_rm\": \"RM-000001\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-20 15:39:32\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"22:39:32\", \"updated_at\": \"2026-08-20 15:39:32\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260820-002\", \"tanggal_kunjungan\": \"2026-08-20\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:39:32', '2026-08-20 15:39:32'),
(79, 'CREATE', 'Tambah Antrian Layanan AL-20260820-002 (01)', 'trx_antrian_layanan', 'AL-20260820-002', NULL, '{\"tz\": \"UTC\", \"status\": \"menunggu\", \"created_at\": \"2026-08-20 15:39:32\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20 15:39:32\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"PKT-002\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260820-002\", \"kode_antrian_layanan\": \"AL-20260820-002\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:39:32', '2026-08-20 15:39:32'),
(80, 'CREATE', 'Tambah Kunjungan KJ-20260820-003 untuk RM RM-000001', 'trx_kunjungan', 'KJ-20260820-003', NULL, '{\"tz\": \"UTC\", \"no_rm\": \"RM-000001\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-20 15:39:32\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"22:39:32\", \"updated_at\": \"2026-08-20 15:39:32\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260820-003\", \"tanggal_kunjungan\": \"2026-08-20\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:39:32', '2026-08-20 15:39:32'),
(81, 'CREATE', 'Tambah Antrian Layanan AL-20260820-003 (01)', 'trx_antrian_layanan', 'AL-20260820-003', NULL, '{\"tz\": \"UTC\", \"status\": \"menunggu\", \"created_at\": \"2026-08-20 15:39:32\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20 15:39:32\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-002\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260820-003\", \"kode_antrian_layanan\": \"AL-20260820-003\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:39:32', '2026-08-20 15:39:32'),
(82, 'DELETE', 'Hapus Antrian Layanan & Kunjungan AL-20260820-002, AL-20260820-003', 'trx_antrian_layanan', 'AL-20260820-002, AL-20260820-003', '[{\"kode_kunjungan\": \"KJ-20260820-002\", \"kode_antrian_layanan\": \"AL-20260820-002\"}, {\"kode_kunjungan\": \"KJ-20260820-003\", \"kode_antrian_layanan\": \"AL-20260820-003\"}]', NULL, 'UTC', 'superadmin@admin.com', '2026-08-20 15:39:32', '2026-08-20 15:39:32'),
(83, 'CREATE', 'Tambah Pasien Baru RM-000001 (Test Pasien Full Field)', 'mst_pasien', 'RM-000001', NULL, '{\"tz\": \"UTC\", \"nik\": \"3515999999999999\", \"nama\": \"Test Pasien Full Field\", \"agama\": \"Islam\", \"email\": \"pasien.test@gmail.com\", \"no_hp\": \"081999888777\", \"no_rm\": \"RM-000001\", \"alergi\": \"Alergi Parasetamol\", \"status\": \"aktif\", \"patokan\": \"Jl. Dharmahusada No. 45\", \"kode_pos\": \"60286\", \"provinsi\": \"Jawa Timur\", \"kecamatan\": \"Gubeng\", \"pekerjaan\": \"Pengusaha\", \"created_at\": \"2026-08-20 15:47:03\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20 15:47:03\", \"updated_by\": \"superadmin@admin.com\", \"tempat_lahir\": \"Surabaya\", \"jenis_kelamin\": \"P\", \"tanggal_lahir\": \"1998-08-20\", \"golongan_darah\": \"O\", \"kelurahan_desa\": \"Airlangga\", \"kota_kabupaten\": \"Surabaya\", \"kewarganegaraan\": \"WNI\", \"status_perkawinan\": \"Menikah\", \"nama_kontak_darurat\": \"Budi Santoso\", \"no_hp_kontak_darurat\": \"081222333444\", \"hubungan_kontak_darurat\": \"Suami\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:47:03', '2026-08-20 15:47:03'),
(84, 'CREATE', 'Tambah Kunjungan KJ-20260820-002 untuk RM RM-000001', 'trx_kunjungan', 'KJ-20260820-002', NULL, '{\"tz\": \"UTC\", \"no_rm\": \"RM-000001\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-20 15:47:03\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"22:47:03\", \"updated_at\": \"2026-08-20 15:47:03\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260820-002\", \"tanggal_kunjungan\": \"2026-08-20\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:47:03', '2026-08-20 15:47:03'),
(85, 'CREATE', 'Tambah Antrian Layanan AL-20260820-002 (01)', 'trx_antrian_layanan', 'AL-20260820-002', NULL, '{\"tz\": \"UTC\", \"status\": \"menunggu\", \"created_at\": \"2026-08-20 15:47:03\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20 15:47:03\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"PKT-002\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260820-002\", \"kode_antrian_layanan\": \"AL-20260820-002\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:47:03', '2026-08-20 15:47:03'),
(86, 'CREATE', 'Tambah Kunjungan KJ-20260820-003 untuk RM RM-000001', 'trx_kunjungan', 'KJ-20260820-003', NULL, '{\"tz\": \"UTC\", \"no_rm\": \"RM-000001\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-20 15:47:03\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"22:47:03\", \"updated_at\": \"2026-08-20 15:47:03\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260820-003\", \"tanggal_kunjungan\": \"2026-08-20\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:47:03', '2026-08-20 15:47:03'),
(87, 'CREATE', 'Tambah Antrian Layanan AL-20260820-003 (01)', 'trx_antrian_layanan', 'AL-20260820-003', NULL, '{\"tz\": \"UTC\", \"status\": \"menunggu\", \"created_at\": \"2026-08-20 15:47:03\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20 15:47:03\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-002\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260820-003\", \"kode_antrian_layanan\": \"AL-20260820-003\"}', 'UTC', 'superadmin@admin.com', '2026-08-20 15:47:03', '2026-08-20 15:47:03'),
(88, 'DELETE', 'Hapus Antrian Layanan & Kunjungan AL-20260820-002, AL-20260820-003', 'trx_antrian_layanan', 'AL-20260820-002, AL-20260820-003', '[{\"kode_kunjungan\": \"KJ-20260820-002\", \"kode_antrian_layanan\": \"AL-20260820-002\"}, {\"kode_kunjungan\": \"KJ-20260820-003\", \"kode_antrian_layanan\": \"AL-20260820-003\"}]', NULL, 'UTC', 'superadmin@admin.com', '2026-08-20 15:47:03', '2026-08-20 15:47:03');

-- --------------------------------------------------------

--
-- Table structure for table `mst_alat`
--

CREATE TABLE `mst_alat` (
  `id` int NOT NULL,
  `kode_alat` varchar(20) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `merk` varchar(100) DEFAULT NULL,
  `tanggal_beli` date DEFAULT NULL,
  `kondisi` enum('baik','rusak_ringan','rusak_berat','maintenance') NOT NULL DEFAULT 'baik',
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mst_detail_paket_layanan`
--

CREATE TABLE `mst_detail_paket_layanan` (
  `id` int NOT NULL,
  `kode_detail_paket_layanan` varchar(20) NOT NULL,
  `kode_paket_layanan` varchar(20) NOT NULL,
  `kode_layanan` varchar(20) NOT NULL,
  `jumlah_sesi` int NOT NULL DEFAULT '1',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `mst_detail_paket_layanan`
--

INSERT INTO `mst_detail_paket_layanan` (`id`, `kode_detail_paket_layanan`, `kode_paket_layanan`, `kode_layanan`, `jumlah_sesi`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(1, 'DPKT-001', 'PKT-001', 'LAY-001', 5, 'UTC', 'superadmin@admin.com', '2026-08-20 15:46:53', NULL, '2026-08-20 15:46:53'),
(2, 'DPKT-002', 'PKT-002', 'LAY-002', 3, 'UTC', 'superadmin@admin.com', '2026-08-20 15:46:53', NULL, '2026-08-20 15:46:53'),
(3, 'DPKT-003', 'PKT-003', 'LAY-003', 4, 'UTC', 'superadmin@admin.com', '2026-08-20 15:46:53', NULL, '2026-08-20 15:46:53'),
(4, 'DPKT-004', 'PKT-004', 'LAY-003', 3, 'UTC', 'superadmin@admin.com', '2026-08-20 15:46:53', NULL, '2026-08-20 15:46:53'),
(5, 'DPKT-005', 'PKT-005', 'LAY-005', 5, 'UTC', 'superadmin@admin.com', '2026-08-20 15:46:53', NULL, '2026-08-20 15:46:53'),
(6, 'DPKT-006', 'PKT-006', 'LAY-004', 6, 'UTC', 'superadmin@admin.com', '2026-08-20 15:46:53', NULL, '2026-08-20 15:46:53');

-- --------------------------------------------------------

--
-- Table structure for table `mst_detail_paket_produk`
--

CREATE TABLE `mst_detail_paket_produk` (
  `id` int NOT NULL,
  `kode_detail_paket_produk` varchar(20) NOT NULL,
  `kode_paket_produk` varchar(20) NOT NULL,
  `kode_produk` varchar(20) NOT NULL,
  `jumlah` int NOT NULL DEFAULT '1',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mst_jadwal_karyawan`
--

CREATE TABLE `mst_jadwal_karyawan` (
  `id` int NOT NULL,
  `kode_jadwal` varchar(20) NOT NULL,
  `no_sip` varchar(20) NOT NULL,
  `hari` enum('senin','selasa','rabu','kamis','jumat','sabtu','minggu') NOT NULL,
  `jam_mulai` time NOT NULL,
  `jam_selesai` time NOT NULL,
  `kuota` int NOT NULL DEFAULT '0',
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mst_karyawan`
--

CREATE TABLE `mst_karyawan` (
  `id` int NOT NULL,
  `no_sip` varchar(20) NOT NULL,
  `kode_user` varchar(20) DEFAULT NULL,
  `nama` varchar(100) NOT NULL,
  `jabatan` enum('dokter','perawat','admin','kasir','apoteker','terapis') NOT NULL,
  `no_hp` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mst_kategori_layanan`
--

CREATE TABLE `mst_kategori_layanan` (
  `id` int NOT NULL,
  `kode_kategori_layanan` varchar(20) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `deskripsi` varchar(255) DEFAULT NULL,
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `mst_kategori_layanan`
--

INSERT INTO `mst_kategori_layanan` (`id`, `kode_kategori_layanan`, `nama`, `deskripsi`, `status`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(1, 'KAT-001', 'Perawatan Wajah', 'Perawatan komprehensif area wajah', 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 06:40:08'),
(2, 'KAT-002', 'Perawatan Kulit', 'Treatment kesehatan dan peremajaan kulit', 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:55:00', 'superadmin@admin.com', '2026-08-20 06:42:10'),
(3, 'KAT-003', 'Perawatan Rambut', 'Layanan terapi scalp dan nutrisi rambut', 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 06:00:15', 'superadmin@admin.com', '2026-08-20 06:45:00'),
(4, 'KAT-004', 'Perawatan Tubuh', 'Spa dan pemijatan relaksasi tubuh', 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 06:10:00', 'superadmin@admin.com', '2026-08-20 06:48:22'),
(5, 'KAT-005', 'Anti Aging', 'Terapi khusus penuaan dini dan kerutan', 'nonaktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 06:15:30', 'superadmin@admin.com', '2026-08-20 06:50:00');

-- --------------------------------------------------------

--
-- Table structure for table `mst_kategori_produk`
--

CREATE TABLE `mst_kategori_produk` (
  `id` int NOT NULL,
  `kode_kategori_produk` varchar(20) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `deskripsi` varchar(255) DEFAULT NULL,
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mst_layanan`
--

CREATE TABLE `mst_layanan` (
  `id` int NOT NULL,
  `kode_layanan` varchar(20) NOT NULL,
  `kode_kategori_layanan` varchar(20) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `harga` decimal(12,2) NOT NULL DEFAULT '0.00',
  `durasi_menit` int NOT NULL DEFAULT '30',
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `mst_layanan`
--

INSERT INTO `mst_layanan` (`id`, `kode_layanan`, `kode_kategori_layanan`, `nama`, `harga`, `durasi_menit`, `status`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(1, 'LAY-001', 'KAT-001', 'Facial Glow Up', '150000.00', 45, 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 06:40:08'),
(2, 'LAY-002', 'KAT-001', 'Acne Care Treatment', '200000.00', 60, 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:58:00', 'superadmin@admin.com', '2026-08-20 06:43:00'),
(3, 'LAY-003', 'KAT-002', 'Laser Brightening', '450000.00', 30, 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 06:02:00', 'superadmin@admin.com', '2026-08-20 06:46:12'),
(4, 'LAY-004', 'KAT-003', 'Hair Spa Therapy', '120000.00', 60, 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 06:12:00', 'superadmin@admin.com', '2026-08-20 06:49:05'),
(5, 'LAY-005', 'KAT-004', 'Body Scrub & Massage', '250000.00', 90, 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 06:20:00', 'superadmin@admin.com', '2026-08-20 06:52:40');

-- --------------------------------------------------------

--
-- Table structure for table `mst_master_navigation`
--

CREATE TABLE `mst_master_navigation` (
  `id` int NOT NULL,
  `kode_navigation` varchar(20) NOT NULL,
  `kode_parent` varchar(20) DEFAULT NULL,
  `nama_menu` varchar(100) NOT NULL,
  `url` varchar(150) DEFAULT NULL,
  `icon` varchar(50) DEFAULT NULL,
  `urutan` int NOT NULL DEFAULT '0',
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mst_navigation`
--

CREATE TABLE `mst_navigation` (
  `id` int NOT NULL,
  `menu` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tz` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'UTC',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `mst_navigation`
--

INSERT INTO `mst_navigation` (`id`, `menu`, `role`, `tz`, `created_at`, `updated_at`) VALUES
(1, '[{\"label\":\"HOME\",\"icon\":\"pi pi-fw pi-home\",\"items\":[{\"label\":\"Dashboard\",\"icon\":\"pi pi-fw pi-home\",\"to\":\"/dashboard\"}]},{\"label\":\"Pendaftaran & Antrean\",\"icon\":\"pi pi-fw pi-calendar\",\"items\":[{\"label\":\"Antrean Awal\",\"icon\":\"pi pi-fw pi-ticket\",\"to\":\"/antrian-awal\"},{\"label\":\"Pendaftaran Pasien\",\"icon\":\"pi pi-fw pi-user-plus\",\"to\":\"/pendaftaran-antrean/pendaftaran-pasien\"},{\"label\":\"Antrean\",\"icon\":\"pi pi-fw pi-list\",\"to\":\"/pendaftaran-antrean/antrean\"}]},{\"label\":\"Pelayanan Medis\",\"icon\":\"pi pi-fw pi-heart\",\"items\":[{\"label\":\"Rekam Medis\",\"icon\":\"pi pi-fw pi-folder\",\"to\":\"/pelayanan-medis/rekam-medis\"},{\"label\":\"Riwayat Treatment\",\"icon\":\"pi pi-fw pi-history\",\"to\":\"/pelayanan-medis/riwayat-treatment\"}]},{\"label\":\"Layanan & Treatment\",\"icon\":\"pi pi-fw pi-sparkles\",\"items\":[{\"label\":\"Kategori Layanan\",\"icon\":\"pi pi-fw pi-tags\",\"to\":\"/layanan-treatment/kategori-layanan\"},{\"label\":\"Data Layanan\",\"icon\":\"pi pi-fw pi-briefcase\",\"to\":\"/layanan-treatment/data-layanan\"},{\"label\":\"Paket Layanan\",\"icon\":\"pi pi-fw pi-box\",\"to\":\"/layanan-treatment/paket-layanan\"}]},{\"label\":\"Produk & Skincare\",\"icon\":\"pi pi-fw pi-shopping-bag\",\"items\":[{\"label\":\"Kategori Produk\",\"icon\":\"pi pi-fw pi-tags\",\"to\":\"/produk-skincare/kategori-produk\"},{\"label\":\"Data Produk\",\"icon\":\"pi pi-fw pi-box\",\"to\":\"/produk-skincare/data-produk\"},{\"label\":\"Paket Produk\",\"icon\":\"pi pi-fw pi-inbox\",\"to\":\"/produk-skincare/paket-produk\"},{\"label\":\"Stok / Inventori\",\"icon\":\"pi pi-fw pi-database\",\"to\":\"/produk-skincare/stok-inventori\"}]},{\"label\":\"Kasir & Transaksi\",\"icon\":\"pi pi-fw pi-dollar\",\"items\":[{\"label\":\"Transaksi\",\"icon\":\"pi pi-fw pi-shopping-cart\",\"to\":\"/kasir-transaksi/transaksi\"},{\"label\":\"Promo\",\"icon\":\"pi pi-fw pi-percentage\",\"to\":\"/kasir-transaksi/promo\"}]},{\"label\":\"Alat & Maintenance\",\"icon\":\"pi pi-fw pi-wrench\",\"to\":\"/alat-maintenance\"},{\"label\":\"Pembelian & Supplier\",\"icon\":\"pi pi-fw pi-truck\",\"items\":[{\"label\":\"Supplier\",\"icon\":\"pi pi-fw pi-users\",\"to\":\"/pembelian-supplier/supplier\"},{\"label\":\"Purchase Order\",\"icon\":\"pi pi-fw pi-file\",\"to\":\"/pembelian-supplier/purchase-order\"}]},{\"label\":\"Karyawan & Jadwal\",\"icon\":\"pi pi-fw pi-id-card\",\"items\":[{\"label\":\"Data Karyawan\",\"icon\":\"pi pi-fw pi-users\",\"to\":\"/karyawan-jadwal/data-karyawan\"},{\"label\":\"Jadwal Praktik\",\"icon\":\"pi pi-fw pi-clock\",\"to\":\"/karyawan-jadwal/jadwal-praktik\"}]},{\"label\":\"Master Data & User\",\"icon\":\"pi pi-fw pi-cog\",\"items\":[{\"label\":\"Data Pasien\",\"icon\":\"pi pi-fw pi-user\",\"to\":\"/master-data-user/data-pasien\"},{\"label\":\"Manajemen Menu\",\"icon\":\"pi pi-fw pi-bars\",\"to\":\"/setup/navigation\"},{\"label\":\"Manajemen User\",\"icon\":\"pi pi-fw pi-users\",\"to\":\"/setup/users\"}]},{\"label\":\"Laporan & Analitik\",\"icon\":\"pi pi-fw pi-chart-bar\",\"to\":\"/laporan-analitik\"}]', 'master', 'UTC', '2026-08-20 11:29:37', '2026-08-20 11:29:37');

-- --------------------------------------------------------

--
-- Table structure for table `mst_paket_layanan`
--

CREATE TABLE `mst_paket_layanan` (
  `id` int NOT NULL,
  `kode_paket_layanan` varchar(20) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `harga_paket` decimal(12,2) NOT NULL DEFAULT '0.00',
  `masa_berlaku_hari` int NOT NULL DEFAULT '365',
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `mst_paket_layanan`
--

INSERT INTO `mst_paket_layanan` (`id`, `kode_paket_layanan`, `nama`, `harga_paket`, `masa_berlaku_hari`, `status`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(4, 'PKT-001', 'Paket Glowing Skin (5x Facial + Serum)', '1250000.00', 90, 'aktif', 'UTC', 'superadmin@admin.com', '2026-08-20 15:38:44', NULL, '2026-08-20 15:38:44'),
(5, 'PKT-002', 'Paket Acne Cure Complete (3x Laser + Peeling)', '1850000.00', 60, 'aktif', 'UTC', 'superadmin@admin.com', '2026-08-20 15:38:44', NULL, '2026-08-20 15:38:44'),
(6, 'PKT-003', 'Paket Anti-Aging Premium (4x Botox & HIFU)', '4500000.00', 180, 'aktif', 'UTC', 'superadmin@admin.com', '2026-08-20 15:38:44', NULL, '2026-08-20 15:38:44'),
(7, 'PKT-004', 'Paket Brightening Laser Rejuvenation (3x)', '2200000.00', 90, 'aktif', 'UTC', 'superadmin@admin.com', '2026-08-20 15:38:44', NULL, '2026-08-20 15:38:44'),
(8, 'PKT-005', 'Paket Slimming & Body Contour (5x Treatment)', '3200000.00', 120, 'aktif', 'UTC', 'superadmin@admin.com', '2026-08-20 15:38:44', NULL, '2026-08-20 15:38:44'),
(9, 'PKT-006', 'Paket Hair Removal Underarm (6x Session)', '950000.00', 180, 'aktif', 'UTC', 'superadmin@admin.com', '2026-08-20 15:38:44', NULL, '2026-08-20 15:38:44');

-- --------------------------------------------------------

--
-- Table structure for table `mst_paket_produk`
--

CREATE TABLE `mst_paket_produk` (
  `id` int NOT NULL,
  `kode_paket_produk` varchar(20) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `harga_paket` decimal(12,2) NOT NULL DEFAULT '0.00',
  `masa_berlaku_hari` int NOT NULL DEFAULT '365',
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mst_pasien`
--

CREATE TABLE `mst_pasien` (
  `id` int NOT NULL,
  `no_rm` varchar(20) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `nik` varchar(20) DEFAULT NULL,
  `tempat_lahir` varchar(50) DEFAULT NULL,
  `tanggal_lahir` date NOT NULL,
  `jenis_kelamin` enum('L','P') NOT NULL,
  `golongan_darah` enum('A','B','AB','O','-') DEFAULT NULL,
  `agama` enum('Islam','Kristen','Katolik','Hindu','Buddha','Konghucu','Lainnya') DEFAULT NULL,
  `status_perkawinan` enum('belum_menikah','menikah','cerai_hidup','cerai_mati') DEFAULT NULL,
  `kewarganegaraan` enum('WNI','WNA') NOT NULL DEFAULT 'WNI',
  `pekerjaan` varchar(50) DEFAULT NULL,
  `provinsi` varchar(50) DEFAULT NULL,
  `kota_kabupaten` varchar(50) DEFAULT NULL,
  `kecamatan` varchar(50) DEFAULT NULL,
  `kelurahan_desa` varchar(50) DEFAULT NULL,
  `kode_pos` varchar(10) DEFAULT NULL,
  `patokan` varchar(255) DEFAULT NULL,
  `no_hp` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `nama_kontak_darurat` varchar(100) DEFAULT NULL,
  `no_hp_kontak_darurat` varchar(20) DEFAULT NULL,
  `hubungan_kontak_darurat` varchar(30) DEFAULT NULL,
  `alergi` text,
  `foto` varchar(255) DEFAULT NULL,
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `mst_pasien`
--

INSERT INTO `mst_pasien` (`id`, `no_rm`, `nama`, `nik`, `tempat_lahir`, `tanggal_lahir`, `jenis_kelamin`, `golongan_darah`, `agama`, `status_perkawinan`, `kewarganegaraan`, `pekerjaan`, `provinsi`, `kota_kabupaten`, `kecamatan`, `kelurahan_desa`, `kode_pos`, `patokan`, `no_hp`, `email`, `nama_kontak_darurat`, `no_hp_kontak_darurat`, `hubungan_kontak_darurat`, `alergi`, `foto`, `status`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(1, 'RM-000000', 'Pasien Umum / Antrian Awal', NULL, NULL, '2000-01-01', 'L', NULL, NULL, NULL, 'WNI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0800000000', NULL, NULL, NULL, NULL, NULL, NULL, 'aktif', 'UTC', NULL, '2026-08-20 04:50:15', NULL, '2026-08-20 04:50:15');

-- --------------------------------------------------------

--
-- Table structure for table `mst_produk`
--

CREATE TABLE `mst_produk` (
  `id` int NOT NULL,
  `kode_produk` varchar(20) NOT NULL,
  `kode_kategori_produk` varchar(20) NOT NULL,
  `kode_supplier` varchar(20) DEFAULT NULL,
  `nama` varchar(100) NOT NULL,
  `satuan` varchar(20) NOT NULL DEFAULT 'pcs',
  `harga_beli` decimal(12,2) NOT NULL DEFAULT '0.00',
  `harga_jual` decimal(12,2) NOT NULL DEFAULT '0.00',
  `stok_minimum` int NOT NULL DEFAULT '0',
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mst_promo`
--

CREATE TABLE `mst_promo` (
  `id` int NOT NULL,
  `kode_promo` varchar(20) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `jenis_diskon` enum('persen','nominal') NOT NULL DEFAULT 'persen',
  `nilai_diskon` decimal(12,2) NOT NULL DEFAULT '0.00',
  `tanggal_mulai` date NOT NULL,
  `tanggal_selesai` date NOT NULL,
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mst_supplier`
--

CREATE TABLE `mst_supplier` (
  `id` int NOT NULL,
  `kode_supplier` varchar(20) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `alamat` varchar(255) DEFAULT NULL,
  `no_hp` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trx_antrian_awal`
--

CREATE TABLE `trx_antrian_awal` (
  `id` int NOT NULL,
  `kode_antrian_awal` varchar(20) NOT NULL,
  `nomor_antrian` varchar(10) NOT NULL,
  `status` enum('tersedia','terpakai','dipanggil') NOT NULL DEFAULT 'tersedia',
  `diambil_at` timestamp NULL DEFAULT NULL,
  `dipanggil_at` timestamp NULL DEFAULT NULL,
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `trx_antrian_awal`
--

INSERT INTO `trx_antrian_awal` (`id`, `kode_antrian_awal`, `nomor_antrian`, `status`, `diambil_at`, `dipanggil_at`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(35, 'A-20260820-001', '01', 'terpakai', '2026-08-20 06:36:36', '2026-08-20 06:36:41', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 06:40:08'),
(36, 'A-20260820-002', '02', 'terpakai', '2026-08-20 05:51:17', '2026-08-20 05:51:21', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 06:36:33'),
(37, 'A-20260820-003', '03', 'dipanggil', '2026-08-20 06:40:12', '2026-08-20 06:40:16', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 06:40:16'),
(38, 'A-20260820-004', '04', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(39, 'A-20260820-005', '05', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(40, 'A-20260820-006', '06', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(41, 'A-20260820-007', '07', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(42, 'A-20260820-008', '08', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(43, 'A-20260820-009', '09', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(44, 'A-20260820-010', '10', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(45, 'A-20260820-011', '11', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(46, 'A-20260820-012', '12', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(47, 'A-20260820-013', '13', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(48, 'A-20260820-014', '14', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(49, 'A-20260820-015', '15', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(50, 'A-20260820-016', '16', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(51, 'A-20260820-017', '17', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(52, 'A-20260820-018', '18', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(53, 'A-20260820-019', '19', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(54, 'A-20260820-020', '20', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(55, 'A-20260820-021', '21', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(56, 'A-20260820-022', '22', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(57, 'A-20260820-023', '23', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(58, 'A-20260820-024', '24', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(59, 'A-20260820-025', '25', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(60, 'A-20260820-026', '26', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(61, 'A-20260820-027', '27', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(62, 'A-20260820-028', '28', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(63, 'A-20260820-029', '29', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(64, 'A-20260820-030', '30', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(65, 'A-20260820-031', '31', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(66, 'A-20260820-032', '32', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(67, 'A-20260820-033', '33', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(68, 'A-20260820-034', '34', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(69, 'A-20260820-035', '35', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(70, 'A-20260820-036', '36', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(71, 'A-20260820-037', '37', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(72, 'A-20260820-038', '38', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(73, 'A-20260820-039', '39', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(74, 'A-20260820-040', '40', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(75, 'A-20260820-041', '41', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(76, 'A-20260820-042', '42', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(77, 'A-20260820-043', '43', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(78, 'A-20260820-044', '44', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(79, 'A-20260820-045', '45', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(80, 'A-20260820-046', '46', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(81, 'A-20260820-047', '47', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(82, 'A-20260820-048', '48', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(83, 'A-20260820-049', '49', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(84, 'A-20260820-050', '50', 'tersedia', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00');

-- --------------------------------------------------------

--
-- Table structure for table `trx_antrian_layanan`
--

CREATE TABLE `trx_antrian_layanan` (
  `id` int NOT NULL,
  `kode_antrian_layanan` varchar(20) NOT NULL,
  `kode_kunjungan` varchar(20) NOT NULL,
  `kode_layanan` varchar(20) NOT NULL,
  `nomor_antrian` varchar(10) NOT NULL,
  `status` enum('menunggu','dipanggil','selesai','batal') NOT NULL DEFAULT 'menunggu',
  `dipanggil_at` timestamp NULL DEFAULT NULL,
  `selesai_at` timestamp NULL DEFAULT NULL,
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `trx_antrian_layanan`
--

INSERT INTO `trx_antrian_layanan` (`id`, `kode_antrian_layanan`, `kode_kunjungan`, `kode_layanan`, `nomor_antrian`, `status`, `dipanggil_at`, `selesai_at`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(5, 'AL-20260820-001', 'KJ-20260820-001', 'LAY-005', '01', 'batal', '2026-08-20 08:01:16', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 07:46:41', 'superadmin@admin.com', '2026-08-20 08:30:51');

-- --------------------------------------------------------

--
-- Table structure for table `trx_detail_kepemilikan_paket_layanan`
--

CREATE TABLE `trx_detail_kepemilikan_paket_layanan` (
  `id` int NOT NULL,
  `kode_detail_kepemilikan_paket_layanan` varchar(20) NOT NULL,
  `kode_kepemilikan_paket_layanan` varchar(20) NOT NULL,
  `kode_layanan` varchar(20) NOT NULL,
  `sesi_total` int NOT NULL DEFAULT '0',
  `sesi_terpakai` int NOT NULL DEFAULT '0',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trx_detail_purchase_order`
--

CREATE TABLE `trx_detail_purchase_order` (
  `id` int NOT NULL,
  `kode_detail_po` varchar(20) NOT NULL,
  `kode_po` varchar(20) NOT NULL,
  `kode_produk` varchar(20) NOT NULL,
  `qty` int NOT NULL DEFAULT '1',
  `harga_satuan` decimal(12,2) NOT NULL DEFAULT '0.00',
  `subtotal` decimal(12,2) NOT NULL DEFAULT '0.00',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trx_detail_transaksi`
--

CREATE TABLE `trx_detail_transaksi` (
  `id` int NOT NULL,
  `kode_detail_transaksi` varchar(20) NOT NULL,
  `kode_transaksi` varchar(20) NOT NULL,
  `kode_layanan` varchar(20) DEFAULT NULL,
  `kode_produk` varchar(20) DEFAULT NULL,
  `qty` int NOT NULL DEFAULT '1',
  `harga_satuan` decimal(12,2) NOT NULL DEFAULT '0.00',
  `subtotal` decimal(12,2) NOT NULL DEFAULT '0.00',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trx_kepemilikan_paket_layanan`
--

CREATE TABLE `trx_kepemilikan_paket_layanan` (
  `id` int NOT NULL,
  `kode_kepemilikan_paket_layanan` varchar(20) NOT NULL,
  `no_rm` varchar(20) NOT NULL,
  `kode_paket_layanan` varchar(20) NOT NULL,
  `kode_transaksi` varchar(20) DEFAULT NULL,
  `tanggal_beli` date NOT NULL,
  `tanggal_expired` date NOT NULL,
  `status` enum('aktif','habis','expired') NOT NULL DEFAULT 'aktif',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trx_kepemilikan_paket_produk`
--

CREATE TABLE `trx_kepemilikan_paket_produk` (
  `id` int NOT NULL,
  `kode_kepemilikan_paket_produk` varchar(20) NOT NULL,
  `no_rm` varchar(20) NOT NULL,
  `kode_paket_produk` varchar(20) NOT NULL,
  `kode_transaksi` varchar(20) DEFAULT NULL,
  `tanggal_beli` date NOT NULL,
  `tanggal_expired` date NOT NULL,
  `status` enum('aktif','habis','expired') NOT NULL DEFAULT 'aktif',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trx_kunjungan`
--

CREATE TABLE `trx_kunjungan` (
  `id` int NOT NULL,
  `kode_kunjungan` varchar(20) NOT NULL,
  `no_rm` varchar(20) NOT NULL,
  `tanggal_kunjungan` date NOT NULL,
  `jam_datang` time NOT NULL,
  `status` enum('berlangsung','selesai','batal') NOT NULL DEFAULT 'berlangsung',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `trx_kunjungan`
--

INSERT INTO `trx_kunjungan` (`id`, `kode_kunjungan`, `no_rm`, `tanggal_kunjungan`, `jam_datang`, `status`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(8, 'KJ-20260820-001', 'RM-000000', '2026-08-20', '21:46:41', 'berlangsung', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 07:46:41', 'superadmin@admin.com', '2026-08-20 07:46:41');

-- --------------------------------------------------------

--
-- Table structure for table `trx_maintenance_alat`
--

CREATE TABLE `trx_maintenance_alat` (
  `id` int NOT NULL,
  `kode_maintenance` varchar(20) NOT NULL,
  `kode_alat` varchar(20) NOT NULL,
  `tanggal_maintenance` date NOT NULL,
  `jenis` enum('rutin','perbaikan','kalibrasi') NOT NULL DEFAULT 'rutin',
  `biaya` decimal(12,2) NOT NULL DEFAULT '0.00',
  `keterangan` varchar(255) DEFAULT NULL,
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trx_pemakaian_paket_layanan`
--

CREATE TABLE `trx_pemakaian_paket_layanan` (
  `id` int NOT NULL,
  `kode_pemakaian_paket_layanan` varchar(20) NOT NULL,
  `kode_detail_kepemilikan_paket_layanan` varchar(20) NOT NULL,
  `kode_kunjungan` varchar(20) NOT NULL,
  `tanggal_pakai` date NOT NULL,
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trx_pengambilan_paket_produk`
--

CREATE TABLE `trx_pengambilan_paket_produk` (
  `id` int NOT NULL,
  `kode_pengambilan_paket_produk` varchar(20) NOT NULL,
  `kode_kepemilikan_paket_produk` varchar(20) NOT NULL,
  `kode_produk` varchar(20) NOT NULL,
  `qty_diambil` int NOT NULL DEFAULT '1',
  `tanggal_ambil` date NOT NULL,
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trx_purchase_order`
--

CREATE TABLE `trx_purchase_order` (
  `id` int NOT NULL,
  `kode_po` varchar(20) NOT NULL,
  `kode_supplier` varchar(20) NOT NULL,
  `tanggal_po` date NOT NULL,
  `total_po` decimal(12,2) NOT NULL DEFAULT '0.00',
  `status` enum('draft','dikirim','diterima','batal') NOT NULL DEFAULT 'draft',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trx_rekam_medis`
--

CREATE TABLE `trx_rekam_medis` (
  `id` int NOT NULL,
  `kode_rekam_medis` varchar(20) NOT NULL,
  `kode_kunjungan` varchar(20) NOT NULL,
  `no_rm` varchar(20) NOT NULL,
  `no_sip` varchar(20) NOT NULL,
  `keluhan` text,
  `diagnosa` text,
  `tindakan` text,
  `catatan` text,
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trx_riwayat_treatment`
--

CREATE TABLE `trx_riwayat_treatment` (
  `id` int NOT NULL,
  `kode_riwayat_treatment` varchar(20) NOT NULL,
  `no_rm` varchar(20) NOT NULL,
  `kode_layanan` varchar(20) NOT NULL,
  `kode_rekam_medis` varchar(20) DEFAULT NULL,
  `tanggal_treatment` date NOT NULL,
  `hasil` text,
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trx_stok_movement`
--

CREATE TABLE `trx_stok_movement` (
  `id` int NOT NULL,
  `kode_stok_movement` varchar(20) NOT NULL,
  `kode_produk` varchar(20) NOT NULL,
  `jenis_movement` enum('masuk','keluar','penyesuaian') NOT NULL,
  `referensi` varchar(20) DEFAULT NULL COMMENT 'kode_po / kode_transaksi / kode_pengambilan_paket_produk',
  `qty` int NOT NULL,
  `stok_sebelum` int NOT NULL DEFAULT '0',
  `stok_sesudah` int NOT NULL DEFAULT '0',
  `tanggal` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trx_transaksi`
--

CREATE TABLE `trx_transaksi` (
  `id` int NOT NULL,
  `kode_transaksi` varchar(20) NOT NULL,
  `kode_kunjungan` varchar(20) DEFAULT NULL,
  `no_rm` varchar(20) NOT NULL,
  `kode_promo` varchar(20) DEFAULT NULL,
  `tanggal_transaksi` date NOT NULL,
  `total_harga` decimal(12,2) NOT NULL DEFAULT '0.00',
  `total_diskon` decimal(12,2) NOT NULL DEFAULT '0.00',
  `total_bayar` decimal(12,2) NOT NULL DEFAULT '0.00',
  `metode_bayar` enum('tunai','debit','kredit','qris','transfer') NOT NULL DEFAULT 'tunai',
  `status` enum('draft','lunas','batal') NOT NULL DEFAULT 'draft',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `kode_user` varchar(20) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `role` enum('admin','dokter','kasir','apoteker','owner') NOT NULL DEFAULT 'admin',
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `tz` varchar(50) NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `kode_user`, `nama`, `email`, `role`, `status`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(1, 'USR000000', 'Superadmin', 'superadmin@admin.com', 'admin', 'aktif', 'UTC', NULL, '2026-08-20 11:29:37', NULL, '2026-08-20 11:29:37');

-- --------------------------------------------------------

--
-- Table structure for table `user_credential`
--

CREATE TABLE `user_credential` (
  `id` bigint NOT NULL,
  `user_code` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fullname` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telp` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('0','1') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
  `tz` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'UTC',
  `created_at` datetime DEFAULT NULL,
  `created_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_credential`
--

INSERT INTO `user_credential` (`id`, `user_code`, `username`, `fullname`, `telp`, `role`, `password`, `status`, `tz`, `created_at`, `created_by`, `updated_by`, `updated_at`) VALUES
(1, 'USR000000', 'superadmin@admin.com', 'Superadmin', '08100000000', 'superadmin', '5e7bd870d5c8563803be2973dd4403ef50c918d3b728f22787c9514d0f379f94d7f6bbb7e8b0a8cc338a6a18bd399aa8e5888a28b5f91452ad55fd6e2cf0b58c', '1', 'UTC', '2026-08-20 11:29:37', NULL, NULL, '2026-08-20 11:29:37');

-- --------------------------------------------------------

--
-- Table structure for table `user_navigation`
--

CREATE TABLE `user_navigation` (
  `id` int NOT NULL,
  `user_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `menu` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `tz` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'UTC',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_navigation`
--

INSERT INTO `user_navigation` (`id`, `user_code`, `menu`, `tz`, `created_at`, `updated_at`) VALUES
(1, 'USR000000', '[{\"label\":\"HOME\",\"icon\":\"pi pi-fw pi-home\",\"items\":[{\"label\":\"Dashboard\",\"icon\":\"pi pi-fw pi-home\",\"to\":\"/dashboard\"}]},{\"label\":\"Pendaftaran & Antrean\",\"icon\":\"pi pi-fw pi-calendar\",\"items\":[{\"label\":\"Antrean Awal\",\"icon\":\"pi pi-fw pi-ticket\",\"to\":\"/antrian-awal\"},{\"label\":\"Pendaftaran Pasien\",\"icon\":\"pi pi-fw pi-user-plus\",\"to\":\"/pendaftaran-antrean/pendaftaran-pasien\"},{\"label\":\"Antrean\",\"icon\":\"pi pi-fw pi-list\",\"to\":\"/pendaftaran-antrean/antrean\"}]},{\"label\":\"Pelayanan Medis\",\"icon\":\"pi pi-fw pi-heart\",\"items\":[{\"label\":\"Rekam Medis\",\"icon\":\"pi pi-fw pi-folder\",\"to\":\"/pelayanan-medis/rekam-medis\"},{\"label\":\"Riwayat Treatment\",\"icon\":\"pi pi-fw pi-history\",\"to\":\"/pelayanan-medis/riwayat-treatment\"}]},{\"label\":\"Layanan & Treatment\",\"icon\":\"pi pi-fw pi-sparkles\",\"items\":[{\"label\":\"Kategori Layanan\",\"icon\":\"pi pi-fw pi-tags\",\"to\":\"/layanan-treatment/kategori-layanan\"},{\"label\":\"Data Layanan\",\"icon\":\"pi pi-fw pi-briefcase\",\"to\":\"/layanan-treatment/data-layanan\"},{\"label\":\"Paket Layanan\",\"icon\":\"pi pi-fw pi-box\",\"to\":\"/layanan-treatment/paket-layanan\"}]},{\"label\":\"Produk & Skincare\",\"icon\":\"pi pi-fw pi-shopping-bag\",\"items\":[{\"label\":\"Kategori Produk\",\"icon\":\"pi pi-fw pi-tags\",\"to\":\"/produk-skincare/kategori-produk\"},{\"label\":\"Data Produk\",\"icon\":\"pi pi-fw pi-box\",\"to\":\"/produk-skincare/data-produk\"},{\"label\":\"Paket Produk\",\"icon\":\"pi pi-fw pi-inbox\",\"to\":\"/produk-skincare/paket-produk\"},{\"label\":\"Stok / Inventori\",\"icon\":\"pi pi-fw pi-database\",\"to\":\"/produk-skincare/stok-inventori\"}]},{\"label\":\"Kasir & Transaksi\",\"icon\":\"pi pi-fw pi-dollar\",\"items\":[{\"label\":\"Transaksi\",\"icon\":\"pi pi-fw pi-shopping-cart\",\"to\":\"/kasir-transaksi/transaksi\"},{\"label\":\"Promo\",\"icon\":\"pi pi-fw pi-percentage\",\"to\":\"/kasir-transaksi/promo\"}]},{\"label\":\"Alat & Maintenance\",\"icon\":\"pi pi-fw pi-wrench\",\"to\":\"/alat-maintenance\"},{\"label\":\"Pembelian & Supplier\",\"icon\":\"pi pi-fw pi-truck\",\"items\":[{\"label\":\"Supplier\",\"icon\":\"pi pi-fw pi-users\",\"to\":\"/pembelian-supplier/supplier\"},{\"label\":\"Purchase Order\",\"icon\":\"pi pi-fw pi-file\",\"to\":\"/pembelian-supplier/purchase-order\"}]},{\"label\":\"Karyawan & Jadwal\",\"icon\":\"pi pi-fw pi-id-card\",\"items\":[{\"label\":\"Data Karyawan\",\"icon\":\"pi pi-fw pi-users\",\"to\":\"/karyawan-jadwal/data-karyawan\"},{\"label\":\"Jadwal Praktik\",\"icon\":\"pi pi-fw pi-clock\",\"to\":\"/karyawan-jadwal/jadwal-praktik\"}]},{\"label\":\"Master Data & User\",\"icon\":\"pi pi-fw pi-cog\",\"items\":[{\"label\":\"Data Pasien\",\"icon\":\"pi pi-fw pi-user\",\"to\":\"/master-data-user/data-pasien\"},{\"label\":\"Manajemen Menu\",\"icon\":\"pi pi-fw pi-bars\",\"to\":\"/setup/navigation\"},{\"label\":\"Manajemen User\",\"icon\":\"pi pi-fw pi-users\",\"to\":\"/setup/users\"}]},{\"label\":\"Laporan & Analitik\",\"icon\":\"pi pi-fw pi-chart-bar\",\"to\":\"/laporan-analitik\"}]', 'UTC', '2026-08-20 11:29:37', '2026-08-20 11:29:37');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `access_token`
--
ALTER TABLE `access_token`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `config`
--
ALTER TABLE `config`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `config_kode_unique` (`kode`);

--
-- Indexes for table `log`
--
ALTER TABLE `log`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `log_perubahan`
--
ALTER TABLE `log_perubahan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_log_perubahan_tabel_ref` (`nama_tabel`,`kode_referensi`),
  ADD KEY `idx_log_perubahan_created_at` (`created_at`);

--
-- Indexes for table `mst_alat`
--
ALTER TABLE `mst_alat`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_alat` (`kode_alat`);

--
-- Indexes for table `mst_detail_paket_layanan`
--
ALTER TABLE `mst_detail_paket_layanan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_detail_paket_layanan` (`kode_detail_paket_layanan`),
  ADD KEY `fk_detailpaketlyn_paket` (`kode_paket_layanan`),
  ADD KEY `fk_detailpaketlyn_layanan` (`kode_layanan`);

--
-- Indexes for table `mst_detail_paket_produk`
--
ALTER TABLE `mst_detail_paket_produk`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_detail_paket_produk` (`kode_detail_paket_produk`),
  ADD KEY `fk_detailpaketprd_paket` (`kode_paket_produk`),
  ADD KEY `fk_detailpaketprd_produk` (`kode_produk`);

--
-- Indexes for table `mst_jadwal_karyawan`
--
ALTER TABLE `mst_jadwal_karyawan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_jadwal` (`kode_jadwal`),
  ADD KEY `fk_jadwal_karyawan` (`no_sip`);

--
-- Indexes for table `mst_karyawan`
--
ALTER TABLE `mst_karyawan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `no_sip` (`no_sip`),
  ADD KEY `fk_karyawan_user` (`kode_user`);

--
-- Indexes for table `mst_kategori_layanan`
--
ALTER TABLE `mst_kategori_layanan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_kategori_layanan` (`kode_kategori_layanan`);

--
-- Indexes for table `mst_kategori_produk`
--
ALTER TABLE `mst_kategori_produk`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_kategori_produk` (`kode_kategori_produk`);

--
-- Indexes for table `mst_layanan`
--
ALTER TABLE `mst_layanan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_layanan` (`kode_layanan`),
  ADD KEY `fk_layanan_kategori` (`kode_kategori_layanan`);

--
-- Indexes for table `mst_master_navigation`
--
ALTER TABLE `mst_master_navigation`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_navigation` (`kode_navigation`),
  ADD KEY `fk_nav_parent` (`kode_parent`);

--
-- Indexes for table `mst_navigation`
--
ALTER TABLE `mst_navigation`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `mst_paket_layanan`
--
ALTER TABLE `mst_paket_layanan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_paket_layanan` (`kode_paket_layanan`);

--
-- Indexes for table `mst_paket_produk`
--
ALTER TABLE `mst_paket_produk`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_paket_produk` (`kode_paket_produk`);

--
-- Indexes for table `mst_pasien`
--
ALTER TABLE `mst_pasien`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `no_rm` (`no_rm`),
  ADD UNIQUE KEY `nik` (`nik`);

--
-- Indexes for table `mst_produk`
--
ALTER TABLE `mst_produk`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_produk` (`kode_produk`),
  ADD KEY `fk_produk_kategori` (`kode_kategori_produk`),
  ADD KEY `fk_produk_supplier` (`kode_supplier`);

--
-- Indexes for table `mst_promo`
--
ALTER TABLE `mst_promo`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_promo` (`kode_promo`);

--
-- Indexes for table `mst_supplier`
--
ALTER TABLE `mst_supplier`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_supplier` (`kode_supplier`);

--
-- Indexes for table `trx_antrian_awal`
--
ALTER TABLE `trx_antrian_awal`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_antrian_awal` (`kode_antrian_awal`),
  ADD UNIQUE KEY `uq_nomor_antrian` (`nomor_antrian`);

--
-- Indexes for table `trx_antrian_layanan`
--
ALTER TABLE `trx_antrian_layanan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_antrian_layanan` (`kode_antrian_layanan`),
  ADD KEY `fk_antrianlyn_kunjungan` (`kode_kunjungan`),
  ADD KEY `fk_antrianlyn_layanan` (`kode_layanan`);

--
-- Indexes for table `trx_detail_kepemilikan_paket_layanan`
--
ALTER TABLE `trx_detail_kepemilikan_paket_layanan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_detail_kepemilikan_paket_layanan` (`kode_detail_kepemilikan_paket_layanan`),
  ADD KEY `fk_detailkepemilikanlyn_induk` (`kode_kepemilikan_paket_layanan`),
  ADD KEY `fk_detailkepemilikanlyn_layanan` (`kode_layanan`);

--
-- Indexes for table `trx_detail_purchase_order`
--
ALTER TABLE `trx_detail_purchase_order`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_detail_po` (`kode_detail_po`),
  ADD KEY `fk_detailpo_po` (`kode_po`),
  ADD KEY `fk_detailpo_produk` (`kode_produk`);

--
-- Indexes for table `trx_detail_transaksi`
--
ALTER TABLE `trx_detail_transaksi`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_detail_transaksi` (`kode_detail_transaksi`),
  ADD KEY `fk_detailtrx_transaksi` (`kode_transaksi`),
  ADD KEY `fk_detailtrx_layanan` (`kode_layanan`),
  ADD KEY `fk_detailtrx_produk` (`kode_produk`);

--
-- Indexes for table `trx_kepemilikan_paket_layanan`
--
ALTER TABLE `trx_kepemilikan_paket_layanan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_kepemilikan_paket_layanan` (`kode_kepemilikan_paket_layanan`),
  ADD KEY `fk_kepemilikanlyn_pasien` (`no_rm`),
  ADD KEY `fk_kepemilikanlyn_paket` (`kode_paket_layanan`),
  ADD KEY `fk_kepemilikanlyn_transaksi` (`kode_transaksi`);

--
-- Indexes for table `trx_kepemilikan_paket_produk`
--
ALTER TABLE `trx_kepemilikan_paket_produk`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_kepemilikan_paket_produk` (`kode_kepemilikan_paket_produk`),
  ADD KEY `fk_kepemilikanprd_pasien` (`no_rm`),
  ADD KEY `fk_kepemilikanprd_paket` (`kode_paket_produk`),
  ADD KEY `fk_kepemilikanprd_transaksi` (`kode_transaksi`);

--
-- Indexes for table `trx_kunjungan`
--
ALTER TABLE `trx_kunjungan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_kunjungan` (`kode_kunjungan`),
  ADD KEY `fk_kunjungan_pasien` (`no_rm`);

--
-- Indexes for table `trx_maintenance_alat`
--
ALTER TABLE `trx_maintenance_alat`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_maintenance` (`kode_maintenance`),
  ADD KEY `fk_maintenance_alat` (`kode_alat`);

--
-- Indexes for table `trx_pemakaian_paket_layanan`
--
ALTER TABLE `trx_pemakaian_paket_layanan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_pemakaian_paket_layanan` (`kode_pemakaian_paket_layanan`),
  ADD KEY `fk_pemakaianlyn_detailkepemilikan` (`kode_detail_kepemilikan_paket_layanan`),
  ADD KEY `fk_pemakaianlyn_kunjungan` (`kode_kunjungan`);

--
-- Indexes for table `trx_pengambilan_paket_produk`
--
ALTER TABLE `trx_pengambilan_paket_produk`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_pengambilan_paket_produk` (`kode_pengambilan_paket_produk`),
  ADD KEY `fk_pengambilanprd_kepemilikan` (`kode_kepemilikan_paket_produk`),
  ADD KEY `fk_pengambilanprd_produk` (`kode_produk`);

--
-- Indexes for table `trx_purchase_order`
--
ALTER TABLE `trx_purchase_order`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_po` (`kode_po`),
  ADD KEY `fk_po_supplier` (`kode_supplier`);

--
-- Indexes for table `trx_rekam_medis`
--
ALTER TABLE `trx_rekam_medis`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_rekam_medis` (`kode_rekam_medis`),
  ADD KEY `fk_rekammedis_kunjungan` (`kode_kunjungan`),
  ADD KEY `fk_rekammedis_pasien` (`no_rm`),
  ADD KEY `fk_rekammedis_karyawan` (`no_sip`);

--
-- Indexes for table `trx_riwayat_treatment`
--
ALTER TABLE `trx_riwayat_treatment`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_riwayat_treatment` (`kode_riwayat_treatment`),
  ADD KEY `fk_riwayattrt_pasien` (`no_rm`),
  ADD KEY `fk_riwayattrt_layanan` (`kode_layanan`),
  ADD KEY `fk_riwayattrt_rekammedis` (`kode_rekam_medis`);

--
-- Indexes for table `trx_stok_movement`
--
ALTER TABLE `trx_stok_movement`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_stok_movement` (`kode_stok_movement`),
  ADD KEY `fk_stokmovement_produk` (`kode_produk`);

--
-- Indexes for table `trx_transaksi`
--
ALTER TABLE `trx_transaksi`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_transaksi` (`kode_transaksi`),
  ADD KEY `fk_transaksi_kunjungan` (`kode_kunjungan`),
  ADD KEY `fk_transaksi_pasien` (`no_rm`),
  ADD KEY `fk_transaksi_promo` (`kode_promo`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_user` (`kode_user`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `user_credential`
--
ALTER TABLE `user_credential`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `user_navigation`
--
ALTER TABLE `user_navigation`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uq_user_navigation_uniqueid` (`user_code`) USING BTREE;

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `access_token`
--
ALTER TABLE `access_token`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `config`
--
ALTER TABLE `config`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `log`
--
ALTER TABLE `log`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `log_perubahan`
--
ALTER TABLE `log_perubahan`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=89;

--
-- AUTO_INCREMENT for table `mst_alat`
--
ALTER TABLE `mst_alat`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mst_detail_paket_layanan`
--
ALTER TABLE `mst_detail_paket_layanan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `mst_detail_paket_produk`
--
ALTER TABLE `mst_detail_paket_produk`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mst_jadwal_karyawan`
--
ALTER TABLE `mst_jadwal_karyawan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mst_karyawan`
--
ALTER TABLE `mst_karyawan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mst_kategori_layanan`
--
ALTER TABLE `mst_kategori_layanan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `mst_kategori_produk`
--
ALTER TABLE `mst_kategori_produk`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mst_layanan`
--
ALTER TABLE `mst_layanan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `mst_master_navigation`
--
ALTER TABLE `mst_master_navigation`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mst_navigation`
--
ALTER TABLE `mst_navigation`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `mst_paket_layanan`
--
ALTER TABLE `mst_paket_layanan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `mst_paket_produk`
--
ALTER TABLE `mst_paket_produk`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mst_pasien`
--
ALTER TABLE `mst_pasien`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `mst_produk`
--
ALTER TABLE `mst_produk`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mst_promo`
--
ALTER TABLE `mst_promo`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mst_supplier`
--
ALTER TABLE `mst_supplier`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trx_antrian_awal`
--
ALTER TABLE `trx_antrian_awal`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=86;

--
-- AUTO_INCREMENT for table `trx_antrian_layanan`
--
ALTER TABLE `trx_antrian_layanan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `trx_detail_kepemilikan_paket_layanan`
--
ALTER TABLE `trx_detail_kepemilikan_paket_layanan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trx_detail_purchase_order`
--
ALTER TABLE `trx_detail_purchase_order`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trx_detail_transaksi`
--
ALTER TABLE `trx_detail_transaksi`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trx_kepemilikan_paket_layanan`
--
ALTER TABLE `trx_kepemilikan_paket_layanan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trx_kepemilikan_paket_produk`
--
ALTER TABLE `trx_kepemilikan_paket_produk`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trx_kunjungan`
--
ALTER TABLE `trx_kunjungan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `trx_maintenance_alat`
--
ALTER TABLE `trx_maintenance_alat`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trx_pemakaian_paket_layanan`
--
ALTER TABLE `trx_pemakaian_paket_layanan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trx_pengambilan_paket_produk`
--
ALTER TABLE `trx_pengambilan_paket_produk`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trx_purchase_order`
--
ALTER TABLE `trx_purchase_order`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trx_rekam_medis`
--
ALTER TABLE `trx_rekam_medis`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trx_riwayat_treatment`
--
ALTER TABLE `trx_riwayat_treatment`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trx_stok_movement`
--
ALTER TABLE `trx_stok_movement`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trx_transaksi`
--
ALTER TABLE `trx_transaksi`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `user_credential`
--
ALTER TABLE `user_credential`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `user_navigation`
--
ALTER TABLE `user_navigation`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
