-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Aug 24, 2026 at 02:11 AM
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
(10, '4286aa213d7e58100b9ba73c1a119e3bc3372d9cdde8da82e7c25150c26d3dd427d137e3976977ec', 'USR000000', '1', '2026-08-22 02:24:05', NULL),
(11, '2a0eefe843291419692b0ec42e04d93d1dae94af89d816431fa2ab4209a8d250634c583700660fd6', 'USR000000', '1', '2026-08-22 02:28:24', NULL),
(12, '2472d082d845da68630fa57c5c5084bc60fb1d2f37e7a87bf4fb59efc3899061d1b34fb030c1851f', 'USR000000', '1', '2026-08-22 02:28:25', NULL),
(13, 'dd305f922983a85e9f9a2d34a5d0b62ca21ef604bfc2b9a7f912a091ff067fc00d739bfb4d8cd7eb', 'USR000000', '1', '2026-08-22 02:28:26', NULL),
(14, '8b86ff6d7cc5603f8e0b5eda859cf48fafe1dc0b303173638580771d65a1e06a354b0d5cf234806a', 'USR000000', '1', '2026-08-22 02:28:26', NULL),
(15, 'b6e21203e2d8374c3ae2c7ac684c4fd201d5d583bf20b5aef6636d811b10d336ad7d8c73929c513d', 'USR000000', '1', '2026-08-22 02:28:27', NULL),
(16, 'ffbe7c787a66aeb1e909f0a8a2e44acea71f32b16ed34e40b4bd9edf7b19aae5ed9a351bbbd119af', 'USR000000', '1', '2026-08-22 02:28:27', NULL),
(17, '9df874fb4dd5310d6466bbbe656a30526b7c9b99547060b38a872c8b31188e3695c1e9384693977b', 'USR000000', '1', '2026-08-22 02:28:28', NULL),
(18, '21d911bd5d51793b3adea1d825da3cc356b392d983ed66bbcf736658f23135f05494eba027893877', 'USR000000', '1', '2026-08-22 02:28:28', NULL),
(19, 'abe522d78d9f2485c700af91b7de2bfaf4b26e1b7682f4f346941f68083f261a22297b8d1eec520c', 'USR000000', '1', '2026-08-22 02:28:29', NULL),
(20, 'ffb634802e623e7ac0bd9ca01f010680fce8cfa2e6a54915c928f9c71e5f8d8be63718c2769b5645', 'USR000000', '1', '2026-08-22 02:28:30', NULL),
(21, 'fd8e763aac617b0c02b2005f6970d3b8367868e6177d4cb95cbf92c8386731373de0ff0bfdf5c4b8', 'USR000000', '1', '2026-08-22 02:28:30', NULL),
(22, '8427358499dec3674f595091c441c233296ed7c28730486bbc498fbee519109776e953b766db47bd', 'USR000000', '1', '2026-08-22 02:28:31', NULL),
(23, '9f2b8cdcf800c5f2e2b390eedba61bca1fbe0f696e449050591439bc4657c8e2581a82690ab97791', 'USR000000', '1', '2026-08-22 02:28:31', NULL),
(24, 'dc72d8957655f9e20c419dc37d95e9449ff5bbe8cde1f77ef532fe9268bdbf863c0cca9973f493d7', 'USR000000', '1', '2026-08-22 02:28:32', NULL),
(25, '4a7945487db8143421c4cca5c6f34d14d6bf1455b34155581172c8ddd628ccfbbb176c4c79c04bcc', 'USR000000', '1', '2026-08-22 02:28:33', NULL),
(26, 'ddc0e6520d7446faed7df46fc70959708db7e8e2a5c3d73d4d3f1806c9b4b00b3e7b0058932c4439', 'USR000000', '1', '2026-08-22 02:28:33', NULL),
(27, '3e1f82b2e6a747d61c650e4fb6557272bcc54530cc32a46d7f131cad71e35dc6737e44c5b75a2793', 'USR000000', '1', '2026-08-22 02:28:34', NULL),
(28, 'db712d555eb567388ff3a09b0a0bfa7a20c9e3dc8cd38654ce06904fb1b1c7840f84c9d61abf588f', 'USR000000', '1', '2026-08-22 02:28:34', NULL),
(29, '6db5719423d9191947881bcd6f9a5ca6a5255d817df080693847ccb639aa6ff8a797fbf1cf2f64df', 'USR000000', '1', '2026-08-28 02:33:01', NULL),
(30, 'a160af4b774cef24539da53bc82fd5b91d4c2fd8f4009fc90a7b92672a0307629b4faf39cbea9d9d', 'USR000000', '1', '2026-08-28 02:33:56', NULL),
(31, 'bccabeb90055cf9c1ad89f9df9efcd83aa826ef1b4c66edecacf338338582465319660599b9766d4', 'USR000000', '1', '2026-08-28 02:34:06', NULL),
(32, 'd5a3209822858aa898c2f670e4dcd08b8a2e71a82165405f7174aefd072a37f8bfb42740530247d8', 'USR000000', '1', '2026-08-22 02:35:20', NULL),
(33, '2f940de2647c22faa4a56c96cc0f7fa34e2c2b764186d7fb358288a1072fb54272c457e0ffebf3ad', 'USR000000', '1', '2026-08-28 02:58:37', NULL),
(34, '5c820a5167699bfc3cd1ec200bf9318c333d9634d136d5975c940103e88f682149bc55dc5a045f4b', 'USR000000', '1', '2026-08-28 02:58:48', NULL),
(35, '506933df68ca3e4b63823ce06e4e19756e28a4c0985df1c25ea7213a5bcaa31b7b7f9f46781580df', 'USR000000', '1', '2026-08-28 03:10:08', NULL),
(36, '1f97898c1bbd1001b13f84a00cc897700e03da3761acc607790d92753a25c5fa11fd436902cf48d8', 'USR000000', '1', '2026-08-28 03:10:46', NULL),
(37, 'aa8f6708a643a1394106ce030e8f28a9a610b80d6f0b086b27dd4cce526dfc6722f3869aeae3ba48', 'USR000000', '1', '2026-08-22 04:17:02', NULL),
(38, '807d492208c64ba03b539156a3100b6cdabf616478f4cce35a939afdcf9a9fb0bd44b1d23c90a142', 'USR000000', '1', '2026-08-22 04:17:10', NULL),
(39, '973dd7f42383a366db397d8e48cc88839b170dbe18be2459e8454b9c04a93f0fba62bd7c66b38985', 'USR000000', '1', '2026-08-22 04:22:06', NULL),
(40, '3749d93fa017e4dbff7a8a4e93832456e08b2dc429b496e64f7018c198d6c13fae0b9c9f363f8fc2', 'USR000000', '1', '2026-08-22 04:22:15', NULL),
(41, '86d534f16c0c4eaa489dc6c6143d961c494166f27e7efca6de92cef05d8dd7b6076b8d3460b02415', 'USR000000', '1', '2026-08-22 04:35:50', NULL),
(42, '5f281f8022dc702c2d7b4c37e6aab6c86725c40c7cbae7a90128f5a1c062b2599dfd4340cd45bfd4', 'USR000000', '1', '2026-08-22 12:01:49', NULL),
(43, 'becb5e2f85a26d074d0cdf84cf52ee005cb5fa38ac022a5fa904e9425a4c542ddae26dddc5ab203a', 'USR000000', '1', '2026-08-23 05:40:08', NULL),
(44, '23b68e79512f88ee4eec5a1420b88ed5a34e133527e737527d874512c9a5ea033702510b4cf5aebb', 'USR000000', '1', '2026-08-23 06:58:09', NULL),
(45, '06a8c850c516a66ee2f4fd31c05d412d281120ebefaaac0d3e181a4aed3ff377664b337eca119a1d', 'USR000000', '0', '2026-08-23 06:58:12', NULL);

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
(15, '2026-08-20', '/pendaftaran/pendaftaran_pasien_search.js', 'get', '{\"query\":\"Test Pasien\"}', '{\"status\":\"99\",\"message\":\"Sistem sedang maintenance harap tunggu sebentar\",\"datetime\":\"2026-08-20 14:42:24\"}', 'Error: select `no_rm`, `nama`, `nik`, `tanggal_lahir`, `jenis_kelamin`, `no_hp`, `alamat` from `mst_pasien` where (LOWER(no_rm) LIKE \'%test pasien%\' or LOWER(nama) LIKE \'%test pasien%\' or LOWER(nik) LIKE \'%test pasien%\' or LOWER(no_hp) LIKE \'%test pasien%\') order by `nama` asc limit 20 - Unknown column \'alamat\' in \'field list\'\n    at Packet.asError (c:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (c:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (c:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (c:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (c:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (c:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-20 14:42:24', NULL),
(16, '2026-08-21', 'test', 'test', 'test', 'test', '', 'test', 'UTC', '2026-08-21 09:00:00', NULL),
(17, '2026-08-21', '/master/paket_produk/paket_produk_create.js', 'create', '{\"kode_paket_produk\":\"\",\"nama\":\"paket es teh\",\"harga_paket\":100000,\"masa_berlaku_hari\":30,\"status\":\"aktif\",\"details\":[{\"kode_produk\":\"PRD-001\",\"jumlah\":1},{\"kode_produk\":\"PRD-001\",\"jumlah\":1},{\"kode_produk\":\"PRD-001\",\"jumlah\":1}]}', '{\"status\":\"99\",\"message\":\"insert into `mst_detail_paket_produk` (`created_at`, `created_by`, `jumlah`, `kode_detail_paket_produk`, `kode_paket_produk`, `kode_produk`, `tz`, `updated_at`, `updated_by`) values (\'2026-08-21 06:16:13\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-01\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:16:13\', \'superadmin@admin.com\'), (\'2026-08-21 06:16:13\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-02\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:16:13\', \'superadmin@admin.com\'), (\'2026-08-21 06:16:13\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-03\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:16:13\', \'superadmin@admin.com\') - Data too long for column \'kode_detail_paket_produk\' at row 1\",\"datetime\":\"2026-08-21 06:16:13\"}', 'Error: insert into `mst_detail_paket_produk` (`created_at`, `created_by`, `jumlah`, `kode_detail_paket_produk`, `kode_paket_produk`, `kode_produk`, `tz`, `updated_at`, `updated_by`) values (\'2026-08-21 06:16:13\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-01\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:16:13\', \'superadmin@admin.com\'), (\'2026-08-21 06:16:13\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-02\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:16:13\', \'superadmin@admin.com\'), (\'2026-08-21 06:16:13\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-03\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:16:13\', \'superadmin@admin.com\') - Data too long for column \'kode_detail_paket_produk\' at row 1\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 06:16:14', NULL),
(18, '2026-08-21', '/master/paket_produk/paket_produk_create.js', 'create', '{\"kode_paket_produk\":\"\",\"nama\":\"paket es teh\",\"harga_paket\":100000,\"masa_berlaku_hari\":30,\"status\":\"aktif\",\"details\":[{\"kode_produk\":\"PRD-001\",\"jumlah\":1}]}', '{\"status\":\"99\",\"message\":\"insert into `mst_detail_paket_produk` (`created_at`, `created_by`, `jumlah`, `kode_detail_paket_produk`, `kode_paket_produk`, `kode_produk`, `tz`, `updated_at`, `updated_by`) values (\'2026-08-21 06:16:22\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-01\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:16:22\', \'superadmin@admin.com\') - Data too long for column \'kode_detail_paket_produk\' at row 1\",\"datetime\":\"2026-08-21 06:16:22\"}', 'Error: insert into `mst_detail_paket_produk` (`created_at`, `created_by`, `jumlah`, `kode_detail_paket_produk`, `kode_paket_produk`, `kode_produk`, `tz`, `updated_at`, `updated_by`) values (\'2026-08-21 06:16:22\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-01\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:16:22\', \'superadmin@admin.com\') - Data too long for column \'kode_detail_paket_produk\' at row 1\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 06:16:22', NULL),
(19, '2026-08-21', '/master/paket_produk/paket_produk_create.js', 'create', '{\"kode_paket_produk\":\"\",\"nama\":\"paket es teh\",\"harga_paket\":100000,\"masa_berlaku_hari\":30,\"status\":\"aktif\",\"details\":[{\"kode_produk\":\"PRD-001\",\"jumlah\":1}]}', '{\"status\":\"99\",\"message\":\"insert into `mst_detail_paket_produk` (`created_at`, `created_by`, `jumlah`, `kode_detail_paket_produk`, `kode_paket_produk`, `kode_produk`, `tz`, `updated_at`, `updated_by`) values (\'2026-08-21 06:16:27\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-01\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:16:27\', \'superadmin@admin.com\') - Data too long for column \'kode_detail_paket_produk\' at row 1\",\"datetime\":\"2026-08-21 06:16:27\"}', 'Error: insert into `mst_detail_paket_produk` (`created_at`, `created_by`, `jumlah`, `kode_detail_paket_produk`, `kode_paket_produk`, `kode_produk`, `tz`, `updated_at`, `updated_by`) values (\'2026-08-21 06:16:27\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-01\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:16:27\', \'superadmin@admin.com\') - Data too long for column \'kode_detail_paket_produk\' at row 1\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 06:16:27', NULL),
(20, '2026-08-21', '/master/paket_produk/paket_produk_create.js', 'create', '{\"kode_paket_produk\":\"\",\"nama\":\"paket es teh\",\"harga_paket\":100000,\"masa_berlaku_hari\":30,\"status\":\"aktif\",\"details\":[{\"kode_produk\":\"PRD-001\",\"jumlah\":1}]}', '{\"status\":\"99\",\"message\":\"insert into `mst_detail_paket_produk` (`created_at`, `created_by`, `jumlah`, `kode_detail_paket_produk`, `kode_paket_produk`, `kode_produk`, `tz`, `updated_at`, `updated_by`) values (\'2026-08-21 06:16:32\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-01\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:16:32\', \'superadmin@admin.com\') - Data too long for column \'kode_detail_paket_produk\' at row 1\",\"datetime\":\"2026-08-21 06:16:32\"}', 'Error: insert into `mst_detail_paket_produk` (`created_at`, `created_by`, `jumlah`, `kode_detail_paket_produk`, `kode_paket_produk`, `kode_produk`, `tz`, `updated_at`, `updated_by`) values (\'2026-08-21 06:16:32\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-01\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:16:32\', \'superadmin@admin.com\') - Data too long for column \'kode_detail_paket_produk\' at row 1\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 06:16:32', NULL),
(21, '2026-08-21', '/master/paket_produk/paket_produk_create.js', 'create', '{\"kode_paket_produk\":\"\",\"nama\":\"paket es teh\",\"harga_paket\":100000,\"masa_berlaku_hari\":30,\"status\":\"aktif\",\"details\":[{\"kode_produk\":\"PRD-001\",\"jumlah\":1}]}', '{\"status\":\"99\",\"message\":\"insert into `mst_detail_paket_produk` (`created_at`, `created_by`, `jumlah`, `kode_detail_paket_produk`, `kode_paket_produk`, `kode_produk`, `tz`, `updated_at`, `updated_by`) values (\'2026-08-21 06:16:36\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-01\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:16:36\', \'superadmin@admin.com\') - Data too long for column \'kode_detail_paket_produk\' at row 1\",\"datetime\":\"2026-08-21 06:16:36\"}', 'Error: insert into `mst_detail_paket_produk` (`created_at`, `created_by`, `jumlah`, `kode_detail_paket_produk`, `kode_paket_produk`, `kode_produk`, `tz`, `updated_at`, `updated_by`) values (\'2026-08-21 06:16:36\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-01\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:16:36\', \'superadmin@admin.com\') - Data too long for column \'kode_detail_paket_produk\' at row 1\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 06:16:36', NULL),
(22, '2026-08-21', '/master/paket_produk/paket_produk_create.js', 'create', '{\"kode_paket_produk\":\"\",\"nama\":\"paket es teh\",\"harga_paket\":100000,\"masa_berlaku_hari\":30,\"status\":\"aktif\",\"details\":[{\"kode_produk\":\"PRD-001\",\"jumlah\":1}]}', '{\"status\":\"99\",\"message\":\"insert into `mst_detail_paket_produk` (`created_at`, `created_by`, `jumlah`, `kode_detail_paket_produk`, `kode_paket_produk`, `kode_produk`, `tz`, `updated_at`, `updated_by`) values (\'2026-08-21 06:16:41\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-01\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:16:41\', \'superadmin@admin.com\') - Data too long for column \'kode_detail_paket_produk\' at row 1\",\"datetime\":\"2026-08-21 06:16:41\"}', 'Error: insert into `mst_detail_paket_produk` (`created_at`, `created_by`, `jumlah`, `kode_detail_paket_produk`, `kode_paket_produk`, `kode_produk`, `tz`, `updated_at`, `updated_by`) values (\'2026-08-21 06:16:41\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-01\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:16:41\', \'superadmin@admin.com\') - Data too long for column \'kode_detail_paket_produk\' at row 1\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 06:16:41', NULL),
(23, '2026-08-21', '/master/paket_produk/paket_produk_create.js', 'create', '{\"kode_paket_produk\":\"\",\"nama\":\"tess\",\"harga_paket\":10000,\"masa_berlaku_hari\":365,\"status\":\"aktif\",\"details\":[{\"kode_produk\":\"PRD-001\",\"jumlah\":1}]}', '{\"status\":\"99\",\"message\":\"insert into `mst_detail_paket_produk` (`created_at`, `created_by`, `jumlah`, `kode_detail_paket_produk`, `kode_paket_produk`, `kode_produk`, `tz`, `updated_at`, `updated_by`) values (\'2026-08-21 06:18:59\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-01\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:18:59\', \'superadmin@admin.com\') - Data too long for column \'kode_detail_paket_produk\' at row 1\",\"datetime\":\"2026-08-21 06:18:59\"}', 'Error: insert into `mst_detail_paket_produk` (`created_at`, `created_by`, `jumlah`, `kode_detail_paket_produk`, `kode_paket_produk`, `kode_produk`, `tz`, `updated_at`, `updated_by`) values (\'2026-08-21 06:18:59\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-01\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:18:59\', \'superadmin@admin.com\') - Data too long for column \'kode_detail_paket_produk\' at row 1\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 06:18:59', NULL),
(24, '2026-08-21', '/master/paket_produk/paket_produk_create.js', 'create', '{\"kode_paket_produk\":\"\",\"nama\":\"tess\",\"harga_paket\":10000,\"masa_berlaku_hari\":365,\"status\":\"aktif\",\"details\":[{\"kode_produk\":\"PRD-001\",\"jumlah\":1}]}', '{\"status\":\"99\",\"message\":\"insert into `mst_detail_paket_produk` (`created_at`, `created_by`, `jumlah`, `kode_detail_paket_produk`, `kode_paket_produk`, `kode_produk`, `tz`, `updated_at`, `updated_by`) values (\'2026-08-21 06:19:03\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-01\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:19:03\', \'superadmin@admin.com\') - Data too long for column \'kode_detail_paket_produk\' at row 1\",\"datetime\":\"2026-08-21 06:19:03\"}', 'Error: insert into `mst_detail_paket_produk` (`created_at`, `created_by`, `jumlah`, `kode_detail_paket_produk`, `kode_paket_produk`, `kode_produk`, `tz`, `updated_at`, `updated_by`) values (\'2026-08-21 06:19:03\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-01\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:19:03\', \'superadmin@admin.com\') - Data too long for column \'kode_detail_paket_produk\' at row 1\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 06:19:03', NULL);
INSERT INTO `log` (`id`, `tgl`, `controller`, `function`, `request`, `response`, `stack`, `user`, `tz`, `datetime`, `datetime_eng`) VALUES
(25, '2026-08-21', '/master/paket_produk/paket_produk_create.js', 'create', '{\"kode_paket_produk\":\"\",\"nama\":\"tess\",\"harga_paket\":10000,\"masa_berlaku_hari\":365,\"status\":\"aktif\",\"details\":[{\"kode_produk\":\"PRD-001\",\"jumlah\":1}]}', '{\"status\":\"99\",\"message\":\"insert into `mst_detail_paket_produk` (`created_at`, `created_by`, `jumlah`, `kode_detail_paket_produk`, `kode_paket_produk`, `kode_produk`, `tz`, `updated_at`, `updated_by`) values (\'2026-08-21 06:19:07\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-01\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:19:07\', \'superadmin@admin.com\') - Data too long for column \'kode_detail_paket_produk\' at row 1\",\"datetime\":\"2026-08-21 06:19:07\"}', 'Error: insert into `mst_detail_paket_produk` (`created_at`, `created_by`, `jumlah`, `kode_detail_paket_produk`, `kode_paket_produk`, `kode_produk`, `tz`, `updated_at`, `updated_by`) values (\'2026-08-21 06:19:07\', \'superadmin@admin.com\', 1, \'DPKTPRD-PKTPRD-001-01\', \'PKTPRD-001\', \'PRD-001\', \'UTC\', \'2026-08-21 06:19:07\', \'superadmin@admin.com\') - Data too long for column \'kode_detail_paket_produk\' at row 1\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 06:19:07', NULL),
(26, '2026-08-21', '/master/wilayah.js', 'provinsi', '{}', '{}', 'Error: select `kode`, `nama` from `mst_provinsi` order by `nama` asc - Table \'db_klinik_kecantikan.mst_provinsi\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 12:03:17', NULL),
(27, '2026-08-21', '/master/wilayah.js', 'provinsi', '{}', '{}', 'Error: select `kode`, `nama` from `mst_provinsi` order by `nama` asc - Table \'db_klinik_kecantikan.mst_provinsi\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 12:03:17', NULL),
(28, '2026-08-21', '/master/wilayah.js', 'provinsi', '{}', '{}', 'Error: select `kode`, `nama` from `mst_provinsi` order by `nama` asc - Table \'db_klinik_kecantikan.mst_provinsi\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 12:04:58', NULL),
(29, '2026-08-21', '/master/wilayah.js', 'provinsi', '{}', '{}', 'Error: select `kode`, `nama` from `mst_provinsi` order by `nama` asc - Table \'db_klinik_kecantikan.mst_provinsi\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 12:04:58', NULL),
(30, '2026-08-21', '/master/pendaftaran_pasien/pendaftaran_pasien_ambil_antrian_layanan.js', 'ambil_antrian_layanan_terpadu', '{\"no_rm\":\"RM-000001\",\"items\":[{\"jenis_layanan\":\"paket\",\"kode_layanan\":\"PKT-001\"}]}', '{\"status\":\"99\",\"message\":\"update `trx_antrian_awal` set `status` = \'terpakai\', `diambil_at` = \'2026-08-21 12:07:29\', `no_rm` = \'RM-000001\', `kode_kunjungan` = \'KJ-20260821-001\', `updated_by` = \'superadmin@admin.com\', `updated_at` = \'2026-08-21 12:07:29\' where `id` = 38 - Unknown column \'no_rm\' in \'field list\'\",\"datetime\":\"2026-08-21 12:07:29\"}', 'Error: update `trx_antrian_awal` set `status` = \'terpakai\', `diambil_at` = \'2026-08-21 12:07:29\', `no_rm` = \'RM-000001\', `kode_kunjungan` = \'KJ-20260821-001\', `updated_by` = \'superadmin@admin.com\', `updated_at` = \'2026-08-21 12:07:29\' where `id` = 38 - Unknown column \'no_rm\' in \'field list\'\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 12:07:29', NULL),
(31, '2026-08-21', '/master/pendaftaran_pasien/pendaftaran_pasien_ambil_antrian_layanan.js', 'ambil_antrian_layanan_terpadu', '{\"no_rm\":\"RM-000001\",\"items\":[{\"jenis_layanan\":\"paket\",\"kode_layanan\":\"PKT-001\"},{\"jenis_layanan\":\"layanan\",\"kode_layanan\":\"LAY-005\"}]}', '{\"status\":\"99\",\"message\":\"update `trx_antrian_awal` set `status` = \'terpakai\', `diambil_at` = \'2026-08-21 12:07:35\', `no_rm` = \'RM-000001\', `kode_kunjungan` = \'KJ-20260821-001\', `updated_by` = \'superadmin@admin.com\', `updated_at` = \'2026-08-21 12:07:35\' where `id` = 38 - Unknown column \'no_rm\' in \'field list\'\",\"datetime\":\"2026-08-21 12:07:35\"}', 'Error: update `trx_antrian_awal` set `status` = \'terpakai\', `diambil_at` = \'2026-08-21 12:07:35\', `no_rm` = \'RM-000001\', `kode_kunjungan` = \'KJ-20260821-001\', `updated_by` = \'superadmin@admin.com\', `updated_at` = \'2026-08-21 12:07:35\' where `id` = 38 - Unknown column \'no_rm\' in \'field list\'\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 12:07:35', NULL),
(32, '2026-08-21', '/master/wilayah.js', 'provinsi', '{}', '{}', 'Error: select `kode`, `nama` from `mst_provinsi` order by `nama` asc - Table \'db_klinik_kecantikan.mst_provinsi\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 12:07:43', NULL),
(33, '2026-08-21', '/master/wilayah.js', 'provinsi', '{}', '{}', 'Error: select `kode`, `nama` from `mst_provinsi` order by `nama` asc - Table \'db_klinik_kecantikan.mst_provinsi\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 12:07:43', NULL),
(34, '2026-08-21', '/master/wilayah.js', 'provinsi', '{}', '{}', 'Error: select `kode`, `nama` from `mst_provinsi` order by `nama` asc - Table \'db_klinik_kecantikan.mst_provinsi\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 12:07:59', NULL),
(35, '2026-08-21', '/master/wilayah.js', 'provinsi', '{}', '{}', 'Error: select `kode`, `nama` from `mst_provinsi` order by `nama` asc - Table \'db_klinik_kecantikan.mst_provinsi\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 12:07:59', NULL),
(36, '2026-08-21', '/master/pendaftaran_pasien/pendaftaran_pasien_ambil_antrian_layanan.js', 'ambil_antrian_layanan_terpadu', '{\"no_rm\":\"RM-000002\",\"items\":[{\"jenis_layanan\":\"layanan\",\"kode_layanan\":\"LAY-002\"}]}', '{\"status\":\"99\",\"message\":\"update `trx_antrian_awal` set `status` = \'terpakai\', `diambil_at` = \'2026-08-21 12:09:05\', `no_rm` = \'RM-000002\', `kode_kunjungan` = \'KJ-20260821-001\', `updated_by` = \'superadmin@admin.com\', `updated_at` = \'2026-08-21 12:09:05\' where `id` = 38 - Unknown column \'no_rm\' in \'field list\'\",\"datetime\":\"2026-08-21 12:09:05\"}', 'Error: update `trx_antrian_awal` set `status` = \'terpakai\', `diambil_at` = \'2026-08-21 12:09:05\', `no_rm` = \'RM-000002\', `kode_kunjungan` = \'KJ-20260821-001\', `updated_by` = \'superadmin@admin.com\', `updated_at` = \'2026-08-21 12:09:05\' where `id` = 38 - Unknown column \'no_rm\' in \'field list\'\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 12:09:05', NULL),
(37, '2026-08-21', '/master/pendaftaran_pasien/pendaftaran_pasien_ambil_antrian_layanan.js', 'ambil_antrian_layanan_terpadu', '{\"no_rm\":\"RM-000002\",\"items\":[{\"jenis_layanan\":\"layanan\",\"kode_layanan\":\"LAY-002\"}]}', '{\"status\":\"99\",\"message\":\"update `trx_antrian_awal` set `status` = \'terpakai\', `diambil_at` = \'2026-08-21 12:09:06\', `no_rm` = \'RM-000002\', `kode_kunjungan` = \'KJ-20260821-001\', `updated_by` = \'superadmin@admin.com\', `updated_at` = \'2026-08-21 12:09:06\' where `id` = 38 - Unknown column \'no_rm\' in \'field list\'\",\"datetime\":\"2026-08-21 12:09:06\"}', 'Error: update `trx_antrian_awal` set `status` = \'terpakai\', `diambil_at` = \'2026-08-21 12:09:06\', `no_rm` = \'RM-000002\', `kode_kunjungan` = \'KJ-20260821-001\', `updated_by` = \'superadmin@admin.com\', `updated_at` = \'2026-08-21 12:09:06\' where `id` = 38 - Unknown column \'no_rm\' in \'field list\'\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 12:09:06', NULL),
(38, '2026-08-21', '/master/pendaftaran_pasien/pendaftaran_pasien_ambil_antrian_layanan.js', 'ambil_antrian_layanan_terpadu', '{\"no_rm\":\"RM-000002\",\"items\":[{\"jenis_layanan\":\"layanan\",\"kode_layanan\":\"LAY-002\"}]}', '{\"status\":\"99\",\"message\":\"update `trx_antrian_awal` set `status` = \'terpakai\', `diambil_at` = \'2026-08-21 12:09:07\', `no_rm` = \'RM-000002\', `kode_kunjungan` = \'KJ-20260821-001\', `updated_by` = \'superadmin@admin.com\', `updated_at` = \'2026-08-21 12:09:07\' where `id` = 38 - Unknown column \'no_rm\' in \'field list\'\",\"datetime\":\"2026-08-21 12:09:07\"}', 'Error: update `trx_antrian_awal` set `status` = \'terpakai\', `diambil_at` = \'2026-08-21 12:09:07\', `no_rm` = \'RM-000002\', `kode_kunjungan` = \'KJ-20260821-001\', `updated_by` = \'superadmin@admin.com\', `updated_at` = \'2026-08-21 12:09:07\' where `id` = 38 - Unknown column \'no_rm\' in \'field list\'\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 12:09:07', NULL),
(39, '2026-08-21', '/master/pendaftaran_pasien/pendaftaran_pasien_ambil_antrian_layanan.js', 'ambil_antrian_layanan_terpadu', '{\"no_rm\":\"RM-000002\",\"items\":[{\"jenis_layanan\":\"layanan\",\"kode_layanan\":\"LAY-002\"}]}', '{\"status\":\"99\",\"message\":\"update `trx_antrian_awal` set `status` = \'terpakai\', `diambil_at` = \'2026-08-21 12:09:07\', `no_rm` = \'RM-000002\', `kode_kunjungan` = \'KJ-20260821-001\', `updated_by` = \'superadmin@admin.com\', `updated_at` = \'2026-08-21 12:09:07\' where `id` = 38 - Unknown column \'no_rm\' in \'field list\'\",\"datetime\":\"2026-08-21 12:09:07\"}', 'Error: update `trx_antrian_awal` set `status` = \'terpakai\', `diambil_at` = \'2026-08-21 12:09:07\', `no_rm` = \'RM-000002\', `kode_kunjungan` = \'KJ-20260821-001\', `updated_by` = \'superadmin@admin.com\', `updated_at` = \'2026-08-21 12:09:07\' where `id` = 38 - Unknown column \'no_rm\' in \'field list\'\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 12:09:07', NULL),
(40, '2026-08-21', '/master/pendaftaran_pasien/pendaftaran_pasien_ambil_antrian_layanan.js', 'ambil_antrian_layanan_terpadu', '{\"no_rm\":\"RM-000002\",\"items\":[{\"jenis_layanan\":\"layanan\",\"kode_layanan\":\"LAY-002\"}]}', '{\"status\":\"99\",\"message\":\"update `trx_antrian_awal` set `status` = \'terpakai\', `diambil_at` = \'2026-08-21 12:09:08\', `no_rm` = \'RM-000002\', `kode_kunjungan` = \'KJ-20260821-001\', `updated_by` = \'superadmin@admin.com\', `updated_at` = \'2026-08-21 12:09:08\' where `id` = 38 - Unknown column \'no_rm\' in \'field list\'\",\"datetime\":\"2026-08-21 12:09:08\"}', 'Error: update `trx_antrian_awal` set `status` = \'terpakai\', `diambil_at` = \'2026-08-21 12:09:08\', `no_rm` = \'RM-000002\', `kode_kunjungan` = \'KJ-20260821-001\', `updated_by` = \'superadmin@admin.com\', `updated_at` = \'2026-08-21 12:09:08\' where `id` = 38 - Unknown column \'no_rm\' in \'field list\'\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 12:09:08', NULL),
(41, '2026-08-21', '/master/pendaftaran_pasien/pendaftaran_pasien_ambil_antrian_layanan.js', 'ambil_antrian_layanan_terpadu', '{\"no_rm\":\"RM-000002\",\"items\":[{\"jenis_layanan\":\"layanan\",\"kode_layanan\":\"LAY-002\"}]}', '{\"status\":\"99\",\"message\":\"update `trx_antrian_awal` set `status` = \'terpakai\', `diambil_at` = \'2026-08-21 12:09:08\', `no_rm` = \'RM-000002\', `kode_kunjungan` = \'KJ-20260821-001\', `updated_by` = \'superadmin@admin.com\', `updated_at` = \'2026-08-21 12:09:08\' where `id` = 38 - Unknown column \'no_rm\' in \'field list\'\",\"datetime\":\"2026-08-21 12:09:08\"}', 'Error: update `trx_antrian_awal` set `status` = \'terpakai\', `diambil_at` = \'2026-08-21 12:09:08\', `no_rm` = \'RM-000002\', `kode_kunjungan` = \'KJ-20260821-001\', `updated_by` = \'superadmin@admin.com\', `updated_at` = \'2026-08-21 12:09:08\' where `id` = 38 - Unknown column \'no_rm\' in \'field list\'\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 12:09:08', NULL),
(42, '2026-08-21', '/master/wilayah.js', 'provinsi', '{}', '{}', 'Error: select `kode`, `nama` from `mst_provinsi` order by `nama` asc - Table \'db_klinik_kecantikan.mst_provinsi\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 12:10:26', NULL),
(43, '2026-08-21', '/master/wilayah.js', 'provinsi', '{}', '{}', 'Error: select `kode`, `nama` from `mst_provinsi` order by `nama` asc - Table \'db_klinik_kecantikan.mst_provinsi\' doesn\'t exist\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-21 12:10:26', NULL),
(44, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"page\":1,\"perPage\":10,\"keyword\":\"\",\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `nomor_antrian` asc limit 10 - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:08:22', NULL),
(45, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `al`.`nomor_antrian` asc - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:08:22', NULL),
(46, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `al`.`nomor_antrian` asc - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:08:22', NULL),
(47, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"page\":1,\"perPage\":10,\"keyword\":\"\",\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `nomor_antrian` asc limit 10 - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:08:22', NULL),
(48, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `al`.`nomor_antrian` asc - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:15:09', NULL),
(49, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `al`.`nomor_antrian` asc - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:15:10', NULL);
INSERT INTO `log` (`id`, `tgl`, `controller`, `function`, `request`, `response`, `stack`, `user`, `tz`, `datetime`, `datetime_eng`) VALUES
(50, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"page\":1,\"perPage\":10,\"keyword\":\"\",\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `nomor_antrian` asc limit 10 - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:15:10', NULL),
(51, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"page\":1,\"perPage\":10,\"keyword\":\"\",\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `nomor_antrian` asc limit 10 - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:15:10', NULL),
(52, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"page\":1,\"perPage\":10,\"keyword\":\"\",\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `nomor_antrian` asc limit 10 - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:16:02', NULL),
(53, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `al`.`nomor_antrian` asc - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:16:02', NULL),
(54, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"page\":1,\"perPage\":10,\"keyword\":\"\",\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `nomor_antrian` asc limit 10 - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:16:02', NULL),
(55, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `al`.`nomor_antrian` asc - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:16:02', NULL),
(56, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"page\":1,\"perPage\":10,\"keyword\":\"\",\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `nomor_antrian` asc limit 10 - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:16:18', NULL),
(57, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `al`.`nomor_antrian` asc - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:16:18', NULL),
(58, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `al`.`nomor_antrian` asc - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:16:18', NULL),
(59, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"page\":1,\"perPage\":10,\"keyword\":\"\",\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `nomor_antrian` asc limit 10 - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:16:18', NULL),
(60, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"page\":1,\"perPage\":10,\"keyword\":\"\",\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `nomor_antrian` asc limit 10 - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:16:55', NULL),
(61, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `al`.`nomor_antrian` asc - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:16:55', NULL),
(62, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `al`.`nomor_antrian` asc - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:17:06', NULL),
(63, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"page\":1,\"perPage\":10,\"keyword\":\"\",\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `nomor_antrian` asc limit 10 - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:17:06', NULL),
(64, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"page\":1,\"perPage\":10,\"keyword\":\"\",\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `nomor_antrian` asc limit 10 - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:17:16', NULL),
(65, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `al`.`nomor_antrian` asc - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:17:16', NULL);
INSERT INTO `log` (`id`, `tgl`, `controller`, `function`, `request`, `response`, `stack`, `user`, `tz`, `datetime`, `datetime_eng`) VALUES
(66, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `al`.`nomor_antrian` asc - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:17:32', NULL),
(67, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `al`.`nomor_antrian` asc - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:21:43', NULL),
(68, '2026-08-22', '/master/antrian_layanan/antrian_layanan_data.js', 'getData', '{\"page\":1,\"perPage\":10,\"keyword\":\"\",\"sortField\":\"nomor_antrian\",\"sortOrder\":\"asc\"}', '{}', 'Error: select `al`.`id`, `al`.`kode_antrian_layanan`, `al`.`kode_kunjungan`, `al`.`nomor_antrian`, `al`.`jenis_layanan`, `al`.`kode_layanan`, `al`.`status`, `al`.`dipanggil_at`, `al`.`selesai_at`, `al`.`created_at`, `k`.`no_rm`, `k`.`jam_datang`, `p`.`nama` as `nama_pasien`, `p`.`no_hp`, COALESCE(al.kode_ruangan, ml.kode_ruangan, mp.kode_ruangan, \'R-01\') as kode_ruangan, COALESCE(al.nama_ruangan, rml.nama_ruangan, rmp.nama_ruangan, \'Ruang Treatment\') as nama_ruangan, COALESCE(ml.nama, mp.nama, \'-\') as nama_layanan, MAX(dpl.jumlah_sesi) as jumlah_sesi_paket from `trx_antrian_layanan` as `al` left join `trx_kunjungan` as `k` on `al`.`kode_kunjungan` = `k`.`kode_kunjungan` left join `mst_pasien` as `p` on `k`.`no_rm` = `p`.`no_rm` left join `mst_layanan` as `ml` on `al`.`kode_layanan` = `ml`.`kode_layanan` and `al`.`jenis_layanan` = \'layanan\' left join `mst_paket_layanan` as `mp` on `al`.`kode_layanan` = `mp`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_detail_paket_layanan` as `dpl` on `al`.`kode_layanan` = `dpl`.`kode_paket_layanan` and `al`.`jenis_layanan` = \'paket\' left join `mst_ruangan` as `rml` on `ml`.`kode_ruangan` = `rml`.`kode_ruangan` left join `mst_ruangan` as `rmp` on `mp`.`kode_ruangan` = `rmp`.`kode_ruangan` where DATE(al.created_at) = \'2026-08-22\' group by `al`.`id` order by `nomor_antrian` asc limit 10 - Expression #16 of SELECT list is not in GROUP BY clause and contains nonaggregated column \'db_klinik_kecantikan.rml.nama_ruangan\' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by\n    at Packet.asError (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packets\\packet.js:833:17)\n    at Query.execute (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\commands\\command.js:29:26)\n    at Connection.handlePacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:554:34)\n    at PacketParser.onPacket (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:104:12)\n    at PacketParser.executeStart (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\packet_parser.js:75:16)\n    at Socket.<anonymous> (C:\\laragon\\www\\klinik_kecantikan\\express_standart_be\\node_modules\\mysql2\\lib\\base\\connection.js:111:25)\n    at Socket.emit (node:events:508:28)\n    at addChunk (node:internal/streams/readable:563:12)\n    at readableAddChunkPushByteMode (node:internal/streams/readable:514:3)\n    at Readable.push (node:internal/streams/readable:394:5)', 'superadmin@admin.com', 'UTC', '2026-08-22 06:21:43', NULL),
(69, '2026-08-22', '/master/antrian_layanan/antrian_layanan_panggil.js', 'panggil', '{\"kode_antrian_layanan\":\"AL-20260822-002\",\"status\":\"dipanggil\",\"tz\":\"Asia/Jakarta\"}', '{}', 'ValidationError: \"Aksi\" is required', 'superadmin@admin.com', 'UTC', '2026-08-22 06:23:11', NULL),
(70, '2026-08-22', '/master/antrian_layanan/antrian_layanan_panggil.js', 'panggil', '{\"kode_antrian_layanan\":\"AL-20260822-002\",\"status\":\"dipanggil\",\"tz\":\"Asia/Jakarta\"}', '{}', 'ValidationError: \"Aksi\" is required', 'superadmin@admin.com', 'UTC', '2026-08-22 06:23:16', NULL),
(71, '2026-08-22', '/master/antrian_layanan/antrian_layanan_panggil.js', 'panggil', '{\"kode_antrian_layanan\":\"AL-20260822-002\",\"status\":\"dipanggil\",\"tz\":\"Asia/Jakarta\"}', '{}', 'ValidationError: \"Aksi\" is required', 'superadmin@admin.com', 'UTC', '2026-08-22 06:23:56', NULL);

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
(88, 'DELETE', 'Hapus Antrian Layanan & Kunjungan AL-20260820-002, AL-20260820-003', 'trx_antrian_layanan', 'AL-20260820-002, AL-20260820-003', '[{\"kode_kunjungan\": \"KJ-20260820-002\", \"kode_antrian_layanan\": \"AL-20260820-002\"}, {\"kode_kunjungan\": \"KJ-20260820-003\", \"kode_antrian_layanan\": \"AL-20260820-003\"}]', NULL, 'UTC', 'superadmin@admin.com', '2026-08-20 15:47:03', '2026-08-20 15:47:03'),
(89, 'UPDATE', 'Edit Kategori Layanan KAT-005', 'mst_kategori_layanan', 'KAT-005', '{\"id\": 5, \"tz\": \"Asia/Jakarta\", \"nama\": \"Anti Aging\", \"status\": \"nonaktif\", \"deskripsi\": \"Terapi khusus penuaan dini dan kerutan\", \"created_at\": \"2026-08-20T13:15:30.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20T13:50:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"kode_kategori_layanan\": \"KAT-005\"}', '{\"id\": 5, \"tz\": \"Asia/Jakarta\", \"nama\": \"Anti Aging\", \"status\": \"aktif\", \"deskripsi\": \"Terapi khusus penuaan dini dan kerutan\", \"created_at\": \"2026-08-20T13:15:30.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 03:00:44\", \"updated_by\": \"superadmin@admin.com\", \"kode_kategori_layanan\": \"KAT-005\"}', 'UTC', 'superadmin@admin.com', '2026-08-21 03:00:44', '2026-08-21 03:00:44'),
(90, 'UPDATE', 'Edit Kategori Layanan KAT-005', 'mst_kategori_layanan', 'KAT-005', '{\"id\": 5, \"tz\": \"Asia/Jakarta\", \"nama\": \"Anti Aging\", \"status\": \"aktif\", \"deskripsi\": \"Terapi khusus penuaan dini dan kerutan\", \"created_at\": \"2026-08-20T13:15:30.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21T03:00:44.000Z\", \"updated_by\": \"superadmin@admin.com\", \"kode_kategori_layanan\": \"KAT-005\"}', '{\"id\": 5, \"tz\": \"Asia/Jakarta\", \"nama\": \"Anti Aging\", \"status\": \"nonaktif\", \"deskripsi\": \"Terapi khusus penuaan dini dan kerutan\", \"created_at\": \"2026-08-20T13:15:30.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 03:00:49\", \"updated_by\": \"superadmin@admin.com\", \"kode_kategori_layanan\": \"KAT-005\"}', 'UTC', 'superadmin@admin.com', '2026-08-21 03:00:49', '2026-08-21 03:00:49'),
(91, 'UPDATE', 'Edit Kategori Layanan KAT-002', 'mst_kategori_layanan', 'KAT-002', '{\"id\": 2, \"tz\": \"Asia/Jakarta\", \"nama\": \"Perawatan Kulit\", \"status\": \"aktif\", \"deskripsi\": \"Treatment kesehatan dan peremajaan kulit\", \"created_at\": \"2026-08-20T12:55:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20T13:42:10.000Z\", \"updated_by\": \"superadmin@admin.com\", \"kode_kategori_layanan\": \"KAT-002\"}', '{\"id\": 2, \"tz\": \"Asia/Jakarta\", \"nama\": \"Perawatan Kulit\", \"status\": \"nonaktif\", \"deskripsi\": \"Treatment kesehatan dan peremajaan kulit\", \"created_at\": \"2026-08-20T12:55:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 03:00:53\", \"updated_by\": \"superadmin@admin.com\", \"kode_kategori_layanan\": \"KAT-002\"}', 'UTC', 'superadmin@admin.com', '2026-08-21 03:00:53', '2026-08-21 03:00:53'),
(92, 'UPDATE', 'Edit Kategori Layanan KAT-002', 'mst_kategori_layanan', 'KAT-002', '{\"id\": 2, \"tz\": \"Asia/Jakarta\", \"nama\": \"Perawatan Kulit\", \"status\": \"nonaktif\", \"deskripsi\": \"Treatment kesehatan dan peremajaan kulit\", \"created_at\": \"2026-08-20T12:55:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21T03:00:53.000Z\", \"updated_by\": \"superadmin@admin.com\", \"kode_kategori_layanan\": \"KAT-002\"}', '{\"id\": 2, \"tz\": \"Asia/Jakarta\", \"nama\": \"Perawatan Kulit\", \"status\": \"aktif\", \"deskripsi\": \"Treatment kesehatan dan peremajaan kulit\", \"created_at\": \"2026-08-20T12:55:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 03:02:34\", \"updated_by\": \"superadmin@admin.com\", \"kode_kategori_layanan\": \"KAT-002\"}', 'UTC', 'superadmin@admin.com', '2026-08-21 03:02:34', '2026-08-21 03:02:34'),
(93, 'UPDATE', 'Edit Kategori Layanan KAT-003', 'mst_kategori_layanan', 'KAT-003', '{\"id\": 3, \"tz\": \"Asia/Jakarta\", \"nama\": \"Perawatan Rambut\", \"status\": \"aktif\", \"deskripsi\": \"Layanan terapi scalp dan nutrisi rambut\", \"created_at\": \"2026-08-20T13:00:15.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20T13:45:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"kode_kategori_layanan\": \"KAT-003\"}', '{\"id\": 3, \"tz\": \"Asia/Jakarta\", \"nama\": \"Perawatan Rambut\", \"status\": \"nonaktif\", \"deskripsi\": \"Layanan terapi scalp dan nutrisi rambut\", \"created_at\": \"2026-08-20T13:00:15.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 03:02:50\", \"updated_by\": \"superadmin@admin.com\", \"kode_kategori_layanan\": \"KAT-003\"}', 'UTC', 'superadmin@admin.com', '2026-08-21 03:02:50', '2026-08-21 03:02:50'),
(94, 'UPDATE', 'Edit Kategori Layanan KAT-003', 'mst_kategori_layanan', 'KAT-003', '{\"id\": 3, \"tz\": \"Asia/Jakarta\", \"nama\": \"Perawatan Rambut\", \"status\": \"nonaktif\", \"deskripsi\": \"Layanan terapi scalp dan nutrisi rambut\", \"created_at\": \"2026-08-20T13:00:15.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21T03:02:50.000Z\", \"updated_by\": \"superadmin@admin.com\", \"kode_kategori_layanan\": \"KAT-003\"}', '{\"id\": 3, \"tz\": \"Asia/Jakarta\", \"nama\": \"Perawatan Rambut\", \"status\": \"aktif\", \"deskripsi\": \"Layanan terapi scalp dan nutrisi rambut\", \"created_at\": \"2026-08-20T13:00:15.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 03:11:39\", \"updated_by\": \"superadmin@admin.com\", \"kode_kategori_layanan\": \"KAT-003\"}', 'UTC', 'superadmin@admin.com', '2026-08-21 03:11:39', '2026-08-21 03:11:39'),
(95, 'UPDATE', 'Edit Kategori Layanan KAT-005', 'mst_kategori_layanan', 'KAT-005', '{\"id\": 5, \"tz\": \"Asia/Jakarta\", \"nama\": \"Anti Aging\", \"status\": \"nonaktif\", \"deskripsi\": \"Terapi khusus penuaan dini dan kerutan\", \"created_at\": \"2026-08-20T13:15:30.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21T03:00:49.000Z\", \"updated_by\": \"superadmin@admin.com\", \"kode_kategori_layanan\": \"KAT-005\"}', '{\"id\": 5, \"tz\": \"Asia/Jakarta\", \"nama\": \"Anti Aging\", \"status\": \"aktif\", \"deskripsi\": \"Terapi khusus penuaan dini dan kerutan\", \"created_at\": \"2026-08-20T13:15:30.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 03:11:46\", \"updated_by\": \"superadmin@admin.com\", \"kode_kategori_layanan\": \"KAT-005\"}', 'UTC', 'superadmin@admin.com', '2026-08-21 03:11:46', '2026-08-21 03:11:46'),
(96, 'UPDATE', 'Edit Paket Layanan PKT-001', 'mst_paket_layanan', 'PKT-001', '{\"id\": 4, \"tz\": \"UTC\", \"nama\": \"Paket Glowing Skin (5x Facial + Serum)\", \"status\": \"aktif\", \"created_at\": \"2026-08-20T22:38:44.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20T22:38:44.000Z\", \"updated_by\": null, \"harga_paket\": \"1250000.00\", \"masa_berlaku_hari\": 90, \"kode_paket_layanan\": \"PKT-001\"}', '{\"id\": 4, \"tz\": \"UTC\", \"nama\": \"Paket Glowing Skin (5x Facial + Serum)\", \"status\": \"aktif\", \"details\": [{\"tz\": \"UTC\", \"created_at\": \"2026-08-21 04:37:59\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 04:37:59\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-001\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-01\"}, {\"tz\": \"UTC\", \"created_at\": \"2026-08-21 04:37:59\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 04:37:59\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-004\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-02\"}], \"created_at\": \"2026-08-20T22:38:44.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 04:37:59\", \"updated_by\": \"superadmin@admin.com\", \"harga_paket\": \"1250000.00\", \"masa_berlaku_hari\": 90, \"kode_paket_layanan\": \"PKT-001\"}', 'UTC', 'superadmin@admin.com', '2026-08-21 04:37:59', '2026-08-21 04:37:59'),
(97, 'UPDATE', 'Edit Paket Layanan PKT-001', 'mst_paket_layanan', 'PKT-001', '{\"id\": 4, \"tz\": \"UTC\", \"nama\": \"Paket Glowing Skin (5x Facial + Serum)\", \"status\": \"aktif\", \"created_at\": \"2026-08-20T22:38:44.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21T04:37:59.000Z\", \"updated_by\": \"superadmin@admin.com\", \"harga_paket\": \"1250000.00\", \"masa_berlaku_hari\": 90, \"kode_paket_layanan\": \"PKT-001\"}', '{\"id\": 4, \"tz\": \"UTC\", \"nama\": \"Paket Glowing Skin (5x Facial + Serum)\", \"status\": \"nonaktif\", \"details\": [{\"tz\": \"UTC\", \"created_at\": \"2026-08-21 04:38:54\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 04:38:54\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-001\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-01\"}, {\"tz\": \"UTC\", \"created_at\": \"2026-08-21 04:38:54\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 04:38:54\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-004\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-02\"}], \"created_at\": \"2026-08-20T22:38:44.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 04:38:54\", \"updated_by\": \"superadmin@admin.com\", \"harga_paket\": \"1250000.00\", \"masa_berlaku_hari\": 90, \"kode_paket_layanan\": \"PKT-001\"}', 'UTC', 'superadmin@admin.com', '2026-08-21 04:38:54', '2026-08-21 04:38:54'),
(98, 'UPDATE', 'Edit Paket Layanan PKT-001', 'mst_paket_layanan', 'PKT-001', '{\"id\": 4, \"tz\": \"UTC\", \"nama\": \"Paket Glowing Skin (5x Facial + Serum)\", \"status\": \"nonaktif\", \"created_at\": \"2026-08-20T22:38:44.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21T04:38:54.000Z\", \"updated_by\": \"superadmin@admin.com\", \"harga_paket\": \"1250000.00\", \"masa_berlaku_hari\": 90, \"kode_paket_layanan\": \"PKT-001\"}', '{\"id\": 4, \"tz\": \"UTC\", \"nama\": \"Paket Glowing Skin (5x Facial + Serum)\", \"status\": \"nonaktif\", \"details\": [{\"tz\": \"UTC\", \"created_at\": \"2026-08-21 06:10:32\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:10:32\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-001\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-01\"}, {\"tz\": \"UTC\", \"created_at\": \"2026-08-21 06:10:32\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:10:32\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-004\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-02\"}, {\"tz\": \"UTC\", \"created_at\": \"2026-08-21 06:10:32\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:10:32\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-005\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-03\"}, {\"tz\": \"UTC\", \"created_at\": \"2026-08-21 06:10:32\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:10:32\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-003\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-04\"}], \"created_at\": \"2026-08-20T22:38:44.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:10:32\", \"updated_by\": \"superadmin@admin.com\", \"harga_paket\": \"1250000.00\", \"masa_berlaku_hari\": 90, \"kode_paket_layanan\": \"PKT-001\"}', 'UTC', 'superadmin@admin.com', '2026-08-21 06:10:32', '2026-08-21 06:10:32'),
(99, 'UPDATE', 'Edit Paket Layanan PKT-001', 'mst_paket_layanan', 'PKT-001', '{\"id\": 4, \"tz\": \"UTC\", \"nama\": \"Paket Glowing Skin (5x Facial + Serum)\", \"status\": \"nonaktif\", \"created_at\": \"2026-08-20T22:38:44.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21T06:10:32.000Z\", \"updated_by\": \"superadmin@admin.com\", \"harga_paket\": \"1250000.00\", \"masa_berlaku_hari\": 90, \"kode_paket_layanan\": \"PKT-001\"}', '{\"id\": 4, \"tz\": \"UTC\", \"nama\": \"Paket Glowing Skin (5x Facial + Serum)\", \"status\": \"aktif\", \"details\": [{\"tz\": \"UTC\", \"created_at\": \"2026-08-21 06:10:52\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:10:52\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-001\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-01\"}, {\"tz\": \"UTC\", \"created_at\": \"2026-08-21 06:10:52\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:10:52\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-004\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-02\"}, {\"tz\": \"UTC\", \"created_at\": \"2026-08-21 06:10:52\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:10:52\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-005\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-03\"}, {\"tz\": \"UTC\", \"created_at\": \"2026-08-21 06:10:52\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:10:52\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-003\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-04\"}], \"created_at\": \"2026-08-20T22:38:44.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:10:52\", \"updated_by\": \"superadmin@admin.com\", \"harga_paket\": \"1250000.00\", \"masa_berlaku_hari\": 90, \"kode_paket_layanan\": \"PKT-001\"}', 'UTC', 'superadmin@admin.com', '2026-08-21 06:10:52', '2026-08-21 06:10:52'),
(100, 'CREATE', 'Tambah Kategori Produk KATPRD-001', 'mst_kategori_produk', 'KATPRD-001', NULL, '{\"tz\": \"UTC\", \"nama\": \"Muka\", \"status\": \"aktif\", \"deskripsi\": \"untuk kulit berminyak\", \"created_at\": \"2026-08-21 06:11:20\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:11:20\", \"updated_by\": \"superadmin@admin.com\", \"kode_kategori_produk\": \"KATPRD-001\"}', 'UTC', 'superadmin@admin.com', '2026-08-21 06:11:20', '2026-08-21 06:11:20'),
(101, 'UPDATE', 'Edit Paket Layanan PKT-001', 'mst_paket_layanan', 'PKT-001', '{\"id\": 4, \"tz\": \"UTC\", \"nama\": \"Paket Glowing Skin (5x Facial + Serum)\", \"status\": \"aktif\", \"created_at\": \"2026-08-20T22:38:44.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21T06:10:52.000Z\", \"updated_by\": \"superadmin@admin.com\", \"harga_paket\": \"1250000.00\", \"masa_berlaku_hari\": 90, \"kode_paket_layanan\": \"PKT-001\"}', '{\"id\": 4, \"tz\": \"UTC\", \"nama\": \"Paket Glowing Skin (5x Facial + Serum)\", \"status\": \"aktif\", \"details\": [{\"tz\": \"UTC\", \"created_at\": \"2026-08-21 06:13:12\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:13:12\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-001\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-01\"}, {\"tz\": \"UTC\", \"created_at\": \"2026-08-21 06:13:12\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:13:12\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-004\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-02\"}, {\"tz\": \"UTC\", \"created_at\": \"2026-08-21 06:13:12\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:13:12\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-005\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-03\"}, {\"tz\": \"UTC\", \"created_at\": \"2026-08-21 06:13:12\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:13:12\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-003\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-04\"}, {\"tz\": \"UTC\", \"created_at\": \"2026-08-21 06:13:12\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:13:12\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-005\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-05\"}, {\"tz\": \"UTC\", \"created_at\": \"2026-08-21 06:13:12\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:13:12\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-005\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-06\"}, {\"tz\": \"UTC\", \"created_at\": \"2026-08-21 06:13:12\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:13:12\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-005\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-07\"}, {\"tz\": \"UTC\", \"created_at\": \"2026-08-21 06:13:12\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:13:12\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-005\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-08\"}, {\"tz\": \"UTC\", \"created_at\": \"2026-08-21 06:13:12\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:13:12\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 1, \"kode_layanan\": \"LAY-005\", \"kode_paket_layanan\": \"PKT-001\", \"kode_detail_paket_layanan\": \"DPKT-PKT-001-09\"}], \"created_at\": \"2026-08-20T22:38:44.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:13:12\", \"updated_by\": \"superadmin@admin.com\", \"harga_paket\": \"1250000.00\", \"masa_berlaku_hari\": 90, \"kode_paket_layanan\": \"PKT-001\"}', 'UTC', 'superadmin@admin.com', '2026-08-21 06:13:12', '2026-08-21 06:13:12'),
(102, 'CREATE', 'Tambah Produk PRD-001', 'mst_produk', 'PRD-001', NULL, '{\"tz\": \"UTC\", \"nama\": \"Nivia men\", \"satuan\": \"pcs\", \"status\": \"aktif\", \"created_at\": \"2026-08-21 06:15:06\", \"created_by\": \"superadmin@admin.com\", \"harga_beli\": 30000, \"harga_jual\": 45000, \"updated_at\": \"2026-08-21 06:15:06\", \"updated_by\": \"superadmin@admin.com\", \"kode_produk\": \"PRD-001\", \"stok_minimum\": 5, \"kode_supplier\": null, \"kode_kategori_produk\": \"KATPRD-001\"}', 'UTC', 'superadmin@admin.com', '2026-08-21 06:15:06', '2026-08-21 06:15:06'),
(103, 'CREATE', 'Tambah Supplier SUP-001', 'mst_supplier', 'SUP-001', NULL, '{\"tz\": \"UTC\", \"nama\": \"Hais\", \"email\": \"superadmin@gmail.com\", \"no_hp\": \"081335086375\", \"alamat\": \"tes\", \"status\": \"aktif\", \"created_at\": \"2026-08-21 06:17:10\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:17:10\", \"updated_by\": \"superadmin@admin.com\", \"kode_supplier\": \"SUP-001\"}', 'UTC', 'superadmin@admin.com', '2026-08-21 06:17:10', '2026-08-21 06:17:10'),
(104, 'CREATE', 'Tambah Karyawan 999999999', 'mst_karyawan', '999999999', NULL, '{\"tz\": \"UTC\", \"nama\": \"M. Hais Batara\", \"email\": \"batarahais24@gmail.com\", \"no_hp\": \"081335086375\", \"no_sip\": \"999999999\", \"status\": \"aktif\", \"jabatan\": \"terapis\", \"kode_user\": null, \"created_at\": \"2026-08-21 06:17:47\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:17:47\", \"updated_by\": \"superadmin@admin.com\"}', 'UTC', 'superadmin@admin.com', '2026-08-21 06:17:47', '2026-08-21 06:17:47'),
(105, 'CREATE', 'Tambah Alat ALT-001', 'mst_alat', 'ALT-001', NULL, '{\"tz\": \"UTC\", \"merk\": \"tes\", \"nama\": \"kipas\", \"status\": \"aktif\", \"kondisi\": \"rusak_ringan\", \"kode_alat\": \"ALT-001\", \"created_at\": \"2026-08-21 06:18:35\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:18:35\", \"updated_by\": \"superadmin@admin.com\", \"tanggal_beli\": \"2026-08-02\"}', 'UTC', 'superadmin@admin.com', '2026-08-21 06:18:35', '2026-08-21 06:18:35'),
(106, 'UPDATE', 'Edit Paket Layanan PKT-002', 'mst_paket_layanan', 'PKT-002', '{\"id\": 5, \"tz\": \"UTC\", \"nama\": \"Paket Acne Cure Complete (3x Laser + Peeling)\", \"status\": \"aktif\", \"created_at\": \"2026-08-20T22:38:44.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-20T22:38:44.000Z\", \"updated_by\": null, \"harga_paket\": \"1850000.00\", \"masa_berlaku_hari\": 60, \"kode_paket_layanan\": \"PKT-002\"}', '{\"id\": 5, \"tz\": \"UTC\", \"nama\": \"Paket Acne Cure Complete (3x Laser + Peeling)\", \"status\": \"aktif\", \"details\": [{\"tz\": \"UTC\", \"created_at\": \"2026-08-21 06:20:55\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:20:55\", \"updated_by\": \"superadmin@admin.com\", \"jumlah_sesi\": 3, \"kode_layanan\": \"LAY-002\", \"kode_paket_layanan\": \"PKT-002\", \"kode_detail_paket_layanan\": \"DPKT-PKT-002-01\"}], \"created_at\": \"2026-08-20T22:38:44.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 06:20:55\", \"updated_by\": \"superadmin@admin.com\", \"harga_paket\": \"1850000.00\", \"masa_berlaku_hari\": 60, \"kode_paket_layanan\": \"PKT-002\"}', 'UTC', 'superadmin@admin.com', '2026-08-21 06:20:55', '2026-08-21 06:20:55'),
(107, 'UPDATE', 'Antrian selesai dilayani - Nomor 03', 'trx_antrian_awal', 'A-20260820-003', '{\"id\": 37, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-20T13:40:12.000Z\", \"updated_at\": \"2026-08-20T13:40:16.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-20T13:40:16.000Z\", \"nomor_antrian\": \"03\", \"kode_antrian_awal\": \"A-20260820-003\"}', '{\"id\": 37, \"tz\": \"Asia/Jakarta\", \"status\": \"terpakai\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-20T13:40:12.000Z\", \"no_antrian\": \"03\", \"updated_at\": \"2026-08-21 12:02:42\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-20T13:40:16.000Z\", \"kode_antrian\": \"A-20260820-003\", \"nomor_antrian\": \"03\", \"kode_antrian_awal\": \"A-20260820-003\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 12:02:42', '2026-08-21 19:02:42'),
(108, 'CREATE', 'Pendaftaran Pasien Baru (RM-000001 - batara)', 'mst_pasien', 'RM-000001', NULL, '{\"tz\": \"Asia/Jakarta\", \"nik\": \"2121212121212121\", \"foto\": null, \"nama\": \"batara\", \"agama\": \"Islam\", \"email\": \"superadmin@gmail.com\", \"no_hp\": \"081335086375\", \"no_rm\": \"RM-000001\", \"alergi\": \"udang\", \"status\": \"aktif\", \"patokan\": null, \"kode_pos\": null, \"provinsi\": null, \"kecamatan\": null, \"pekerjaan\": \"Pelajar / Mahasiswa\", \"created_at\": \"2026-08-21 12:07:08\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 12:07:08\", \"updated_by\": \"superadmin@admin.com\", \"tempat_lahir\": \"probolinggo jawa timur\", \"jenis_kelamin\": \"L\", \"tanggal_lahir\": \"2026-08-01\", \"golongan_darah\": null, \"kelurahan_desa\": null, \"kota_kabupaten\": null, \"kewarganegaraan\": \"WNI\", \"status_perkawinan\": \"belum_menikah\", \"nama_kontak_darurat\": \"tes\", \"no_hp_kontak_darurat\": \"081111111111\", \"hubungan_kontak_darurat\": \"tes\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 12:07:08', '2026-08-21 19:07:08'),
(109, 'CREATE', 'Pendaftaran Pasien Baru (RM-000002 - hais)', 'mst_pasien', 'RM-000002', NULL, '{\"tz\": \"Asia/Jakarta\", \"nik\": \"1111111111111111\", \"foto\": null, \"nama\": \"hais\", \"agama\": \"Islam\", \"email\": null, \"no_hp\": \"081335086375\", \"no_rm\": \"RM-000002\", \"alergi\": null, \"status\": \"aktif\", \"patokan\": null, \"kode_pos\": null, \"provinsi\": null, \"kecamatan\": null, \"pekerjaan\": \"Karyawan Swasta\", \"created_at\": \"2026-08-21 12:09:01\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 12:09:01\", \"updated_by\": \"superadmin@admin.com\", \"tempat_lahir\": \"pr\", \"jenis_kelamin\": \"L\", \"tanggal_lahir\": \"2026-08-15\", \"golongan_darah\": null, \"kelurahan_desa\": null, \"kota_kabupaten\": null, \"kewarganegaraan\": \"WNI\", \"status_perkawinan\": \"belum_menikah\", \"nama_kontak_darurat\": null, \"no_hp_kontak_darurat\": null, \"hubungan_kontak_darurat\": null}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 12:09:01', '2026-08-21 19:09:01'),
(110, 'CREATE', 'Pendaftaran Kunjungan Pasien (RM-000002 - hais) Kunjungan (KJ-20260821-001) Total 1 Layanan/Paket', 'trx_kunjungan', 'KJ-20260821-001', NULL, '{\"kunjungan\": {\"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000002\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-21 12:20:42\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"19:20:42\", \"updated_at\": \"2026-08-21 12:20:42\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260821-001\", \"tanggal_kunjungan\": \"2026-08-21\"}, \"antrian_awal\": {\"id\": 38, \"tz\": \"Asia/Jakarta\", \"no_rm\": null, \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:51:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"04\", \"kode_kunjungan\": null, \"kode_antrian_awal\": \"A-20260820-004\"}, \"antrian_layanan\": [{\"tz\": \"Asia/Jakarta\", \"harga\": 150000, \"status\": \"menunggu\", \"created_at\": \"2026-08-21 12:20:42\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 12:20:42\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-001\", \"nama_layanan\": \"Facial Glow Up\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260821-001\", \"kode_antrian_layanan\": \"AL-20260821-001\"}]}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 12:20:42', '2026-08-21 19:20:42'),
(111, 'UPDATE', 'Update status antrian layanan 01 ke dipanggil', 'trx_antrian_layanan', 'AL-20260821-001', '{\"id\": 14, \"tz\": \"Asia/Jakarta\", \"status\": \"menunggu\", \"created_at\": \"2026-08-21T12:20:42.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-21T12:20:42.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"kode_layanan\": \"LAY-001\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260821-001\", \"kode_antrian_layanan\": \"AL-20260821-001\"}', '{\"id\": 14, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-21T12:20:42.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-21 12:21:08\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-21 12:21:08\", \"kode_layanan\": \"LAY-001\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260821-001\", \"kode_antrian_layanan\": \"AL-20260821-001\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 12:21:08', '2026-08-21 19:21:08'),
(112, 'UPDATE', 'Update status antrian layanan 01 ke selesai', 'trx_antrian_layanan', 'AL-20260821-001', '{\"id\": 14, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-21T12:20:42.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-21T12:21:08.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-21T12:21:08.000Z\", \"kode_layanan\": \"LAY-001\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260821-001\", \"kode_antrian_layanan\": \"AL-20260821-001\"}', '{\"id\": 14, \"tz\": \"Asia/Jakarta\", \"status\": \"selesai\", \"created_at\": \"2026-08-21T12:20:42.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": \"2026-08-21 12:27:10\", \"updated_at\": \"2026-08-21 12:27:10\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-21T12:21:08.000Z\", \"kode_layanan\": \"LAY-001\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260821-001\", \"kode_antrian_layanan\": \"AL-20260821-001\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 12:27:10', '2026-08-21 19:27:10'),
(113, 'UPDATE', 'Update status antrian layanan 01 ke dipanggil', 'trx_antrian_layanan', 'AL-20260821-001', '{\"id\": 14, \"tz\": \"Asia/Jakarta\", \"status\": \"menunggu\", \"created_at\": \"2026-08-21T12:20:42.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-21T12:27:16.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"kode_layanan\": \"LAY-001\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260821-001\", \"kode_antrian_layanan\": \"AL-20260821-001\"}', '{\"id\": 14, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-21T12:20:42.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-21 12:27:19\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-21 12:27:19\", \"kode_layanan\": \"LAY-001\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260821-001\", \"kode_antrian_layanan\": \"AL-20260821-001\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 12:27:19', '2026-08-21 19:27:19'),
(114, 'CREATE', 'Pendaftaran Kunjungan Pasien (RM-000000 - Pasien Umum / Antrian Awal) Kunjungan (KJ-20260821-002) Total 1 Layanan/Paket', 'trx_kunjungan', 'KJ-20260821-002', NULL, '{\"kunjungan\": {\"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000000\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-21 12:27:53\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"19:27:52\", \"updated_at\": \"2026-08-21 12:27:53\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260821-002\", \"tanggal_kunjungan\": \"2026-08-21\"}, \"antrian_awal\": {\"id\": 39, \"tz\": \"Asia/Jakarta\", \"no_rm\": null, \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:51:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"05\", \"kode_kunjungan\": null, \"kode_antrian_awal\": \"A-20260820-005\"}, \"antrian_layanan\": [{\"tz\": \"Asia/Jakarta\", \"harga\": 1850000, \"status\": \"menunggu\", \"created_at\": \"2026-08-21 12:27:53\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 12:27:53\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"PKT-002\", \"nama_layanan\": \"Paket Acne Cure Complete (3x Laser + Peeling)\", \"jenis_layanan\": \"paket\", \"nomor_antrian\": \"02\", \"kode_kunjungan\": \"KJ-20260821-002\", \"kode_antrian_layanan\": \"AL-20260821-002\"}]}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 12:27:53', '2026-08-21 19:27:53'),
(115, 'CREATE', 'Pendaftaran Kunjungan Pasien (RM-000001 - batara) Kunjungan (KJ-20260821-003) Total 1 Layanan/Paket', 'trx_kunjungan', 'KJ-20260821-003', NULL, '{\"kunjungan\": {\"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000001\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-21 12:32:15\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"19:32:15\", \"updated_at\": \"2026-08-21 12:32:15\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260821-003\", \"tanggal_kunjungan\": \"2026-08-21\"}, \"antrian_awal\": {\"id\": 40, \"tz\": \"Asia/Jakarta\", \"no_rm\": null, \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:51:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"06\", \"kode_kunjungan\": null, \"kode_antrian_awal\": \"A-20260820-006\"}, \"antrian_layanan\": [{\"tz\": \"Asia/Jakarta\", \"harga\": 4500000, \"status\": \"menunggu\", \"created_at\": \"2026-08-21 12:32:15\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 12:32:15\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"PKT-003\", \"nama_layanan\": \"Paket Anti-Aging Premium (4x Botox & HIFU)\", \"jenis_layanan\": \"paket\", \"nomor_antrian\": \"03\", \"kode_kunjungan\": \"KJ-20260821-003\", \"kode_antrian_layanan\": \"AL-20260821-003\"}]}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 12:32:15', '2026-08-21 19:32:15'),
(116, 'CREATE', 'Pendaftaran Kunjungan Pasien (RM-000001 - batara) Kunjungan (KJ-20260821-004) Total 1 Layanan/Paket', 'trx_kunjungan', 'KJ-20260821-004', NULL, '{\"kunjungan\": {\"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000001\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-21 12:37:42\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"19:37:42\", \"updated_at\": \"2026-08-21 12:37:42\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260821-004\", \"tanggal_kunjungan\": \"2026-08-21\"}, \"antrian_awal\": {\"id\": 41, \"tz\": \"Asia/Jakarta\", \"no_rm\": null, \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:51:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"07\", \"kode_kunjungan\": null, \"kode_antrian_awal\": \"A-20260820-007\"}, \"antrian_layanan\": [{\"tz\": \"Asia/Jakarta\", \"harga\": 1250000, \"status\": \"menunggu\", \"created_at\": \"2026-08-21 12:37:42\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-21 12:37:42\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"PKT-001\", \"nama_layanan\": \"Paket Glowing Skin (5x Facial + Serum)\", \"jenis_layanan\": \"paket\", \"nomor_antrian\": \"04\", \"kode_kunjungan\": \"KJ-20260821-004\", \"kode_antrian_layanan\": \"AL-20260821-004\"}]}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 12:37:42', '2026-08-21 19:37:42'),
(117, 'CREATE', 'Tambah Layanan LAY-006', 'mst_layanan', 'LAY-006', NULL, '{\"tz\": \"UTC\", \"nama\": \"keramas\", \"harga\": 100000, \"status\": \"aktif\", \"created_at\": \"2026-08-22 05:42:21\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 05:42:21\", \"updated_by\": \"superadmin@admin.com\", \"durasi_menit\": 30, \"kode_layanan\": \"LAY-006\", \"kode_kategori_layanan\": \"KAT-003\"}', 'UTC', 'superadmin@admin.com', '2026-08-22 05:42:21', '2026-08-22 05:42:21'),
(118, 'CREATE', 'Pendaftaran Kunjungan Pasien (RM-000002 - hais) Kunjungan (KJ-20260822-001) Total 1 Layanan/Paket', 'trx_kunjungan', 'KJ-20260822-001', NULL, '{\"kunjungan\": {\"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000002\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-22 06:08:02\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"13:08:02\", \"updated_at\": \"2026-08-22 06:08:02\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260822-001\", \"tanggal_kunjungan\": \"2026-08-22\"}, \"antrian_awal\": {\"id\": 42, \"tz\": \"Asia/Jakarta\", \"no_rm\": null, \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:51:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"08\", \"kode_kunjungan\": null, \"kode_antrian_awal\": \"A-20260820-008\"}, \"antrian_layanan\": [{\"tz\": \"Asia/Jakarta\", \"harga\": 100000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 06:08:02\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 06:08:02\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-006\", \"kode_ruangan\": \"RG-05\", \"nama_layanan\": \"keramas\", \"nama_ruangan\": \"Ruang Suntik/Injeksi\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260822-001\", \"kode_antrian_layanan\": \"AL-20260822-001\"}]}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 06:08:02', '2026-08-22 13:08:02'),
(119, 'CREATE', 'Pendaftaran Kunjungan Pasien (RM-000001 - batara) Kunjungan (KJ-20260822-002) Total 1 Layanan/Paket', 'trx_kunjungan', 'KJ-20260822-002', NULL, '{\"kunjungan\": {\"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000001\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-22 06:15:57\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"13:15:57\", \"updated_at\": \"2026-08-22 06:15:57\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260822-002\", \"tanggal_kunjungan\": \"2026-08-22\"}, \"antrian_awal\": {\"id\": 43, \"tz\": \"Asia/Jakarta\", \"no_rm\": null, \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:51:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"09\", \"kode_kunjungan\": null, \"kode_antrian_awal\": \"A-20260820-009\"}, \"antrian_layanan\": [{\"tz\": \"Asia/Jakarta\", \"harga\": 150000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 06:15:57\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 06:15:57\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Facial Glow Up\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"02\", \"kode_kunjungan\": \"KJ-20260822-002\", \"kode_antrian_layanan\": \"AL-20260822-002\"}]}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 06:15:57', '2026-08-22 13:15:57'),
(120, 'CREATE', 'Pendaftaran Kunjungan Pasien (RM-000002 - hais) Kunjungan (KJ-20260822-003) Total 1 Layanan/Paket', 'trx_kunjungan', 'KJ-20260822-003', NULL, '{\"kunjungan\": {\"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000002\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-22 06:23:45\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"13:23:45\", \"updated_at\": \"2026-08-22 06:23:45\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260822-003\", \"tanggal_kunjungan\": \"2026-08-22\"}, \"antrian_awal\": {\"id\": 44, \"tz\": \"Asia/Jakarta\", \"no_rm\": null, \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:51:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"10\", \"kode_kunjungan\": null, \"kode_antrian_awal\": \"A-20260820-010\"}, \"antrian_layanan\": [{\"tz\": \"Asia/Jakarta\", \"harga\": 200000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 06:23:45\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 06:23:45\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-002\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Acne Care Treatment\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"03\", \"kode_kunjungan\": \"KJ-20260822-003\", \"kode_antrian_layanan\": \"AL-20260822-003\"}]}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 06:23:45', '2026-08-22 13:23:45'),
(121, 'UPDATE', 'Update status antrian layanan 02 ke dipanggil', 'trx_antrian_layanan', 'AL-20260822-002', '{\"id\": 19, \"tz\": \"Asia/Jakarta\", \"status\": \"menunggu\", \"created_at\": \"2026-08-22T06:15:57.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22T06:15:57.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"02\", \"kode_kunjungan\": \"KJ-20260822-002\", \"kode_antrian_layanan\": \"AL-20260822-002\"}', '{\"id\": 19, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-22T06:15:57.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22 06:25:53\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22 06:25:53\", \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"02\", \"kode_kunjungan\": \"KJ-20260822-002\", \"kode_antrian_layanan\": \"AL-20260822-002\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 06:25:53', '2026-08-22 13:25:53'),
(122, 'UPDATE', 'Update status antrian layanan 01 ke dipanggil', 'trx_antrian_layanan', 'AL-20260822-001', '{\"id\": 18, \"tz\": \"Asia/Jakarta\", \"status\": \"menunggu\", \"created_at\": \"2026-08-22T06:08:02.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22T06:08:02.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"kode_layanan\": \"LAY-006\", \"kode_ruangan\": \"RG-05\", \"nama_ruangan\": \"Ruang Suntik/Injeksi\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260822-001\", \"kode_antrian_layanan\": \"AL-20260822-001\"}', '{\"id\": 18, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-22T06:08:02.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22 06:28:00\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22 06:28:00\", \"kode_layanan\": \"LAY-006\", \"kode_ruangan\": \"RG-05\", \"nama_ruangan\": \"Ruang Suntik/Injeksi\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260822-001\", \"kode_antrian_layanan\": \"AL-20260822-001\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 06:28:00', '2026-08-22 13:28:00');
INSERT INTO `log_perubahan` (`id`, `aksi`, `keterangan`, `nama_tabel`, `kode_referensi`, `data_sebelum`, `data_sesudah`, `tz`, `created_by`, `created_at`, `created_at_eng`) VALUES
(123, 'UPDATE', 'Update status antrian layanan 03 ke dipanggil', 'trx_antrian_layanan', 'AL-20260822-003', '{\"id\": 20, \"tz\": \"Asia/Jakarta\", \"status\": \"menunggu\", \"created_at\": \"2026-08-22T06:23:45.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22T06:23:45.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"kode_layanan\": \"LAY-002\", \"kode_ruangan\": \"RG-01\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"03\", \"kode_kunjungan\": \"KJ-20260822-003\", \"kode_antrian_layanan\": \"AL-20260822-003\"}', '{\"id\": 20, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-22T06:23:45.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22 06:29:47\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22 06:29:47\", \"kode_layanan\": \"LAY-002\", \"kode_ruangan\": \"RG-01\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"03\", \"kode_kunjungan\": \"KJ-20260822-003\", \"kode_antrian_layanan\": \"AL-20260822-003\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 06:29:47', '2026-08-22 13:29:47'),
(124, 'CREATE', 'Tambah Layanan LAY-007', 'mst_layanan', 'LAY-007', NULL, '{\"tz\": \"UTC\", \"nama\": \"Konsultasi\", \"harga\": 0, \"status\": \"aktif\", \"created_at\": \"2026-08-22 06:39:47\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 06:39:47\", \"updated_by\": \"superadmin@admin.com\", \"durasi_menit\": 10, \"kode_layanan\": \"LAY-007\", \"kode_ruangan\": \"RG-01\", \"kode_kategori_layanan\": \"KAT-001\"}', 'UTC', 'superadmin@admin.com', '2026-08-22 06:39:47', '2026-08-22 06:39:47'),
(125, 'UPDATE', 'Edit Layanan LAY-007', 'mst_layanan', 'LAY-007', '{\"id\": 7, \"tz\": \"UTC\", \"nama\": \"Konsultasi\", \"harga\": \"0.00\", \"status\": \"aktif\", \"created_at\": \"2026-08-22T06:39:47.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22T06:39:47.000Z\", \"updated_by\": \"superadmin@admin.com\", \"durasi_menit\": 10, \"kode_layanan\": \"LAY-007\", \"kode_ruangan\": \"RG-01\", \"kode_kategori_layanan\": \"KAT-001\"}', '{\"id\": 7, \"tz\": \"UTC\", \"nama\": \"Konsultasi\", \"harga\": \"0.00\", \"status\": \"aktif\", \"created_at\": \"2026-08-22T06:39:47.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 06:40:08\", \"updated_by\": \"superadmin@admin.com\", \"durasi_menit\": 10, \"kode_layanan\": \"LAY-007\", \"kode_ruangan\": \"RG-04\", \"kode_kategori_layanan\": \"KAT-001\"}', 'UTC', 'superadmin@admin.com', '2026-08-22 06:40:08', '2026-08-22 06:40:08'),
(126, 'UPDATE', 'Panggil nomor antrian ke loket - Nomor 04', 'trx_antrian_awal', 'A-20260820-004', '{\"id\": 38, \"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000002\", \"status\": \"terpakai\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-21T12:20:42.000Z\", \"updated_at\": \"2026-08-21T12:20:42.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"04\", \"kode_kunjungan\": \"KJ-20260821-001\", \"kode_antrian_awal\": \"A-20260820-004\"}', '{\"id\": 38, \"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000002\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-21T12:20:42.000Z\", \"no_antrian\": \"04\", \"updated_at\": \"2026-08-22 11:53:05\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22 11:53:05\", \"kode_antrian\": \"A-20260820-004\", \"nomor_antrian\": \"04\", \"kode_kunjungan\": \"KJ-20260821-001\", \"kode_antrian_awal\": \"A-20260820-004\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 11:53:05', '2026-08-22 18:53:05'),
(127, 'UPDATE', 'Antrian selesai dilayani - Nomor 04', 'trx_antrian_awal', 'A-20260820-004', '{\"id\": 38, \"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000002\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-21T12:20:42.000Z\", \"updated_at\": \"2026-08-22T11:53:05.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22T11:53:05.000Z\", \"nomor_antrian\": \"04\", \"kode_kunjungan\": \"KJ-20260821-001\", \"kode_antrian_awal\": \"A-20260820-004\"}', '{\"id\": 38, \"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000002\", \"status\": \"terpakai\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": \"2026-08-21T12:20:42.000Z\", \"no_antrian\": \"04\", \"updated_at\": \"2026-08-22 11:53:13\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22T11:53:05.000Z\", \"kode_antrian\": \"A-20260820-004\", \"nomor_antrian\": \"04\", \"kode_kunjungan\": \"KJ-20260821-001\", \"kode_antrian_awal\": \"A-20260820-004\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 11:53:13', '2026-08-22 18:53:13'),
(128, 'UPDATE', 'Update status antrian layanan 02 ke selesai', 'trx_antrian_layanan', 'AL-20260822-002', '{\"id\": 19, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-22T06:15:57.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22T06:25:53.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22T06:25:53.000Z\", \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"02\", \"kode_kunjungan\": \"KJ-20260822-002\", \"kode_antrian_layanan\": \"AL-20260822-002\"}', '{\"id\": 19, \"tz\": \"Asia/Jakarta\", \"status\": \"selesai\", \"created_at\": \"2026-08-22T06:15:57.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": \"2026-08-22 11:53:19\", \"updated_at\": \"2026-08-22 11:53:19\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22T06:25:53.000Z\", \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"02\", \"kode_kunjungan\": \"KJ-20260822-002\", \"kode_antrian_layanan\": \"AL-20260822-002\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 11:53:19', '2026-08-22 18:53:19'),
(129, 'UPDATE', 'Update status antrian layanan 03 ke selesai', 'trx_antrian_layanan', 'AL-20260822-003', '{\"id\": 20, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-22T06:23:45.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22T06:29:47.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22T06:29:47.000Z\", \"kode_layanan\": \"LAY-002\", \"kode_ruangan\": \"RG-01\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"03\", \"kode_kunjungan\": \"KJ-20260822-003\", \"kode_antrian_layanan\": \"AL-20260822-003\"}', '{\"id\": 20, \"tz\": \"Asia/Jakarta\", \"status\": \"selesai\", \"created_at\": \"2026-08-22T06:23:45.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": \"2026-08-22 11:53:23\", \"updated_at\": \"2026-08-22 11:53:23\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22T06:29:47.000Z\", \"kode_layanan\": \"LAY-002\", \"kode_ruangan\": \"RG-01\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"03\", \"kode_kunjungan\": \"KJ-20260822-003\", \"kode_antrian_layanan\": \"AL-20260822-003\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 11:53:23', '2026-08-22 18:53:23'),
(130, 'UPDATE', 'Update status antrian layanan 01 ke selesai', 'trx_antrian_layanan', 'AL-20260822-001', '{\"id\": 18, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-22T06:08:02.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22T06:28:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22T06:28:00.000Z\", \"kode_layanan\": \"LAY-006\", \"kode_ruangan\": \"RG-05\", \"nama_ruangan\": \"Ruang Suntik/Injeksi\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260822-001\", \"kode_antrian_layanan\": \"AL-20260822-001\"}', '{\"id\": 18, \"tz\": \"Asia/Jakarta\", \"status\": \"selesai\", \"created_at\": \"2026-08-22T06:08:02.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": \"2026-08-22 11:53:43\", \"updated_at\": \"2026-08-22 11:53:43\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22T06:28:00.000Z\", \"kode_layanan\": \"LAY-006\", \"kode_ruangan\": \"RG-05\", \"nama_ruangan\": \"Ruang Suntik/Injeksi\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"01\", \"kode_kunjungan\": \"KJ-20260822-001\", \"kode_antrian_layanan\": \"AL-20260822-001\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 11:53:43', '2026-08-22 18:53:43'),
(131, 'CREATE', 'Pendaftaran Kunjungan Pasien (RM-000002 - hais) Kunjungan (KJ-20260822-004) Total 5 Layanan/Paket', 'trx_kunjungan', 'KJ-20260822-004', NULL, '{\"kunjungan\": {\"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000002\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-22 11:54:28\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"18:54:28\", \"updated_at\": \"2026-08-22 11:54:28\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260822-004\", \"tanggal_kunjungan\": \"2026-08-22\"}, \"antrian_awal\": {\"id\": 45, \"tz\": \"Asia/Jakarta\", \"no_rm\": null, \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:51:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"11\", \"kode_kunjungan\": null, \"kode_antrian_awal\": \"A-20260820-011\"}, \"antrian_layanan\": [{\"tz\": \"Asia/Jakarta\", \"harga\": 150000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 11:54:28\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 11:54:28\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Facial Glow Up\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"04\", \"kode_kunjungan\": \"KJ-20260822-004\", \"kode_antrian_layanan\": \"AL-20260822-004\"}, {\"tz\": \"Asia/Jakarta\", \"harga\": 450000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 11:54:28\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 11:54:28\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-003\", \"kode_ruangan\": \"RG-02\", \"nama_layanan\": \"Laser Brightening\", \"nama_ruangan\": \"Ruang Facial 2\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"05\", \"kode_kunjungan\": \"KJ-20260822-004\", \"kode_antrian_layanan\": \"AL-20260822-005\"}, {\"tz\": \"Asia/Jakarta\", \"harga\": 120000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 11:54:28\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 11:54:28\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-004\", \"kode_ruangan\": \"RG-03\", \"nama_layanan\": \"Hair Spa Therapy\", \"nama_ruangan\": \"Ruang Laser\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"06\", \"kode_kunjungan\": \"KJ-20260822-004\", \"kode_antrian_layanan\": \"AL-20260822-006\"}, {\"tz\": \"Asia/Jakarta\", \"harga\": 250000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 11:54:28\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 11:54:28\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-005\", \"kode_ruangan\": \"RG-05\", \"nama_layanan\": \"Body Scrub & Massage\", \"nama_ruangan\": \"Ruang Suntik/Injeksi\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"07\", \"kode_kunjungan\": \"KJ-20260822-004\", \"kode_antrian_layanan\": \"AL-20260822-007\"}, {\"tz\": \"Asia/Jakarta\", \"harga\": 3200000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 11:54:28\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 11:54:28\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"PKT-005\", \"kode_ruangan\": \"RG-03\", \"nama_layanan\": \"Paket Slimming & Body Contour (5x Treatment)\", \"nama_ruangan\": \"Ruang Laser\", \"jenis_layanan\": \"paket\", \"nomor_antrian\": \"08\", \"kode_kunjungan\": \"KJ-20260822-004\", \"kode_antrian_layanan\": \"AL-20260822-008\"}]}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 11:54:28', '2026-08-22 18:54:28'),
(132, 'CREATE', 'Pendaftaran Kunjungan Pasien (RM-000002 - hais) Kunjungan (KJ-20260822-005) Total 2 Layanan/Paket', 'trx_kunjungan', 'KJ-20260822-005', NULL, '{\"kunjungan\": {\"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000002\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-22 11:56:38\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"18:56:38\", \"updated_at\": \"2026-08-22 11:56:38\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260822-005\", \"tanggal_kunjungan\": \"2026-08-22\"}, \"antrian_awal\": {\"id\": 46, \"tz\": \"Asia/Jakarta\", \"no_rm\": null, \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:51:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"12\", \"kode_kunjungan\": null, \"kode_antrian_awal\": \"A-20260820-012\"}, \"antrian_layanan\": [{\"tz\": \"Asia/Jakarta\", \"harga\": 150000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 11:56:38\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 11:56:38\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Facial Glow Up\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"09\", \"kode_kunjungan\": \"KJ-20260822-005\", \"kode_antrian_layanan\": \"AL-20260822-009\"}, {\"tz\": \"Asia/Jakarta\", \"harga\": 200000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 11:56:38\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 11:56:38\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-002\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Acne Care Treatment\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"10\", \"kode_kunjungan\": \"KJ-20260822-005\", \"kode_antrian_layanan\": \"AL-20260822-010\"}]}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 11:56:38', '2026-08-22 18:56:38'),
(133, 'CREATE', 'Pendaftaran Kunjungan Pasien (RM-000002 - hais) Kunjungan (KJ-20260822-006) Total 2 Layanan/Paket', 'trx_kunjungan', 'KJ-20260822-006', NULL, '{\"kunjungan\": {\"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000002\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-22 11:57:00\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"18:57:00\", \"updated_at\": \"2026-08-22 11:57:00\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260822-006\", \"tanggal_kunjungan\": \"2026-08-22\"}, \"antrian_awal\": {\"id\": 47, \"tz\": \"Asia/Jakarta\", \"no_rm\": null, \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:51:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"13\", \"kode_kunjungan\": null, \"kode_antrian_awal\": \"A-20260820-013\"}, \"antrian_layanan\": [{\"tz\": \"Asia/Jakarta\", \"harga\": 200000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 11:57:00\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 11:57:00\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-002\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Acne Care Treatment\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"11\", \"kode_kunjungan\": \"KJ-20260822-006\", \"kode_antrian_layanan\": \"AL-20260822-011\"}, {\"tz\": \"Asia/Jakarta\", \"harga\": 0, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 11:57:00\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 11:57:00\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-007\", \"kode_ruangan\": \"RG-04\", \"nama_layanan\": \"Konsultasi\", \"nama_ruangan\": \"Ruang Konsultasi\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"12\", \"kode_kunjungan\": \"KJ-20260822-006\", \"kode_antrian_layanan\": \"AL-20260822-012\"}]}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 11:57:00', '2026-08-22 18:57:00'),
(134, 'UPDATE', 'Edit Layanan LAY-007', 'mst_layanan', 'LAY-007', '{\"id\": 7, \"tz\": \"UTC\", \"nama\": \"Konsultasi\", \"harga\": \"0.00\", \"status\": \"aktif\", \"created_at\": \"2026-08-22T06:39:47.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22T06:40:08.000Z\", \"updated_by\": \"superadmin@admin.com\", \"durasi_menit\": 10, \"kode_layanan\": \"LAY-007\", \"kode_ruangan\": \"RG-04\", \"kode_kategori_layanan\": \"KAT-001\"}', '{\"id\": 7, \"tz\": \"UTC\", \"nama\": \"Konsultasi\", \"harga\": \"0.00\", \"status\": \"aktif\", \"created_at\": \"2026-08-22T06:39:47.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 11:58:24\", \"updated_by\": \"superadmin@admin.com\", \"durasi_menit\": 10, \"kode_layanan\": \"LAY-007\", \"kode_ruangan\": \"RG-01\", \"kode_kategori_layanan\": \"KAT-001\"}', 'UTC', 'superadmin@admin.com', '2026-08-22 11:58:24', '2026-08-22 11:58:24'),
(135, 'UPDATE', 'Edit Layanan LAY-006', 'mst_layanan', 'LAY-006', '{\"id\": 6, \"tz\": \"UTC\", \"nama\": \"keramas\", \"harga\": \"100000.00\", \"status\": \"aktif\", \"created_at\": \"2026-08-22T05:42:21.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22T12:46:26.000Z\", \"updated_by\": \"superadmin@admin.com\", \"durasi_menit\": 30, \"kode_layanan\": \"LAY-006\", \"kode_ruangan\": \"RG-05\", \"kode_kategori_layanan\": \"KAT-003\"}', '{\"id\": 6, \"tz\": \"UTC\", \"nama\": \"keramas\", \"harga\": \"100000.00\", \"status\": \"aktif\", \"created_at\": \"2026-08-22T05:42:21.000Z\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 11:59:10\", \"updated_by\": \"superadmin@admin.com\", \"durasi_menit\": 30, \"kode_layanan\": \"LAY-006\", \"kode_ruangan\": \"RG-03\", \"kode_kategori_layanan\": \"KAT-003\"}', 'UTC', 'superadmin@admin.com', '2026-08-22 11:59:10', '2026-08-22 11:59:10'),
(136, 'CREATE', 'Pendaftaran Kunjungan Pasien (RM-000001 - batara) Kunjungan (KJ-20260822-007) Total 2 Layanan/Paket', 'trx_kunjungan', 'KJ-20260822-007', NULL, '{\"kunjungan\": {\"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000001\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-22 12:02:40\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"19:02:40\", \"updated_at\": \"2026-08-22 12:02:40\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260822-007\", \"tanggal_kunjungan\": \"2026-08-22\"}, \"antrian_awal\": {\"id\": 48, \"tz\": \"Asia/Jakarta\", \"no_rm\": null, \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:51:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"14\", \"kode_kunjungan\": null, \"kode_antrian_awal\": \"A-20260820-014\"}, \"antrian_layanan\": [{\"tz\": \"Asia/Jakarta\", \"harga\": 150000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 12:02:40\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 12:02:40\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Facial Glow Up\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"13\", \"kode_kunjungan\": \"KJ-20260822-007\", \"kode_antrian_layanan\": \"AL-20260822-013\"}, {\"tz\": \"Asia/Jakarta\", \"harga\": 200000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 12:02:40\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 12:02:40\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-002\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Acne Care Treatment\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"14\", \"kode_kunjungan\": \"KJ-20260822-007\", \"kode_antrian_layanan\": \"AL-20260822-014\"}]}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 12:02:40', '2026-08-22 19:02:40'),
(137, 'CREATE', 'Pendaftaran Kunjungan Pasien (RM-000002 - hais) Kunjungan (KJ-20260822-008) Total 2 Layanan/Paket', 'trx_kunjungan', 'KJ-20260822-008', NULL, '{\"kunjungan\": {\"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000002\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-22 12:13:00\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"19:13:00\", \"updated_at\": \"2026-08-22 12:13:00\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260822-008\", \"tanggal_kunjungan\": \"2026-08-22\"}, \"antrian_awal\": {\"id\": 49, \"tz\": \"Asia/Jakarta\", \"no_rm\": null, \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:51:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"15\", \"kode_kunjungan\": null, \"kode_antrian_awal\": \"A-20260820-015\"}, \"antrian_layanan\": [{\"tz\": \"Asia/Jakarta\", \"harga\": 150000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 12:13:00\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 12:13:00\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Facial Glow Up\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"15\", \"kode_kunjungan\": \"KJ-20260822-008\", \"kode_antrian_layanan\": \"AL-20260822-015\"}, {\"tz\": \"Asia/Jakarta\", \"harga\": 200000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 12:13:00\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 12:13:00\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-002\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Acne Care Treatment\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"15\", \"kode_kunjungan\": \"KJ-20260822-008\", \"kode_antrian_layanan\": \"AL-20260822-016\"}]}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 12:13:00', '2026-08-22 19:13:00'),
(138, 'UPDATE', 'Update status antrian layanan 15 ke dipanggil', 'trx_antrian_layanan', 'AL-20260822-015', '{\"id\": 32, \"tz\": \"Asia/Jakarta\", \"status\": \"menunggu\", \"created_at\": \"2026-08-22T12:13:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22T12:13:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"15\", \"kode_kunjungan\": \"KJ-20260822-008\", \"kode_antrian_layanan\": \"AL-20260822-015\"}', '{\"id\": 32, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-22T12:13:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22 12:13:37\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22 12:13:37\", \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"15\", \"kode_kunjungan\": \"KJ-20260822-008\", \"kode_antrian_layanan\": \"AL-20260822-015\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 12:13:37', '2026-08-22 19:13:37'),
(139, 'CREATE', 'Pendaftaran Kunjungan Pasien (RM-000002 - hais) Kunjungan (KJ-20260822-009) Total 2 Layanan/Paket', 'trx_kunjungan', 'KJ-20260822-009', NULL, '{\"kunjungan\": {\"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000002\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-22 12:13:48\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"19:13:48\", \"updated_at\": \"2026-08-22 12:13:48\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260822-009\", \"tanggal_kunjungan\": \"2026-08-22\"}, \"antrian_awal\": {\"id\": 50, \"tz\": \"Asia/Jakarta\", \"no_rm\": null, \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:51:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"16\", \"kode_kunjungan\": null, \"kode_antrian_awal\": \"A-20260820-016\"}, \"antrian_layanan\": [{\"tz\": \"Asia/Jakarta\", \"harga\": 150000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 12:13:48\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 12:13:48\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Facial Glow Up\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"16\", \"kode_kunjungan\": \"KJ-20260822-009\", \"kode_antrian_layanan\": \"AL-20260822-017\"}, {\"tz\": \"Asia/Jakarta\", \"harga\": 200000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 12:13:48\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 12:13:48\", \"updated_by\": \"superadmin@admin.com\", \"kode_layanan\": \"LAY-002\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Acne Care Treatment\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"16\", \"kode_kunjungan\": \"KJ-20260822-009\", \"kode_antrian_layanan\": \"AL-20260822-018\"}]}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 12:13:48', '2026-08-22 19:13:48'),
(140, 'CREATE', 'Pendaftaran Kunjungan Pasien (RM-000002 - hais) Kunjungan (KJ-20260822-010) Total 1 Layanan/Paket', 'trx_kunjungan', 'KJ-20260822-010', NULL, '{\"kunjungan\": {\"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000002\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-22 12:24:55\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"19:24:55\", \"updated_at\": \"2026-08-22 12:24:55\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260822-010\", \"tanggal_kunjungan\": \"2026-08-22\"}, \"antrian_awal\": {\"id\": 51, \"tz\": \"Asia/Jakarta\", \"no_rm\": null, \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:51:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"17\", \"kode_kunjungan\": null, \"kode_antrian_awal\": \"A-20260820-017\"}, \"antrian_layanan\": [{\"tz\": \"Asia/Jakarta\", \"harga\": 350000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 12:24:56\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 12:24:56\", \"updated_by\": \"superadmin@admin.com\", \"detail_items\": [{\"harga\": 150000, \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Facial Glow Up\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\"}, {\"harga\": 200000, \"kode_layanan\": \"LAY-002\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Acne Care Treatment\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\"}], \"kode_layanan\": \"LAY-001, LAY-002\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Facial Glow Up, Acne Care Treatment\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"17\", \"detail_layanan\": \"[{\\\"jenis_layanan\\\":\\\"layanan\\\",\\\"kode_layanan\\\":\\\"LAY-001\\\",\\\"nama_layanan\\\":\\\"Facial Glow Up\\\",\\\"harga\\\":150000,\\\"kode_ruangan\\\":\\\"RG-01\\\",\\\"nama_ruangan\\\":\\\"Ruang Facial 1\\\"},{\\\"jenis_layanan\\\":\\\"layanan\\\",\\\"kode_layanan\\\":\\\"LAY-002\\\",\\\"nama_layanan\\\":\\\"Acne Care Treatment\\\",\\\"harga\\\":200000,\\\"kode_ruangan\\\":\\\"RG-01\\\",\\\"nama_ruangan\\\":\\\"Ruang Facial 1\\\"}]\", \"kode_kunjungan\": \"KJ-20260822-010\", \"kode_antrian_layanan\": \"AL-20260822-019\"}]}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 12:24:56', '2026-08-22 19:24:56'),
(141, 'UPDATE', 'Update status antrian layanan 04 ke dipanggil', 'trx_antrian_layanan', 'AL-20260822-004', '{\"id\": 21, \"tz\": \"Asia/Jakarta\", \"status\": \"menunggu\", \"created_at\": \"2026-08-22T11:54:28.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22T11:54:28.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": null, \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"04\", \"detail_layanan\": null, \"kode_kunjungan\": \"KJ-20260822-004\", \"kode_antrian_layanan\": \"AL-20260822-004\"}', '{\"id\": 21, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-22T11:54:28.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22 12:25:44\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22 12:25:44\", \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": null, \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"04\", \"detail_layanan\": null, \"kode_kunjungan\": \"KJ-20260822-004\", \"kode_antrian_layanan\": \"AL-20260822-004\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 12:25:44', '2026-08-22 19:25:44'),
(142, 'UPDATE', 'Update status antrian layanan 04 ke selesai', 'trx_antrian_layanan', 'AL-20260822-004', '{\"id\": 21, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-22T11:54:28.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22T12:25:44.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22T12:25:44.000Z\", \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": null, \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"04\", \"detail_layanan\": null, \"kode_kunjungan\": \"KJ-20260822-004\", \"kode_antrian_layanan\": \"AL-20260822-004\"}', '{\"id\": 21, \"tz\": \"Asia/Jakarta\", \"status\": \"selesai\", \"created_at\": \"2026-08-22T11:54:28.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": \"2026-08-22 12:25:46\", \"updated_at\": \"2026-08-22 12:25:46\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22T12:25:44.000Z\", \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": null, \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"04\", \"detail_layanan\": null, \"kode_kunjungan\": \"KJ-20260822-004\", \"kode_antrian_layanan\": \"AL-20260822-004\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 12:25:46', '2026-08-22 19:25:46'),
(143, 'UPDATE', 'Update status antrian layanan 09 ke dipanggil', 'trx_antrian_layanan', 'AL-20260822-009', '{\"id\": 26, \"tz\": \"Asia/Jakarta\", \"status\": \"menunggu\", \"created_at\": \"2026-08-22T11:56:38.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22T11:56:38.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": null, \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"09\", \"detail_layanan\": null, \"kode_kunjungan\": \"KJ-20260822-005\", \"kode_antrian_layanan\": \"AL-20260822-009\"}', '{\"id\": 26, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-22T11:56:38.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22 12:25:48\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22 12:25:48\", \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": null, \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"09\", \"detail_layanan\": null, \"kode_kunjungan\": \"KJ-20260822-005\", \"kode_antrian_layanan\": \"AL-20260822-009\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 12:25:48', '2026-08-22 19:25:48'),
(144, 'UPDATE', 'Update status antrian layanan 09 ke selesai', 'trx_antrian_layanan', 'AL-20260822-009', '{\"id\": 26, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-22T11:56:38.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22T12:25:48.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22T12:25:48.000Z\", \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": null, \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"09\", \"detail_layanan\": null, \"kode_kunjungan\": \"KJ-20260822-005\", \"kode_antrian_layanan\": \"AL-20260822-009\"}', '{\"id\": 26, \"tz\": \"Asia/Jakarta\", \"status\": \"selesai\", \"created_at\": \"2026-08-22T11:56:38.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": \"2026-08-22 12:25:50\", \"updated_at\": \"2026-08-22 12:25:50\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22T12:25:48.000Z\", \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": null, \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"09\", \"detail_layanan\": null, \"kode_kunjungan\": \"KJ-20260822-005\", \"kode_antrian_layanan\": \"AL-20260822-009\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 12:25:50', '2026-08-22 19:25:50'),
(145, 'UPDATE', 'Update status antrian layanan 15 ke selesai', 'trx_antrian_layanan', 'AL-20260822-015', '{\"id\": 32, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-22T12:13:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22T12:13:37.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22T12:13:37.000Z\", \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": null, \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"15\", \"detail_layanan\": null, \"kode_kunjungan\": \"KJ-20260822-008\", \"kode_antrian_layanan\": \"AL-20260822-015\"}', '{\"id\": 32, \"tz\": \"Asia/Jakarta\", \"status\": \"selesai\", \"created_at\": \"2026-08-22T12:13:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": \"2026-08-22 12:25:54\", \"updated_at\": \"2026-08-22 12:25:54\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22T12:13:37.000Z\", \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": null, \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"15\", \"detail_layanan\": null, \"kode_kunjungan\": \"KJ-20260822-008\", \"kode_antrian_layanan\": \"AL-20260822-015\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 12:25:54', '2026-08-22 19:25:54'),
(146, 'CREATE', 'Pendaftaran Kunjungan Pasien (RM-000002 - hais) Kunjungan (KJ-20260822-011) Total 1 Layanan/Paket', 'trx_kunjungan', 'KJ-20260822-011', NULL, '{\"kunjungan\": {\"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000002\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-22 12:26:35\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"19:26:35\", \"updated_at\": \"2026-08-22 12:26:35\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260822-011\", \"tanggal_kunjungan\": \"2026-08-22\"}, \"antrian_awal\": {\"id\": 52, \"tz\": \"Asia/Jakarta\", \"no_rm\": null, \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:51:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"18\", \"kode_kunjungan\": null, \"kode_antrian_awal\": \"A-20260820-018\"}, \"antrian_layanan\": [{\"tz\": \"Asia/Jakarta\", \"harga\": 350000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 12:26:35\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 12:26:35\", \"updated_by\": \"superadmin@admin.com\", \"detail_items\": [{\"harga\": 150000, \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Facial Glow Up\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\"}, {\"harga\": 200000, \"kode_layanan\": \"LAY-002\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Acne Care Treatment\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\"}], \"kode_layanan\": \"LAY-001, LAY-002\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Facial Glow Up, Acne Care Treatment\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"18\", \"detail_layanan\": \"[{\\\"jenis_layanan\\\":\\\"layanan\\\",\\\"kode_layanan\\\":\\\"LAY-001\\\",\\\"nama_layanan\\\":\\\"Facial Glow Up\\\",\\\"harga\\\":150000,\\\"kode_ruangan\\\":\\\"RG-01\\\",\\\"nama_ruangan\\\":\\\"Ruang Facial 1\\\"},{\\\"jenis_layanan\\\":\\\"layanan\\\",\\\"kode_layanan\\\":\\\"LAY-002\\\",\\\"nama_layanan\\\":\\\"Acne Care Treatment\\\",\\\"harga\\\":200000,\\\"kode_ruangan\\\":\\\"RG-01\\\",\\\"nama_ruangan\\\":\\\"Ruang Facial 1\\\"}]\", \"kode_kunjungan\": \"KJ-20260822-011\", \"kode_antrian_layanan\": \"AL-20260822-020\"}]}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 12:26:35', '2026-08-22 19:26:35'),
(147, 'CREATE', 'Pendaftaran Kunjungan Pasien (RM-000002 - hais) Kunjungan (KJ-20260822-012) Total 1 Layanan/Paket', 'trx_kunjungan', 'KJ-20260822-012', NULL, '{\"kunjungan\": {\"tz\": \"Asia/Jakarta\", \"no_rm\": \"RM-000002\", \"status\": \"berlangsung\", \"created_at\": \"2026-08-22 12:26:58\", \"created_by\": \"superadmin@admin.com\", \"jam_datang\": \"19:26:58\", \"updated_at\": \"2026-08-22 12:26:58\", \"updated_by\": \"superadmin@admin.com\", \"kode_kunjungan\": \"KJ-20260822-012\", \"tanggal_kunjungan\": \"2026-08-22\"}, \"antrian_awal\": {\"id\": 53, \"tz\": \"Asia/Jakarta\", \"no_rm\": null, \"status\": \"tersedia\", \"created_at\": \"2026-08-20T12:51:00.000Z\", \"created_by\": \"superadmin@admin.com\", \"diambil_at\": null, \"updated_at\": \"2026-08-20T12:51:00.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"nomor_antrian\": \"19\", \"kode_kunjungan\": null, \"kode_antrian_awal\": \"A-20260820-019\"}, \"antrian_layanan\": [{\"tz\": \"Asia/Jakarta\", \"harga\": 200000, \"status\": \"menunggu\", \"created_at\": \"2026-08-22 12:26:58\", \"created_by\": \"superadmin@admin.com\", \"updated_at\": \"2026-08-22 12:26:58\", \"updated_by\": \"superadmin@admin.com\", \"detail_items\": [{\"harga\": 0, \"kode_layanan\": \"LAY-007\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Konsultasi\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\"}, {\"harga\": 200000, \"kode_layanan\": \"LAY-002\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Acne Care Treatment\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\"}], \"kode_layanan\": \"LAY-007, LAY-002\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Konsultasi, Acne Care Treatment\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"19\", \"detail_layanan\": \"[{\\\"jenis_layanan\\\":\\\"layanan\\\",\\\"kode_layanan\\\":\\\"LAY-007\\\",\\\"nama_layanan\\\":\\\"Konsultasi\\\",\\\"harga\\\":0,\\\"kode_ruangan\\\":\\\"RG-01\\\",\\\"nama_ruangan\\\":\\\"Ruang Facial 1\\\"},{\\\"jenis_layanan\\\":\\\"layanan\\\",\\\"kode_layanan\\\":\\\"LAY-002\\\",\\\"nama_layanan\\\":\\\"Acne Care Treatment\\\",\\\"harga\\\":200000,\\\"kode_ruangan\\\":\\\"RG-01\\\",\\\"nama_ruangan\\\":\\\"Ruang Facial 1\\\"}]\", \"kode_kunjungan\": \"KJ-20260822-012\", \"kode_antrian_layanan\": \"AL-20260822-021\"}]}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 12:26:58', '2026-08-22 19:26:58'),
(148, 'UPDATE', 'Update status antrian layanan 05 ke dipanggil', 'trx_antrian_layanan', 'AL-20260822-005', '{\"id\": 22, \"tz\": \"Asia/Jakarta\", \"status\": \"menunggu\", \"created_at\": \"2026-08-22T11:54:28.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22T11:54:28.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"kode_layanan\": \"LAY-003\", \"kode_ruangan\": \"RG-02\", \"nama_layanan\": null, \"nama_ruangan\": \"Ruang Facial 2\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"05\", \"detail_layanan\": null, \"kode_kunjungan\": \"KJ-20260822-004\", \"kode_antrian_layanan\": \"AL-20260822-005\"}', '{\"id\": 22, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-22T11:54:28.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22 12:49:09\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22 12:49:09\", \"kode_layanan\": \"LAY-003\", \"kode_ruangan\": \"RG-02\", \"nama_layanan\": null, \"nama_ruangan\": \"Ruang Facial 2\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"05\", \"detail_layanan\": null, \"kode_kunjungan\": \"KJ-20260822-004\", \"kode_antrian_layanan\": \"AL-20260822-005\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 12:49:09', '2026-08-22 19:49:09'),
(149, 'UPDATE', 'Update status antrian layanan 05 ke selesai', 'trx_antrian_layanan', 'AL-20260822-005', '{\"id\": 22, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-22T11:54:28.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22T12:49:09.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22T12:49:09.000Z\", \"kode_layanan\": \"LAY-003\", \"kode_ruangan\": \"RG-02\", \"nama_layanan\": null, \"nama_ruangan\": \"Ruang Facial 2\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"05\", \"detail_layanan\": null, \"kode_kunjungan\": \"KJ-20260822-004\", \"kode_antrian_layanan\": \"AL-20260822-005\"}', '{\"id\": 22, \"tz\": \"Asia/Jakarta\", \"status\": \"selesai\", \"created_at\": \"2026-08-22T11:54:28.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": \"2026-08-22 12:49:12\", \"updated_at\": \"2026-08-22 12:49:12\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22T12:49:09.000Z\", \"kode_layanan\": \"LAY-003\", \"kode_ruangan\": \"RG-02\", \"nama_layanan\": null, \"nama_ruangan\": \"Ruang Facial 2\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"05\", \"detail_layanan\": null, \"kode_kunjungan\": \"KJ-20260822-004\", \"kode_antrian_layanan\": \"AL-20260822-005\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 12:49:12', '2026-08-22 19:49:12'),
(150, 'UPDATE', 'Update status antrian layanan 06 ke dipanggil', 'trx_antrian_layanan', 'AL-20260822-006', '{\"id\": 23, \"tz\": \"Asia/Jakarta\", \"status\": \"menunggu\", \"created_at\": \"2026-08-22T11:54:28.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22T11:54:28.000Z\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": null, \"kode_layanan\": \"LAY-004\", \"kode_ruangan\": \"RG-03\", \"nama_layanan\": null, \"nama_ruangan\": \"Ruang Laser\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"06\", \"detail_layanan\": null, \"kode_kunjungan\": \"KJ-20260822-004\", \"kode_antrian_layanan\": \"AL-20260822-006\"}', '{\"id\": 23, \"tz\": \"Asia/Jakarta\", \"status\": \"dipanggil\", \"created_at\": \"2026-08-22T11:54:28.000Z\", \"created_by\": \"superadmin@admin.com\", \"selesai_at\": null, \"updated_at\": \"2026-08-22 12:49:16\", \"updated_by\": \"superadmin@admin.com\", \"dipanggil_at\": \"2026-08-22 12:49:16\", \"kode_layanan\": \"LAY-004\", \"kode_ruangan\": \"RG-03\", \"nama_layanan\": null, \"nama_ruangan\": \"Ruang Laser\", \"jenis_layanan\": \"layanan\", \"nomor_antrian\": \"06\", \"detail_layanan\": null, \"kode_kunjungan\": \"KJ-20260822-004\", \"kode_antrian_layanan\": \"AL-20260822-006\"}', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 12:49:16', '2026-08-22 19:49:16');

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

--
-- Dumping data for table `mst_alat`
--

INSERT INTO `mst_alat` (`id`, `kode_alat`, `nama`, `merk`, `tanggal_beli`, `kondisi`, `status`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(1, 'ALT-001', 'kipas', 'tes', '2026-08-02', 'rusak_ringan', 'aktif', 'UTC', 'superadmin@admin.com', '2026-08-20 23:18:35', 'superadmin@admin.com', '2026-08-20 23:18:35');

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
(3, 'DPKT-003', 'PKT-003', 'LAY-003', 4, 'UTC', 'superadmin@admin.com', '2026-08-20 15:46:53', NULL, '2026-08-20 15:46:53'),
(4, 'DPKT-004', 'PKT-004', 'LAY-003', 3, 'UTC', 'superadmin@admin.com', '2026-08-20 15:46:53', NULL, '2026-08-20 15:46:53'),
(5, 'DPKT-005', 'PKT-005', 'LAY-005', 5, 'UTC', 'superadmin@admin.com', '2026-08-20 15:46:53', NULL, '2026-08-20 15:46:53'),
(6, 'DPKT-006', 'PKT-006', 'LAY-004', 6, 'UTC', 'superadmin@admin.com', '2026-08-20 15:46:53', NULL, '2026-08-20 15:46:53'),
(19, 'DPKT-PKT-001-01', 'PKT-001', 'LAY-001', 1, 'UTC', 'superadmin@admin.com', '2026-08-20 23:13:12', 'superadmin@admin.com', '2026-08-20 23:13:12'),
(20, 'DPKT-PKT-001-02', 'PKT-001', 'LAY-004', 1, 'UTC', 'superadmin@admin.com', '2026-08-20 23:13:12', 'superadmin@admin.com', '2026-08-20 23:13:12'),
(21, 'DPKT-PKT-001-03', 'PKT-001', 'LAY-005', 1, 'UTC', 'superadmin@admin.com', '2026-08-20 23:13:12', 'superadmin@admin.com', '2026-08-20 23:13:12'),
(22, 'DPKT-PKT-001-04', 'PKT-001', 'LAY-003', 1, 'UTC', 'superadmin@admin.com', '2026-08-20 23:13:12', 'superadmin@admin.com', '2026-08-20 23:13:12'),
(23, 'DPKT-PKT-001-05', 'PKT-001', 'LAY-005', 1, 'UTC', 'superadmin@admin.com', '2026-08-20 23:13:12', 'superadmin@admin.com', '2026-08-20 23:13:12'),
(24, 'DPKT-PKT-001-06', 'PKT-001', 'LAY-005', 1, 'UTC', 'superadmin@admin.com', '2026-08-20 23:13:12', 'superadmin@admin.com', '2026-08-20 23:13:12'),
(25, 'DPKT-PKT-001-07', 'PKT-001', 'LAY-005', 1, 'UTC', 'superadmin@admin.com', '2026-08-20 23:13:12', 'superadmin@admin.com', '2026-08-20 23:13:12'),
(26, 'DPKT-PKT-001-08', 'PKT-001', 'LAY-005', 1, 'UTC', 'superadmin@admin.com', '2026-08-20 23:13:12', 'superadmin@admin.com', '2026-08-20 23:13:12'),
(27, 'DPKT-PKT-001-09', 'PKT-001', 'LAY-005', 1, 'UTC', 'superadmin@admin.com', '2026-08-20 23:13:12', 'superadmin@admin.com', '2026-08-20 23:13:12'),
(28, 'DPKT-PKT-002-01', 'PKT-002', 'LAY-002', 3, 'UTC', 'superadmin@admin.com', '2026-08-20 23:20:55', 'superadmin@admin.com', '2026-08-20 23:20:55');

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
-- Table structure for table `mst_kabupaten`
--

CREATE TABLE `mst_kabupaten` (
  `kode` varchar(10) NOT NULL,
  `kode_provinsi` varchar(10) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
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

--
-- Dumping data for table `mst_karyawan`
--

INSERT INTO `mst_karyawan` (`id`, `no_sip`, `kode_user`, `nama`, `jabatan`, `no_hp`, `email`, `status`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(1, '999999999', NULL, 'M. Hais Batara', 'terapis', '081335086375', 'batarahais24@gmail.com', 'aktif', 'UTC', 'superadmin@admin.com', '2026-08-20 23:17:47', 'superadmin@admin.com', '2026-08-20 23:17:47');

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
(1, 'KAT-001', 'Perawatan Wajah', 'Perawatan komprehensif area wajah', 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-21 07:48:02'),
(2, 'KAT-002', 'Perawatan Kulit', 'Treatment kesehatan dan peremajaan kulit', 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:55:00', 'superadmin@admin.com', '2026-08-21 07:48:10'),
(3, 'KAT-003', 'Perawatan Rambut', 'Layanan terapi scalp dan nutrisi rambut', 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 06:00:15', 'superadmin@admin.com', '2026-08-21 12:29:53'),
(4, 'KAT-004', 'Perawatan Tubuh', 'Spa dan pemijatan relaksasi tubuh', 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 06:10:00', 'superadmin@admin.com', '2026-08-21 12:30:04'),
(5, 'KAT-005', 'Anti Aging', 'Terapi khusus penuaan dini dan kerutan', 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 06:15:30', 'superadmin@admin.com', '2026-08-21 12:30:17');

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

--
-- Dumping data for table `mst_kategori_produk`
--

INSERT INTO `mst_kategori_produk` (`id`, `kode_kategori_produk`, `nama`, `deskripsi`, `status`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(1, 'KATPRD-001', 'Muka', 'untuk kulit berminyak', 'aktif', 'UTC', 'superadmin@admin.com', '2026-08-20 23:11:20', 'superadmin@admin.com', '2026-08-20 23:11:20');

-- --------------------------------------------------------

--
-- Table structure for table `mst_kecamatan`
--

CREATE TABLE `mst_kecamatan` (
  `kode` varchar(10) NOT NULL,
  `kode_kabupaten` varchar(10) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mst_kelurahan`
--

CREATE TABLE `mst_kelurahan` (
  `kode` varchar(15) NOT NULL,
  `kode_kecamatan` varchar(10) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mst_layanan`
--

CREATE TABLE `mst_layanan` (
  `id` int NOT NULL,
  `kode_layanan` varchar(20) NOT NULL,
  `kode_kategori_layanan` varchar(20) NOT NULL,
  `kode_ruangan` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
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

INSERT INTO `mst_layanan` (`id`, `kode_layanan`, `kode_kategori_layanan`, `kode_ruangan`, `nama`, `harga`, `durasi_menit`, `status`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(1, 'LAY-001', 'KAT-001', 'RG-01', 'Facial Glow Up', '150000.00', 45, 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-22 05:34:26'),
(2, 'LAY-002', 'KAT-001', 'RG-01', 'Acne Care Treatment', '200000.00', 60, 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:58:00', 'superadmin@admin.com', '2026-08-22 05:34:33'),
(3, 'LAY-003', 'KAT-002', 'RG-02', 'Laser Brightening', '450000.00', 30, 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 06:02:00', 'superadmin@admin.com', '2026-08-22 05:34:44'),
(4, 'LAY-004', 'KAT-003', 'RG-03', 'Hair Spa Therapy', '120000.00', 60, 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 06:12:00', 'superadmin@admin.com', '2026-08-22 05:34:55'),
(5, 'LAY-005', 'KAT-004', 'RG-05', 'Body Scrub & Massage', '250000.00', 90, 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 06:20:00', 'superadmin@admin.com', '2026-08-22 05:35:06'),
(6, 'LAY-006', 'KAT-003', 'RG-03', 'keramas', '100000.00', 30, 'aktif', 'UTC', 'superadmin@admin.com', '2026-08-21 22:42:21', 'superadmin@admin.com', '2026-08-22 04:59:10'),
(7, 'LAY-007', 'KAT-001', 'RG-01', 'Konsultasi', '0.00', 10, 'aktif', 'UTC', 'superadmin@admin.com', '2026-08-21 23:39:47', 'superadmin@admin.com', '2026-08-22 04:58:24');

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
(1, '[{"label":"HOME","icon":"pi pi-fw pi-home","items":[{"label":"Dashboard","icon":"pi pi-fw pi-home","to":"/dashboard"}]},{"label":"MASTER DATA","icon":"pi pi-fw pi-database","items":[{"label":"Kategori Layanan","icon":"pi pi-fw pi-tags","to":"/master-data/kategori-layanan"},{"label":"Data Layanan","icon":"pi pi-fw pi-briefcase","to":"/master-data/layanan"},{"label":"Paket Layanan","icon":"pi pi-fw pi-box","to":"/master-data/paket-layanan"},{"label":"Kategori Produk","icon":"pi pi-fw pi-tags","to":"/master-data/kategori-produk"},{"label":"Data Produk","icon":"pi pi-fw pi-box","to":"/master-data/produk"},{"label":"Paket Produk","icon":"pi pi-fw pi-inbox","to":"/master-data/paket-produk"},{"label":"Supplier","icon":"pi pi-fw pi-truck","to":"/master-data/supplier"},{"label":"Karyawan","icon":"pi pi-fw pi-users","to":"/master-data/karyawan"},{"label":"Jadwal Karyawan","icon":"pi pi-fw pi-calendar-times","to":"/master-data/jadwal-karyawan"},{"label":"Alat & Peralatan","icon":"pi pi-fw pi-wrench","to":"/master-data/alat"},{"label":"Data Ruangan","icon":"pi pi-fw pi-building","to":"/master-data/ruangan"},{"label":"Data Promo","icon":"pi pi-fw pi-percentage","to":"/master-data/promo"}]},{"label":"Pendaftaran & Antrean","icon":"pi pi-fw pi-calendar","items":[{"label":"Antrean Awal","icon":"pi pi-fw pi-ticket","to":"/antrian-awal"},{"label":"Pendaftaran Pasien","icon":"pi pi-fw pi-user-plus","to":"/pendaftaran-antrean/pendaftaran-pasien"},{"label":"Antrean","icon":"pi pi-fw pi-list","to":"/pendaftaran-antrean/antrean"}]},{"label":"Master Data & User","icon":"pi pi-fw pi-cog","items":[{"label":"Data Pasien","icon":"pi pi-fw pi-user","to":"/master-data-user/data-pasien"},{"label":"Manajemen Menu","icon":"pi pi-fw pi-bars","to":"/setup/navigation"},{"label":"Manajemen User","icon":"pi pi-fw pi-users","to":"/setup/users"}]}]', 'master', 'UTC', '2026-08-20 11:29:37', '2026-08-20 11:29:37');

-- --------------------------------------------------------

--
-- Table structure for table `mst_paket_layanan`
--

CREATE TABLE `mst_paket_layanan` (
  `id` int NOT NULL,
  `kode_paket_layanan` varchar(20) NOT NULL,
  `kode_ruangan` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
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

INSERT INTO `mst_paket_layanan` (`id`, `kode_paket_layanan`, `kode_ruangan`, `nama`, `harga_paket`, `masa_berlaku_hari`, `status`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(4, 'PKT-001', 'RG-05', 'Paket Glowing Skin (5x Facial + Serum)', '1250000.00', 90, 'aktif', 'UTC', 'superadmin@admin.com', '2026-08-20 15:38:44', 'superadmin@admin.com', '2026-08-22 05:46:41'),
(5, 'PKT-002', 'RG-05', 'Paket Acne Cure Complete (3x Laser + Peeling)', '1850000.00', 60, 'aktif', 'UTC', 'superadmin@admin.com', '2026-08-20 15:38:44', 'superadmin@admin.com', '2026-08-22 05:46:50'),
(6, 'PKT-003', 'RG-04', 'Paket Anti-Aging Premium (4x Botox & HIFU)', '4500000.00', 180, 'aktif', 'UTC', 'superadmin@admin.com', '2026-08-20 15:38:44', NULL, '2026-08-22 05:46:56'),
(7, 'PKT-004', 'RG-03', 'Paket Brightening Laser Rejuvenation (3x)', '2200000.00', 90, 'aktif', 'UTC', 'superadmin@admin.com', '2026-08-20 15:38:44', NULL, '2026-08-22 05:47:04'),
(8, 'PKT-005', 'RG-03', 'Paket Slimming & Body Contour (5x Treatment)', '3200000.00', 120, 'aktif', 'UTC', 'superadmin@admin.com', '2026-08-20 15:38:44', NULL, '2026-08-22 05:47:10'),
(9, 'PKT-006', 'RG-01', 'Paket Hair Removal Underarm (6x Session)', '950000.00', 180, 'aktif', 'UTC', 'superadmin@admin.com', '2026-08-20 15:38:44', NULL, '2026-08-22 05:47:21');

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
(1, 'RM-000000', 'Pasien Umum / Antrian Awal', NULL, NULL, '2000-01-01', 'L', NULL, NULL, NULL, 'WNI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0800000000', NULL, NULL, NULL, NULL, NULL, NULL, 'aktif', 'UTC', NULL, '2026-08-20 04:50:15', NULL, '2026-08-20 04:50:15'),
(8, 'RM-000001', 'batara', '2121212121212121', 'probolinggo jawa timur', '2026-08-01', 'L', NULL, 'Islam', 'belum_menikah', 'WNI', 'Pelajar / Mahasiswa', NULL, NULL, NULL, NULL, NULL, NULL, '081335086375', 'superadmin@gmail.com', 'tes', '081111111111', 'tes', 'udang', NULL, 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 05:07:08', 'superadmin@admin.com', '2026-08-21 05:07:08'),
(9, 'RM-000002', 'hais', '1111111111111111', 'pr', '2026-08-15', 'L', NULL, 'Islam', 'belum_menikah', 'WNI', 'Karyawan Swasta', NULL, NULL, NULL, NULL, NULL, NULL, '081335086375', NULL, NULL, NULL, NULL, NULL, NULL, 'aktif', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 05:09:01', 'superadmin@admin.com', '2026-08-21 05:09:01');

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

--
-- Dumping data for table `mst_produk`
--

INSERT INTO `mst_produk` (`id`, `kode_produk`, `kode_kategori_produk`, `kode_supplier`, `nama`, `satuan`, `harga_beli`, `harga_jual`, `stok_minimum`, `status`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(1, 'PRD-001', 'KATPRD-001', NULL, 'Nivia men', 'pcs', '30000.00', '45000.00', 5, 'aktif', 'UTC', 'superadmin@admin.com', '2026-08-20 23:15:06', 'superadmin@admin.com', '2026-08-20 23:15:06');

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
-- Table structure for table `mst_provinsi`
--

CREATE TABLE `mst_provinsi` (
  `kode` varchar(10) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mst_ruangan`
--

CREATE TABLE `mst_ruangan` (
  `id` int NOT NULL,
  `kode_ruangan` varchar(30) NOT NULL,
  `nama_ruangan` varchar(30) NOT NULL,
  `status` enum('aktif','nonaktif') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'aktif',
  `tz` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'UTC',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `mst_ruangan`
--

INSERT INTO `mst_ruangan` (`id`, `kode_ruangan`, `nama_ruangan`, `status`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(1, 'RG-01', 'Ruang Facial 1', 'aktif', 'Asia/Jakarta', 'admin@klinik.com', '2026-08-21 07:40:32', NULL, '2026-08-21 07:40:32'),
(2, 'RG-02', 'Ruang Facial 2', 'aktif', 'Asia/Jakarta', 'admin@klinik.com', '2026-08-21 07:40:32', NULL, '2026-08-21 07:40:32'),
(3, 'RG-03', 'Ruang Laser', 'aktif', 'Asia/Jakarta', 'admin@klinik.com', '2026-08-21 07:40:32', NULL, '2026-08-21 07:40:32'),
(4, 'RG-04', 'Ruang Konsultasi', 'aktif', 'Asia/Jakarta', 'admin@klinik.com', '2026-08-21 07:40:32', NULL, '2026-08-21 07:40:32'),
(5, 'RG-05', 'Ruang Suntik/Injeksi', 'aktif', 'Asia/Jakarta', 'admin@klinik.com', '2026-08-21 07:40:32', NULL, '2026-08-21 07:40:32');

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

--
-- Dumping data for table `mst_supplier`
--

INSERT INTO `mst_supplier` (`id`, `kode_supplier`, `nama`, `alamat`, `no_hp`, `email`, `status`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(1, 'SUP-001', 'Hais', 'tes', '081335086375', 'superadmin@gmail.com', 'aktif', 'UTC', 'superadmin@admin.com', '2026-08-20 23:17:10', 'superadmin@admin.com', '2026-08-20 23:17:10');

-- --------------------------------------------------------

--
-- Table structure for table `trx_antrian_awal`
--

CREATE TABLE `trx_antrian_awal` (
  `id` int NOT NULL,
  `kode_antrian_awal` varchar(20) NOT NULL,
  `nomor_antrian` varchar(10) NOT NULL,
  `status` enum('tersedia','terpakai','dipanggil') NOT NULL DEFAULT 'tersedia',
  `no_rm` varchar(20) DEFAULT NULL,
  `kode_kunjungan` varchar(20) DEFAULT NULL,
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

INSERT INTO `trx_antrian_awal` (`id`, `kode_antrian_awal`, `nomor_antrian`, `status`, `no_rm`, `kode_kunjungan`, `diambil_at`, `dipanggil_at`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(35, 'A-20260820-001', '01', 'terpakai', NULL, NULL, '2026-08-20 06:36:36', '2026-08-20 06:36:41', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 06:40:08'),
(36, 'A-20260820-002', '02', 'terpakai', NULL, NULL, '2026-08-20 05:51:17', '2026-08-20 05:51:21', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 06:36:33'),
(37, 'A-20260820-003', '03', 'terpakai', NULL, NULL, '2026-08-20 06:40:12', '2026-08-20 06:40:16', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-21 05:02:42'),
(38, 'A-20260820-004', '04', 'terpakai', 'RM-000002', 'KJ-20260821-001', '2026-08-21 05:20:42', '2026-08-22 04:53:05', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-22 04:53:13'),
(39, 'A-20260820-005', '05', 'terpakai', 'RM-000000', 'KJ-20260821-002', '2026-08-21 05:27:53', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-21 05:27:53'),
(40, 'A-20260820-006', '06', 'terpakai', 'RM-000001', 'KJ-20260821-003', '2026-08-21 05:32:15', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-21 05:32:15'),
(41, 'A-20260820-007', '07', 'terpakai', 'RM-000001', 'KJ-20260821-004', '2026-08-21 05:37:42', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-21 05:37:42'),
(42, 'A-20260820-008', '08', 'terpakai', 'RM-000002', 'KJ-20260822-001', '2026-08-21 23:08:02', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-21 23:08:02'),
(43, 'A-20260820-009', '09', 'terpakai', 'RM-000001', 'KJ-20260822-002', '2026-08-21 23:15:57', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-21 23:15:57'),
(44, 'A-20260820-010', '10', 'terpakai', 'RM-000002', 'KJ-20260822-003', '2026-08-21 23:23:45', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-21 23:23:45'),
(45, 'A-20260820-011', '11', 'terpakai', 'RM-000002', 'KJ-20260822-004', '2026-08-22 04:54:28', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-22 04:54:28'),
(46, 'A-20260820-012', '12', 'terpakai', 'RM-000002', 'KJ-20260822-005', '2026-08-22 04:56:38', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-22 04:56:38'),
(47, 'A-20260820-013', '13', 'terpakai', 'RM-000002', 'KJ-20260822-006', '2026-08-22 04:57:00', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-22 04:57:00'),
(48, 'A-20260820-014', '14', 'terpakai', 'RM-000001', 'KJ-20260822-007', '2026-08-22 05:02:40', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-22 05:02:40'),
(49, 'A-20260820-015', '15', 'terpakai', 'RM-000002', 'KJ-20260822-008', '2026-08-22 05:13:00', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-22 05:13:00'),
(50, 'A-20260820-016', '16', 'terpakai', 'RM-000002', 'KJ-20260822-009', '2026-08-22 05:13:48', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-22 05:13:48'),
(51, 'A-20260820-017', '17', 'terpakai', 'RM-000002', 'KJ-20260822-010', '2026-08-22 05:24:55', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-22 05:24:55'),
(52, 'A-20260820-018', '18', 'terpakai', 'RM-000002', 'KJ-20260822-011', '2026-08-22 05:26:35', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-22 05:26:35'),
(53, 'A-20260820-019', '19', 'terpakai', 'RM-000002', 'KJ-20260822-012', '2026-08-22 05:26:58', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-22 05:26:58'),
(54, 'A-20260820-020', '20', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(55, 'A-20260820-021', '21', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(56, 'A-20260820-022', '22', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(57, 'A-20260820-023', '23', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(58, 'A-20260820-024', '24', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(59, 'A-20260820-025', '25', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(60, 'A-20260820-026', '26', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(61, 'A-20260820-027', '27', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(62, 'A-20260820-028', '28', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(63, 'A-20260820-029', '29', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(64, 'A-20260820-030', '30', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(65, 'A-20260820-031', '31', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(66, 'A-20260820-032', '32', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(67, 'A-20260820-033', '33', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(68, 'A-20260820-034', '34', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(69, 'A-20260820-035', '35', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(70, 'A-20260820-036', '36', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(71, 'A-20260820-037', '37', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(72, 'A-20260820-038', '38', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(73, 'A-20260820-039', '39', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(74, 'A-20260820-040', '40', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(75, 'A-20260820-041', '41', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(76, 'A-20260820-042', '42', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(77, 'A-20260820-043', '43', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(78, 'A-20260820-044', '44', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(79, 'A-20260820-045', '45', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(80, 'A-20260820-046', '46', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(81, 'A-20260820-047', '47', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(82, 'A-20260820-048', '48', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(83, 'A-20260820-049', '49', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00'),
(84, 'A-20260820-050', '50', 'tersedia', NULL, NULL, NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 05:51:00', 'superadmin@admin.com', '2026-08-20 05:51:00');

-- --------------------------------------------------------

--
-- Table structure for table `trx_antrian_layanan`
--

CREATE TABLE `trx_antrian_layanan` (
  `id` int NOT NULL,
  `kode_antrian_layanan` varchar(20) NOT NULL,
  `kode_kunjungan` varchar(20) NOT NULL,
  `jenis_layanan` varchar(20) NOT NULL DEFAULT 'layanan',
  `kode_layanan` varchar(100) NOT NULL,
  `detail_layanan` json DEFAULT NULL,
  `nama_layanan` varchar(500) DEFAULT NULL,
  `nomor_antrian` varchar(10) NOT NULL,
  `kode_ruangan` varchar(20) DEFAULT NULL,
  `nama_ruangan` varchar(100) DEFAULT NULL,
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

INSERT INTO `trx_antrian_layanan` (`id`, `kode_antrian_layanan`, `kode_kunjungan`, `jenis_layanan`, `kode_layanan`, `detail_layanan`, `nama_layanan`, `nomor_antrian`, `kode_ruangan`, `nama_ruangan`, `status`, `dipanggil_at`, `selesai_at`, `tz`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
(5, 'AL-20260820-001', 'KJ-20260820-001', 'layanan', 'LAY-005', NULL, NULL, '01', NULL, NULL, 'batal', '2026-08-20 08:01:16', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 07:46:41', 'superadmin@admin.com', '2026-08-20 08:30:51'),
(14, 'AL-20260821-001', 'KJ-20260821-001', 'layanan', 'LAY-001', NULL, NULL, '01', NULL, NULL, 'dipanggil', '2026-08-21 05:27:19', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 05:20:42', 'superadmin@admin.com', '2026-08-21 05:27:19'),
(15, 'AL-20260821-002', 'KJ-20260821-002', 'paket', 'PKT-002', NULL, NULL, '02', NULL, NULL, 'menunggu', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 05:27:53', 'superadmin@admin.com', '2026-08-21 05:27:53'),
(16, 'AL-20260821-003', 'KJ-20260821-003', 'paket', 'PKT-003', NULL, NULL, '03', NULL, NULL, 'menunggu', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 05:32:15', 'superadmin@admin.com', '2026-08-21 05:32:15'),
(17, 'AL-20260821-004', 'KJ-20260821-004', 'paket', 'PKT-001', NULL, NULL, '04', NULL, NULL, 'menunggu', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 05:37:42', 'superadmin@admin.com', '2026-08-21 05:37:42'),
(18, 'AL-20260822-001', 'KJ-20260822-001', 'layanan', 'LAY-006', NULL, NULL, '01', 'RG-05', 'Ruang Suntik/Injeksi', 'selesai', '2026-08-21 23:28:00', '2026-08-22 04:53:43', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 23:08:02', 'superadmin@admin.com', '2026-08-22 04:53:43'),
(19, 'AL-20260822-002', 'KJ-20260822-002', 'layanan', 'LAY-001', NULL, NULL, '02', 'RG-01', 'Ruang Facial 1', 'selesai', '2026-08-21 23:25:53', '2026-08-22 04:53:19', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 23:15:57', 'superadmin@admin.com', '2026-08-22 04:53:19'),
(20, 'AL-20260822-003', 'KJ-20260822-003', 'layanan', 'LAY-002', NULL, NULL, '03', 'RG-01', 'Ruang Facial 1', 'selesai', '2026-08-21 23:29:47', '2026-08-22 04:53:23', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 23:23:45', 'superadmin@admin.com', '2026-08-22 04:53:23'),
(21, 'AL-20260822-004', 'KJ-20260822-004', 'layanan', 'LAY-001', NULL, NULL, '04', 'RG-01', 'Ruang Facial 1', 'selesai', '2026-08-22 05:25:44', '2026-08-22 05:25:46', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 04:54:28', 'superadmin@admin.com', '2026-08-22 05:25:46'),
(22, 'AL-20260822-005', 'KJ-20260822-004', 'layanan', 'LAY-003', NULL, NULL, '05', 'RG-02', 'Ruang Facial 2', 'selesai', '2026-08-22 05:49:09', '2026-08-22 05:49:12', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 04:54:28', 'superadmin@admin.com', '2026-08-22 05:49:12'),
(23, 'AL-20260822-006', 'KJ-20260822-004', 'layanan', 'LAY-004', NULL, NULL, '06', 'RG-03', 'Ruang Laser', 'dipanggil', '2026-08-22 05:49:16', NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 04:54:28', 'superadmin@admin.com', '2026-08-22 05:49:16'),
(24, 'AL-20260822-007', 'KJ-20260822-004', 'layanan', 'LAY-005', NULL, NULL, '07', 'RG-05', 'Ruang Suntik/Injeksi', 'menunggu', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 04:54:28', 'superadmin@admin.com', '2026-08-22 04:54:28'),
(25, 'AL-20260822-008', 'KJ-20260822-004', 'paket', 'PKT-005', NULL, NULL, '08', 'RG-03', 'Ruang Laser', 'menunggu', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 04:54:28', 'superadmin@admin.com', '2026-08-22 04:54:28'),
(26, 'AL-20260822-009', 'KJ-20260822-005', 'layanan', 'LAY-001', NULL, NULL, '09', 'RG-01', 'Ruang Facial 1', 'selesai', '2026-08-22 05:25:48', '2026-08-22 05:25:50', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 04:56:38', 'superadmin@admin.com', '2026-08-22 05:25:50'),
(27, 'AL-20260822-010', 'KJ-20260822-005', 'layanan', 'LAY-002', NULL, NULL, '10', 'RG-01', 'Ruang Facial 1', 'menunggu', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 04:56:38', 'superadmin@admin.com', '2026-08-22 04:56:38'),
(28, 'AL-20260822-011', 'KJ-20260822-006', 'layanan', 'LAY-002', NULL, NULL, '11', 'RG-01', 'Ruang Facial 1', 'menunggu', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 04:57:00', 'superadmin@admin.com', '2026-08-22 04:57:00'),
(29, 'AL-20260822-012', 'KJ-20260822-006', 'layanan', 'LAY-007', NULL, NULL, '12', 'RG-04', 'Ruang Konsultasi', 'menunggu', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 04:57:00', 'superadmin@admin.com', '2026-08-22 04:57:00'),
(30, 'AL-20260822-013', 'KJ-20260822-007', 'layanan', 'LAY-001', NULL, NULL, '13', 'RG-01', 'Ruang Facial 1', 'menunggu', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 05:02:40', 'superadmin@admin.com', '2026-08-22 05:02:40'),
(31, 'AL-20260822-014', 'KJ-20260822-007', 'layanan', 'LAY-002', NULL, NULL, '14', 'RG-01', 'Ruang Facial 1', 'menunggu', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 05:02:40', 'superadmin@admin.com', '2026-08-22 05:02:40'),
(32, 'AL-20260822-015', 'KJ-20260822-008', 'layanan', 'LAY-001', NULL, NULL, '15', 'RG-01', 'Ruang Facial 1', 'selesai', '2026-08-22 05:13:37', '2026-08-22 05:25:54', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 05:13:00', 'superadmin@admin.com', '2026-08-22 05:25:54'),
(33, 'AL-20260822-016', 'KJ-20260822-008', 'layanan', 'LAY-002', NULL, NULL, '15', 'RG-01', 'Ruang Facial 1', 'menunggu', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 05:13:00', 'superadmin@admin.com', '2026-08-22 05:13:00'),
(34, 'AL-20260822-017', 'KJ-20260822-009', 'layanan', 'LAY-001', NULL, NULL, '16', 'RG-01', 'Ruang Facial 1', 'menunggu', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 05:13:48', 'superadmin@admin.com', '2026-08-22 05:13:48'),
(35, 'AL-20260822-018', 'KJ-20260822-009', 'layanan', 'LAY-002', NULL, NULL, '16', 'RG-01', 'Ruang Facial 1', 'menunggu', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 05:13:48', 'superadmin@admin.com', '2026-08-22 05:13:48'),
(36, 'AL-20260822-019', 'KJ-20260822-010', 'layanan', 'LAY-001, LAY-002', '[{\"harga\": 150000, \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Facial Glow Up\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\"}, {\"harga\": 200000, \"kode_layanan\": \"LAY-002\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Acne Care Treatment\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\"}]', 'Facial Glow Up, Acne Care Treatment', '17', 'RG-01', 'Ruang Facial 1', 'menunggu', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 05:24:56', 'superadmin@admin.com', '2026-08-22 05:24:56'),
(37, 'AL-20260822-020', 'KJ-20260822-011', 'layanan', 'LAY-001, LAY-002', '[{\"harga\": 150000, \"kode_layanan\": \"LAY-001\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Facial Glow Up\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\"}, {\"harga\": 200000, \"kode_layanan\": \"LAY-002\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Acne Care Treatment\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\"}]', 'Facial Glow Up, Acne Care Treatment', '18', 'RG-01', 'Ruang Facial 1', 'menunggu', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 05:26:35', 'superadmin@admin.com', '2026-08-22 05:26:35'),
(38, 'AL-20260822-021', 'KJ-20260822-012', 'layanan', 'LAY-007, LAY-002', '[{\"harga\": 0, \"kode_layanan\": \"LAY-007\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Konsultasi\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\"}, {\"harga\": 200000, \"kode_layanan\": \"LAY-002\", \"kode_ruangan\": \"RG-01\", \"nama_layanan\": \"Acne Care Treatment\", \"nama_ruangan\": \"Ruang Facial 1\", \"jenis_layanan\": \"layanan\"}]', 'Konsultasi, Acne Care Treatment', '19', 'RG-01', 'Ruang Facial 1', 'menunggu', NULL, NULL, 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 05:26:58', 'superadmin@admin.com', '2026-08-22 05:26:58');

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
(8, 'KJ-20260820-001', 'RM-000000', '2026-08-20', '21:46:41', 'berlangsung', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-20 07:46:41', 'superadmin@admin.com', '2026-08-20 07:46:41'),
(25, 'KJ-20260821-001', 'RM-000002', '2026-08-21', '19:20:42', 'berlangsung', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 05:20:42', 'superadmin@admin.com', '2026-08-21 05:20:42'),
(26, 'KJ-20260821-002', 'RM-000000', '2026-08-21', '19:27:52', 'berlangsung', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 05:27:53', 'superadmin@admin.com', '2026-08-21 05:27:53'),
(27, 'KJ-20260821-003', 'RM-000001', '2026-08-21', '19:32:15', 'berlangsung', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 05:32:15', 'superadmin@admin.com', '2026-08-21 05:32:15'),
(28, 'KJ-20260821-004', 'RM-000001', '2026-08-21', '19:37:42', 'berlangsung', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 05:37:42', 'superadmin@admin.com', '2026-08-21 05:37:42'),
(29, 'KJ-20260822-001', 'RM-000002', '2026-08-22', '13:08:02', 'berlangsung', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 23:08:02', 'superadmin@admin.com', '2026-08-21 23:08:02'),
(30, 'KJ-20260822-002', 'RM-000001', '2026-08-22', '13:15:57', 'berlangsung', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 23:15:57', 'superadmin@admin.com', '2026-08-21 23:15:57'),
(31, 'KJ-20260822-003', 'RM-000002', '2026-08-22', '13:23:45', 'berlangsung', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-21 23:23:45', 'superadmin@admin.com', '2026-08-21 23:23:45'),
(32, 'KJ-20260822-004', 'RM-000002', '2026-08-22', '18:54:28', 'berlangsung', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 04:54:28', 'superadmin@admin.com', '2026-08-22 04:54:28'),
(33, 'KJ-20260822-005', 'RM-000002', '2026-08-22', '18:56:38', 'berlangsung', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 04:56:38', 'superadmin@admin.com', '2026-08-22 04:56:38'),
(34, 'KJ-20260822-006', 'RM-000002', '2026-08-22', '18:57:00', 'berlangsung', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 04:57:00', 'superadmin@admin.com', '2026-08-22 04:57:00'),
(35, 'KJ-20260822-007', 'RM-000001', '2026-08-22', '19:02:40', 'berlangsung', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 05:02:40', 'superadmin@admin.com', '2026-08-22 05:02:40'),
(36, 'KJ-20260822-008', 'RM-000002', '2026-08-22', '19:13:00', 'berlangsung', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 05:13:00', 'superadmin@admin.com', '2026-08-22 05:13:00'),
(37, 'KJ-20260822-009', 'RM-000002', '2026-08-22', '19:13:48', 'berlangsung', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 05:13:48', 'superadmin@admin.com', '2026-08-22 05:13:48'),
(38, 'KJ-20260822-010', 'RM-000002', '2026-08-22', '19:24:55', 'berlangsung', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 05:24:55', 'superadmin@admin.com', '2026-08-22 05:24:55'),
(39, 'KJ-20260822-011', 'RM-000002', '2026-08-22', '19:26:35', 'berlangsung', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 05:26:35', 'superadmin@admin.com', '2026-08-22 05:26:35'),
(40, 'KJ-20260822-012', 'RM-000002', '2026-08-22', '19:26:58', 'berlangsung', 'Asia/Jakarta', 'superadmin@admin.com', '2026-08-22 05:26:58', 'superadmin@admin.com', '2026-08-22 05:26:58');

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
(1, 'USR000000', '[{\"label\":\"HOME\",\"icon\":\"pi pi-fw pi-home\",\"items\":[{\"label\":\"Dashboard\",\"icon\":\"pi pi-fw pi-home\",\"to\":\"/dashboard\"}]},{\"label\":\"MASTER DATA\",\"icon\":\"pi pi-fw pi-database\",\"items\":[{\"label\":\"Kategori Layanan\",\"icon\":\"pi pi-fw pi-tags\",\"to\":\"/master-data/kategori-layanan\"},{\"label\":\"Data Layanan\",\"icon\":\"pi pi-fw pi-briefcase\",\"to\":\"/master-data/layanan\"},{\"label\":\"Paket Layanan\",\"icon\":\"pi pi-fw pi-box\",\"to\":\"/master-data/paket-layanan\"},{\"label\":\"Kategori Produk\",\"icon\":\"pi pi-fw pi-tags\",\"to\":\"/master-data/kategori-produk\"},{\"label\":\"Data Produk\",\"icon\":\"pi pi-fw pi-box\",\"to\":\"/master-data/produk\"},{\"label\":\"Paket Produk\",\"icon\":\"pi pi-fw pi-inbox\",\"to\":\"/master-data/paket-produk\"},{\"label\":\"Supplier\",\"icon\":\"pi pi-fw pi-truck\",\"to\":\"/master-data/supplier\"},{\"label\":\"Karyawan\",\"icon\":\"pi pi-fw pi-users\",\"to\":\"/master-data/karyawan\"},{\"label\":\"Alat & Peralatan\",\"icon\":\"pi pi-fw pi-wrench\",\"to\":\"/master-data/alat\"}]},{\"label\":\"Pendaftaran & Antrean\",\"icon\":\"pi pi-fw pi-calendar\",\"items\":[{\"label\":\"Antrean Awal\",\"icon\":\"pi pi-fw pi-ticket\",\"to\":\"/antrian-awal\"},{\"label\":\"Pendaftaran Pasien\",\"icon\":\"pi pi-fw pi-user-plus\",\"to\":\"/pendaftaran-antrean/pendaftaran-pasien\"},{\"label\":\"Antrean\",\"icon\":\"pi pi-fw pi-list\",\"to\":\"/pendaftaran-antrean/antrean\"}]},{\"label\":\"Master Data & User\",\"icon\":\"pi pi-fw pi-cog\",\"items\":[{\"label\":\"Data Pasien\",\"icon\":\"pi pi-fw pi-user\",\"to\":\"/master-data-user/data-pasien\"},{\"label\":\"Manajemen Menu\",\"icon\":\"pi pi-fw pi-bars\",\"to\":\"/setup/navigation\"},{\"label\":\"Manajemen User\",\"icon\":\"pi pi-fw pi-users\",\"to\":\"/setup/users\"}]}]', 'UTC', '2026-08-20 11:29:37', '2026-08-20 11:29:37');

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
-- Indexes for table `mst_kabupaten`
--
ALTER TABLE `mst_kabupaten`
  ADD PRIMARY KEY (`kode`),
  ADD KEY `mst_kabupaten_kode_provinsi_index` (`kode_provinsi`);

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
-- Indexes for table `mst_kecamatan`
--
ALTER TABLE `mst_kecamatan`
  ADD PRIMARY KEY (`kode`),
  ADD KEY `mst_kecamatan_kode_kabupaten_index` (`kode_kabupaten`);

--
-- Indexes for table `mst_kelurahan`
--
ALTER TABLE `mst_kelurahan`
  ADD PRIMARY KEY (`kode`),
  ADD KEY `mst_kelurahan_kode_kecamatan_index` (`kode_kecamatan`);

--
-- Indexes for table `mst_layanan`
--
ALTER TABLE `mst_layanan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_layanan` (`kode_layanan`),
  ADD KEY `fk_layanan_kategori` (`kode_kategori_layanan`),
  ADD KEY `idx_kode_ruangan` (`kode_ruangan`);

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
  ADD UNIQUE KEY `kode_paket_layanan` (`kode_paket_layanan`),
  ADD KEY `idx_kode_ruangan` (`kode_ruangan`);

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
-- Indexes for table `mst_provinsi`
--
ALTER TABLE `mst_provinsi`
  ADD PRIMARY KEY (`kode`);

--
-- Indexes for table `mst_ruangan`
--
ALTER TABLE `mst_ruangan`
  ADD PRIMARY KEY (`id`);

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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- AUTO_INCREMENT for table `config`
--
ALTER TABLE `config`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `log`
--
ALTER TABLE `log`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=72;

--
-- AUTO_INCREMENT for table `log_perubahan`
--
ALTER TABLE `log_perubahan`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=151;

--
-- AUTO_INCREMENT for table `mst_alat`
--
ALTER TABLE `mst_alat`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `mst_detail_paket_layanan`
--
ALTER TABLE `mst_detail_paket_layanan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `mst_kategori_layanan`
--
ALTER TABLE `mst_kategori_layanan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `mst_kategori_produk`
--
ALTER TABLE `mst_kategori_produk`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `mst_layanan`
--
ALTER TABLE `mst_layanan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `mst_pasien`
--
ALTER TABLE `mst_pasien`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `mst_produk`
--
ALTER TABLE `mst_produk`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `mst_promo`
--
ALTER TABLE `mst_promo`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mst_ruangan`
--
ALTER TABLE `mst_ruangan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `mst_supplier`
--
ALTER TABLE `mst_supplier`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `trx_antrian_awal`
--
ALTER TABLE `trx_antrian_awal`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=86;

--
-- AUTO_INCREMENT for table `trx_antrian_layanan`
--
ALTER TABLE `trx_antrian_layanan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

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
