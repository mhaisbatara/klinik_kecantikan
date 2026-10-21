'use client';

import React, { useState, useEffect, useRef, useMemo } from 'react';
import { Toast } from 'primereact/toast';
import { DataTable } from 'primereact/datatable';
import { Column } from 'primereact/column';
import { Tag } from 'primereact/tag';
import { Button } from 'primereact/button';
import { Dialog } from 'primereact/dialog';
import { InputText } from 'primereact/inputtext';
import { Dropdown } from 'primereact/dropdown';
import { Password } from 'primereact/password';
import { Divider } from 'primereact/divider';
import { Checkbox } from 'primereact/checkbox';
import { IconField } from 'primereact/iconfield';
import { InputIcon } from 'primereact/inputicon';
import { ConfirmDialog, confirmDialog } from 'primereact/confirmdialog';
import { TabView, TabPanel } from 'primereact/tabview';
import { useSession } from 'next-auth/react';
import postData from '@/lib/axios/postData';
import { showError, showSuccess } from '@/lib/tools/generalTools';
import { clearUserMenuCache } from '@/lib/tools/serverTools';
import KeteranganStatus from '@/app/components/KeteranganStatus';

interface UserRecord {
  id?: number;
  user_code: string;
  username: string;
  fullname: string;
  telp: string;
  role: string;
  kode_cabang?: string | null;
  nama_cabang?: string | null;
  status: string | number;
  created_at?: string;
}

const SUPERADMIN_ROLE_OPTIONS = [
  { label: 'Owner / Manager', value: 'owner' },
  { label: 'Admin', value: 'admin' },
  { label: 'Dokter', value: 'dokter' },
  { label: 'Beautician / Terapis', value: 'beautician' },
  { label: 'Kasir', value: 'kasir' },
  { label: 'Warehouse / Logistik', value: 'warehouse' },
  { label: 'Superadmin / IT', value: 'superadmin' },
];

const MANAGER_ROLE_OPTIONS = [
  { label: 'Admin', value: 'admin' },
  { label: 'Beautician / Terapis', value: 'beautician' },
  { label: 'Kasir', value: 'kasir' },
  { label: 'Warehouse / Logistik', value: 'warehouse' },
  { label: 'Dokter', value: 'dokter' },
];

const STATUS_OPTIONS = [
  { label: 'Aktif', value: '1' },
  { label: 'Tidak Aktif', value: '0' },
];

interface PermissionModule {
  id: string;
  label: string;
  to: string;
  icon: string;
  desc: string;
}

interface PermissionCategory {
  category: string;
  icon: string;
  items: PermissionModule[];
}

const AVAILABLE_MODULE_CATEGORIES: PermissionCategory[] = [
  {
    category: 'Home & Dashboard',
    icon: 'pi pi-home',
    items: [
      { id: 'dashboard', label: 'Dashboard Utama', to: '/dashboard', icon: 'pi pi-home', desc: 'Ringkasan statistik & performa operasional klinik' },
      { id: 'antrean_ruangan', label: 'Dashboard Ruangan', to: '/pendaftaran-antrean/antrean', icon: 'pi pi-home', desc: 'Monitoring dan analisis antrean seluruh ruangan klinik' },
      { id: 'cek_jadwal_ruangan', label: 'Dashboard Jadwal', to: '/dashboard/jadwal-ruangan', icon: 'pi pi-home', desc: 'Cek cepat jadwal shift kerja dokter & karyawan' },
    ]
  },
  {
    category: 'Pendaftaran & Pasien',
    icon: 'pi pi-calendar',
    items: [
      { id: 'antrian_awal', label: 'Antrean Pendaftaran', to: '/antrian-awal', icon: 'pi pi-ticket', desc: 'Display pemanggilan nomor tiket antrean awal' },
      { id: 'registrasi_pasien', label: 'Pasien Baru', to: '/pendaftaran-antrean/registrasi-pasien', icon: 'pi pi-user-plus', desc: 'Pendaftaran dan registrasi identitas pasien baru' },
      { id: 'pendaftaran_pasien', label: 'Pendaftaran Kunjungan & Booking', to: '/pendaftaran-antrean/pendaftaran-pasien', icon: 'pi pi-calendar', desc: 'Check-in kunjungan harian & booking konsultasi/layanan' },
      { id: 'data_pasien', label: 'Data Pasien', to: '/master-data-user/data-pasien', icon: 'pi pi-user', desc: 'Katalog profil lengkap & riwayat data pasien' },
    ]
  },
  {
    category: 'Layanan & Tindakan',
    icon: 'pi pi-sparkles',
    items: [
      { id: 'tindakan', label: 'Tindakan Perawatan', to: '/pendaftaran-antrean/antrean?type=layanan', icon: 'pi pi-sparkles', desc: 'Antrean & pengerjaan tindakan ruangan estetika (dengan filter hak ruangan)' },
      { id: 'konsul', label: 'Konsultasi Medis', to: '/pendaftaran-antrean/antrean?type=konsul', icon: 'pi pi-comments', desc: 'Antrean & konsultasi anamnesa dokter (dengan filter hak ruangan)' },
      { id: 'jadwal_karyawan_layanan', label: 'Jadwal Karyawan (Operasional)', to: '/pendaftaran-antrean/jadwal-karyawan', icon: 'pi pi-calendar', desc: 'Melihat jadwal shift tugas harian dokter, terapis & staf klinik' },
    ]
  },
  {
    category: 'Kasir & Pembayaran',
    icon: 'pi pi-calculator',
    items: [
      { id: 'kasir', label: 'Kasir Pembayaran', to: '/kasir', icon: 'pi pi-calculator', desc: 'Transaksi pembayaran kasir, invoice, mutasi kas, dan pelunasan' },
      { id: 'tracking_kasir', label: 'Tracking Kas Kasir', to: '/transaksi/tracking-kasir', icon: 'pi pi-wallet', desc: 'Monitoring kas keluar-masuk, modal awal & rekonsiliasi shift setiap kasir' },
    ]
  },
  {
    category: 'Master Data - Layanan & Treatment',
    icon: 'pi pi-briefcase',
    items: [
      { id: 'kategori_layanan', label: 'Kategori Layanan', to: '/master-data/kategori-layanan', icon: 'pi pi-tags', desc: 'Master kategori tindakan dan treatment' },
      { id: 'layanan', label: 'Data Layanan', to: '/master-data/layanan', icon: 'pi pi-briefcase', desc: 'Katalog tindakan dan treatment klinik' },
      { id: 'paket_layanan', label: 'Paket Layanan', to: '/master-data/paket-layanan', icon: 'pi pi-box', desc: 'Paket bundling layanan treatment estetika' },
    ]
  },
  {
    category: 'Master Data - Produk & Inventori',
    icon: 'pi pi-box',
    items: [
      { id: 'kategori_produk', label: 'Kategori Produk', to: '/master-data/kategori-produk', icon: 'pi pi-tags', desc: 'Kategori produk skincare, obat, dan bahan medis' },
      { id: 'produk', label: 'Data Produk', to: '/master-data/produk', icon: 'pi pi-box', desc: 'Katalog produk & master harga jual/beli' },
      { id: 'paket_produk', label: 'Paket Produk', to: '/master-data/paket-produk', icon: 'pi pi-inbox', desc: 'Bundling paket produk skincare' },
      { id: 'inventori', label: 'Stok Inventori', to: '/master-data/inventori', icon: 'pi pi-box', desc: 'Monitoring saldo stok, mutasi & kartu stok gudang' },
      { id: 'supplier', label: 'Supplier & Vendor', to: '/master-data/supplier', icon: 'pi pi-truck', desc: 'Daftar vendor dan supplier pengadaan klinik' },
      { id: 'alat', label: 'Alat & Peralatan', to: '/master-data/alat', icon: 'pi pi-wrench', desc: 'Daftar mesin estetika dan peralatan medis' },
    ]
  },
  {
    category: 'Master Data - Promo & Diskon',
    icon: 'pi pi-percentage',
    items: [
      { id: 'promo', label: 'Data Promo', to: '/master-data/promo', icon: 'pi pi-percentage', desc: 'Master daftar program promo & potongan harga klinik' },
      { id: 'detail_promo', label: 'Detail Promo', to: '/master-data/detail-promo', icon: 'pi pi-tags', desc: 'Ketentuan dan rincian diskon promo klinik' },
    ]
  },
  {
    category: 'Master Data - Karyawan & Ruangan',
    icon: 'pi pi-users',
    items: [
      { id: 'karyawan', label: 'Data Karyawan', to: '/master-data/karyawan', icon: 'pi pi-users', desc: 'Data profil staf medis, dokter, dan terapis klinik' },
      { id: 'jadwal_karyawan', label: 'Jadwal Karyawan (Master Shift)', to: '/master-data/jadwal-karyawan', icon: 'pi pi-calendar-times', desc: 'Master jadwal shift kerja & praktik dokter/staf' },
      { id: 'ruangan', label: 'Data Ruangan', to: '/master-data/ruangan', icon: 'pi pi-building', desc: 'Master data ruangan perawatan, tindakan, dan konsultasi' },
    ]
  },
  {
    category: 'Laporan & Rekam Medis',
    icon: 'pi pi-chart-bar',
    items: [
      { id: 'lap_penjualan', label: 'Laporan Penjualan', to: '/riwayat/rekam-medis?tab=penjualan', icon: 'pi pi-shopping-cart', desc: 'Rekap transaksi kasir, invoice, dan total omzet penjualan' },
      { id: 'lap_treatment', label: 'Laporan Treatment', to: '/riwayat/rekam-medis?tab=treatment', icon: 'pi pi-sparkles', desc: 'Pengerjaan tindakan medis, estetika, dan utilisasi ruangan' },
      { id: 'lap_produk', label: 'Laporan Produk', to: '/riwayat/rekam-medis?tab=produk', icon: 'pi pi-box', desc: 'Volume dan rekap nilai penjualan produk skincare klinik' },
      { id: 'lap_paket', label: 'Laporan Paket', to: '/riwayat/rekam-medis?tab=paket', icon: 'pi pi-tags', desc: 'Rekap penjualan bundling paket treatment dan produk' },
      { id: 'lap_pasien', label: 'Laporan Pasien', to: '/riwayat/rekam-medis?tab=pasien', icon: 'pi pi-users', desc: 'Demografi, pertumbuhan pasien baru & riwayat pasien lama' },
      { id: 'lap_kunjungan', label: 'Laporan Kunjungan', to: '/riwayat/rekam-medis?tab=kunjungan', icon: 'pi pi-calendar', desc: 'Statistik kedatangan dan volume kunjungan harian/bulanan' },
      { id: 'lap_dokter', label: 'Laporan Dokter', to: '/riwayat/rekam-medis?tab=dokter', icon: 'pi pi-heart', desc: 'Performa konsultasi & volume penanganan pasien oleh dokter' },
      { id: 'lap_beautician', label: 'Laporan Beautician', to: '/riwayat/rekam-medis?tab=beautician', icon: 'pi pi-star', desc: 'Kinerja pengerjaan treatment oleh terapis/beautician' },
      { id: 'lap_inventory', label: 'Laporan Inventory', to: '/riwayat/rekam-medis?tab=inventory', icon: 'pi pi-database', desc: 'Saldo stok gudang, mutasi masuk/keluar, dan kartu stok' },
      { id: 'lap_keuangan', label: 'Laporan Keuangan', to: '/riwayat/rekam-medis?tab=keuangan', icon: 'pi pi-wallet', desc: 'Ringkasan laba kotor, kas masuk-keluar & metode bayar' },
      { id: 'lap_voucher', label: 'Laporan Voucher', to: '/riwayat/rekam-medis?tab=voucher', icon: 'pi pi-ticket', desc: 'Penggunaan voucher diskon promo dan potongan harga transaksi' },
      { id: 'lap_rme', label: 'Laporan RME (Rekam Medis)', to: '/riwayat/rekam-medis?tab=rekam_medis', icon: 'pi pi-file-edit', desc: 'Riwayat catatan medis, diagnosis dokter, dan SOAP pasien' },
      { id: 'lap_membership', label: 'Laporan Membership', to: '/riwayat/rekam-medis?tab=membership', icon: 'pi pi-id-card', desc: 'Data member aktif, tingkat tier loyalitas, dan status membership' },
      { id: 'lap_appointment', label: 'Laporan Appointment', to: '/riwayat/rekam-medis?tab=appointment', icon: 'pi pi-clock', desc: 'Rekap jadwal reservasi & status booking kunjungan pasien' },
      { id: 'lap_komisi', label: 'Laporan Komisi', to: '/riwayat/rekam-medis?tab=komisi', icon: 'pi pi-percentage', desc: 'Perhitungan komisi dan insentif pengerjaan tindakan staf/nakes' },
      { id: 'lap_stok_opname', label: 'Laporan Stok Opname', to: '/riwayat/rekam-medis?tab=stok_opname', icon: 'pi pi-check-square', desc: 'Hasil audit fisik inventori vs saldo pencatatan sistem' },
      { id: 'lap_pembelian', label: 'Laporan Pembelian', to: '/riwayat/rekam-medis?tab=pembelian', icon: 'pi pi-truck', desc: 'Pengadaan produk dan bahan medis dari vendor/supplier' },
      { id: 'lap_expired', label: 'Laporan Expired', to: '/riwayat/rekam-medis?tab=expired', icon: 'pi pi-exclamation-triangle', desc: 'Monitoring obat dan produk mendekati tanggal kedaluwarsa' },
      { id: 'lap_deposit', label: 'Laporan Deposit', to: '/riwayat/rekam-medis?tab=deposit', icon: 'pi pi-money-bill', desc: 'Mutasi saldo tabungan deposit pasien dan pemakaiannya' },
      { id: 'lap_crm', label: 'Laporan CRM', to: '/riwayat/rekam-medis?tab=crm', icon: 'pi pi-comments', desc: 'Log interaksi follow-up, kepuasan, dan pengingat jadwal pasien' },
    ]
  },
  {
    category: 'Pengaturan Sistem & Cabang',
    icon: 'pi pi-cog',
    items: [
      { id: 'monitoring_cabang', label: 'Monitoring Cabang', to: '/setup/monitoring-cabang', icon: 'pi pi-chart-line', desc: 'Monitoring operasional dan performa multi cabang klinik' },
      { id: 'cabang', label: 'Manajemen Cabang', to: '/setup/cabang', icon: 'pi pi-building', desc: 'Master data cabang klinik kecantikan' },
      { id: 'pengaturan_klinik', label: 'Pengaturan Klinik', to: '/setup/config', icon: 'pi pi-sliders-h', desc: 'Konfigurasi umum identitas, logo & profil klinik' },
      { id: 'manajemen_user', label: 'Manajemen User', to: '/setup/users', icon: 'pi pi-users', desc: 'Kelola akun staf, reset password, dan hak akses modul' },
      { id: 'manajemen_role', label: 'Manajemen Role', to: '/setup/navigation', icon: 'pi pi-shield', desc: 'Daftar peran dan tanggung jawab jabatan staf' },
    ]
  },
];

