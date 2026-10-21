'use client';

import React, { useState, useEffect, useRef, use } from 'react';
import { useSession } from 'next-auth/react';
import { useRouter } from 'next/navigation';
import { Toast } from 'primereact/toast';
import { Skeleton } from 'primereact/skeleton';
import postData from '@/lib/axios/postData';
import { showError } from '@/lib/tools/generalTools';
import { formatRupiah } from '@/app/(main)/dashboard/components/RevenueHero';
import PaymentDonutPanel from '@/app/(main)/dashboard/components/PaymentDonutPanel';
import TopTreatmentsPanel from '@/app/(main)/dashboard/components/TopTreatmentsPanel';
import BranchActivityFeed from '@/app/(main)/dashboard/components/BranchActivityFeed';

interface PageProps {
  params: Promise<{ kode: string }>;
}

const getInitials = (fullName: string) => {
  if (!fullName) return '--';
  const clean = fullName.replace(/^(dr\.|drg\.|prof\.|ners\.)\s*/i, '').trim();
  const parts = clean.split(' ').filter(Boolean);
  if (parts.length === 0) return '--';
  if (parts.length === 1) return parts[0].substring(0, 2).toUpperCase();
  return (parts[0][0] + parts[1][0]).toUpperCase();
};

export default function DashboardCabangDetail({ params }: PageProps) {
  const resolvedParams = use(params);
  const kodeCabang = resolvedParams.kode || 'CBG-001';

  const { data: session, status: authStatus } = useSession();
  const router = useRouter();
  const toast = useRef<Toast>(null);

  const [loading, setLoading] = useState<boolean>(true);
  const [data, setData] = useState<any>(null);
  const [autoRefresh, setAutoRefresh] = useState<boolean>(true);
  const [lastUpdated, setLastUpdated] = useState<string>('');

  const formatCurrentTime = () => {
    const now = new Date();
    return (
      now.toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false }).replace(/\./g, ':') + ' WIB'
    );
  };

  const userRole = (session?.user?.role || '').toLowerCase();
  const isSuperAdmin = userRole === 'superadmin' || userRole === 'admin_pusat';

  // 1. Proteksi Akses: HANYA Superadmin yang berhak mengakses Dashboard Cabang
  useEffect(() => {
    if (authStatus === 'loading') return;
    if (!isSuperAdmin) {
      router.replace('/dashboard');
    }
  }, [authStatus, isSuperAdmin, router]);

  useEffect(() => {
    setLastUpdated(formatCurrentTime());
  }, []);

  // 2. Fetch Data Aktivitas & Metrik Cabang dari Backend
  const fetchCabangDetail = async () => {
    setLoading(true);
    try {
      const res = await postData('/master/dashboard/cabang-detail', {
        kode_cabang: kodeCabang,
        role: userRole,
      });

      if (['00', '0000', 200].includes(res?.data?.status) || res?.status === 200) {
        setData(res?.data?.data || null);
        setLastUpdated(formatCurrentTime());
      } else {
        showError(toast, res?.data?.message || 'Gagal memuat detail dashboard cabang');
      }
    } catch (err: any) {
      showError(toast, err?.response?.data?.message || err?.message || 'Terjadi kesalahan sistem');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (isSuperAdmin && kodeCabang) {
      fetchCabangDetail();
    }
  }, [kodeCabang, isSuperAdmin]);

  // Auto-refresh data aktivitas setiap 30 detik
  useEffect(() => {
    if (!autoRefresh || !isSuperAdmin) return;
    const interval = setInterval(() => {
      fetchCabangDetail();
    }, 30000);
    return () => clearInterval(interval);
  }, [autoRefresh, kodeCabang, isSuperAdmin]);

  // Loading skeleton screen
  if (authStatus === 'loading' || (loading && !data)) {
    return (
      <div className="clinic-dashboard w-full" style={{ backgroundColor: '#FFFFFF', padding: '0 24px 24px 24px' }}>
        <div className="flex justify-content-between align-items-center mb-4">
          <Skeleton width="320px" height="32px" />
          <Skeleton width="220px" height="36px" />
        </div>
        <Skeleton width="100%" height="160px" className="mb-4 border-round-lg" />
        <div className="clinic-two-col-grid mb-4">
          <Skeleton height="320px" className="border-round-lg" />
          <Skeleton height="320px" className="border-round-lg" />
        </div>
        <Skeleton width="100%" height="380px" className="border-round-lg" />
      </div>
    );
  }

  // Fallback proteksi non-superadmin
  if (!isSuperAdmin) {
    return (
      <div className="clinic-dashboard w-full min-h-screen flex flex-column align-items-center justify-content-center p-5 text-center">
        <div
          className="w-4rem h-4rem border-round-circle flex align-items-center justify-content-center mb-3"
          style={{ backgroundColor: '#FEE2E2', color: '#DC2626' }}
        >
          <i className="pi pi-lock text-2xl" />
        </div>
        <h2 className="text-900 font-bold mb-2">Akses Terbatas Superadmin</h2>
        <p className="text-600 mb-4 text-sm max-w-26rem">
          Fitur Dashboard Monitoring Cabang ini dirancang eksklusif untuk Superadmin pusat klinik.
        </p>
        <button
          type="button"
          className="btn-primary-clinic"
          onClick={() => router.push('/dashboard')}
        >
          <i className="pi pi-arrow-left text-xs mr-2" />
          Kembali ke Dashboard Utama
        </button>
      </div>
    );
  }

  const cabang = data?.cabang || {};
  const kpi = data?.kpi || {};
  const allCabang = data?.all_cabang || [
    { kode_cabang: 'CBG-001', nama_cabang: 'Klinik Cabang Utama' },
    { kode_cabang: 'CBG-002', nama_cabang: 'Klinik Cabang Surabaya' },
  ];
  const managers = data?.managers || [];
  const stafList = data?.staf_list || [];
  const ruanganList = data?.ruangan_list || [];
  const allActivities = data?.activities || [];
  const activeShift = data?.active_shift || null;

  const paymentDataFormatted = (data?.metode_bayar || []).map((m: any) => ({
    metode_bayar: m.metode_bayar,
    nominal: parseFloat(m.total || 0),
  }));

  const treatmentsFormatted = (data?.top_treatment || []).map((t: any) => ({
    nama_layanan: t.nama,
    total_sesi: parseInt(t.count || 0, 10),
  }));

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
        {/* Kolom Kiri: Detail Cabang */}
        <div className="flex flex-column min-w-0">
          {/* Judul Cabang */}
          <h1 className="text-2xl md:text-3xl font-bold text-900 m-0 tracking-tight text-overflow-ellipsis overflow-hidden white-space-nowrap">
            {cabang.nama_cabang || (kodeCabang === 'CBG-001' ? 'Klinik Cabang Utama' : 'Klinik Cabang Surabaya')}
          </h1>

          {/* Meta Info: Alamat (Jalan), Telp, PJ */}
          <div
            className="flex flex-wrap align-items-center gap-3 text-xs md:text-sm m-0 mt-1"
            style={{ color: '#6F7A74' }}
          >
            <span className="flex align-items-center gap-1.5">
              <i className="pi pi-map-marker text-sm" style={{ color: '#066F47' }} />
              <span>{cabang.alamat || 'Alamat cabang'}</span>
            </span>
            <span className="flex align-items-center gap-1.5">
              <i className="pi pi-phone text-sm" style={{ color: '#066F47' }} />
              <span>{cabang.no_telp || '-'}</span>
            </span>
            <span className="flex align-items-center gap-1.5">
              <i className="pi pi-user text-sm" style={{ color: '#066F47' }} />
              <span>
                PJ: <strong style={{ color: '#202A26', fontWeight: 700 }}>{cabang.pj_manager || managers[0]?.fullname || 'Manager Cabang'}</strong>
              </span>
            </span>
          </div>
        </div>

        {/* Kolom Kanan: Tombol Refresh */}
        <div className="flex align-items-center gap-2 flex-shrink-0">
          {/* Tombol Refresh */}
          <button
            type="button"
            title="Segarkan data aktivitas cabang"
            onClick={fetchCabangDetail}
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

      {/* ─── 2. HERO REVENUE & STAT STRIP ─── */}
      <div
        className="clinic-panel overflow-hidden bg-white"
        style={{ marginBottom: '24px' }}
      >
        <div className="clinic-top-card-grid">
          {/* Section Kiri: Hero Revenue Cabang */}
          <div className="clinic-hero-col">
            <div
              className="flex flex-column justify-content-between h-full"
              style={{
                padding: '24px 28px',
                background: 'linear-gradient(150deg, #FFFFFF 0%, #F6FAF8 100%)',
              }}
            >
              <div>
                <span
                  className="text-xs font-semibold tracking-wide block mb-2"
                  style={{ color: 'var(--primary-700, #047857)', height: '16px', lineHeight: '16px' }}
                >
                  Total omzet cabang
                </span>

                <div
                  className="text-3xl lg:text-4xl font-bold tracking-tight my-1 tabular-nums flex align-items-baseline"
                  style={{ color: 'var(--primary-900, #064e3b)', lineHeight: 1.1, minHeight: '40px' }}
                >
                  {formatRupiah(kpi.total_omzet || 0)}
                </div>

                <p className="text-xs m-0 mt-2 font-normal" style={{ color: '#6F7A74' }}>
                  Akumulasi omzet transaksi di cabang ini
                </p>
              </div>

              <div
                className="mt-4 pt-3 text-xs flex align-items-center gap-2"
                style={{
                  borderTop: '1px dashed #E5E7EB',
                  color: '#6F7A74',
                  minHeight: '20px',
                }}
              >
                <span
                  style={{
                    width: '6px',
                    height: '6px',
                    borderRadius: '50%',
                    backgroundColor: Number(kpi.omzet_hari_ini || 0) === 0 ? '#9AA39D' : 'var(--primary-color, #10b981)',
                    display: 'inline-block',
                    flexShrink: 0,
                  }}
                />
                <span>
                  {Number(kpi.omzet_hari_ini || 0) === 0
                    ? 'Hari ini: belum ada transaksi baru (Rp 0)'
                    : `Hari ini: ${formatRupiah(kpi.omzet_hari_ini || 0)}`}
                </span>
              </div>
            </div>
          </div>

          {/* Section Kanan: 4 Metrik Vertikal Simetris */}
          <div className="clinic-stat-strip-grid">
            {/* 1. Pasien & Kunjungan */}
            <div className="clinic-stat-col">
              <div>
                <span
                  className="text-xs font-medium block mb-2"
                  style={{ color: '#6F7A74', height: '16px', lineHeight: '16px' }}
                >
                  Kunjungan cabang
                </span>
                <div className="flex align-items-baseline gap-2 my-1" style={{ minHeight: '40px' }}>
                  <span
                    className="text-3xl lg:text-4xl font-bold tabular-nums"
                    style={{ color: '#202A26', lineHeight: 1.1 }}
                  >
                    {kpi.kunjungan_hari_ini || 0}
                  </span>
                  <span className="text-xs font-normal" style={{ color: '#6F7A74', alignSelf: 'baseline' }}>
                    kunjungan hari ini
                  </span>
                </div>
              </div>

              <div
                className="text-xs font-medium"
                style={{
                  color: 'var(--primary-700, #047857)',
                  marginTop: '16px',
                  paddingTop: '12px',
                  minHeight: '20px',
                  display: 'flex',
                  alignItems: 'center',
                  whiteSpace: 'nowrap',
                }}
              >
                {kpi.total_pasien || 0} pasien terdaftar
              </div>
            </div>

            {/* 2. Aktivitas Transaksi */}
            <div className="clinic-stat-col">
              <div>
                <span
                  className="text-xs font-medium block mb-2"
                  style={{ color: '#6F7A74', height: '16px', lineHeight: '16px' }}
                >
                  Transaksi kasir
                </span>
                <div className="flex align-items-baseline gap-2 my-1" style={{ minHeight: '40px' }}>
                  <span
                    className="text-3xl lg:text-4xl font-bold tabular-nums"
                    style={{ color: '#202A26', lineHeight: 1.1 }}
                  >
                    {kpi.transaksi_hari_ini || 0}
                  </span>
                  <span className="text-xs font-normal" style={{ color: '#6F7A74', alignSelf: 'baseline' }}>
                    transaksi hari ini
                  </span>
                </div>
              </div>

              <div
                className="text-xs font-medium"
                style={{
                  color: 'var(--primary-700, #047857)',
                  marginTop: '16px',
                  paddingTop: '12px',
                  minHeight: '20px',
                  display: 'flex',
                  alignItems: 'center',
                  whiteSpace: 'nowrap',
                }}
              >
                {kpi.total_transaksi || 0} invoice terbit
              </div>
            </div>

            {/* 3. Tenaga Medis & Karyawan */}
            <div className="clinic-stat-col">
              <div>
                <span
                  className="text-xs font-medium block mb-2"
                  style={{ color: '#6F7A74', height: '16px', lineHeight: '16px' }}
                >
                  SDM operasional
                </span>
                <div className="flex align-items-baseline gap-2 my-1" style={{ minHeight: '40px' }}>
                  <span
                    className="text-3xl lg:text-4xl font-bold tabular-nums"
                    style={{ color: '#202A26', lineHeight: 1.1 }}
                  >
                    {kpi.total_staf || 0}
                  </span>
                  <span className="text-xs font-normal" style={{ color: '#6F7A74', alignSelf: 'baseline' }}>
                    staf aktif
                  </span>
                </div>
              </div>

              <div
                className="text-xs font-medium"
                style={{
                  color: 'var(--primary-700, #047857)',
                  marginTop: '16px',
                  paddingTop: '12px',
                  minHeight: '20px',
                  display: 'flex',
                  alignItems: 'center',
                  whiteSpace: 'nowrap',
                }}
              >
                {kpi.total_dokter || 0} dr • {kpi.total_beautician || 0} terapis
              </div>
            </div>

            {/* 4. Ruangan & Shift */}
            <div className="clinic-stat-col">
              <div>
                <span
                  className="text-xs font-medium block mb-2"
                  style={{ color: '#6F7A74', height: '16px', lineHeight: '16px' }}
                >
                  Fasilitas &amp; Shift
                </span>
                <div className="flex align-items-baseline gap-2 my-1" style={{ minHeight: '40px' }}>
                  <span
                    className="text-3xl lg:text-4xl font-bold tabular-nums"
                    style={{ color: '#202A26', lineHeight: 1.1 }}
                  >
                    {kpi.total_ruangan || 0}
                  </span>
                  <span className="text-xs font-normal" style={{ color: '#6F7A74', alignSelf: 'baseline' }}>
                    ruang perawatan
                  </span>
                </div>
              </div>

              <div
                className="text-xs font-medium"
                style={{
                  color: activeShift ? 'var(--primary-700, #047857)' : '#9AA39D',
                  marginTop: '16px',
                  paddingTop: '12px',
                  minHeight: '20px',
                  display: 'flex',
                  alignItems: 'center',
                  whiteSpace: 'nowrap',
                }}
              >
                <span
                  style={{
                    width: '6px',
                    height: '6px',
                    borderRadius: '50%',
                    backgroundColor: activeShift ? '#10b981' : '#9AA39D',
                    display: 'inline-block',
                    marginRight: '6px',
                  }}
                />
                Shift: {activeShift ? 'Sedang Dibuka' : 'Belum Dibuka'}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* ─── 3. DUA PANEL BERDAMPINGAN: KOMPOSISI & TOP TREATMENT ─── */}
      <div
        className="clinic-two-col-grid"
        style={{ marginBottom: '24px' }}
      >
        <PaymentDonutPanel paymentData={paymentDataFormatted} totalOmzet={kpi.total_omzet || 0} />
        <TopTreatmentsPanel treatments={treatmentsFormatted} />
      </div>

      {/* ─── 4. LIVE TRACKING SELURUH AKTIVITAS CABANG (REAL-TIME FEED) ─── */}
      <BranchActivityFeed
        activities={allActivities}
        subtitle={`Monitoring real-time transaksi kasir, kunjungan pasien & reservasi booking di ${cabang.nama_cabang || 'Klinik Cabang Utama'}`}
        loading={loading}
      />

      {/* ─── 5. DUA PANEL: TIM MEDIS/STAF & KETERSEDIAAN RUANGAN ─── */}
      <div className="clinic-two-col-grid">
        {/* Panel 1: Tim Medis & Karyawan Cabang */}
        <div
          className="clinic-panel bg-white h-full flex flex-column justify-content-between"
          style={{ padding: '24px' }}
        >
          <div>
            <div className="clinic-card-header mb-3">
              <div className="flex align-items-center gap-2">
                <span
                  className="flex align-items-center justify-content-center border-round-md flex-shrink-0"
                  style={{
                    width: '28px',
                    height: '28px',
                    backgroundColor: '#ECFDF5',
                    color: '#047857',
                    border: '1px solid #A7F3D0',
                  }}
                >
                  <i className="pi pi-users text-sm" />
                </span>
                <h3 className="clinic-card-title text-base font-bold text-900 m-0">
                  Tenaga Medis &amp; Karyawan
                </h3>
              </div>
              <span className="clinic-pill clinic-pill-emerald">
                {stafList.length} personel
              </span>
            </div>

            {/* Table Header */}
            <div
              className="grid m-0 px-3 py-2 border-round-lg text-xs font-semibold text-600 mb-2 align-items-center"
              style={{ backgroundColor: '#F8FAFC', border: '1px solid #E2E8F0' }}
            >
              <div className="col-6 p-0 text-left font-bold text-700">Nama Personel</div>
              <div className="col-3 p-0 text-center font-bold text-700">Peran</div>
              <div className="col-3 p-0 text-right font-bold text-700">Status</div>
            </div>

            {stafList.length === 0 ? (
              <div className="text-center py-5 text-xs text-500">
                Belum ada data personel terdaftar di cabang ini.
              </div>
            ) : (
              <div className="flex flex-column gap-1 overflow-y-auto pr-1" style={{ maxHeight: '280px' }}>
                {stafList.map((s: any) => {
                  const roleLower = (s.jabatan || '').toLowerCase();
                  let pillRole = 'clinic-pill-role-terapis';
                  if (roleLower.includes('dokter')) pillRole = 'clinic-pill-role-dokter';
                  else if (roleLower.includes('perawat')) pillRole = 'clinic-pill-role-perawat';

                  return (
                    <div
                      key={s.id || s.kode_karyawan}
                      className="clinic-table-row grid m-0 align-items-center p-2 border-round-lg"
                    >
                      <div className="col-6 p-0 flex align-items-center gap-2">
                        <div
                          className="clinic-avatar"
                          style={{
                            backgroundColor: roleLower.includes('dokter') ? '#ECFDF5' : '#F5F3FF',
                            color: roleLower.includes('dokter') ? '#047857' : '#6D28D9',
                            border: `1px solid ${roleLower.includes('dokter') ? '#A7F3D0' : '#DDD6FE'}`,
                          }}
                        >
                          {getInitials(s.nama || '')}
                        </div>
                        <div className="truncate pr-1">
                          <span className="text-xs font-semibold block text-900 truncate" title={s.nama}>
                            {s.nama}
                          </span>
                          <span className="text-xs text-500 block truncate" style={{ fontSize: '11px' }}>
                            {s.no_hp || s.email || '-'}
                          </span>
                        </div>
                      </div>

                      <div className="col-3 p-0 text-center">
                        <span
                          className={`clinic-pill ${pillRole}`}
                          style={{ fontSize: '10px', height: '20px', padding: '2px 8px' }}
                        >
                          {s.jabatan || 'Staf'}
                        </span>
                      </div>

                      <div className="col-3 p-0 text-right">
                        <span
                          className={`clinic-pill ${
                            s.status === 'aktif' ? 'clinic-pill-emerald' : 'bg-gray-100 text-600'
                          }`}
                          style={{ fontSize: '10px', height: '20px', padding: '2px 8px' }}
                        >
                          {String(s.status || 'aktif').toUpperCase()}
                        </span>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </div>

        {/* Panel 2: Ketersediaan Ruangan Cabang */}
        <div
          className="clinic-panel bg-white h-full flex flex-column justify-content-between"
          style={{ padding: '24px' }}
        >
          <div>
            <div className="clinic-card-header mb-3">
              <div className="flex align-items-center gap-2">
                <span
                  className="flex align-items-center justify-content-center border-round-md flex-shrink-0"
                  style={{
                    width: '28px',
                    height: '28px',
                    backgroundColor: '#FEF3C7',
                    color: '#B45309',
                    border: '1px solid #FDE68A',
                  }}
                >
                  <i className="pi pi-building text-sm" />
                </span>
                <h3 className="clinic-card-title text-base font-bold text-900 m-0">
                  Fasilitas &amp; Ruangan Cabang
                </h3>
              </div>
              <span className="clinic-pill clinic-pill-gold">
                {ruanganList.length} ruangan
              </span>
            </div>

            {/* Table Header */}
            <div
              className="grid m-0 px-3 py-2 border-round-lg text-xs font-semibold text-600 mb-2 align-items-center"
              style={{ backgroundColor: '#F8FAFC', border: '1px solid #E2E8F0' }}
            >
              <div className="col-6 p-0 text-left font-bold text-700">Nama Ruangan</div>
              <div className="col-3 p-0 text-center font-bold text-700">Tipe Fasilitas</div>
              <div className="col-3 p-0 text-right font-bold text-700">Status</div>
            </div>

            {ruanganList.length === 0 ? (
              <div className="text-center py-5 text-xs text-500">
                Belum ada data ruangan terdaftar di cabang ini.
              </div>
            ) : (
              <div className="flex flex-column gap-1 overflow-y-auto pr-1" style={{ maxHeight: '280px' }}>
                {ruanganList.map((r: any) => {
                  const isKonsul = r.is_konsultasi === 1 || r.is_konsultasi === '1';

                  return (
                    <div
                      key={r.id || r.kode_ruangan}
                      className="clinic-table-row grid m-0 align-items-center p-2 border-round-lg"
                    >
                      <div className="col-6 p-0 flex align-items-center gap-2">
                        <div
                          className="clinic-avatar"
                          style={{
                            backgroundColor: isKonsul ? '#EFF6FF' : '#ECFDF5',
                            color: isKonsul ? '#1D4ED8' : '#047857',
                            border: `1px solid ${isKonsul ? '#BFDBFE' : '#A7F3D0'}`,
                          }}
                        >
                          <i className={`pi ${isKonsul ? 'pi-user-md' : 'pi-sparkles'} text-xs`} />
                        </div>
                        <div className="truncate pr-1">
                          <span className="text-xs font-semibold block text-900 truncate">
                            {r.nama_ruangan}
                          </span>
                          <span className="text-xs text-500 block truncate" style={{ fontSize: '11px' }}>
                            Kode: {r.kode_ruangan}
                          </span>
                        </div>
                      </div>

                      <div className="col-3 p-0 text-center">
                        <span
                          className={`clinic-pill ${isKonsul ? 'clinic-pill-role-perawat' : 'clinic-pill-emerald'}`}
                          style={{ fontSize: '10px', height: '20px', padding: '2px 8px' }}
                        >
                          {isKonsul ? 'Konsultasi' : 'Tindakan'}
                        </span>
                      </div>

                      <div className="col-3 p-0 text-right">
                        <span
                          className={`clinic-pill ${
                            r.status === 'aktif' ? 'clinic-pill-emerald' : 'bg-gray-100 text-600'
                          }`}
                          style={{ fontSize: '10px', height: '20px', padding: '2px 8px' }}
                        >
                          {String(r.status || 'aktif').toUpperCase()}
                        </span>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
