'use client';

import React, { useState, useEffect, useRef } from 'react';
import { useSession } from 'next-auth/react';
import { useRouter } from 'next/navigation';
import { Toast } from 'primereact/toast';
import postData from '@/lib/axios/postData';

import RevenueHero from './components/RevenueHero';
import StatStrip from './components/StatStrip';
import PaymentDonutPanel from './components/PaymentDonutPanel';
import TopTreatmentsPanel from './components/TopTreatmentsPanel';
import BranchComparisonSection from './components/BranchComparisonSection';
import BranchActivityFeed from './components/BranchActivityFeed';
import {
  DokterView,
  BeauticianView,
  KasirView,
  WarehouseView,
  AdminView,
} from './components/RoleViews';

const DashboardPage: React.FC = () => {
  const { data: session } = useSession();
  const router = useRouter();
  const toast = useRef<Toast>(null);

  const [dashboardData, setDashboardData] = useState<any>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [refreshCounter, setRefreshCounter] = useState<number>(0);

  const userRole = (session?.user?.role || 'owner').toLowerCase();
  const userName = session?.user?.name || session?.user?.username || 'Pengguna';
  const isSuperAdmin = userRole === 'superadmin' || userRole === 'admin_pusat';

  const [cabangList, setCabangList] = useState<any[]>([]);

  useEffect(() => {
    if (isSuperAdmin) {
      postData('/master/cabang-data', {})
        .then((res) => {
          if (res?.data?.data && Array.isArray(res.data.data)) {
            setCabangList(res.data.data);
          }
        })
        .catch(() => {});
    }
  }, [isSuperAdmin]);

  const [activities, setActivities] = useState<any[]>([]);
  const [activitiesLoading, setActivitiesLoading] = useState<boolean>(false);

  // Mengambil data aktivitas live feed cabang
  const fetchActivities = async () => {
    setActivitiesLoading(true);
    try {
      const res = await postData('/master/dashboard/cabang-detail', {
        kode_cabang: 'CBG-001',
        role: userRole,
      });
      if (['00', '0000', 200].includes(res?.data?.status) || res?.status === 200) {
        setActivities(res?.data?.data?.activities || []);
      }
    } catch (err: any) {
      console.warn('Gagal memuat aktivitas:', err?.message);
    } finally {
      setActivitiesLoading(false);
    }
  };

  // Mengambil data real-time langsung dari database backend berdasarkan role pengguna
  const fetchDashboardData = async () => {
    setLoading(true);
    setRefreshCounter((prev) => prev + 1);
    fetchActivities();
    try {
      const res = await postData('/master/dashboard/role-data', {
        role: userRole,
        kode_cabang: session?.user?.kode_cabang || null,
        user_code: (session?.user as any)?.user_code || null,
        username: session?.user?.username || (session?.user as any)?.email || null,
      });
      if (['00', '0000'].includes(res?.data?.status)) {
        setDashboardData(res.data.data || {});
      } else {
        setDashboardData(res?.data?.data || {});
      }
    } catch (err: any) {
      console.warn('Gagal memuat data dashboard:', err?.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (session?.user) {
      fetchDashboardData();
      fetchActivities();
    }
  }, [session]);

  // ─── VIEW KHUSUS DOKTER ───
  if (userRole === 'dokter') {
    return (
      <div className="clinic-dashboard w-full" style={{ backgroundColor: '#FFFFFF', padding: '24px' }}>
        <Toast ref={toast} />
        <div
          className="flex flex-column sm:flex-row justify-content-between align-items-start sm:align-items-center gap-3"
          style={{ marginBottom: '24px' }}
        >
          <div>
            <h1 className="text-2xl md:text-3xl font-bold text-900 m-0 tracking-tight">
              Portal Medis Dokter {session?.user?.nama_cabang ? `— ${session.user.nama_cabang}` : ''}
            </h1>
            <p className="text-xs md:text-sm m-0 mt-1" style={{ color: '#6F7A74' }}>
              Selamat datang, <strong style={{ color: '#202A26' }}>{userName}</strong> (Dokter Spesialis) — jadwal konsultasi &amp; rekam medis pasien hari ini.
            </p>
          </div>
          <div className="flex align-items-center gap-2">
            <button
              type="button"
              className="btn-primary-clinic"
              onClick={() => router.push('/pendaftaran-antrean/antrean?type=konsul')}
            >
              <i className="pi pi-comments mr-2" /> Antrean Konsultasi
            </button>
            <button
              type="button"
              className="btn-ghost-clinic"
              onClick={() => router.push('/riwayat/rekam-medis')}
            >
              <i className="pi pi-file mr-2" /> Rekam Medis
            </button>
            <button
              type="button"
              className="btn-icon-clinic"
              title="Segarkan data"
              onClick={fetchDashboardData}
            >
              <i className={`pi pi-refresh text-xs ${loading ? 'pi-spin' : ''}`} />
            </button>
          </div>
        </div>
        <DokterView data={dashboardData} onRefresh={fetchDashboardData} loading={loading} />
      </div>
    );
  }

  // ─── VIEW KHUSUS BEAUTICIAN / TERAPIS ───
  if (userRole === 'beautician') {
    return (
      <div className="clinic-dashboard w-full" style={{ backgroundColor: '#FFFFFF', padding: '24px' }}>
        <Toast ref={toast} />
        <div
          className="flex flex-column sm:flex-row justify-content-between align-items-start sm:align-items-center gap-3"
          style={{ marginBottom: '24px' }}
        >
          <div>
            <h1 className="text-2xl md:text-3xl font-bold text-900 m-0 tracking-tight">
              Portal Tindakan &amp; Terapi {session?.user?.nama_cabang ? `— ${session.user.nama_cabang}` : ''}
            </h1>
            <p className="text-xs md:text-sm m-0 mt-1" style={{ color: '#6F7A74' }}>
              Selamat datang, <strong style={{ color: '#202A26' }}>{userName}</strong> (Terapis &amp; Beautician) — antrean ruangan perawatan &amp; treatment estetika.
            </p>
          </div>
          <div className="flex align-items-center gap-2">
            <button
              type="button"
              className="btn-primary-clinic"
              onClick={() => router.push('/pendaftaran-antrean/antrean?type=layanan')}
            >
              <i className="pi pi-sparkles mr-2" /> Tindakan Perawatan
            </button>
            <button
              type="button"
              className="btn-icon-clinic"
              title="Segarkan data"
              onClick={fetchDashboardData}
            >
              <i className={`pi pi-refresh text-xs ${loading ? 'pi-spin' : ''}`} />
            </button>
          </div>
        </div>
        <BeauticianView data={dashboardData} onRefresh={fetchDashboardData} loading={loading} />
      </div>
    );
  }

  // ─── VIEW KHUSUS KASIR ───
  if (userRole === 'kasir') {
    return (
      <div className="clinic-dashboard w-full" style={{ backgroundColor: '#FFFFFF', padding: '24px' }}>
        <Toast ref={toast} />
        <div
          className="flex flex-column sm:flex-row justify-content-between align-items-start sm:align-items-center gap-3"
          style={{ marginBottom: '24px' }}
        >
          <div>
            <h1 className="text-2xl md:text-3xl font-bold text-900 m-0 tracking-tight">
              Terminal Kasir Klinik {session?.user?.nama_cabang ? `— ${session.user.nama_cabang}` : ''}
            </h1>
            <p className="text-xs md:text-sm m-0 mt-1" style={{ color: '#6F7A74' }}>
              Selamat datang, <strong style={{ color: '#202A26' }}>{userName}</strong> (Petugas Kasir) — transaksi pembayaran, kasir, dan ringkasan keuangan.
            </p>
          </div>
          <div className="flex align-items-center gap-2">
            <button
              type="button"
              className="btn-primary-clinic"
              onClick={() => router.push('/kasir')}
            >
              <i className="pi pi-calculator mr-2" /> Buka Kasir
            </button>
            <button
              type="button"
              className="btn-icon-clinic"
              title="Segarkan data"
              onClick={fetchDashboardData}
            >
              <i className={`pi pi-refresh text-xs ${loading ? 'pi-spin' : ''}`} />
            </button>
          </div>
        </div>
        <KasirView data={dashboardData} onRefresh={fetchDashboardData} loading={loading} />
      </div>
    );
  }

  // ─── VIEW KHUSUS WAREHOUSE / LOGISTIK ───
  if (userRole === 'warehouse') {
    return (
      <div className="clinic-dashboard w-full" style={{ backgroundColor: '#FFFFFF', padding: '24px' }}>
        <Toast ref={toast} />
        <div
          className="flex flex-column sm:flex-row justify-content-between align-items-start sm:align-items-center gap-3"
          style={{ marginBottom: '24px' }}
        >
          <div>
            <h1 className="text-2xl md:text-3xl font-bold text-900 m-0 tracking-tight">
              Manajemen Logistik &amp; Farmasi {session?.user?.nama_cabang ? `— ${session.user.nama_cabang}` : ''}
            </h1>
            <p className="text-xs md:text-sm m-0 mt-1" style={{ color: '#6F7A74' }}>
              Selamat datang, <strong style={{ color: '#202A26' }}>{userName}</strong> (Petugas Logistik &amp; Farmasi) — monitoring stok produk, inventori, dan pengadaan logistik.
            </p>
          </div>
          <div className="flex align-items-center gap-2">
            <button
              type="button"
              className="btn-primary-clinic"
              onClick={() => router.push('/master-data/produk')}
            >
              <i className="pi pi-box mr-2" /> Katalog Produk
            </button>
            <button
              type="button"
              className="btn-ghost-clinic"
              onClick={() => router.push('/master-data/inventori')}
            >
              <i className="pi pi-database mr-2" /> Stok Inventori
            </button>
            <button
              type="button"
              className="btn-icon-clinic"
              title="Segarkan data"
              onClick={fetchDashboardData}
            >
              <i className={`pi pi-refresh text-xs ${loading ? 'pi-spin' : ''}`} />
            </button>
          </div>
        </div>
        <WarehouseView data={dashboardData} onRefresh={fetchDashboardData} loading={loading} />
      </div>
    );
  }

  // ─── VIEW KHUSUS ADMIN (PENDAFTARAN & ANTREAN) ───
  if (userRole === 'admin') {
    return (
      <div className="clinic-dashboard w-full" style={{ backgroundColor: '#FFFFFF', padding: '24px' }}>
        <Toast ref={toast} />
        <div
          className="flex flex-column sm:flex-row justify-content-between align-items-start sm:align-items-center gap-3"
          style={{ marginBottom: '24px' }}
        >
          <div>
            <h1 className="text-2xl md:text-3xl font-bold text-900 m-0 tracking-tight">
              Portal Pendaftaran &amp; Front Office {session?.user?.nama_cabang ? `— ${session.user.nama_cabang}` : ''}
            </h1>
            <p className="text-xs md:text-sm m-0 mt-1" style={{ color: '#6F7A74' }}>
              Selamat datang, <strong style={{ color: '#202A26' }}>{userName}</strong> (Petugas Administrasi) — kelola antrean pendaftaran, pasien baru, dan pendaftaran kunjungan.
            </p>
          </div>
          <div className="flex align-items-center gap-2">
            <button
              type="button"
              className="btn-primary-clinic"
              onClick={() => router.push('/pendaftaran-antrean/pendaftaran-pasien')}
            >
              <i className="pi pi-calendar mr-2" /> Pendaftaran Kunjungan
            </button>
            <button
              type="button"
              className="btn-ghost-clinic"
              onClick={() => router.push('/antrian-awal')}
            >
              <i className="pi pi-ticket mr-2" /> Antrean Pendaftaran
            </button>
            <button
              type="button"
              className="btn-icon-clinic"
              title="Segarkan data"
              onClick={fetchDashboardData}
            >
              <i className={`pi pi-refresh text-xs ${loading ? 'pi-spin' : ''}`} />
            </button>
          </div>
        </div>
        <AdminView data={dashboardData} onRefresh={fetchDashboardData} loading={loading} />
      </div>
    );
  }

  // ─── VIEW OWNER / MANAGER / SUPERADMIN (EKSEKUTIF) ───
  const owner = dashboardData?.owner || {};
  const kpi = owner.kpi || {};
  const inventory = owner.inventory || {};
  const sdm = owner.sdm || {};

  const totalOmzet = parseFloat(kpi.omzet_total ?? 8205000);
  const omzetHariIni = parseFloat(kpi.omzet_hari_ini ?? 0);
  const totalPasien = parseInt(kpi.total_pasien ?? 8, 10);
  const kunjunganHariIni = parseInt(kpi.kunjungan_hari_ini ?? 4, 10);
  const totalLayanan = parseInt(kpi.total_layanan ?? 5, 10);
  const totalSku = parseInt(inventory.total_sku ?? 4, 10);
  const totalAset = parseFloat(inventory.total_aset ?? 900000);
  const stokMenipis = parseInt(inventory.stok_menipis ?? 1, 10);

  const paymentData = owner.metode_bayar || [];
  const topTreatments = owner.top_treatment || [];
  const doctors = sdm.dokter || [];
  const staff = sdm.beautician || [];

  const allCabang =
    cabangList.length > 0
      ? cabangList
      : dashboardData?.all_cabang || [
          { kode_cabang: 'CBG-001', nama_cabang: 'Klinik Cabang Utama', alamat: 'Kantor Pusat Klinik Kecantikan', no_telp: '081234567890' },
          { kode_cabang: 'CBG-002', nama_cabang: 'Klinik Cabang Surabaya', alamat: 'Jl. Pemuda No. 45, Surabaya', no_telp: '081298765432' },
        ];
  const cabangUtama = allCabang.find((c: any) => c.kode_cabang === 'CBG-001') || allCabang[0] || {};

  return (
    <div
      className="clinic-dashboard w-full"
      style={{
        backgroundColor: '#FFFFFF',
        padding: '0 24px 24px 24px',
      }}
    >
      <Toast ref={toast} />

      {/* ─── 1. TOPBAR & CABANG SELECTOR ─── */}
      <div
        className="card border-round-xl border-1 surface-border bg-white shadow-1 flex flex-column lg:flex-row justify-content-between align-items-start lg:align-items-center mb-4"
        style={{
          padding: '16px 22px',
          gap: '16px',
        }}
      >
        {/* Kolom Kiri: Detail Pusat / Cabang */}
        <div className="flex flex-column min-w-0">
          <h1 className="text-2xl md:text-3xl font-bold text-900 m-0 tracking-tight text-overflow-ellipsis overflow-hidden white-space-nowrap">
            {isSuperAdmin
              ? 'Klinik Kecantikan — Semua Cabang (Kantor Pusat)'
              : `Klinik Kecantikan ${session?.user?.nama_cabang ? `— ${session.user.nama_cabang}` : ''}`}
          </h1>

          <div
            className="flex flex-wrap align-items-center gap-3 text-xs md:text-sm m-0 mt-1"
            style={{ color: '#6F7A74' }}
          >
            <span className="flex align-items-center gap-1.5">
              <i className="pi pi-map-marker text-sm" style={{ color: '#066F47' }} />
              <span>
                {isSuperAdmin
                  ? (cabangUtama?.alamat || 'Kantor Pusat Klinik Kecantikan')
                  : (session?.user?.nama_cabang || 'Kantor Pusat')}
              </span>
            </span>
            <span className="flex align-items-center gap-1.5">
              <i className="pi pi-phone text-sm" style={{ color: '#066F47' }} />
              <span>{cabangUtama?.no_telp || '081234567890'}</span>
            </span>
            <span className="flex align-items-center gap-1.5">
              <i className="pi pi-user text-sm" style={{ color: '#066F47' }} />
              <span>
                PJ: <strong style={{ color: '#202A26', fontWeight: 700 }}>{userName} ({isSuperAdmin ? 'Superadmin' : 'Manager Klinik'})</strong>
              </span>
            </span>
          </div>
        </div>

        {/* Kolom Kanan: Tombol Refresh */}
        <div className="flex align-items-center gap-2 flex-shrink-0">
          {/* Tombol Refresh */}
          <button
            type="button"
            title="Segarkan data performa klinik"
            onClick={fetchDashboardData}
            style={{
              width: '38px',
              height: '38px',
              borderRadius: '10px',
              backgroundColor: '#FFFFFF',
              border: '1px solid #DDE8E3',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              transition: 'all 0.15s ease',
              boxShadow: '0 1px 2px rgba(0,0,0,0.03)',
            }}
            className="hover:surface-100"
          >
            <i
              className={`pi pi-refresh text-xs ${loading ? 'pi-spin' : ''}`}
              style={{ color: '#066F47' }}
            />
          </button>
        </div>
      </div>

      {/* ─── 2. HERO REVENUE + STAT STRIP ─── */}
      <div
        className="clinic-panel overflow-hidden bg-white"
        style={{ marginBottom: '24px' }}
      >
        <div className="clinic-top-card-grid">
          {/* Section Kiri: Hero Revenue */}
          <div className="clinic-hero-col">
            <RevenueHero totalOmzet={totalOmzet} omzetHariIni={omzetHariIni} />
          </div>

          {/* Section Kanan: 4 Metrik dipisah garis vertikal simetris */}
          <div className="w-full h-full">
            <StatStrip
              totalPasien={totalPasien}
              kunjunganHariIni={kunjunganHariIni}
              totalLayanan={totalLayanan}
              totalSku={totalSku}
              totalAset={totalAset}
              stokMenipis={stokMenipis}
              dokterCount={doctors.length || 3}
              beauticianCount={staff.length || 4}
            />
          </div>
        </div>
      </div>

      {/* ─── 3. DUA PANEL BERDAMPINGAN: KOMPOSISI & TOP TREATMENT ─── */}
      <div className="clinic-two-col-grid" style={{ marginBottom: '24px' }}>
        <PaymentDonutPanel paymentData={paymentData} totalOmzet={totalOmzet} />
        <TopTreatmentsPanel treatments={topTreatments} />
      </div>

      {/* ─── 4. LIVE TRACKING SELURUH AKTIVITAS CABANG (REAL-TIME FEED) ─── */}
      <BranchActivityFeed
        activities={activities}
        loading={activitiesLoading}
        subtitle="Monitoring real-time transaksi kasir, kunjungan pasien & reservasi booking di seluruh cabang klinik"
      />

      {/* ─── 5. PERBANDINGAN SEMUA CABANG (KHUSUS SUPERADMIN / PUSAT) ─── */}
      {isSuperAdmin && (
        <BranchComparisonSection refreshTrigger={refreshCounter} />
      )}
    </div>
  );
};

export default DashboardPage;