const ALL_SYSTEM_MODULE_PATHS: string[] = AVAILABLE_MODULE_CATEGORIES.flatMap((c) => c.items.map((it) => it.to));

const ROLE_PRESET_PATHS: Record<string, string[]> = {
  admin: [
    '/dashboard',
    '/antrian-awal',
    '/pendaftaran-antrean/registrasi-pasien',
    '/pendaftaran-antrean/pendaftaran-pasien',
    '/master-data-user/data-pasien',
    '/pendaftaran-antrean/jadwal-karyawan',
    '/riwayat/rekam-medis?tab=pasien',
    '/riwayat/rekam-medis?tab=kunjungan',
    '/riwayat/rekam-medis?tab=appointment',
    '/riwayat/rekam-medis?tab=membership',
    '/transaksi/tracking-kasir',
  ],
  beautician: [
    '/dashboard',
    '/pendaftaran-antrean/antrean?type=layanan',
    '/pendaftaran-antrean/antrean',
    '/pendaftaran-antrean/jadwal-karyawan',
    '/master-data/layanan',
    '/master-data/jadwal-karyawan',
    '/riwayat/rekam-medis?tab=beautician',
    '/riwayat/rekam-medis?tab=treatment',
  ],
  kasir: [
    '/dashboard',
    '/kasir',
    '/antrian-awal',
    '/master-data-user/data-pasien',
    '/master-data/promo',
    '/master-data/detail-promo',
    '/riwayat/rekam-medis?tab=penjualan',
    '/riwayat/rekam-medis?tab=keuangan',
    '/riwayat/rekam-medis?tab=voucher',
    '/riwayat/rekam-medis?tab=deposit',
    '/riwayat/rekam-medis?tab=pasien',
  ],
  warehouse: [
    '/dashboard',
    '/master-data/kategori-produk',
    '/master-data/produk',
    '/master-data/paket-produk',
    '/master-data/inventori',
    '/master-data/supplier',
    '/master-data/alat',
    '/riwayat/rekam-medis?tab=inventory',
    '/riwayat/rekam-medis?tab=stok_opname',
    '/riwayat/rekam-medis?tab=pembelian',
    '/riwayat/rekam-medis?tab=expired',
    '/riwayat/rekam-medis?tab=produk',
  ],
  dokter: [
    '/dashboard',
    '/pendaftaran-antrean/antrean?type=konsul',
    '/pendaftaran-antrean/antrean?type=layanan',
    '/pendaftaran-antrean/antrean',
    '/pendaftaran-antrean/jadwal-karyawan',
    '/master-data-user/data-pasien',
    '/master-data/layanan',
    '/master-data/paket-layanan',
    '/master-data/jadwal-karyawan',
    '/riwayat/rekam-medis?tab=dokter',
    '/riwayat/rekam-medis?tab=rekam_medis',
    '/riwayat/rekam-medis?tab=pasien',
    '/riwayat/rekam-medis?tab=kunjungan',
    '/riwayat/rekam-medis?tab=treatment',
  ],
  owner: ALL_SYSTEM_MODULE_PATHS,
  manager: ALL_SYSTEM_MODULE_PATHS,
  superadmin: ALL_SYSTEM_MODULE_PATHS,
};

const buildMenuFromSelectedPaths = (
  selectedPaths: Set<string>,
  selectedTindakanRooms: Set<string>,
  selectedKonsulRooms: Set<string>,
  tindakanRooms: any[],
  konsulRooms: any[]
) => {
  const resultMenu: any[] = [];

  // 1. HOME
  const homeCategory = AVAILABLE_MODULE_CATEGORIES.find((c) => c.category === 'Home & Dashboard');
  const homeMatches = (homeCategory?.items || []).filter((it) => selectedPaths.has(it.to));
  if (homeMatches.length > 0) {
    resultMenu.push({
      label: 'HOME',
      icon: 'pi pi-fw pi-home',
      items: homeMatches.map((it) => ({
        label: it.label,
        icon: it.icon,
        to: it.to,
      })),
    });
  }

  // 2. MASTER DATA (Kumpulkan semua modul dari kategori Master Data)
  const masterCategories = AVAILABLE_MODULE_CATEGORIES.filter((c) => c.category.startsWith('Master Data'));
  const allMasterMatches: any[] = [];
  masterCategories.forEach((cat) => {
    cat.items.forEach((it) => {
      if (selectedPaths.has(it.to)) {
        allMasterMatches.push({
          label: it.label,
          icon: it.icon,
          to: it.to,
        });
      }
    });
  });
  if (allMasterMatches.length > 0) {
    resultMenu.push({
      label: 'MASTER DATA',
      icon: 'pi pi-fw pi-database',
      items: allMasterMatches,
    });
  }

  // 3. PENDAFTARAN & PASIEN
  const pendaftaranCat = AVAILABLE_MODULE_CATEGORIES.find((c) => c.category === 'Pendaftaran & Pasien');
  const pendaftaranMatches = (pendaftaranCat?.items || []).filter((it) => selectedPaths.has(it.to));
  if (pendaftaranMatches.length > 0) {
    resultMenu.push({
      label: 'Pendaftaran & Pasien',
      icon: 'pi pi-calendar',
      items: pendaftaranMatches.map((it) => ({
        label: it.label,
        icon: it.icon,
        to: it.to,
      })),
    });
  }

  // 4. LAYANAN & TINDAKAN
  const layananCat = AVAILABLE_MODULE_CATEGORIES.find((c) => c.category === 'Layanan & Tindakan');
  const layananMatches = (layananCat?.items || []).filter((it) => selectedPaths.has(it.to));
  if (layananMatches.length > 0) {
    resultMenu.push({
      label: 'LAYANAN',
      icon: 'pi pi-fw pi-sparkles',
      items: layananMatches.map((it) => {
        const itemObj: any = {
          label: it.label,
          icon: it.icon,
          to: it.to,
        };

        // Rincian Ruangan Tindakan
        if (it.to.includes('type=layanan')) {
          const isAll = selectedTindakanRooms.size === 0 || selectedTindakanRooms.size === tindakanRooms.length;
          itemObj.allowed_ruangan = isAll ? [] : Array.from(selectedTindakanRooms);
          const activeRooms = tindakanRooms.filter((r) => isAll || selectedTindakanRooms.has(r.kode_ruangan));
          if (activeRooms.length > 0) {
            itemObj.items = activeRooms.map((r) => ({
              label: r.nama_ruangan,
              icon: 'pi pi-building',
              to: `/pendaftaran-antrean/antrean?type=layanan&ruangan=${r.kode_ruangan}`,
            }));
          }
        }

        // Rincian Ruangan Konsultasi
        if (it.to.includes('type=konsul')) {
          const isAll = selectedKonsulRooms.size === 0 || selectedKonsulRooms.size === konsulRooms.length;
          itemObj.allowed_ruangan = isAll ? [] : Array.from(selectedKonsulRooms);
          const activeRooms = konsulRooms.filter((r) => isAll || selectedKonsulRooms.has(r.kode_ruangan));
          if (activeRooms.length > 0) {
            itemObj.items = activeRooms.map((r) => ({
              label: r.nama_ruangan,
              icon: 'pi pi-building',
              to: `/pendaftaran-antrean/antrean?type=konsul&ruangan=${r.kode_ruangan}`,
            }));
          }
        }

        return itemObj;
      }),
    });
  }

  // 5. KASIR & PEMBAYARAN
  const kasirCat = AVAILABLE_MODULE_CATEGORIES.find((c) => c.category === 'Kasir & Pembayaran');
  const kasirMatches = (kasirCat?.items || []).filter((it) => selectedPaths.has(it.to));
  if (kasirMatches.length > 0) {
    resultMenu.push({
      label: 'TRANSAKSI & KASIR',
      icon: 'pi pi-fw pi-calculator',
      items: kasirMatches.map((it) => ({
        label: it.label,
        icon: it.icon,
        to: it.to,
      })),
    });
  }

  // 6. LAPORAN & REKAM MEDIS
  const laporanCat = AVAILABLE_MODULE_CATEGORIES.find((c) => c.category === 'Laporan & Rekam Medis');
  const laporanMatches = (laporanCat?.items || []).filter((it) => selectedPaths.has(it.to));
  if (laporanMatches.length > 0) {
    resultMenu.push({
      label: 'LAPORAN',
      icon: 'pi pi-fw pi-chart-bar',
      to: '/riwayat/rekam-medis',
      items: laporanMatches.map((it) => ({
        label: it.label,
        icon: it.icon,
        to: it.to,
      })),
    });
  }

  // 7. PENGATURAN KLINIK
  const pengaturanCat = AVAILABLE_MODULE_CATEGORIES.find((c) => c.category === 'Pengaturan Sistem & Cabang');
  const pengaturanMatches = (pengaturanCat?.items || []).filter((it) => selectedPaths.has(it.to));
  if (pengaturanMatches.length > 0) {
    resultMenu.push({
      label: 'PENGATURAN KLINIK',
      icon: 'pi pi-fw pi-cog',
      items: pengaturanMatches.map((it) => ({
        label: it.label,
        icon: it.icon,
        to: it.to,
      })),
    });
  }

  return resultMenu;
};

