import express from "express";
const router = express.Router();

import antrianAwalIndex from "./antrian_awal/index.js";
import pendaftaranPasienIndex from "./pendaftaran_pasien/index.js";

import kategoriLayananData from "./kategori_layanan/kategori_layanan_data.js";
import kategoriLayananCreate from "./kategori_layanan/kategori_layanan_create.js";
import kategoriLayananUpdate from "./kategori_layanan/kategori_layanan_update.js";
import kategoriLayananDelete from "./kategori_layanan/kategori_layanan_delete.js";

import layananData from "./layanan/layanan_data.js";
import layananCreate from "./layanan/layanan_create.js";
import layananUpdate from "./layanan/layanan_update.js";
import layananDelete from "./layanan/layanan_delete.js";

import paketLayananData from "./paket_layanan/paket_layanan_data.js";
import paketLayananCreate from "./paket_layanan/paket_layanan_create.js";
import paketLayananUpdate from "./paket_layanan/paket_layanan_update.js";
import paketLayananDelete from "./paket_layanan/paket_layanan_delete.js";

import kategoriProdukData from "./kategori_produk/kategori_produk_data.js";
import kategoriProdukCreate from "./kategori_produk/kategori_produk_create.js";
import kategoriProdukUpdate from "./kategori_produk/kategori_produk_update.js";
import kategoriProdukDelete from "./kategori_produk/kategori_produk_delete.js";

import produkData from "./produk/produk_data.js";
import produkCreate from "./produk/produk_create.js";
import produkUpdate from "./produk/produk_update.js";
import produkDelete from "./produk/produk_delete.js";

import paketProdukData from "./paket_produk/paket_produk_data.js";
import paketProdukCreate from "./paket_produk/paket_produk_create.js";
import paketProdukUpdate from "./paket_produk/paket_produk_update.js";
import paketProdukDelete from "./paket_produk/paket_produk_delete.js";

import supplierData from "./supplier/supplier_data.js";
import supplierCreate from "./supplier/supplier_create.js";
import supplierUpdate from "./supplier/supplier_update.js";
import supplierDelete from "./supplier/supplier_delete.js";

import karyawanData from "./karyawan/karyawan_data.js";
import karyawanCreate from "./karyawan/karyawan_create.js";
import karyawanUpdate from "./karyawan/karyawan_update.js";
import karyawanDelete from "./karyawan/karyawan_delete.js";

import alatData from "./alat/alat_data.js";
import alatCreate from "./alat/alat_create.js";
import alatUpdate from "./alat/alat_update.js";
import alatDelete from "./alat/alat_delete.js";

import dokterDropdown from "./dokter_dropdown.js";
import penjaminDropdown from "./penjamin_dropdown.js";
import antrianLayananIndex from "./antrian_layanan/index.js";
import poliDropdown from "./poli_dropdown.js";
import ruanganDropdown from "./ruangan_dropdown.js";
import wilayah from "./wilayah.js";

// Dropdown & Utility (must be before "/" catch-all routers)
router.use("/wilayah", wilayah);
router.use("/ruangan-dropdown", ruanganDropdown);
router.use("/dokter-dropdown", dokterDropdown);
router.use("/penjamin-dropdown", penjaminDropdown);
router.use("/poli-dropdown", poliDropdown);

// Antrian Awal & Layanan
router.use("/", antrianAwalIndex);
router.use("/", antrianLayananIndex);

// Pendaftaran Pasien
router.use("/", pendaftaranPasienIndex);

// Kategori Layanan
router.use("/kategori-layanan-data", kategoriLayananData);
router.use("/kategori-layanan-create", kategoriLayananCreate);
router.use("/kategori-layanan-update", kategoriLayananUpdate);
router.use("/kategori-layanan-delete", kategoriLayananDelete);

// Layanan
router.use("/layanan-data", layananData);
router.use("/layanan-create", layananCreate);
router.use("/layanan-update", layananUpdate);
router.use("/layanan-delete", layananDelete);

// Paket Layanan
router.use("/paket-layanan-data", paketLayananData);
router.use("/paket-layanan-create", paketLayananCreate);
router.use("/paket-layanan-update", paketLayananUpdate);
router.use("/paket-layanan-delete", paketLayananDelete);

// Kategori Produk
router.use("/kategori-produk-data", kategoriProdukData);
router.use("/kategori-produk-create", kategoriProdukCreate);
router.use("/kategori-produk-update", kategoriProdukUpdate);
router.use("/kategori-produk-delete", kategoriProdukDelete);

// Produk
router.use("/produk-data", produkData);
router.use("/produk-create", produkCreate);
router.use("/produk-update", produkUpdate);
router.use("/produk-delete", produkDelete);

// Paket Produk
router.use("/paket-produk-data", paketProdukData);
router.use("/paket-produk-create", paketProdukCreate);
router.use("/paket-produk-update", paketProdukUpdate);
router.use("/paket-produk-delete", paketProdukDelete);

// Supplier
router.use("/supplier-data", supplierData);
router.use("/supplier-create", supplierCreate);
router.use("/supplier-update", supplierUpdate);
router.use("/supplier-delete", supplierDelete);

// Karyawan
router.use("/karyawan-data", karyawanData);
router.use("/karyawan-create", karyawanCreate);
router.use("/karyawan-update", karyawanUpdate);
router.use("/karyawan-delete", karyawanDelete);

// Alat
router.use("/alat-data", alatData);
router.use("/alat-create", alatCreate);
router.use("/alat-update", alatUpdate);
router.use("/alat-delete", alatDelete);

export default router;
