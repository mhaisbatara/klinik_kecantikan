'use client';

import React, { useState, useEffect, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { Skeleton } from 'primereact/skeleton';
import { Chart } from 'primereact/chart';
import postData from '@/lib/axios/postData';
import { formatRupiah } from './RevenueHero';

interface TreatmentItem {
  layanan_id?: number | string;
  nama_layanan?: string;
  kategori?: string;
  total_sesi?: number;
}

interface CabangMetodeBayar {
  tunai: number;
  qris: number;
  debit: number;
}

interface CabangComparisonItem {
  kode_cabang: string;
  nama_cabang: string;
  alamat?: string;
  no_telp?: string;
  omzet: number;
  transaksi_count: number;
  pasien_count: number;
  kunjungan_hari_ini: number;
  dokter_count: number;
  beautician_count: number;
  total_staf: number;
  shift_aktif: boolean;
  shift_status: string;
  kontribusi_pct: number;
  rank: number;
  is_top: boolean;
  metode_bayar: CabangMetodeBayar;
  top_treatments: TreatmentItem[];
}

interface ComparisonSummary {
  total_omzet: number;
  total_pasien: number;
  total_kunjungan_hari_ini: number;
  total_transaksi: number;
  total_staf: number;
  total_cabang: number;
  top_cabang: {
    kode_cabang: string;
    nama_cabang: string;
    omzet: number;
  } | null;
}

interface BranchComparisonSectionProps {
  refreshTrigger?: number;
}

type PeriodeType = 'today' | '7d' | '30d' | 'this_month' | 'all';

const PERIODE_OPTIONS: { key: PeriodeType; label: string }[] = [
  { key: 'today', label: 'Hari ini' },
  { key: '7d', label: '7 hari' },
  { key: '30d', label: '30 hari' },
  { key: 'this_month', label: 'Bulan ini' },
  { key: 'all', label: 'Semua' },
];

export const BranchComparisonSection: React.FC<BranchComparisonSectionProps> = ({
  refreshTrigger = 0,
}) => {
  const router = useRouter();

  const [periode, setPeriode] = useState<PeriodeType>('all');
  const [loading, setLoading] = useState<boolean>(true);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  const [cabangList, setCabangList] = useState<CabangComparisonItem[]>([]);
  const [summary, setSummary] = useState<ComparisonSummary>({
    total_omzet: 0,
    total_pasien: 0,
    total_kunjungan_hari_ini: 0,
    total_transaksi: 0,
    total_staf: 0,
    total_cabang: 0,
    top_cabang: null,
  });

  const fetchComparison = useCallback(async (currentPeriode: PeriodeType) => {
    setLoading(true);
    setErrorMsg(null);
    try {
      let res;
      try {
        res = await postData('/master/dashboard/perbandingan-cabang', {
          periode: currentPeriode,
        });
      } catch (firstErr: any) {
        // Fallback jika alias /dashboard/perbandingan-cabang digunakan
        if (firstErr?.response?.status === 404 || firstErr?.status === 404) {
          res = await postData('/dashboard/perbandingan-cabang', {
            periode: currentPeriode,
          });
        } else {
          throw firstErr;
        }
      }

      if (['00', '0000', 200].includes(res?.data?.status) || res?.status === 200) {
        const payload = res?.data?.data || {};
        const rawBranches = Array.isArray(payload.branches)
          ? payload.branches
          : Array.isArray(payload.cabang)
          ? payload.cabang
          : [];
        const branches: CabangComparisonItem[] = rawBranches.map((c: any) => {
          const omzet = Number(c.total_omzet ?? c.omzet ?? 0);
          const qris = Number(c.metode_komposisi?.QRIS ?? c.metode_bayar?.qris ?? 0);
          const debit = Number(c.metode_komposisi?.Debit ?? c.metode_bayar?.debit ?? 0);
          const tunai = Number(c.metode_komposisi?.Tunai ?? c.metode_bayar?.tunai ?? 0);
          const shiftAktif = Boolean(c.has_active_shift ?? c.shift_aktif);
          const shiftStatus = c.status_shift || c.shift_status || (shiftAktif ? 'Shift Aktif' : 'Tutup');
          const isTop = Boolean(c.is_top_performer ?? c.is_top);
          const kontribusiPct = Number(c.persentase_kontribusi ?? c.kontribusi_pct ?? 0);

          return {
            kode_cabang: c.kode_cabang,
            nama_cabang: c.nama_cabang,
            alamat: c.alamat,
            no_telp: c.no_telp,
            omzet,
            transaksi_count: Number(c.total_transaksi ?? c.transaksi_count ?? 0),
            pasien_count: Number(c.total_pasien ?? c.pasien_count ?? 0),
            kunjungan_hari_ini: Number(c.kunjungan_hari_ini ?? 0),
            dokter_count: Number(c.total_dokter ?? c.dokter_count ?? 0),
            beautician_count: Number(c.total_beautician ?? c.beautician_count ?? 0),
            total_staf: Number(c.total_staf ?? 0),
            shift_aktif: shiftAktif,
            shift_status: shiftStatus,
            kontribusi_pct: kontribusiPct,
            rank: Number(c.rank || 1),
            is_top: isTop,
            metode_bayar: { tunai, qris, debit },
            top_treatments: Array.isArray(c.top_treatments) ? c.top_treatments : [],
          };
        });

        setCabangList(branches);

        if (payload.summary) {
          const s = payload.summary;
          const topCabangCandidate =
            typeof s.top_cabang === 'string'
              ? branches.find((b) => b.nama_cabang === s.top_cabang) || branches.find((b) => b.is_top)
              : s.top_cabang || branches.find((b) => b.is_top);

          setSummary({
            total_omzet: Number(s.total_omzet || 0),
            total_pasien: Number(s.total_pasien || 0),
            total_kunjungan_hari_ini: Number(s.total_kunjungan_hari_ini || 0),
            total_transaksi: Number(s.total_transaksi || 0),
            total_staf: Number(s.total_staf || 0),
            total_cabang: Number(s.total_cabang || branches.length),
            top_cabang: topCabangCandidate
              ? {
                  kode_cabang: topCabangCandidate.kode_cabang || '',
                  nama_cabang: topCabangCandidate.nama_cabang || String(s.top_cabang),
                  omzet: Number(topCabangCandidate.omzet || 0),
                }
              : null,
          });
        }
      } else {
        setErrorMsg(res?.data?.message || 'Gagal memuat perbandingan cabang');
      }
    } catch (err: any) {
      console.error('Error fetch perbandingan cabang:', err);
      setErrorMsg(err?.response?.data?.message || err?.message || 'Gagal terhubung ke server');
    } finally {
      setLoading(false);
    }
  }, []);

  // Fetch when periode changes
  useEffect(() => {
    fetchComparison(periode);
  }, [periode, fetchComparison]);

  // Synchronize when parent refresh button is clicked
  useEffect(() => {
    if (refreshTrigger > 0) {
      fetchComparison(periode);
    }
  }, [refreshTrigger, fetchComparison, periode]);

  // Chart 1: Omzet Bar Chart per Cabang
  const omzetChartData = {
    labels: cabangList.map((c) => c.nama_cabang.replace(/^Klinik\s+/i, '')),
    datasets: [
      {
        label: 'Total Omzet (Rp)',
        backgroundColor: cabangList.map((c) => (c.is_top ? '#066F47' : '#10B981')),
        hoverBackgroundColor: cabangList.map((c) => (c.is_top ? '#045335' : '#059669')),
        borderRadius: 8,
        data: cabangList.map((c) => Number(c.omzet || 0)),
        barPercentage: 0.5,
      },
    ],
  };

  const omzetChartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: false },
      tooltip: {
        backgroundColor: '#0f172a',
        padding: 10,
        cornerRadius: 8,
        callbacks: {
          label: (context: any) => ` Omzet: ${formatRupiah(context.parsed.y)}`,
        },
      },
    },
    scales: {
      x: {
        ticks: { font: { family: 'Plus Jakarta Sans', size: 11, weight: '600' }, color: '#334155' },
        grid: { display: false },
      },
      y: {
        ticks: {
          font: { family: 'Plus Jakarta Sans', size: 10 },
          color: '#64748b',
          callback: (val: any) => {
            if (val >= 1000000000) return `Rp ${(val / 1000000000).toFixed(1)}M`;
            if (val >= 1000000) return `Rp ${(val / 1000000).toFixed(1)}Jt`;
            if (val >= 1000) return `Rp ${(val / 1000).toFixed(0)}Rb`;
            return `Rp ${val}`;
          },
        },
        grid: { color: '#f1f5f9' },
      },
    },
  };

  // Chart 2: Komposisi Metode Bayar per Cabang (Stacked Bar)
  const paymentChartData = {
    labels: cabangList.map((c) => c.nama_cabang.replace(/^Klinik\s+/i, '')),
    datasets: [
      {
        label: 'QRIS',
        backgroundColor: '#10b981',
        borderRadius: 6,
        data: cabangList.map((c) => Number(c.metode_bayar?.qris || 0)),
      },
      {
        label: 'Debit',
        backgroundColor: '#B3873F',
        borderRadius: 6,
        data: cabangList.map((c) => Number(c.metode_bayar?.debit || 0)),
      },
      {
        label: 'Tunai',
        backgroundColor: '#34d399',
        borderRadius: 6,
        data: cabangList.map((c) => Number(c.metode_bayar?.tunai || 0)),
      },
    ],
  };

  const paymentChartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'top' as const,
        labels: {
          font: { family: 'Plus Jakarta Sans', size: 11, weight: '600' },
          boxWidth: 12,
          usePointStyle: true,
        },
      },
      tooltip: {
        backgroundColor: '#0f172a',
        padding: 10,
        cornerRadius: 8,
        callbacks: {
          label: (context: any) => ` ${context.dataset.label}: ${formatRupiah(context.parsed.y)}`,
        },
      },
    },
    scales: {
      x: {
        stacked: true,
        ticks: { font: { family: 'Plus Jakarta Sans', size: 11, weight: '600' }, color: '#334155' },
        grid: { display: false },
      },
      y: {
        stacked: true,
        ticks: {
          font: { family: 'Plus Jakarta Sans', size: 10 },
          color: '#64748b',
          callback: (val: any) => {
            if (val >= 1000000000) return `Rp ${(val / 1000000000).toFixed(1)}M`;
            if (val >= 1000000) return `Rp ${(val / 1000000).toFixed(1)}Jt`;
            if (val >= 1000) return `Rp ${(val / 1000).toFixed(0)}Rb`;
            return `Rp ${val}`;
          },
        },
        grid: { color: '#f1f5f9' },
      },
    },
  };

  // Active shift count
  const activeShiftCount = cabangList.filter((c) => c.shift_aktif).length;

  return (
    <div className="flex flex-column w-full" style={{ gap: '24px', marginBottom: '24px' }}>
      {/* ─── 1. SECTION HEADER + PERIODE FILTER ─── */}
      <div
        className="card border-round-xl border-1 surface-border bg-white shadow-1 flex flex-column md:flex-row justify-content-between align-items-start md:align-items-center gap-3 m-0"
        style={{ padding: '16px 22px', marginBottom: 0 }}
      >
        <div>
          <div className="flex align-items-center gap-2">
            <h2 className="text-xl md:text-2xl font-bold text-900 m-0 tracking-tight">
              Perbandingan Semua Cabang
            </h2>
            <span
              className="inline-flex align-items-center px-2 py-0.5 rounded-full text-xs font-bold"
              style={{ backgroundColor: '#E8F5E9', color: '#066F47' }}
            >
              Multi-Branch
            </span>
          </div>
          <p className="text-xs md:text-sm m-0 mt-1" style={{ color: '#6F7A74' }}>
            Komparasi performa omzet, kunjungan pasien, transaksi, dan produktivitas staf antar cabang klinik.
          </p>
        </div>

        {/* Filter Periode & Refresh */}
        <div className="flex align-items-center gap-2 flex-wrap">
          <div
            style={{
              backgroundColor: '#EDF3EE',
              padding: '3px',
              borderRadius: '10px',
              display: 'inline-flex',
              alignItems: 'center',
              gap: '2px',
            }}
          >
            {PERIODE_OPTIONS.map((opt) => {
              const isActive = periode === opt.key;
              return (
                <button
                  key={opt.key}
                  type="button"
                  onClick={() => setPeriode(opt.key)}
                  className="transition-all border-none cursor-pointer text-xs"
                  style={{
                    height: '32px',
                    padding: '0 12px',
                    borderRadius: '7px',
                    backgroundColor: isActive ? '#066F47' : 'transparent',
                    color: isActive ? '#FFFFFF' : '#4B5563',
                    fontWeight: isActive ? 700 : 500,
                    boxShadow: isActive ? '0 1px 3px rgba(6, 111, 71, 0.25)' : 'none',
                    display: 'inline-flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  {opt.label}
                </button>
              );
            })}
          </div>

          <button
            type="button"
            title="Segarkan data perbandingan"
            onClick={() => fetchComparison(periode)}
            style={{
              width: '36px',
              height: '36px',
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

      {/* ERROR STATE */}
      {errorMsg && (
        <div
          className="border-round-lg p-3 flex align-items-center justify-content-between"
          style={{ backgroundColor: '#FEF2F2', border: '1px solid #FCA5A5', color: '#991B1B' }}
        >
          <div className="flex align-items-center gap-2 text-xs md:text-sm">
            <i className="pi pi-exclamation-circle text-base" />
            <span>{errorMsg}</span>
          </div>
          <button
            type="button"
            className="btn-ghost-clinic text-xs py-1 px-3"
            style={{ borderColor: '#F87171', color: '#991B1B' }}
            onClick={() => fetchComparison(periode)}
          >
            Coba Lagi
          </button>
        </div>
      )}

      {/* ─── 2. TABEL PERBANDINGAN CABANG ─── */}
      <div className="clinic-panel bg-white overflow-hidden" style={{ padding: '24px' }}>
        <div className="clinic-card-header mb-3">
          <div>
            <h3 className="clinic-card-title">Tabel Perbandingan Antar Cabang</h3>
            <span className="text-xs" style={{ color: '#6F7A74' }}>
              Klik nama cabang untuk membuka dashboard operasional spesifik cabang
            </span>
          </div>
          <span className="clinic-pill clinic-pill-emerald">
            {cabangList.length} Cabang Terdata
          </span>
        </div>

        {/* Tabel Responsif dengan Horizontal Scroll */}
        <div className="w-full overflow-x-auto" style={{ WebkitOverflowScrolling: 'touch' }}>
          <table
            className="w-full text-left"
            style={{
              borderCollapse: 'collapse',
              minWidth: '780px',
              fontFamily: 'inherit',
            }}
          >
            <thead>
              <tr
                style={{
                  borderBottom: '2px solid #E5E7EB',
                  backgroundColor: '#F8FAF9',
                }}
              >
                <th
                  style={{
                    padding: '12px 16px',
                    fontSize: '11px',
                    fontWeight: 700,
                    color: '#4B5563',
                    textTransform: 'uppercase',
                    letterSpacing: '0.05em',
                  }}
                >
                  Cabang Klinik
                </th>
                <th
                  style={{
                    padding: '12px 16px',
                    fontSize: '11px',
                    fontWeight: 700,
                    color: '#4B5563',
                    textTransform: 'uppercase',
                    letterSpacing: '0.05em',
                    textAlign: 'right',
                  }}
                >
                  Total Omzet
                </th>
                <th
                  style={{
                    padding: '12px 16px',
                    fontSize: '11px',
                    fontWeight: 700,
                    color: '#4B5563',
                    textTransform: 'uppercase',
                    letterSpacing: '0.05em',
                    textAlign: 'center',
                  }}
                >
                  Kontribusi
                </th>
                <th
                  style={{
                    padding: '12px 16px',
                    fontSize: '11px',
                    fontWeight: 700,
                    color: '#4B5563',
                    textTransform: 'uppercase',
                    letterSpacing: '0.05em',
                    textAlign: 'right',
                  }}
                >
                  Pasien
                </th>
                <th
                  style={{
                    padding: '12px 16px',
                    fontSize: '11px',
                    fontWeight: 700,
                    color: '#4B5563',
                    textTransform: 'uppercase',
                    letterSpacing: '0.05em',
                    textAlign: 'right',
                  }}
                >
                  Kunjungan Hari Ini
                </th>
                <th
                  style={{
                    padding: '12px 16px',
                    fontSize: '11px',
                    fontWeight: 700,
                    color: '#4B5563',
                    textTransform: 'uppercase',
                    letterSpacing: '0.05em',
                    textAlign: 'right',
                  }}
                >
                  Transaksi Kasir
                </th>
                <th
                  style={{
                    padding: '12px 16px',
                    fontSize: '11px',
                    fontWeight: 700,
                    color: '#4B5563',
                    textTransform: 'uppercase',
                    letterSpacing: '0.05em',
                    textAlign: 'center',
                  }}
                >
                  Staf Aktif
                </th>
                <th
                  style={{
                    padding: '12px 16px',
                    fontSize: '11px',
                    fontWeight: 700,
                    color: '#4B5563',
                    textTransform: 'uppercase',
                    letterSpacing: '0.05em',
                    textAlign: 'center',
                  }}
                >
                  Status Shift
                </th>
                <th
                  style={{
                    padding: '12px 16px',
                    fontSize: '11px',
                    fontWeight: 700,
                    color: '#4B5563',
                    textTransform: 'uppercase',
                    letterSpacing: '0.05em',
                    textAlign: 'center',
                  }}
                >
                  Aksi
                </th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                // Skeleton Rows
                Array.from({ length: 3 }).map((_, i) => (
                  <tr key={i} style={{ borderBottom: '1px solid #F1F5F9' }}>
                    <td style={{ padding: '14px 16px' }}>
                      <Skeleton width="180px" height="20px" className="mb-1" />
                      <Skeleton width="90px" height="14px" />
                    </td>
                    <td style={{ padding: '14px 16px' }}>
                      <Skeleton width="110px" height="20px" className="ml-auto" />
                    </td>
                    <td style={{ padding: '14px 16px' }}>
                      <Skeleton width="60px" height="18px" className="mx-auto" />
                    </td>
                    <td style={{ padding: '14px 16px' }}>
                      <Skeleton width="50px" height="18px" className="ml-auto" />
                    </td>
                    <td style={{ padding: '14px 16px' }}>
                      <Skeleton width="50px" height="18px" className="ml-auto" />
                    </td>
                    <td style={{ padding: '14px 16px' }}>
                      <Skeleton width="50px" height="18px" className="ml-auto" />
                    </td>
                    <td style={{ padding: '14px 16px' }}>
                      <Skeleton width="70px" height="18px" className="mx-auto" />
                    </td>
                    <td style={{ padding: '14px 16px' }}>
                      <Skeleton width="80px" height="22px" className="mx-auto" />
                    </td>
                    <td style={{ padding: '14px 16px' }}>
                      <Skeleton width="70px" height="24px" className="mx-auto" />
                    </td>
                  </tr>
                ))
              ) : cabangList.length === 0 ? (
                <tr>
                  <td colSpan={9} style={{ padding: '32px', textAlign: 'center', color: '#6F7A74' }}>
                    Tidak ada data cabang yang ditemukan.
                  </td>
                </tr>
              ) : (
                cabangList.map((c) => {
                  return (
                    <tr
                      key={c.kode_cabang}
                      style={{
                        borderBottom: '1px solid #F1F5F9',
                        transition: 'background-color 0.15s ease',
                      }}
                      className="hover:surface-50"
                    >
                      {/* Cabang Klinik */}
                      <td style={{ padding: '14px 16px' }}>
                        <div className="flex flex-column">
                          <div className="flex align-items-center gap-2">
                            <button
                              type="button"
                              onClick={() => router.push(`/dashboard/cabang/${c.kode_cabang}`)}
                              className="font-bold text-sm text-left border-none bg-transparent p-0 cursor-pointer text-slate-800 hover:text-emerald-700 transition-colors"
                              style={{ textDecoration: 'none' }}
                            >
                              {c.nama_cabang}
                            </button>
                          </div>
                          <span className="text-xs font-mono text-slate-400 mt-0.5">
                            {c.kode_cabang} · {c.alamat || 'Alamat cabang'}
                          </span>
                        </div>
                      </td>

                      {/* Total Omzet */}
                      <td style={{ padding: '14px 16px', textAlign: 'right' }}>
                        <strong className="text-sm font-bold text-slate-900 tabular-nums block">
                          {formatRupiah(c.omzet)}
                        </strong>
                      </td>

                      {/* Kontribusi */}
                      <td style={{ padding: '14px 16px', textAlign: 'center' }}>
                        <div className="inline-flex flex-column align-items-center gap-1">
                          <span
                            className="px-2 py-0.5 rounded-full text-xs font-bold tabular-nums"
                            style={{
                              backgroundColor: c.kontribusi_pct > 0 ? '#E8F5E9' : '#F1F5F9',
                              color: c.kontribusi_pct > 0 ? '#066F47' : '#94A3B8',
                            }}
                          >
                            {c.kontribusi_pct}%
                          </span>
                          <div
                            className="border-round overflow-hidden"
                            style={{ width: '48px', height: '4px', backgroundColor: '#E2E8F0' }}
                          >
                            <div
                              style={{
                                width: `${Math.min(c.kontribusi_pct, 100)}%`,
                                height: '100%',
                                backgroundColor: '#066F47',
                              }}
                            />
                          </div>
                        </div>
                      </td>

                      {/* Pasien Terdaftar */}
                      <td style={{ padding: '14px 16px', textAlign: 'right' }}>
                        <span className="text-xs font-semibold text-slate-700 tabular-nums">
                          {c.pasien_count}
                        </span>
                        <span className="text-[11px] text-slate-400 block">pasien</span>
                      </td>

                      {/* Kunjungan Hari Ini */}
                      <td style={{ padding: '14px 16px', textAlign: 'right' }}>
                        <span className="text-xs font-semibold text-slate-700 tabular-nums">
                          {c.kunjungan_hari_ini}
                        </span>
                        <span className="text-[11px] text-slate-400 block">kunjungan</span>
                      </td>

                      {/* Transaksi Kasir */}
                      <td style={{ padding: '14px 16px', textAlign: 'right' }}>
                        <span className="text-xs font-semibold text-slate-700 tabular-nums">
                          {c.transaksi_count}
                        </span>
                        <span className="text-[11px] text-slate-400 block">invoice</span>
                      </td>

                      {/* Staf Aktif */}
                      <td style={{ padding: '14px 16px', textAlign: 'center' }}>
                        <span className="text-xs font-bold text-slate-800 tabular-nums block">
                          {c.total_staf} Staf
                        </span>
                        <span className="text-[11px] text-slate-400">
                          {c.dokter_count} dr · {c.beautician_count} terapis
                        </span>
                      </td>

                      {/* Status Shift */}
                      <td style={{ padding: '14px 16px', textAlign: 'center' }}>
                        {c.shift_aktif ? (
                          <span
                            className="inline-flex align-items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold"
                            style={{ backgroundColor: '#EDF7F2', color: '#066F47' }}
                          >
                            <span
                              className="w-2 h-2 rounded-full"
                              style={{ backgroundColor: '#10B981' }}
                            />
                            Shift Aktif
                          </span>
                        ) : (
                          <span
                            className="inline-flex align-items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold"
                            style={{ backgroundColor: '#F3F4F6', color: '#6B7280' }}
                          >
                            <span
                              className="w-2 h-2 rounded-full"
                              style={{ backgroundColor: '#9CA3AF' }}
                            />
                            Tutup
                          </span>
                        )}
                      </td>

                      {/* Aksi */}
                      <td style={{ padding: '14px 16px', textAlign: 'center' }}>
                        <button
                          type="button"
                          onClick={() => router.push(`/dashboard/cabang/${c.kode_cabang}`)}
                          className="px-2.5 py-1 rounded text-xs font-bold border-1 cursor-pointer transition-colors inline-flex align-items-center gap-1"
                          style={{
                            borderColor: '#DDE8E3',
                            backgroundColor: '#FFFFFF',
                            color: '#066F47',
                          }}
                          onMouseEnter={(e) => {
                            e.currentTarget.style.backgroundColor = '#EDF7F2';
                          }}
                          onMouseLeave={(e) => {
                            e.currentTarget.style.backgroundColor = '#FFFFFF';
                          }}
                        >
                          <span>Buka</span>
                          <i className="pi pi-arrow-up-right text-[10px]" />
                        </button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>

            {/* BARIS TOTAL KONSOLIDASI DI BAWAH */}
            {!loading && cabangList.length > 0 && (
              <tfoot>
                <tr
                  style={{
                    backgroundColor: '#F8FAF9',
                    borderTop: '2px solid #CBD5E1',
                    borderBottom: '2px solid #CBD5E1',
                  }}
                >
                  <td style={{ padding: '14px 16px' }}>
                    <div className="font-bold text-sm text-slate-900">
                      Total Konsolidasi ({cabangList.length} Cabang)
                    </div>
                    <span className="text-xs text-slate-500">Akumulasi seluruh cabang pusat</span>
                  </td>
                  <td style={{ padding: '14px 16px', textAlign: 'right' }}>
                    <strong className="text-sm font-extrabold text-emerald-800 tabular-nums">
                      {formatRupiah(summary.total_omzet)}
                    </strong>
                  </td>
                  <td style={{ padding: '14px 16px', textAlign: 'center' }}>
                    <span
                      className="px-2 py-0.5 rounded-full text-xs font-extrabold"
                      style={{ backgroundColor: '#066F47', color: '#FFFFFF' }}
                    >
                      100%
                    </span>
                  </td>
                  <td style={{ padding: '14px 16px', textAlign: 'right' }}>
                    <strong className="text-xs font-bold text-slate-800 tabular-nums">
                      {summary.total_pasien}
                    </strong>
                    <span className="text-[11px] text-slate-500 block">pasien</span>
                  </td>
                  <td style={{ padding: '14px 16px', textAlign: 'right' }}>
                    <strong className="text-xs font-bold text-slate-800 tabular-nums">
                      {summary.total_kunjungan_hari_ini}
                    </strong>
                    <span className="text-[11px] text-slate-500 block">kunjungan</span>
                  </td>
                  <td style={{ padding: '14px 16px', textAlign: 'right' }}>
                    <strong className="text-xs font-bold text-slate-800 tabular-nums">
                      {summary.total_transaksi}
                    </strong>
                    <span className="text-[11px] text-slate-500 block">invoice</span>
                  </td>
                  <td style={{ padding: '14px 16px', textAlign: 'center' }}>
                    <strong className="text-xs font-bold text-slate-800 tabular-nums block">
                      {summary.total_staf} Staf
                    </strong>
                    <span className="text-[11px] text-slate-500">Total Tenaga Medis</span>
                  </td>
                  <td style={{ padding: '14px 16px', textAlign: 'center' }}>
                    <span className="text-xs font-bold text-slate-700">
                      {activeShiftCount} Buka / {cabangList.length - activeShiftCount} Tutup
                    </span>
                  </td>
                  <td style={{ padding: '14px 16px' }} />
                </tr>
              </tfoot>
            )}
          </table>
        </div>
      </div>

      {/* ─── 4. DUA CHART BERDAMPINGAN: OMZET & KOMPOSISI METODE BAYAR ─── */}
      <div className="clinic-two-col-grid">
        {/* CHART 1: BAR CHART OMZET PER CABANG */}
        <div
          className="clinic-panel bg-white flex flex-column justify-content-between"
          style={{ padding: '24px' }}
        >
          <div>
            <div className="clinic-card-header mb-3">
              <div>
                <h3 className="clinic-card-title">Perbandingan Omzet Cabang</h3>
                <span className="text-xs" style={{ color: '#6F7A74' }}>
                  Pendapatan kotor terverifikasi kasir per cabang klinik
                </span>
              </div>
              <span className="clinic-pill clinic-pill-emerald">Rupiah (IDR)</span>
            </div>

            <div style={{ height: '240px' }} className="w-full">
              {loading ? (
                <Skeleton width="100%" height="100%" className="border-round-lg" />
              ) : cabangList.length > 0 ? (
                <Chart
                  type="bar"
                  data={omzetChartData}
                  options={omzetChartOptions}
                  className="h-full w-full"
                />
              ) : (
                <div className="h-full flex align-items-center justify-content-center text-xs text-slate-400">
                  Data omzet tidak tersedia
                </div>
              )}
            </div>
          </div>

          <div
            className="text-xs flex justify-content-between align-items-center"
            style={{
              borderTop: '1px solid #E5E7EB',
              paddingTop: '16px',
              marginTop: '16px',
              color: '#6F7A74',
            }}
          >
            <span>Total Omzet Konsolidasi:</span>
            <strong className="font-bold tabular-nums text-sm" style={{ color: '#066F47' }}>
              {formatRupiah(summary.total_omzet)}
            </strong>
          </div>
        </div>

        {/* CHART 2: KOMPOSISI METODE PEMBAYARAN PER CABANG */}
        <div
          className="clinic-panel bg-white flex flex-column justify-content-between"
          style={{ padding: '24px' }}
        >
          <div>
            <div className="clinic-card-header mb-3">
              <div>
                <h3 className="clinic-card-title">Komposisi Metode Bayar per Cabang</h3>
                <span className="text-xs" style={{ color: '#6F7A74' }}>
                  Distribusi pembayaran kasir (QRIS, Debit, Tunai) per cabang
                </span>
              </div>
              <span className="clinic-pill clinic-pill-emerald">Stacked Bar</span>
            </div>

            <div style={{ height: '240px' }} className="w-full">
              {loading ? (
                <Skeleton width="100%" height="100%" className="border-round-lg" />
              ) : cabangList.length > 0 ? (
                <Chart
                  type="bar"
                  data={paymentChartData}
                  options={paymentChartOptions}
                  className="h-full w-full"
                />
              ) : (
                <div className="h-full flex align-items-center justify-content-center text-xs text-slate-400">
                  Data metode pembayaran tidak tersedia
                </div>
              )}
            </div>
          </div>

          <div
            className="text-xs flex justify-content-between align-items-center"
            style={{
              borderTop: '1px solid #E5E7EB',
              paddingTop: '16px',
              marginTop: '16px',
              color: '#6F7A74',
            }}
          >
            <span className="flex align-items-center gap-2">
              <span className="inline-block w-2 h-2 rounded-full" style={{ backgroundColor: '#10b981' }} /> QRIS
              <span className="inline-block w-2 h-2 rounded-full ml-1" style={{ backgroundColor: '#B3873F' }} /> Debit
              <span className="inline-block w-2 h-2 rounded-full ml-1" style={{ backgroundColor: '#34d399' }} /> Tunai
            </span>
            <span className="text-slate-500 font-medium">Berdasarkan invoice terbayar</span>
          </div>
        </div>
      </div>

      {/* ─── 5. TREATMENT TERPOPULER PER CABANG (TOP 5) ─── */}
      <div className="clinic-panel bg-white" style={{ padding: '24px' }}>
        <div className="mb-4">
          <div className="flex align-items-center gap-2">
            <h3 className="clinic-card-title m-0">Treatment Terpopuler per Cabang</h3>
            <span className="clinic-pill clinic-pill-emerald">Top 5 Tiap Cabang</span>
          </div>
          <span className="text-xs" style={{ color: '#6F7A74' }}>
            5 tindakan medis dan perawatan estetika paling diminati pasien di masing-masing cabang
          </span>
        </div>

        {/* Treatment Cards Grid */}
        <div className="grid m-0">
          {loading ? (
            Array.from({ length: 2 }).map((_, idx) => (
              <div key={idx} className="col-12 md:col-6 p-2">
                <div
                  className="border-round-xl p-3 border-1"
                  style={{ borderColor: '#E5E7EB', backgroundColor: '#F8FAF9' }}
                >
                  <Skeleton width="160px" height="22px" className="mb-3" />
                  <Skeleton width="100%" height="28px" className="mb-2" />
                  <Skeleton width="100%" height="28px" className="mb-2" />
                  <Skeleton width="100%" height="28px" />
                </div>
              </div>
            ))
          ) : (
            cabangList.map((c) => {
              const treatments = c.top_treatments || [];
              const maxSessions = Math.max(
                ...treatments.map((t) => Number(t.total_sesi || 1)),
                1
              );

              return (
                <div
                  key={c.kode_cabang}
                  className={`col-12 ${
                    cabangList.length > 1 ? 'md:col-6' : 'md:col-12'
                  } p-2`}
                >
                    <div
                      className="border-round-xl p-4 border-1 h-full flex flex-column justify-content-between"
                      style={{
                        borderColor: '#E2E8F0',
                        backgroundColor: '#FFFFFF',
                      }}
                    >
                      <div>
                        {/* Cabang Header */}
                        <div className="flex justify-content-between align-items-center mb-3 pb-3 border-bottom-1 border-slate-100">
                          <div className="flex align-items-center gap-2">
                            <strong className="text-sm font-bold text-slate-800" style={{ color: '#0F172A' }}>
                              {c.nama_cabang}
                            </strong>
                            <span
                              className="text-xs font-semibold px-2 py-0.5"
                              style={{
                                backgroundColor: '#F1F5F9',
                                color: '#475569',
                                fontSize: '11px',
                                borderRadius: '6px',
                              }}
                            >
                              {c.kode_cabang}
                            </span>
                          </div>
                        </div>

                        {/* Top 5 Items */}
                        {treatments.length === 0 ? (
                          <div
                            className="py-5 text-center flex flex-column align-items-center justify-content-center"
                            style={{ minHeight: '210px' }}
                          >
                            <div className="mb-2">
                              <svg
                                width="36"
                                height="36"
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="#94A3B8"
                                strokeWidth="1.75"
                                strokeLinecap="round"
                                strokeLinejoin="round"
                              >
                                <path d="M22 12h-6l-2 3h-4l-2-3H2" />
                                <path d="M5.45 5.11L2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z" />
                              </svg>
                            </div>
                            <span className="text-sm font-bold text-slate-700 mb-1" style={{ color: '#334155' }}>
                              Belum ada tindakan tercatat
                            </span>
                            <span
                              className="text-xs text-slate-400 text-center"
                              style={{ maxWidth: '290px', lineHeight: '1.45', color: '#64748B' }}
                            >
                              Cabang ini belum memiliki tindakan selesai pada periode yang dipilih.
                            </span>
                          </div>
                        ) : (
                          <div className="flex flex-column gap-3.5 py-1">
                            {treatments.map((item, tIdx) => {
                              const isFirst = tIdx === 0;
                              const sessions = Number(item.total_sesi || 0);
                              const rawTitle = item.nama_layanan || 'Treatment';
                              const title =
                                rawTitle === rawTitle.toLowerCase()
                                  ? rawTitle.replace(/\b\w/g, (char) => char.toUpperCase())
                                  : rawTitle;
                              const widthPct = Math.max(
                                Math.round((sessions / maxSessions) * 100),
                                6
                              );

                              return (
                                <div
                                  key={tIdx}
                                  className="flex align-items-center gap-3"
                                  style={{ minHeight: '38px' }}
                                >
                                  {/* 1. Rank Badge */}
                                  <div
                                    className="flex align-items-center justify-content-center flex-shrink-0"
                                    style={{
                                      width: '26px',
                                      height: '26px',
                                      borderRadius: '50%',
                                      backgroundColor: isFirst ? '#0f6b43' : '#EDF3EE',
                                      color: isFirst ? '#FFFFFF' : '#1F2937',
                                      fontSize: '12px',
                                      fontWeight: 700,
                                    }}
                                  >
                                    {tIdx + 1}
                                  </div>

                                  {/* 2. Middle: Title + Progress Bar */}
                                  <div className="flex-1" style={{ minWidth: 0 }}>
                                    <div
                                      className="text-xs font-medium text-slate-800 text-overflow-ellipsis overflow-hidden white-space-nowrap mb-1.5"
                                      title={title}
                                      style={{ color: '#1E293B', fontSize: '13px', lineHeight: '1.2' }}
                                    >
                                      {title}
                                    </div>

                                    <div
                                      className="w-full overflow-hidden"
                                      style={{
                                        height: '6px',
                                        backgroundColor: '#E5E7EB',
                                        borderRadius: '9999px',
                                      }}
                                    >
                                      <div
                                        style={{
                                          width: `${widthPct}%`,
                                          backgroundColor: isFirst ? '#0f6b43' : '#16a36a',
                                          height: '100%',
                                          borderRadius: '9999px',
                                          transition: 'width 0.4s ease',
                                        }}
                                      />
                                    </div>
                                  </div>

                                  {/* 3. Right: Sesi Count */}
                                  <div
                                    className="flex-shrink-0 text-right flex align-items-baseline justify-content-end"
                                    style={{ width: '58px' }}
                                  >
                                    <strong
                                      className="tabular-nums"
                                      style={{ color: '#0F172A', fontSize: '12px', fontWeight: 700 }}
                                    >
                                      {sessions}
                                    </strong>
                                    <span
                                      className="ml-1"
                                      style={{ color: '#64748B', fontSize: '12px', fontWeight: 400 }}
                                    >
                                      sesi
                                    </span>
                                  </div>
                                </div>
                              );
                            })}
                          </div>
                        )}
                      </div>

                      {/* Footer Link to Branch */}
                      <div className="pt-3 mt-3 border-top-1 border-slate-100 flex justify-content-between align-items-center text-xs">
                        <span className="text-slate-500">
                          <strong className="text-slate-800 font-bold" style={{ color: '#0F172A' }}>
                            {treatments.reduce((acc, t) => acc + Number(t.total_sesi || 0), 0)}
                          </strong>{' '}
                          total sesi selesai
                        </span>
                        <button
                          type="button"
                          onClick={() => router.push(`/dashboard/cabang/${c.kode_cabang}`)}
                          className="border-none bg-transparent p-0 cursor-pointer text-xs font-semibold hover:underline"
                          style={{ color: '#005b38' }}
                        >
                          Lihat semua &rarr;
                        </button>
                      </div>
                    </div>
                  </div>
                );
              })
          )}
        </div>
      </div>
    </div>
  );
};

export default BranchComparisonSection;