const getRoleSeverity = (role: string): 'success' | 'info' | 'warning' | 'danger' | 'secondary' => {
  const r = (role || '').toLowerCase();
  if (r.includes('owner') || r.includes('manager')) return 'info';
  if (r.includes('dokter')) return 'danger';
  if (r.includes('beautician') || r.includes('terapis')) return 'warning';
  if (r.includes('kasir')) return 'success';
  if (r.includes('warehouse') || r.includes('gudang')) return 'secondary';
  return 'info';
};

export default function ManajemenUserPage() {
  const { data: session } = useSession();
  const isSuperAdmin = (session?.user?.role || '').toLowerCase() === 'superadmin';
  const roleOptions = isSuperAdmin ? SUPERADMIN_ROLE_OPTIONS : MANAGER_ROLE_OPTIONS;
  const toast = useRef<Toast>(null);

  const [users, setUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [totalRecords, setTotalRecords] = useState<number>(0);
  const [page, setPage] = useState<number>(1);
  const [rows, setRows] = useState<number>(10);
  const [keyword, setKeyword] = useState<string>('');
  const [selectedRole, setSelectedRole] = useState<string | null>(null);
  const [selectedCabang, setSelectedCabang] = useState<string | null>(null);
  const [branchOptions, setBranchOptions] = useState<any[]>([]);
  const [selectedRows, setSelectedRows] = useState<any[]>([]);

  // Modal Create / Edit
  const [showModal, setShowModal] = useState<boolean>(false);
  const [activeTab, setActiveTab] = useState<number>(0);
  const [isEdit, setIsEdit] = useState<boolean>(false);
  const [formData, setFormData] = useState<any>({
    user_code: '',
    fullname: '',
    username: '',
    telp: '',
    role: 'beautician',
    kode_cabang: null,
    password: '',
    status: '1',
  });
  const [formLoading, setFormLoading] = useState<boolean>(false);

  // Hak Akses (Permissions) State
  const [selectedPermissions, setSelectedPermissions] = useState<Set<string>>(new Set());
  const [permissionFilter, setPermissionFilter] = useState<string>('');
  const [loadingPermissions, setLoadingPermissions] = useState<boolean>(false);

  // Master Karyawan & Ruangan State
  const [karyawanList, setKaryawanList] = useState<any[]>([]);
  const [selectedKaryawanId, setSelectedKaryawanId] = useState<string | null>(null);
  const [ruanganList, setRuanganList] = useState<any[]>([]);
  const [selectedTindakanRooms, setSelectedTindakanRooms] = useState<Set<string>>(new Set());
  const [selectedKonsulRooms, setSelectedKonsulRooms] = useState<Set<string>>(new Set());

  // Filter ruangan per cabang sesuai cabang aktif dari akun pengguna
  const activeBranchCode = useMemo(() => {
    return formData.kode_cabang || session?.user?.kode_cabang || branchOptions.find((b) => b.value)?.value || 'CBG-001';
  }, [formData.kode_cabang, session?.user?.kode_cabang, branchOptions]);

  const branchRuanganList = useMemo(() => {
    if (!activeBranchCode) return ruanganList;
    return ruanganList.filter((r) => r.kode_cabang === activeBranchCode);
  }, [ruanganList, activeBranchCode]);

  const tindakanRooms = useMemo(
    () => branchRuanganList.filter((r) => !r.is_konsultasi || r.is_konsultasi === 0),
    [branchRuanganList]
  );
  const konsulRooms = useMemo(
    () => branchRuanganList.filter((r) => r.is_konsultasi === 1),
    [branchRuanganList]
  );

  const fetchBranches = async () => {
    try {
      const res = await postData('/master/cabang-data', {});
      if (['00', '0000'].includes(res?.data?.status)) {
        const list = res.data.data || [];
        setBranchOptions([
          { label: 'Semua Cabang / Pusat', value: null },
          ...list.map((b: any) => ({
            label: `${b.kode_cabang} - ${b.nama_cabang}`,
            value: b.kode_cabang,
          })),
        ]);
      }
    } catch (_) {}
  };

  const fetchKaryawan = async () => {
    try {
      const payload: any = {};
      if (!isSuperAdmin && session?.user?.kode_cabang) {
        payload.kode_cabang = session.user.kode_cabang;
      }
      const res = await postData('/master/karyawan-data', payload);
      if (['00', '0000'].includes(res?.data?.status)) {
        setKaryawanList(res.data.data || []);
      }
    } catch (_) {}
  };

  const fetchRuangan = async (targetCabang?: string | null): Promise<any[]> => {
    try {
      const branchToUse = targetCabang || formData.kode_cabang || session?.user?.kode_cabang || 'CBG-001';
      const payload: any = {};
      if (branchToUse) {
        payload.kode_cabang = branchToUse;
      }
      const res = await postData('/master/ruangan-dropdown', payload);
      if (res?.data?.data) {
        const mapped = (res.data.data || []).map((r: any) => ({
          ...r,
          kode_cabang: r.kode_cabang || branchToUse,
        }));
        setRuanganList(mapped);
        return mapped;
      }
    } catch (_) {}
    return [];
  };

  const fetchUsers = async () => {
    setLoading(true);
    try {
      const payload: any = {
        first: (page - 1) * rows,
        rows: rows,
      };
      if (keyword) payload.search = keyword;
      if (selectedRole) payload.role = selectedRole;

      // Jika Manager, kunci query ke cabang sendiri
      if (!isSuperAdmin && session?.user?.kode_cabang) {
        payload.kode_cabang = session.user.kode_cabang;
      } else if (selectedCabang) {
        payload.kode_cabang = selectedCabang;
      }

      const res = await postData('/setup/user-login/user-data', payload);
      if (['00', '0000', 200].includes(res?.data?.status) || res?.status === 200) {
        setUsers(res.data.data || []);
        setTotalRecords(res.data.total_data ?? (res.data.data ? res.data.data.length : 0));
      } else {
        showError(toast, res?.data?.message || 'Gagal memuat data pengguna');
      }
    } catch (err: any) {
      showError(toast, err?.message || 'Gagal terhubung ke server');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBranches();
    fetchKaryawan();
    fetchRuangan();
  }, []);

  useEffect(() => {
    fetchUsers();
  }, [page, rows, keyword, selectedRole, selectedCabang]);

  const handleSelectKaryawan = async (kodeKaryawan: string | null) => {
    setSelectedKaryawanId(kodeKaryawan);
    if (!kodeKaryawan) return;
    const emp = karyawanList.find((k) => k.kode_karyawan === kodeKaryawan);
    if (!emp) return;

    let mappedRole = 'admin';
    const jab = (emp.jabatan || '').toLowerCase();
    if (jab === 'admin' || (jab.includes('admin') && !jab.includes('superadmin')) || jab.includes('resepsionis') || jab.includes('front')) {
      mappedRole = 'admin';
    } else if (jab.includes('warehouse') || jab.includes('logistik') || jab.includes('gudang') || jab.includes('apoteker')) {
      mappedRole = 'warehouse';
    } else if (jab.includes('dokter')) {
      mappedRole = 'dokter';
    } else if (jab.includes('kasir')) {
      mappedRole = 'kasir';
    } else if (jab.includes('owner') || jab.includes('manager')) {
      mappedRole = 'owner';
    } else if (jab.includes('superadmin') || jab.includes('it')) {
      mappedRole = 'superadmin';
    } else if (jab.includes('beautician') || jab.includes('terapis') || jab.includes('perawat')) {
      mappedRole = 'beautician';
    }

    const empEmail = emp.email || `${(emp.nama || 'staf').toLowerCase().replace(/[^a-z0-9]/g, '.')}@klinik.com`;

    const targetCabang = emp.kode_cabang || formData.kode_cabang || session?.user?.kode_cabang || 'CBG-001';

    setFormData((prev: any) => ({
      ...prev,
      fullname: emp.nama || '',
      username: empEmail,
      telp: emp.no_hp || '',
      role: mappedRole,
      kode_karyawan: emp.kode_karyawan,
      kode_cabang: targetCabang,
    }));

    const branchRooms = await fetchRuangan(targetCabang);
    const roomsToUse = branchRooms && branchRooms.length > 0 ? branchRooms : ruanganList.filter((r: any) => r.kode_cabang === targetCabang);
    const empTindakan = roomsToUse.filter((r: any) => !r.is_konsultasi || r.is_konsultasi === 0);
    const empKonsul = roomsToUse.filter((r: any) => r.is_konsultasi === 1);

    if (mappedRole === 'superadmin') {
      const all = new Set<string>();
      AVAILABLE_MODULE_CATEGORIES.forEach((cat) => {
        cat.items.forEach((it) => all.add(it.to));
      });
      setSelectedPermissions(all);
      setSelectedTindakanRooms(new Set(empTindakan.map((r: any) => r.kode_ruangan)));
      setSelectedKonsulRooms(new Set(empKonsul.map((r: any) => r.kode_ruangan)));
    } else {
      const preset = ROLE_PRESET_PATHS[mappedRole] || (mappedRole === 'manager' ? ROLE_PRESET_PATHS['owner'] : []);
      setSelectedPermissions(new Set(preset));

      if (mappedRole === 'beautician' || mappedRole === 'dokter') {
        setSelectedTindakanRooms(new Set(empTindakan.map((r: any) => r.kode_ruangan)));
      } else {
        setSelectedTindakanRooms(new Set());
      }
      if (mappedRole === 'dokter') {
        setSelectedKonsulRooms(new Set(empKonsul.map((r: any) => r.kode_ruangan)));
      } else {
        setSelectedKonsulRooms(new Set());
      }
    }
  };

  const handleOpenCreate = async () => {
    setIsEdit(false);
    setActiveTab(0);
    setSelectedKaryawanId(null);
    const defaultRole = isSuperAdmin ? 'owner' : 'beautician';
    const initialCabang = session?.user?.kode_cabang || branchOptions.find((b) => b.value)?.value || 'CBG-001';
    setFormData({
      user_code: '',
      fullname: '',
      username: '',
      telp: '',
      role: defaultRole,
      kode_cabang: initialCabang,
      password: '',
      status: '1',
      kode_karyawan: null,
    });
    const preset = ROLE_PRESET_PATHS[defaultRole] || [];
    setSelectedPermissions(new Set(preset));
    const branchRooms = await fetchRuangan(initialCabang);
    const roomsToUse = branchRooms && branchRooms.length > 0 ? branchRooms : ruanganList.filter((r: any) => r.kode_cabang === initialCabang);
    const initialTindakan = roomsToUse.filter((r: any) => !r.is_konsultasi || r.is_konsultasi === 0);
    const initialKonsul = roomsToUse.filter((r: any) => r.is_konsultasi === 1);
    setSelectedTindakanRooms(new Set(initialTindakan.map((r: any) => r.kode_ruangan)));
    setSelectedKonsulRooms(new Set(initialKonsul.map((r: any) => r.kode_ruangan)));
    setPermissionFilter('');
    setShowModal(true);
  };

  const handleOpenEdit = async (u: UserRecord) => {
    const isTargetProtected = ['superadmin', 'owner', 'manager'].includes(String(u.role || '').toLowerCase());
    if (!isSuperAdmin && isTargetProtected) {
      showError(toast, 'Akses ditolak: Hanya Superadmin yang berhak mengedit data atau hak akses akun ini.');
      return;
    }

    setIsEdit(true);
    setActiveTab(0);
    const matchedKaryawan = karyawanList.find(
      (k) => k.kode_user === u.user_code || k.email === u.username
    );
    setSelectedKaryawanId(matchedKaryawan ? matchedKaryawan.kode_karyawan : null);

    const userCabang = u.kode_cabang || session?.user?.kode_cabang || branchOptions.find((b) => b.value)?.value || 'CBG-001';

    setFormData({
      user_code: u.user_code,
      fullname: u.fullname || '',
      username: u.username || '',
      telp: u.telp || '',
      role: u.role || 'beautician',
      kode_cabang: userCabang,
      password: '',
      status: String(u.status) === '1' || u.status === 1 ? '1' : '0',
      kode_karyawan: matchedKaryawan ? matchedKaryawan.kode_karyawan : null,
    });
    setPermissionFilter('');
    setShowModal(true);
    setLoadingPermissions(true);

    const branchRooms = await fetchRuangan(userCabang);
    const roomsToUse = branchRooms && branchRooms.length > 0 ? branchRooms : ruanganList.filter((r: any) => r.kode_cabang === userCabang);
    const targetBranchTindakan = roomsToUse.filter((r: any) => !r.is_konsultasi || r.is_konsultasi === 0);
    const targetBranchKonsul = roomsToUse.filter((r: any) => r.is_konsultasi === 1);

    // Jika akun adalah Superadmin: Hak akses otomatis terkunci penuh tanpa bisa diubah-ubah
    if (String(u.role || '').toLowerCase() === 'superadmin' || u.user_code === 'USR000000') {
      const allPaths = new Set<string>();
      AVAILABLE_MODULE_CATEGORIES.forEach((cat) => {
        cat.items.forEach((it) => allPaths.add(it.to));
      });
      setSelectedPermissions(allPaths);
      setSelectedTindakanRooms(new Set(targetBranchTindakan.map((r: any) => r.kode_ruangan)));
      setSelectedKonsulRooms(new Set(targetBranchKonsul.map((r: any) => r.kode_ruangan)));
      setLoadingPermissions(false);
      return;
    }

    try {
      const resNav = await postData('/setup/nav/user-data', { user_code: u.user_code });
      if (['00', '0000'].includes(resNav?.data?.status) && resNav.data.data) {
        const paths = new Set<string>();
        let loadedTindakanRooms = new Set<string>();
        let loadedKonsulRooms = new Set<string>();
        let hasTindakanConfig = false;
        let hasKonsulConfig = false;

        const extractPaths = (items: any[]) => {
          if (!items || !Array.isArray(items)) return;
          items.forEach((it) => {
            if (it.to) paths.add(it.to);
            if (it.to?.includes('type=layanan')) {
              hasTindakanConfig = true;
              if (Array.isArray(it.allowed_ruangan) && it.allowed_ruangan.length > 0) {
                loadedTindakanRooms = new Set(it.allowed_ruangan);
              }
            }
            if (it.to?.includes('type=konsul')) {
              hasKonsulConfig = true;
              if (Array.isArray(it.allowed_ruangan) && it.allowed_ruangan.length > 0) {
                loadedKonsulRooms = new Set(it.allowed_ruangan);
              }
            }
            if (it.items) extractPaths(it.items);
          });
        };
        extractPaths(resNav.data.data);

        // Kompatibilitas data legacy: Jika user sebelumnya memiliki rute umum '/riwayat/rekam-medis'
        // tanpa spesifik tab '?tab=...', ekspansi otomatis ke modul laporan sesuai rolenya agar checkbox tercentang
        const hasGranularReport = Array.from(paths).some((p) => p.startsWith('/riwayat/rekam-medis?tab='));
        if (paths.has('/riwayat/rekam-medis') && !hasGranularReport) {
          const reportCategory = AVAILABLE_MODULE_CATEGORIES.find((c) => c.category === 'Laporan & Rekam Medis');
          if (reportCategory) {
            const role = (u.role || '').toLowerCase();
            if (['owner', 'manager', 'superadmin'].includes(role)) {
              reportCategory.items.forEach((it) => paths.add(it.to));
            } else {
              const preset = ROLE_PRESET_PATHS[role] || [];
              const presetReports = preset.filter((p) => p.startsWith('/riwayat/rekam-medis?tab='));
              if (presetReports.length > 0) {
                presetReports.forEach((p) => paths.add(p));
              } else {
                reportCategory.items.forEach((it) => paths.add(it.to));
              }
            }
          }
        }

        setSelectedPermissions(paths);

        if (hasTindakanConfig && loadedTindakanRooms.size > 0) {
          const branchTindakanCodes = new Set(targetBranchTindakan.map((r: any) => r.kode_ruangan));
          const validLoadedTindakan = new Set(
            Array.from(loadedTindakanRooms).filter((code) => branchTindakanCodes.has(code))
          );
          setSelectedTindakanRooms(
            validLoadedTindakan.size > 0 ? validLoadedTindakan : new Set(targetBranchTindakan.map((r: any) => r.kode_ruangan))
          );
        } else {
          setSelectedTindakanRooms(new Set(targetBranchTindakan.map((r: any) => r.kode_ruangan)));
        }

        if (hasKonsulConfig && loadedKonsulRooms.size > 0) {
          const branchKonsulCodes = new Set(targetBranchKonsul.map((r: any) => r.kode_ruangan));
          const validLoadedKonsul = new Set(
            Array.from(loadedKonsulRooms).filter((code) => branchKonsulCodes.has(code))
          );
          setSelectedKonsulRooms(
            validLoadedKonsul.size > 0 ? validLoadedKonsul : new Set(targetBranchKonsul.map((r: any) => r.kode_ruangan))
          );
        } else {
          setSelectedKonsulRooms(new Set(targetBranchKonsul.map((r: any) => r.kode_ruangan)));
        }
      } else {
        const defaultPaths = ROLE_PRESET_PATHS[u.role] || [];
        setSelectedPermissions(new Set(defaultPaths));
        setSelectedTindakanRooms(new Set(targetBranchTindakan.map((r: any) => r.kode_ruangan)));
        setSelectedKonsulRooms(new Set(targetBranchKonsul.map((r: any) => r.kode_ruangan)));
      }
    } catch (_) {
      const defaultPaths = ROLE_PRESET_PATHS[u.role] || [];
      setSelectedPermissions(new Set(defaultPaths));
      setSelectedTindakanRooms(new Set(targetBranchTindakan.map((r: any) => r.kode_ruangan)));
      setSelectedKonsulRooms(new Set(targetBranchKonsul.map((r: any) => r.kode_ruangan)));
    } finally {
      setLoadingPermissions(false);
    }
  };

  const handleRoleChange = (newRole: string) => {
    setFormData((prev: any) => ({ ...prev, role: newRole }));
    if (newRole === 'superadmin') {
      const all = new Set<string>();
      AVAILABLE_MODULE_CATEGORIES.forEach((cat) => {
        cat.items.forEach((it) => all.add(it.to));
      });
      setSelectedPermissions(all);
      setSelectedTindakanRooms(new Set(tindakanRooms.map((r) => r.kode_ruangan)));
      setSelectedKonsulRooms(new Set(konsulRooms.map((r) => r.kode_ruangan)));
    } else {
      const preset = ROLE_PRESET_PATHS[newRole] || (newRole === 'manager' ? ROLE_PRESET_PATHS['owner'] : []);
      setSelectedPermissions(new Set(preset));
      if (newRole === 'beautician' || newRole === 'dokter') {
        setSelectedTindakanRooms(new Set(tindakanRooms.map((r) => r.kode_ruangan)));
      } else {
        setSelectedTindakanRooms(new Set());
      }
      if (newRole === 'dokter') {
        setSelectedKonsulRooms(new Set(konsulRooms.map((r) => r.kode_ruangan)));
      } else {
        setSelectedKonsulRooms(new Set());
      }
    }
  };

  const togglePermission = (path: string) => {
    setSelectedPermissions((prev) => {
      const next = new Set(prev);
      if (next.has(path)) {
        next.delete(path);
      } else {
        next.add(path);
      }
      return next;
    });
  };

  const toggleCategory = (category: PermissionCategory) => {
    const categoryPaths = category.items.map((it) => it.to);
    const allSelected = categoryPaths.every((p) => selectedPermissions.has(p));
    setSelectedPermissions((prev) => {
      const next = new Set(prev);
      if (allSelected) {
        categoryPaths.forEach((p) => next.delete(p));
      } else {
        categoryPaths.forEach((p) => next.add(p));
      }
      return next;
    });
  };

  const applyPreset = () => {
    if (formData.role === 'superadmin') {
      selectAllPermissions();
      setSelectedTindakanRooms(new Set(tindakanRooms.map((r) => r.kode_ruangan)));
      setSelectedKonsulRooms(new Set(konsulRooms.map((r) => r.kode_ruangan)));
      showSuccess(toast, "Preset hak akses role 'SUPERADMIN' diterapkan.");
      return;
    }
    const preset = ROLE_PRESET_PATHS[formData.role] || (formData.role === 'manager' ? ROLE_PRESET_PATHS['owner'] : null);
    if (preset) {
      setSelectedPermissions(new Set(preset));
      if (formData.role === 'beautician' || formData.role === 'dokter') {
        setSelectedTindakanRooms(new Set(tindakanRooms.map((r) => r.kode_ruangan)));
      } else {
        setSelectedTindakanRooms(new Set());
      }
      if (formData.role === 'dokter') {
        setSelectedKonsulRooms(new Set(konsulRooms.map((r) => r.kode_ruangan)));
      } else {
        setSelectedKonsulRooms(new Set());
      }
      showSuccess(toast, `Preset hak akses role '${formData.role.toUpperCase()}' diterapkan.`);
    }
  };

  const selectAllPermissions = () => {
    const all = new Set<string>();
    AVAILABLE_MODULE_CATEGORIES.forEach((cat) => {
      cat.items.forEach((it) => all.add(it.to));
    });
    setSelectedPermissions(all);
  };

  const deselectAllPermissions = () => {
    setSelectedPermissions(new Set());
  };

  const karyawanOptions = useMemo(() => {
    // Kumpulkan kode_user dan email dari seluruh user yang ada di sistem
    const existingUserCodes = new Set(users.map((u) => u.user_code).filter(Boolean));
    const existingUsernames = new Set(
      users.map((u) => (u.username || '').toLowerCase().trim()).filter(Boolean)
    );

    // Hanya tampilkan karyawan yang belum memiliki akun
    const filtered = karyawanList.filter((k) => {
      // Jika mode Edit dan ini adalah karyawan yang sedang terhubung ke user saat ini, tetap izinkan tampil
      if (isEdit && formData.kode_karyawan && k.kode_karyawan === formData.kode_karyawan) {
        return true;
      }
      // Cek apakah karyawan ini sudah memiliki akun
      const hasAccountByKodeUser = Boolean(k.kode_user);
      const hasAccountByEmail = Boolean(
        k.email && existingUsernames.has(k.email.toLowerCase().trim())
      );

      return !hasAccountByKodeUser && !hasAccountByEmail;
    });

    return filtered.map((k) => ({
      label: `${k.nama} (${k.kode_karyawan}) - ${k.jabatan?.toUpperCase() || 'STAF'}`,
      value: k.kode_karyawan,
      karyawan: k,
    }));
  }, [karyawanList, users, isEdit, formData.kode_karyawan]);

  const karyawanOptionTemplate = (option: any) => {
    const k = option.karyawan;
    if (!k) return option.label;
    const isLinkedToCurrent = isEdit && formData.kode_karyawan === k.kode_karyawan;

    return (
      <div className="flex align-items-center justify-content-between w-full py-2.5 px-1 gap-3">
        <div className="flex flex-column gap-1.5">
          <span className="font-semibold text-sm text-900 leading-tight">{k.nama}</span>
          <div className="text-xs text-500 flex flex-wrap align-items-center gap-2 leading-tight">
            <span className="font-mono font-bold text-[11px] text-gray-700 bg-gray-100 px-1.5 py-0.5 border-round">
              {k.kode_karyawan}
            </span>
            <span>•</span>
            <span>{k.email || '-'}</span>
            <span>•</span>
            <span>{k.no_hp || '-'}</span>
          </div>
        </div>
        <div className="flex align-items-center gap-2 flex-shrink-0">
          <Tag
            value={
              k.jabatan === 'admin'
                ? 'ADMIN'
                : k.jabatan === 'beautician' || k.jabatan === 'terapis'
                ? 'BEAUTICIAN / TERAPIS'
                : k.jabatan === 'warehouse' || k.jabatan === 'logistik'
                ? 'WAREHOUSE / LOGISTIK'
                : k.jabatan === 'owner' || k.jabatan === 'manager'
                ? 'OWNER / MANAGER'
                : k.jabatan === 'superadmin'
                ? 'SUPERADMIN / IT'
                : k.jabatan?.toUpperCase() || 'STAF'
            }
            severity={
              k.jabatan === 'dokter'
                ? 'danger'
                : k.jabatan === 'kasir'
                ? 'success'
                : k.jabatan === 'beautician' || k.jabatan === 'terapis'
                ? 'warning'
                : k.jabatan === 'warehouse' || k.jabatan === 'logistik'
                ? 'secondary'
                : 'info'
            }
            className="text-xs px-2.5 py-1 font-bold"
          />
          {isLinkedToCurrent && (
            <Tag value="Akun Ini" severity="info" className="text-xs px-2.5 py-1" />
          )}
        </div>
      </div>
    );
  };

  const handleSubmit = async () => {
    if (!formData.fullname || !formData.username || !formData.telp || !formData.role) {
      showError(toast, 'Harap lengkapi semua kolom yang wajib diisi!');
      return;
    }
    if (!isEdit && !formData.password) {
      showError(toast, 'Password wajib diisi untuk pengguna baru!');
      return;
    }

    setFormLoading(true);
    try {
      if (formData.role === 'superadmin' || formData.user_code === 'USR000000') {
        const allPaths = new Set<string>();
        AVAILABLE_MODULE_CATEGORIES.forEach((cat) => {
          cat.items.forEach((it) => allPaths.add(it.to));
        });
        selectedPermissions.clear();
        allPaths.forEach((p) => selectedPermissions.add(p));
      }

      const customMenu = buildMenuFromSelectedPaths(
        selectedPermissions,
        selectedTindakanRooms,
        selectedKonsulRooms,
        tindakanRooms,
        konsulRooms
      );

      if (isEdit) {
        const payload: any = {
          user_code: formData.user_code,
          fullname: formData.fullname,
          username: formData.username,
          telp: formData.telp,
          role: formData.role,
          kode_cabang: formData.kode_cabang || null,
          status: formData.status,
          kode_karyawan: formData.kode_karyawan || null,
          menu: customMenu,
        };
        if (formData.password) payload.password = formData.password;

        const res = await postData('/setup/user-login/user-update', payload);
        if (['00', '0000'].includes(res?.data?.status)) {
          showSuccess(toast, 'Data pengguna & hak akses berhasil diperbarui');
          setShowModal(false);
          fetchUsers();
          fetchKaryawan();
          try {
            await clearUserMenuCache(payload.user_code);
          } catch (_) {}
          if (typeof window !== 'undefined') {
            window.dispatchEvent(new Event('menu-updated'));
          }
        } else {
          showError(toast, res?.data?.message || 'Gagal memperbarui data pengguna');
        }
      } else {
        const payload = {
          fullname: formData.fullname,
          username: formData.username,
          telp: formData.telp,
          role: formData.role,
          kode_cabang: formData.kode_cabang || null,
          password: formData.password,
          status: formData.status,
          kode_karyawan: formData.kode_karyawan || null,
          menu: customMenu,
        };

        const res = await postData('/setup/user-login/user-create', payload);
        if (['00', '0000'].includes(res?.data?.status)) {
          showSuccess(toast, 'Pengguna baru & hak akses berhasil dibuat');
          setShowModal(false);
          fetchUsers();
          fetchKaryawan();
          try {
            await clearUserMenuCache();
          } catch (_) {}
          if (typeof window !== 'undefined') {
            window.dispatchEvent(new Event('menu-updated'));
          }
        } else {
          showError(toast, res?.data?.message || 'Gagal menambahkan pengguna baru');
        }
      }
    } catch (err: any) {
      const errMsg = err?.response?.data?.message || err?.message || 'Terjadi kesalahan sistem';
      showError(toast, errMsg);
    } finally {
      setFormLoading(false);
    }
  };

  const handleDelete = (codes: string[], names?: string) => {
    const targetUsers = users.filter((u) => codes.includes(u.user_code));
    const hasSuperAdminUser = targetUsers.some((u) =>
      ['superadmin'].includes(String(u.role || '').toLowerCase()) || u.user_code === 'USR000000'
    );
    if (hasSuperAdminUser) {
      showError(toast, 'Akun Superadmin terkunci permanen dan tidak dapat dihapus.');
      return;
    }

    const hasProtectedUser = targetUsers.some((u) =>
      ['owner', 'manager'].includes(String(u.role || '').toLowerCase())
    );
    if (!isSuperAdmin && hasProtectedUser) {
      showError(toast, 'Akses ditolak: Hanya Superadmin yang berhak menghapus akun Owner/Manager.');
      return;
    }

    const confirmText = names || `${codes.length} data pengguna ini`;

    confirmDialog({
      message: `Apakah Anda yakin ingin menghapus akun pengguna "${confirmText}"?`,
      header: 'Konfirmasi Hapus Pengguna',
      icon: 'pi pi-exclamation-triangle',
      acceptClassName: 'p-button-danger',
      acceptLabel: 'Ya, Hapus',
      rejectLabel: 'Batal',
      accept: async () => {
        try {
          const res = await postData('/setup/user-login/user-delete', { user_code: codes });
          if (['00', '0000'].includes(res?.data?.status)) {
            showSuccess(toast, 'Pengguna berhasil dihapus');
            setSelectedRows([]);
            fetchUsers();
          } else {
            showError(toast, res?.data?.message || 'Gagal menghapus pengguna');
          }
        } catch (err: any) {
          const errMsg = err?.response?.data?.message || err?.message || 'Gagal menghapus pengguna';
          showError(toast, errMsg);
        }
      },
    });
  };

  const isFormSuperAdmin = formData.role === 'superadmin' || formData.user_code === 'USR000000';

  return (
    <div className="w-full">
      <Toast ref={toast} />
      <ConfirmDialog />

      <div className="card border-round-xl p-4 shadow-1 surface-card mb-4">
        {/* Page Header */}
        <div className="mb-4">
          <h3 className="text-2xl font-bold text-900 flex align-items-center gap-2 mb-1">
            <i className="pi pi-users text-purple-600 text-2xl" />
            Kelola Pengguna & Hak Akses Staf
          </h3>
          <p className="text-500 text-sm m-0">
            {isSuperAdmin
              ? 'Kelola akun seluruh staf klinik lintas cabang dan konfigurasi hak akses modul.'
              : 'Buat akun staf cabang (Beautician, Kasir, Warehouse) dan atur hak akses modulnya secara manual.'}
          </p>
        </div>

        {/* Action Buttons Toolbar */}
        <div className="flex flex-row flex-wrap align-items-center gap-2 mb-4">
          <Button
            size="small"
            label="Baru"
            icon="pi pi-plus"
            outlined
            severity="success"
            className="border-round-md font-medium px-3"
            onClick={handleOpenCreate}
          />
          <Divider layout="vertical" className="m-0 h-2rem" />
          <Button
            size="small"
            label="Cetak"
            icon="pi pi-print"
            outlined
            className="border-round-md font-medium px-3 border-purple-600 text-purple-600"
            onClick={() => window.print()}
          />
          <Divider layout="vertical" className="m-0 h-2rem" />
          <Button
            size="small"
            label={`Hapus${selectedRows.length > 0 ? ` (${selectedRows.length})` : ''}`}
            icon="pi pi-trash"
            severity="danger"
            outlined
            disabled={selectedRows.length === 0}
            className="border-round-md font-medium px-3"
            onClick={() => {
              if (selectedRows.length < 1) return;
              handleDelete(selectedRows.map((r) => r.user_code));
            }}
          />
          <Divider layout="vertical" className="m-0 h-2rem" />
          <Button
            size="small"
            label="Refresh"
            icon="pi pi-refresh"
            outlined
            severity="success"
            className="border-round-md font-medium px-3"
            loading={loading}
            onClick={fetchUsers}
          />
        </div>

        {/* DataTable */}
        <DataTable
          value={users}
          loading={loading}
          paginator
          rows={rows}
          totalRecords={totalRecords}
          lazy
          first={(page - 1) * rows}
          onPage={(e) => {
            setPage((e.page || 0) + 1);
            setRows(e.rows);
          }}
          selection={selectedRows}
          onSelectionChange={(e: any) => setSelectedRows(e.value)}
          dataKey="user_code"
          isDataSelectable={(e) =>
            String(e.data.role || '').toLowerCase() !== 'superadmin' &&
            e.data.user_code !== 'USR000000' &&
            (isSuperAdmin || !['owner', 'manager'].includes(String(e.data.role || '').toLowerCase()))
          }
          className="p-datatable-sm"
          emptyMessage="Data pengguna tidak ditemukan."
          responsiveLayout="scroll"
          rowsPerPageOptions={[10, 25, 50]}
          paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
          currentPageReportTemplate="Menampilkan {first} - {last} dari {totalRecords} data"
          header={
            <div className="flex flex-column gap-3">
              <div className="flex flex-wrap align-items-center justify-content-between gap-2">
                <span className="text-xl font-bold">Data Pengguna & Hak Akses</span>
                <div className="flex flex-wrap align-items-center gap-2 ml-auto w-full md:w-auto">
                  <Dropdown
                    value={selectedRole}
                    options={[{ label: 'Semua Role', value: null }, ...roleOptions]}
                    onChange={(e) => {
                      setSelectedRole(e.value);
                      setPage(1);
                    }}
                    placeholder="Filter Role"
                    className="p-inputtext-sm w-full md:w-12rem text-sm border-round-md"
                    showClear
                  />
                  {isSuperAdmin && (
                    <Dropdown
                      value={selectedCabang}
                      options={branchOptions}
                      onChange={(e) => {
                        setSelectedCabang(e.value);
                        setPage(1);
                      }}
                      placeholder="Filter Cabang"
                      className="p-inputtext-sm w-full md:w-14rem text-sm border-round-md"
                      showClear
                    />
                  )}
                  <IconField iconPosition="left" className="w-full md:w-18rem">
                    <InputIcon className="pi pi-search" />
                    <InputText
                      value={keyword}
                      onChange={(e) => {
                        setKeyword(e.target.value);
                        setPage(1);
                      }}
                      placeholder="Cari Data..."
                      className="w-full text-sm"
                    />
                  </IconField>
                  <Button
                    type="button"
                    icon="pi pi-filter-slash"
                    outlined
                    severity="danger"
                    tooltip="Reset Filter"
                    tooltipOptions={{ position: 'bottom' }}
                    onClick={() => {
                      setKeyword('');
                      setSelectedRole(null);
                      setSelectedCabang(null);
                      setPage(1);
                    }}
                  />
                </div>
              </div>
              <KeteranganStatus className="mb-2" />
            </div>
          }
        >
          <Column selectionMode="multiple" headerStyle={{ width: '3rem' }} />
          <Column
            header=""
            headerStyle={{ width: '3rem' }}
            align="center"
            body={(r: UserRecord) => {
              const isActive = String(r.status) === '1' || r.status === 1 || r.status === 'aktif';
              return (
                <span
                  style={{
                    display: 'inline-block',
                    width: '14px',
                    height: '14px',
                    borderRadius: '3px',
                    backgroundColor: isActive ? '#22c55e' : '#ef4444',
                    boxShadow: isActive ? '0 1px 3px #22c55e55' : '0 1px 3px #ef444455',
                  }}
                  title={isActive ? 'Status: Aktif' : 'Status: Tidak Aktif'}
                />
              );
            }}
          />
          <Column
            field="user_code"
            header="Kode User"
            sortable
            headerStyle={{ fontWeight: 'bold', width: '8rem' }}
            body={(r: UserRecord) => <span className="font-mono text-xs font-bold text-gray-700">{r.user_code}</span>}
          />
          <Column
            field="fullname"
            header="Nama Pengguna"
            sortable
            headerStyle={{ fontWeight: 'bold' }}
            body={(r: UserRecord) => (
              <div>
                <div className="font-semibold text-900 text-sm">{r.fullname}</div>
                <div className="text-xs text-500">{r.username}</div>
              </div>
            )}
          />
          <Column
            field="telp"
            header="No. Telp"
            sortable
            headerStyle={{ fontWeight: 'bold', width: '10rem' }}
            body={(r: UserRecord) => <span className="text-sm text-gray-700">{r.telp || '-'}</span>}
          />
          <Column
            field="role"
            header="Role Dashboard"
            sortable
            headerStyle={{ fontWeight: 'bold', width: '10rem' }}
            body={(r: UserRecord) => (
              <Tag
                value={String(r.role || 'USER').toUpperCase()}
                severity={getRoleSeverity(r.role)}
                className="text-xs font-bold px-2 py-0.5"
              />
            )}
          />
          <Column
            field="nama_cabang"
            header="Cabang"
            sortable
            headerStyle={{ fontWeight: 'bold', width: '12rem' }}
            body={(r: UserRecord) => {
              const label = r.nama_cabang || (r.kode_cabang ? r.kode_cabang : 'Pusat / Semua');
              const isPusat = !r.kode_cabang;
              return (
                <Tag
                  value={label}
                  severity={isPusat ? 'info' : 'secondary'}
                  className="text-xs"
                  icon={isPusat ? 'pi pi-shield' : 'pi pi-building'}
                />
              );
            }}
          />
          <Column
            header="Aksi"
            align="center"
            headerStyle={{ width: '8rem', textAlign: 'center', fontWeight: 'bold' }}
            body={(r: UserRecord) => {
              const isSuperAdminAccount = String(r.role || '').toLowerCase() === 'superadmin' || r.user_code === 'USR000000';
              const isTargetProtected = ['owner', 'manager'].includes(String(r.role || '').toLowerCase());
              const canEdit = isSuperAdmin || !isTargetProtected;
              const canDelete = !isSuperAdminAccount && (isSuperAdmin || !isTargetProtected);

              return (
                <div className="flex align-items-center justify-content-center gap-2">
                  <Button
                    icon={canEdit ? 'pi pi-pencil' : 'pi pi-lock'}
                    outlined
                    severity={canEdit ? 'success' : 'secondary'}
                    className="p-button-sm border-round-md"
                    tooltip={
                      isSuperAdminAccount
                        ? 'Edit Profil Pengguna (Hak Akses Terkunci)'
                        : canEdit
                        ? 'Edit Pengguna & Hak Akses'
                        : 'Hanya Superadmin yang dapat mengedit akun ini'
                    }
                    tooltipOptions={{ position: 'top' }}
                    disabled={!canEdit}
                    onClick={() => canEdit && handleOpenEdit(r)}
                  />
                  <Button
                    icon={canDelete ? 'pi pi-trash' : 'pi pi-lock'}
                    outlined
                    severity={canDelete ? 'danger' : 'secondary'}
                    className="p-button-sm border-round-md"
                    tooltip={
                      isSuperAdminAccount
                        ? 'Akun Superadmin terkunci permanen dan tidak dapat dihapus'
                        : canDelete
                        ? 'Hapus Pengguna'
                        : 'Hanya Superadmin yang dapat menghapus akun ini'
                    }
                    tooltipOptions={{ position: 'top' }}
                    disabled={!canDelete}
                    onClick={() => canDelete && handleDelete([r.user_code], `${r.fullname} (${r.username})`)}
                  />
                </div>
              );
            }}
          />
        </DataTable>
      </div>

      {/* DIALOG CREATE / EDIT USER & PEMILIHAN HAK AKSES */}
      <Dialog
        header={
          <div className="flex align-items-center gap-2">
            <i className={`pi ${isEdit ? 'pi-user-edit text-green-600' : 'pi-user-plus text-purple-600'} text-xl`} />
            <span className="font-bold text-lg">
              {isEdit ? `Edit Data Pengguna: ${formData.fullname || formData.username}` : 'Tambah Pengguna Baru'}
            </span>
            {formData.role && (
              <Tag
                value={String(formData.role).toUpperCase()}
                severity={getRoleSeverity(formData.role)}
                className="text-xs font-bold ml-2"
              />
            )}
          </div>
        }
        visible={showModal}
        style={{ width: '880px', maxWidth: '96vw' }}
        modal
        onHide={() => setShowModal(false)}
        footer={
          <div className="flex justify-content-between align-items-center pt-2 border-top-1 surface-border">
            {!isFormSuperAdmin ? (
              <div className="text-xs text-600 font-medium flex align-items-center gap-2">
                <i className="pi pi-shield text-purple-600" />
                <span>
                  Total modul aktif: <strong className="text-purple-700">{selectedPermissions.size} modul</strong> terpilih
                </span>
              </div>
            ) : (
              <div />
            )}
            <div className="flex gap-2">
              <Button
                label="Batal"
                icon="pi pi-times"
                outlined
                severity="secondary"
                onClick={() => setShowModal(false)}
              />
              <Button
                label={isEdit ? 'Simpan Perubahan' : 'Simpan Pengguna'}
                icon="pi pi-check"
                severity="success"
                onClick={handleSubmit}
                loading={formLoading}
              />
            </div>
          </div>
        }
      >
        <TabView activeIndex={activeTab} onTabChange={(e) => setActiveTab(e.index)} className="mt-2">
          {/* TAB 1: INFORMASI AKUN */}
          <TabPanel header="Informasi Akun Staf" leftIcon="pi pi-user mr-2">
            <div className="p-1">
              {/* Opsi Pilih dari Master Karyawan */}
              <div className="surface-50 border-1 border-200 border-round-lg p-3 mb-4">
                <div className="flex align-items-center justify-content-between mb-2">
                  <label className="text-xs font-bold text-700 flex align-items-center gap-2">
                    <i className="pi pi-id-card text-purple-600" />
                    Pilih Staf dari Master Karyawan (Opsional)
                  </label>
                  {selectedKaryawanId && (
                    <Button
                      type="button"
                      label="Reset Pilihan"
                      icon="pi pi-times"
                      text
                      severity="danger"
                      className="p-0 text-xs font-semibold"
                      onClick={() => {
                        setSelectedKaryawanId(null);
                        setFormData((prev: any) => ({ ...prev, kode_karyawan: null }));
                      }}
                    />
                  )}
                </div>
                <Dropdown
                  value={selectedKaryawanId}
                  options={karyawanOptions}
                  onChange={(e) => handleSelectKaryawan(e.value)}
                  placeholder="-- Pilih staf klinik (hanya yang belum punya akun) --"
                  emptyMessage="Semua karyawan sudah memiliki akun login"
                  className="w-full text-sm"
                  filter
                  showClear
                  itemTemplate={karyawanOptionTemplate}
                />
                <small className="text-500 mt-1 block">
                  Hanya menampilkan staf yang belum memiliki akun. Memilih staf akan otomatis mengisi Nama, Email, No. HP, Role, dan rekomendasi hak akses.
                </small>
              </div>

              {/* Form Input Grid (2 Kolom Rapi) */}
              <div className="grid p-fluid">
                <div className="col-12 md:col-6 field mb-3">
                  <label className="text-xs font-bold text-700 block mb-1">
                    Nama Lengkap <span className="text-red-500">*</span>
                  </label>
                  <InputText
                    value={formData.fullname}
                    onChange={(e) => setFormData({ ...formData, fullname: e.target.value })}
                    placeholder="Contoh: dr. Amanda Putri"
                    className="w-full text-sm"
                  />
                </div>

                <div className="col-12 md:col-6 field mb-3">
                  <label className="text-xs font-bold text-700 block mb-1">
                    Username / Email Login <span className="text-red-500">*</span>
                  </label>
                  <InputText
                    value={formData.username}
                    onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                    placeholder="Contoh: dokter@klinik.com"
                    className="w-full text-sm"
                  />
                </div>

                <div className="col-12 md:col-6 field mb-3">
                  <label className="text-xs font-bold text-700 block mb-1">
                    No. Telepon / WhatsApp <span className="text-red-500">*</span>
                  </label>
                  <InputText
                    value={formData.telp}
                    onChange={(e) => setFormData({ ...formData, telp: e.target.value })}
                    placeholder="Contoh: 081234567890"
                    className="w-full text-sm"
                  />
                </div>

                <div className="col-12 md:col-6 field mb-3">
                  <label className="text-xs font-bold text-700 block mb-1">
                    Role Operasional <span className="text-red-500">*</span>
                  </label>
                  <Dropdown
                    value={formData.role}
                    options={roleOptions}
                    onChange={(e) => handleRoleChange(e.value)}
                    placeholder="Pilih Role Operasional"
                    className="w-full text-sm"
                    disabled={isEdit && (formData.role === 'superadmin' || formData.user_code === 'USR000000')}
                  />
                  {isEdit && (formData.role === 'superadmin' || formData.user_code === 'USR000000') && (
                    <small className="text-teal-700 font-medium mt-1 block">Role Superadmin terkunci permanen.</small>
                  )}
                </div>

                <div className="col-12 md:col-6 field mb-3">
                  <label className="text-xs font-bold text-700 block mb-1">Penempatan Cabang</label>
                  <Dropdown
                    value={formData.kode_cabang}
                    options={branchOptions.filter((b) => b.value !== null)}
                    onChange={async (e) => {
                      const newCabang = e.value;
                      setFormData((prev: any) => ({ ...prev, kode_cabang: newCabang }));
                      if (newCabang) {
                        const branchRooms = await fetchRuangan(newCabang);
                        const roomsToUse = branchRooms && branchRooms.length > 0 ? branchRooms : ruanganList.filter((r: any) => r.kode_cabang === newCabang);
                        const newTindakan = roomsToUse.filter((r: any) => !r.is_konsultasi || r.is_konsultasi === 0);
                        const newKonsul = roomsToUse.filter((r: any) => r.is_konsultasi === 1);
                        setSelectedTindakanRooms(new Set(newTindakan.map((r: any) => r.kode_ruangan)));
                        setSelectedKonsulRooms(new Set(newKonsul.map((r: any) => r.kode_ruangan)));
                      }
                    }}
                    placeholder="Pusat / Semua Cabang"
                    className="w-full text-sm"
                    disabled={formData.role === 'superadmin' || formData.user_code === 'USR000000' || (!isSuperAdmin && Boolean(session?.user?.kode_cabang))}
                  />
                  {(formData.role === 'superadmin' || formData.user_code === 'USR000000') && (
                    <small className="text-teal-700 font-medium mt-1 block">Superadmin memiliki akses pusat ke seluruh cabang.</small>
                  )}
                  {!isSuperAdmin && session?.user?.kode_cabang && (
                    <small className="text-500 mt-1 block">Terikat otomatis pada cabang Anda.</small>
                  )}
                </div>

                <div className="col-12 md:col-6 field mb-3">
                  <label className="text-xs font-bold text-700 block mb-1">Status Akun</label>
                  <Dropdown
                    value={formData.status}
                    options={STATUS_OPTIONS}
                    onChange={(e) => setFormData({ ...formData, status: e.value })}
                    className="w-full text-sm"
                  />
                </div>

                <div className="col-12 field mb-2">
                  <label className="text-xs font-bold text-700 block mb-1">
                    {isEdit ? 'Password Baru (Kosongkan jika tidak diubah)' : 'Password Login *'}
                  </label>
                  <Password
                    value={formData.password}
                    onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                    placeholder="Minimal 6 karakter"
                    toggleMask
                    className="w-full"
                    inputClassName="w-full text-sm"
                  />
                </div>
              </div>

              {/* Tombol Navigasi ke Tab Hak Akses (Hanya untuk non-superadmin) */}
              {!isFormSuperAdmin && (
                <div className="flex justify-content-end mt-3 pt-2 border-top-1 surface-border">
                  <Button
                    type="button"
                    label="Lanjut ke Hak Akses & Menu Modul"
                    icon="pi pi-arrow-right"
                    iconPos="right"
                    outlined
                    severity="success"
                    className="text-sm font-medium"
                    onClick={() => setActiveTab(1)}
                  />
                </div>
              )}
            </div>
          </TabPanel>

          {/* TAB 2: HAK AKSES & MENU OPERASIONAL (Hanya untuk non-superadmin) */}
          {!isFormSuperAdmin && (
            <TabPanel header="Hak Akses & Menu Operasional" leftIcon="pi pi-shield mr-2">
            <div className="p-1">
              {/* Banner Hak Akses Terkunci jika akun Superadmin */}
              {(formData.role === 'superadmin' || formData.user_code === 'USR000000') && (
                <div className="surface-50 border-1 border-teal-200 border-round-lg p-3 mb-3 flex align-items-center gap-3">
                  <div
                    style={{
                      width: '36px',
                      height: '36px',
                      borderRadius: '8px',
                      backgroundColor: '#ccfbf1',
                      color: '#0f766e',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      flexShrink: 0,
                    }}
                  >
                    <i className="pi pi-lock text-lg" />
                  </div>
                  <div>
                    <div className="font-bold text-sm text-teal-900">Hak Akses Superadmin Terkunci Permanen</div>
                    <div className="text-xs text-600 mt-0.5">
                      Akun Superadmin memiliki hak akses permanen dan tidak dapat diubah-ubah. Seluruh fitur dan menu sistem aktif penuh tanpa batasan.
                    </div>
                  </div>
                </div>
              )}

              {/* Header Action Bar */}
              <div className="flex flex-column sm:flex-row justify-content-between align-items-stretch sm:align-items-center gap-2 mb-3 pb-2 border-bottom-1 surface-border">
                <IconField iconPosition="left" className="w-full sm:w-20rem">
                  <InputIcon className="pi pi-search text-gray-400 text-xs" />
                  <InputText
                    value={permissionFilter}
                    onChange={(e) => setPermissionFilter(e.target.value)}
                    placeholder="Cari fitur / modul..."
                    className="w-full text-xs p-inputtext-sm border-round-md"
                  />
                </IconField>

                <div className="flex align-items-center gap-2">
                  <Button
                    type="button"
                    size="small"
                    label={`Preset (${String(formData.role || '').toUpperCase()})`}
                    icon="pi pi-history"
                    outlined
                    severity="info"
                    className="text-xs py-1.5 px-2.5 border-round-md"
                    onClick={applyPreset}
                    disabled={formData.role === 'superadmin' || formData.user_code === 'USR000000'}
                    tooltip={`Terapkan preset rekomendasi untuk role ${formData.role}`}
                    tooltipOptions={{ position: 'bottom' }}
                  />
                  <Button
                    type="button"
                    size="small"
                    label="Pilih Semua"
                    icon="pi pi-check-square"
                    outlined
                    severity="success"
                    className="text-xs py-1.5 px-2.5 border-round-md"
                    onClick={selectAllPermissions}
                    disabled={formData.role === 'superadmin' || formData.user_code === 'USR000000'}
                  />
                  <Button
                    type="button"
                    size="small"
                    label="Reset"
                    icon="pi pi-times"
                    outlined
                    severity="secondary"
                    className="text-xs py-1.5 px-2.5 border-round-md"
                    onClick={deselectAllPermissions}
                    disabled={formData.role === 'superadmin' || formData.user_code === 'USR000000'}
                  />
                </div>
              </div>

              {/* Daftar Kategori & Modul */}
              {loadingPermissions ? (
                <div className="p-5 text-center text-gray-500 text-sm">
                  <i className="pi pi-spin pi-spinner text-purple-600 text-2xl block mb-2" />
                  Memuat konfigurasi modul...
                </div>
              ) : (
                <div
                  className="overflow-y-auto pr-2 flex flex-column gap-3"
                  style={{ maxHeight: '460px', scrollbarWidth: 'thin' }}
                >
                  {AVAILABLE_MODULE_CATEGORIES.map((cat, idx) => {
                    const filterLower = permissionFilter.toLowerCase().trim();
                    const filteredItems = cat.items.filter(
                      (it) =>
                        it.label.toLowerCase().includes(filterLower) ||
                        it.desc.toLowerCase().includes(filterLower) ||
                        cat.category.toLowerCase().includes(filterLower)
                    );

                    if (filterLower && filteredItems.length === 0) return null;

                    const allCatPaths = cat.items.map((it) => it.to);
                    const isCatAllChecked = allCatPaths.every((p) => selectedPermissions.has(p));
                    const checkedCount = cat.items.filter((it) => selectedPermissions.has(it.to)).length;

                    return (
                      <div
                        key={cat.category || idx}
                        className="border-1 surface-border border-round-lg p-3 surface-50"
                      >
                        {/* Header Kategori */}
                        <div className="flex align-items-center justify-content-between mb-2 pb-2 border-bottom-1 surface-border">
                          <div
                            className={`flex align-items-center gap-2 ${(formData.role === 'superadmin' || formData.user_code === 'USR000000') ? 'opacity-80' : 'cursor-pointer'} select-none`}
                            onClick={() => !(formData.role === 'superadmin' || formData.user_code === 'USR000000') && toggleCategory(cat)}
                          >
                            <Checkbox
                              checked={isCatAllChecked || formData.role === 'superadmin' || formData.user_code === 'USR000000'}
                              readOnly
                              disabled={formData.role === 'superadmin' || formData.user_code === 'USR000000'}
                              className="pointer-events-none"
                            />
                            <span className="font-bold text-sm text-900 flex align-items-center gap-2">
                              <i className={`${cat.icon} text-purple-600 text-sm`} />
                              <span>{cat.category}</span>
                            </span>
                          </div>
                          <span className="text-xs text-500 font-semibold bg-white px-2 py-0.5 border-round border-1 surface-border">
                            {(formData.role === 'superadmin' || formData.user_code === 'USR000000') ? `${cat.items.length}/${cat.items.length} Modul Aktif` : `${checkedCount}/${cat.items.length} Modul Aktif`}
                          </span>
                        </div>

                        {/* Items dalam Kategori */}
                        <div className="flex flex-column gap-2">
                          {filteredItems.map((item) => {
                            const isSuperAdminAccount = formData.role === 'superadmin' || formData.user_code === 'USR000000';
                            const isChecked = selectedPermissions.has(item.to) || isSuperAdminAccount;
                            const isTindakanModule = item.to.includes('type=layanan');
                            const isKonsulModule = item.to.includes('type=konsul');

                            return (
                              <div
                                key={item.id}
                                className={`border-round-lg transition-all border-1 overflow-hidden ${
                                  isChecked
                                    ? 'bg-white shadow-1 border-purple-200'
                                    : 'bg-white/60 border-transparent hover:bg-white hover:border-200'
                                }`}
                              >
                                <div
                                  className={`p-3 flex align-items-start gap-3 ${isSuperAdminAccount ? 'opacity-90' : 'cursor-pointer'} select-none`}
                                  onClick={() => !isSuperAdminAccount && togglePermission(item.to)}
                                >
                                  <Checkbox
                                    checked={isChecked}
                                    readOnly
                                    disabled={isSuperAdminAccount}
                                    className="mt-0.5 pointer-events-none"
                                  />
                                  <div className="flex-1">
                                    <div
                                      className={`text-sm font-semibold ${isSuperAdminAccount ? '' : 'cursor-pointer'} block ${
                                        isChecked ? 'text-purple-900' : 'text-800'
                                      }`}
                                    >
                                      {item.label}
                                    </div>
                                    <p className="text-xs text-500 m-0 mt-0.5 leading-normal">{item.desc}</p>
                                  </div>
                                </div>

                                {/* RINCIAN RUANGAN TINDAKAN */}
                                {isChecked && isTindakanModule && (
                                  <div
                                    className="px-3 pb-3"
                                    onClick={(e) => e.stopPropagation()}
                                  >
                                    <div className="p-3 bg-purple-50/70 border-round-xl border-1 border-purple-200 shadow-xs">
                                      <div className="flex flex-wrap align-items-center justify-content-between gap-2 mb-3 pb-2 border-bottom-1 border-purple-200/60">
                                        <div className="flex align-items-center gap-2">
                                          <i className="pi pi-building text-purple-600 text-base" />
                                          <span className="text-sm font-bold text-purple-900">
                                            Akses Ruangan Tindakan
                                          </span>
                                          <span className="text-xs px-2 py-0.5 border-round-md font-semibold bg-purple-200/80 text-purple-900">
                                            {tindakanRooms.filter((r) => selectedTindakanRooms.has(r.kode_ruangan)).length}/{tindakanRooms.length} aktif
                                          </span>
                                        </div>
                                        <div className="flex align-items-center gap-1.5">
                                          <Button
                                            type="button"
                                            size="small"
                                            text
                                            label="Pilih Semua"
                                            icon="pi pi-check"
                                            disabled={isSuperAdminAccount}
                                            className="px-2 py-1 text-xs text-purple-700 font-bold hover:bg-purple-100 border-round-md"
                                            onClick={() =>
                                              !isSuperAdminAccount &&
                                              setSelectedTindakanRooms(new Set(tindakanRooms.map((r) => r.kode_ruangan)))
                                            }
                                          />
                                          <span className="text-xs text-300">|</span>
                                          <Button
                                            type="button"
                                            size="small"
                                            text
                                            label="Kosongkan"
                                            icon="pi pi-times"
                                            className="px-2 py-1 text-xs text-red-500 font-bold hover:bg-red-50 border-round-md"
                                            disabled={isSuperAdminAccount}
                                            onClick={() => !isSuperAdminAccount && setSelectedTindakanRooms(new Set())}
                                          />
                                        </div>
                                      </div>
                                      {tindakanRooms.length === 0 ? (
                                        <div className="text-xs text-500 italic p-3 text-center bg-white border-round-lg border-1 surface-border">
                                          Tidak ada ruangan tindakan pada cabang ini.
                                        </div>
                                      ) : (
                                        <div
                                          className="w-full"
                                          style={{
                                            display: 'grid',
                                            gridTemplateColumns: 'repeat(auto-fill, minmax(210px, 1fr))',
                                            gap: '10px',
                                          }}
                                        >
                                          {tindakanRooms.map((room) => {
                                            const isRoomChecked = selectedTindakanRooms.has(room.kode_ruangan);
                                            return (
                                              <div
                                                key={room.kode_ruangan}
                                                onClick={() => {
                                                  if (isSuperAdminAccount) return;
                                                  const next = new Set(selectedTindakanRooms);
                                                  if (isRoomChecked) next.delete(room.kode_ruangan);
                                                  else next.add(room.kode_ruangan);
                                                  setSelectedTindakanRooms(next);
                                                }}
                                                className={`cursor-pointer py-2.5 pl-4 pr-3 border-round-xl flex align-items-center gap-3 border-1 transition-all select-none ${
                                                  isRoomChecked
                                                    ? 'shadow-xs'
                                                    : 'hover:border-purple-300 hover:bg-purple-50/20'
                                                }`}
                                                style={{
                                                  borderColor: isRoomChecked ? '#7c3aed' : '#cbd5e1',
                                                  backgroundColor: isRoomChecked ? '#fbf9ff' : '#ffffff',
                                                  minHeight: '58px',
                                                }}
                                              >
                                                {isRoomChecked ? (
                                                  <div
                                                    className="flex align-items-center justify-content-center flex-shrink-0"
                                                    style={{
                                                      width: '22px',
                                                      height: '22px',
                                                      borderRadius: '6px',
                                                      backgroundColor: '#7c3aed',
                                                      marginLeft: '6px',
                                                    }}
                                                  >
                                                    <i className="pi pi-check text-white" style={{ fontSize: '11px', fontWeight: 'bold' }} />
                                                  </div>
                                                ) : (
                                                  <div
                                                    className="flex-shrink-0"
                                                    style={{
                                                      width: '22px',
                                                      height: '22px',
                                                      borderRadius: '6px',
                                                      border: '2px solid #cbd5e1',
                                                      backgroundColor: 'transparent',
                                                      marginLeft: '6px',
                                                    }}
                                                  />
                                                )}
                                                <div className="flex flex-column overflow-hidden flex-1" style={{ minWidth: 0 }}>
                                                  <span
                                                    className="font-bold text-sm text-900 white-space-nowrap overflow-hidden text-overflow-ellipsis"
                                                    title={room.nama_ruangan}
                                                    style={{ lineHeight: '1.25' }}
                                                  >
                                                    {room.nama_ruangan}
                                                  </span>
                                                  <span
                                                    className="text-xs text-500 mt-1 font-medium tracking-wide white-space-nowrap overflow-hidden text-overflow-ellipsis"
                                                    style={{ lineHeight: '1' }}
                                                  >
                                                    {room.kode_ruangan}
                                                  </span>
                                                </div>
                                              </div>
                                            );
                                          })}
                                        </div>
                                      )}
                                    </div>
                                  </div>
                                )}

                                {/* RINCIAN RUANGAN KONSULTASI */}
                                {isChecked && isKonsulModule && (
                                  <div
                                    className="px-3 pb-3"
                                    onClick={(e) => e.stopPropagation()}
                                  >
                                    <div className="p-3 bg-purple-50/70 border-round-xl border-1 border-purple-200 shadow-xs">
                                      <div className="flex flex-wrap align-items-center justify-content-between gap-2 mb-3 pb-2 border-bottom-1 border-purple-200/60">
                                        <div className="flex align-items-center gap-2">
                                          <i className="pi pi-comments text-purple-600 text-base" />
                                          <span className="text-sm font-bold text-purple-900">
                                            Akses Ruangan Konsultasi
                                          </span>
                                          <span className="text-xs px-2 py-0.5 border-round-md font-semibold bg-purple-200/80 text-purple-900">
                                            {konsulRooms.filter((r) => selectedKonsulRooms.has(r.kode_ruangan)).length}/{konsulRooms.length} aktif
                                          </span>
                                        </div>
                                        <div className="flex align-items-center gap-1.5">
                                          <Button
                                            type="button"
                                            size="small"
                                            text
                                            label="Pilih Semua"
                                            icon="pi pi-check"
                                            className="px-2 py-1 text-xs text-purple-700 font-bold hover:bg-purple-100 border-round-md"
                                            onClick={() =>
                                              setSelectedKonsulRooms(new Set(konsulRooms.map((r) => r.kode_ruangan)))
                                            }
                                          />
                                          <span className="text-xs text-300">|</span>
                                          <Button
                                            type="button"
                                            size="small"
                                            text
                                            label="Kosongkan"
                                            icon="pi pi-times"
                                            className="px-2 py-1 text-xs text-red-500 font-bold hover:bg-red-50 border-round-md"
                                            onClick={() => setSelectedKonsulRooms(new Set())}
                                          />
                                        </div>
                                      </div>
                                      {konsulRooms.length === 0 ? (
                                        <div className="text-xs text-500 italic p-3 text-center bg-white border-round-lg border-1 surface-border">
                                          Tidak ada ruangan konsultasi pada cabang ini.
                                        </div>
                                      ) : (
                                        <div
                                          className="w-full"
                                          style={{
                                            display: 'grid',
                                            gridTemplateColumns: 'repeat(auto-fill, minmax(210px, 1fr))',
                                            gap: '10px',
                                          }}
                                        >
                                          {konsulRooms.map((room) => {
                                            const isRoomChecked = selectedKonsulRooms.has(room.kode_ruangan);
                                            return (
                                              <div
                                                key={room.kode_ruangan}
                                                onClick={() => {
                                                  if (isSuperAdminAccount) return;
                                                  const next = new Set(selectedKonsulRooms);
                                                  if (isRoomChecked) next.delete(room.kode_ruangan);
                                                  else next.add(room.kode_ruangan);
                                                  setSelectedKonsulRooms(next);
                                                }}
                                                className={`cursor-pointer py-2.5 pl-4 pr-3 border-round-xl flex align-items-center gap-3 border-1 transition-all select-none ${
                                                  isRoomChecked
                                                    ? 'shadow-xs'
                                                    : 'hover:border-purple-300 hover:bg-purple-50/20'
                                                }`}
                                                style={{
                                                  borderColor: isRoomChecked ? '#7c3aed' : '#cbd5e1',
                                                  backgroundColor: isRoomChecked ? '#fbf9ff' : '#ffffff',
                                                  minHeight: '58px',
                                                }}
                                              >
                                                {isRoomChecked ? (
                                                  <div
                                                    className="flex align-items-center justify-content-center flex-shrink-0"
                                                    style={{
                                                      width: '22px',
                                                      height: '22px',
                                                      borderRadius: '6px',
                                                      backgroundColor: '#7c3aed',
                                                      marginLeft: '6px',
                                                    }}
                                                  >
                                                    <i className="pi pi-check text-white" style={{ fontSize: '11px', fontWeight: 'bold' }} />
                                                  </div>
                                                ) : (
                                                  <div
                                                    className="flex-shrink-0"
                                                    style={{
                                                      width: '22px',
                                                      height: '22px',
                                                      borderRadius: '6px',
                                                      border: '2px solid #cbd5e1',
                                                      backgroundColor: 'transparent',
                                                      marginLeft: '6px',
                                                    }}
                                                  />
                                                )}
                                                <div className="flex flex-column overflow-hidden flex-1" style={{ minWidth: 0 }}>
                                                  <span
                                                    className="font-bold text-sm text-900 white-space-nowrap overflow-hidden text-overflow-ellipsis"
                                                    title={room.nama_ruangan}
                                                    style={{ lineHeight: '1.25' }}
                                                  >
                                                    {room.nama_ruangan}
                                                  </span>
                                                  <span
                                                    className="text-xs text-500 mt-1 font-medium tracking-wide white-space-nowrap overflow-hidden text-overflow-ellipsis"
                                                    style={{ lineHeight: '1' }}
                                                  >
                                                    {room.kode_ruangan}
                                                  </span>
                                                </div>
                                              </div>
                                            );
                                          })}
                                        </div>
                                      )}
                                    </div>
                                  </div>
                                )}
                              </div>
                            );
                          })}
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          </TabPanel>
          )}
        </TabView>
      </Dialog>
    </div>
  );
}