'use client';

import React, { useState, useRef } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { Chart } from 'primereact/chart';
import { Button } from 'primereact/button';
import { ProgressBar } from 'primereact/progressbar';
import { Tag } from 'primereact/tag';
import { Menu } from 'primereact/menu';
import { DataTable } from 'primereact/datatable';
import { Column } from 'primereact/column';
import { Toast } from 'primereact/toast';

interface PasienPerRuangan {
  nama: string;
  count: number;
  max: number;
  color: string;
}

interface TreatmentBerjalan {
  id: string;
  no_rm: string;
  nama_pasien: string;
  layanan: string;
  ruangan: string;
  dokter: string;
  jam: string;
  status: 'Konsultasi' | 'Sedang Treatment' | 'Menunggu Kasir' | 'Selesai';
}

const Dashboard = () => {
  const router = useRouter();
  const menuRef = useRef<Menu>(null);
  const toast = useRef<Toast>(null);
  const [selectedPeriod, setSelectedPeriod] = useState<'7' | '30' | 'bulan'>('7');

  // Datasets berdasarkan periode terpilih
  const chartDataMap = {
    '7': {
      labels: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
      data: [35, 65, 48, 92, 75, 135, 110],
    },
    '30': {
      labels: ['Minggu 1', 'Minggu 2', 'Minggu 3', 'Minggu 4'],
      data: [280, 340, 410, 390],
    },
    'bulan': {
      labels: ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu'],
      data: [950, 1100, 1250, 1180, 1350, 1420, 1380, 1520],
    },
  };

  const currentChart = chartDataMap[selectedPeriod];

  const chartData = {
    labels: currentChart.labels,
    datasets: [
      {
        label: 'Kunjungan Pasien',
        data: currentChart.data,
        fill: true,
        borderColor: '#2563eb',
        tension: 0.4,
        backgroundColor: 'rgba(37, 99, 235, 0.12)',
        pointBackgroundColor: '#2563eb',
        pointBorderColor: '#ffffff',
        pointBorderWidth: 3,
        pointRadius: 6,
        pointHoverRadius: 8,
      },
    ],
  };

  const chartOptions = {
    maintainAspectRatio: false,
    aspectRatio: 0.6,
    plugins: {
      legend: {
        display: false,
      },
      tooltip: {
        mode: 'index',
        intersect: false,
        padding: 12,
        backgroundColor: '#1e293b',
        titleFont: { size: 13, weight: 'bold' },
        bodyFont: { size: 13 },
        callbacks: {
          label: (context: any) => ` ${context.parsed.y} Pasien`,
        },
      },
    },
    scales: {
      x: {
        ticks: {
          color: '#64748b',
          font: { weight: 500 },
        },
        grid: { display: false },
      },
      y: {
        ticks: {
          color: '#64748b',
        },
        grid: {
          color: '#f1f5f9',
        },
        min: 0,
      },
    },
  };

  // Distribution Pasien per Ruangan / Layanan
  const ruanganList: PasienPerRuangan[] = [
    { nama: 'Facial & Skincare', count: 80, max: 100, color: '#2563eb' },
    { nama: 'Laser & Anti-Aging', count: 45, max: 100, color: '#0d9488' },
    { nama: 'Acne & Skin Treatment', count: 60, max: 100, color: '#b45309' },
    { nama: 'Body Slimming & Treatment', count: 25, max: 100, color: '#4f46e5' },
    { nama: 'Konsultasi Dokter Spesialis', count: 35, max: 100, color: '#10b981' },
  ];

  // Treatment Berjalan Hari Ini (Dummy Real-Time)
  const treatmentBerjalanData: TreatmentBerjalan[] = [
    {
      id: 'TRX-001',
      no_rm: 'RM-000001',
      nama_pasien: 'Siti Rahmawati',
      layanan: 'Facial Glowing Premium',
      ruangan: 'Ruang Treatment 1',
      dokter: 'dr. Anita Wijaya, Sp.DVE',
      jam: '09:15',
      status: 'Sedang Treatment',
    },
    {
      id: 'TRX-002',
      no_rm: 'RM-000002',
      nama_pasien: 'Dewi Lestari',
      layanan: 'Laser Rejuvenation',
      ruangan: 'Ruang Laser A',
      dokter: 'dr. Budi Santoso',
      jam: '09:30',
      status: 'Konsultasi',
    },
    {
      id: 'TRX-003',
      no_rm: 'RM-000003',
      nama_pasien: 'Maya Indah',
      layanan: 'Acne Peel & LED Therapy',
      ruangan: 'Ruang Treatment 3',
      dokter: 'dr. Anita Wijaya, Sp.DVE',
      jam: '09:00',
      status: 'Menunggu Kasir',
    },
    {
      id: 'TRX-004',
      no_rm: 'RM-000004',
      nama_pasien: 'Rina Kusumawati',
      layanan: 'Body Slimming Cavitation',
      ruangan: 'Ruang Body 2',
      dokter: 'dr. Citra Melati',
      jam: '10:00',
      status: 'Sedang Treatment',
    },
  ];

  const menuItems = [
    { label: 'Refresh Data', icon: 'pi pi-refresh', command: () => toast.current?.show({ severity: 'info', summary: 'Diperbarui', detail: 'Data tren berhasil diperbarui' }) },
    { label: 'Unduh Grafik', icon: 'pi pi-download', command: () => toast.current?.show({ severity: 'success', summary: 'Unduh', detail: 'Grafik berhasil diunduh' }) },
  ];

  const statusBodyTemplate = (rowData: TreatmentBerjalan) => {
    let severity: 'success' | 'info' | 'warning' | 'danger' | 'secondary' = 'info';
    if (rowData.status === 'Sedang Treatment') severity = 'info';
    if (rowData.status === 'Konsultasi') severity = 'warning';
    if (rowData.status === 'Menunggu Kasir') severity = 'danger';
    if (rowData.status === 'Selesai') severity = 'success';

    return <Tag value={rowData.status} severity={severity} className="text-xs px-2 py-1" />;
  };

  return (
    <div className="surface-ground min-h-screen p-3 md:p-4 border-round-xl">
      <Toast ref={toast} />
      <Menu model={menuItems} popup ref={menuRef} />

      {/* HEADER & TOP ACTIONS */}
      <div className="flex flex-column md:flex-row justify-content-between align-items-start md:align-items-center mb-4 gap-3">
        <div>
          <h1 className="text-2xl md:text-3xl font-bold text-900 m-0 tracking-tight">Ringkasan Hari Ini</h1>
          <p className="text-500 m-0 mt-1 text-sm md:text-base">Pantau aktivitas operasional klinik secara real-time.</p>
        </div>

        <div className="flex flex-wrap gap-2 w-full md:w-auto">
          <Button
            label="Daftar Pasien Baru"
            icon="pi pi-user-plus"
            className="p-button-primary p-button-sm border-round-lg shadow-1"
            onClick={() => router.push('/pendaftaran-antrean/antrean')}
          />
          <Button
            label="Panggil Antrean"
            icon="pi pi-megaphone"
            className="p-button-info p-button-sm border-round-lg shadow-1"
            style={{ backgroundColor: '#0d9488', borderColor: '#0d9488' }}
            onClick={() => router.push('/pendaftaran-antrean/antrean')}
          />
          <Button
            label="Lihat Laporan"
            icon="pi pi-file"
            className="p-button-outlined p-button-secondary p-button-sm border-round-lg bg-white"
            onClick={() => router.push('/contoh_laporan')}
          />
        </div>
      </div>

      {/* 4 SUMMARY KPI CARDS */}
      <div className="grid mb-4">
        {/* CARD 1: Kunjungan Hari Ini */}
        <div className="col-12 sm:col-6 lg:col-3">
          <div className="surface-card p-3 md:p-4 border-round-xl shadow-1 border-1 border-200 hover:shadow-2 transition-all">
            <div className="flex justify-content-between align-items-start mb-3">
              <div
                className="flex align-items-center justify-content-center border-round-circle"
                style={{ width: '48px', height: '48px', backgroundColor: 'rgba(37, 99, 235, 0.12)', color: '#2563eb' }}
              >
                <i className="pi pi-users text-xl font-bold"></i>
              </div>
              <span
                className="px-2 py-1 border-round-pill text-xs font-semibold flex align-items-center gap-1"
                style={{ backgroundColor: '#eff6ff', color: '#1d4ed8' }}
              >
                <i className="pi pi-arrow-up-right text-xs"></i> +12%
              </span>
            </div>
            <span className="block text-500 font-medium text-sm mb-1">Kunjungan Hari Ini</span>
            <div className="text-900 font-bold text-3xl mb-1">142</div>
            <span className="text-xs text-500">+15 dibanding kemarin</span>
          </div>
        </div>

        {/* CARD 2: Pendapatan Hari Ini */}
        <div className="col-12 sm:col-6 lg:col-3">
          <div className="surface-card p-3 md:p-4 border-round-xl shadow-1 border-1 border-200 hover:shadow-2 transition-all">
            <div className="flex justify-content-between align-items-start mb-3">
              <div
                className="flex align-items-center justify-content-center border-round-circle"
                style={{ width: '48px', height: '48px', backgroundColor: 'rgba(13, 148, 136, 0.12)', color: '#0d9488' }}
              >
                <i className="pi pi-wallet text-xl font-bold"></i>
              </div>
              <span
                className="px-2 py-1 border-round-pill text-xs font-semibold flex align-items-center gap-1"
                style={{ backgroundColor: '#f0fdf4', color: '#15803d' }}
              >
                <i className="pi pi-arrow-up-right text-xs"></i> +5%
              </span>
            </div>
            <span className="block text-500 font-medium text-sm mb-1">Pendapatan Hari Ini</span>
            <div className="text-900 font-bold text-3xl mb-1">Rp 12.4M</div>
            <span className="text-xs text-500">Total transaksi kasir hari ini</span>
          </div>
        </div>

        {/* CARD 3: Pasien Menunggu */}
        <div className="col-12 sm:col-6 lg:col-3">
          <div className="surface-card p-3 md:p-4 border-round-xl shadow-1 border-1 border-200 hover:shadow-2 transition-all">
            <div className="flex justify-content-between align-items-start mb-3">
              <div
                className="flex align-items-center justify-content-center border-round-circle"
                style={{ width: '48px', height: '48px', backgroundColor: 'rgba(239, 68, 68, 0.12)', color: '#ef4444' }}
              >
                <i className="pi pi-clock text-xl font-bold"></i>
              </div>
              <span
                className="px-2 py-1 border-round-pill text-xs font-semibold"
                style={{ backgroundColor: '#fef2f2', color: '#b91c1c' }}
              >
                Perlu Perhatian
              </span>
            </div>
            <span className="block text-500 font-medium text-sm mb-1">Pasien Menunggu</span>
            <div className="text-900 font-bold text-3xl mb-1">24</div>
            <span className="text-xs text-500">Dalam antrean treatment & dokter</span>
          </div>
        </div>

        {/* CARD 4: Okupansi Ruangan */}
        <div className="col-12 sm:col-6 lg:col-3">
          <div className="surface-card p-3 md:p-4 border-round-xl shadow-1 border-1 border-200 hover:shadow-2 transition-all">
            <div className="flex justify-content-between align-items-start mb-3">
              <div
                className="flex align-items-center justify-content-center border-round-circle"
                style={{ width: '48px', height: '48px', backgroundColor: 'rgba(217, 119, 6, 0.12)', color: '#d97706' }}
              >
                <i className="pi pi-building text-xl font-bold"></i>
              </div>
              <span
                className="px-2 py-1 border-round-pill text-xs font-semibold"
                style={{ backgroundColor: '#f8fafc', color: '#64748b' }}
              >
                Stabil
              </span>
            </div>
            <span className="block text-500 font-medium text-sm mb-1">Okupansi Ruangan</span>
            <div className="text-900 font-bold text-3xl mb-1">78%</div>
            <span className="text-xs text-500">14 dari 18 Ruangan terisi</span>
          </div>
        </div>
      </div>

      {/* MAIN CONTENT GRID: 2 COLUMNS */}
      <div className="grid mb-4">
        {/* LEFT COLUMN: TREN KUNJUNGAN CHART (70%) */}
        <div className="col-12 lg:col-8">
          <div className="surface-card p-4 border-round-xl shadow-1 border-1 border-200 h-full flex flex-column justify-content-between">
            <div>
              <div className="flex justify-content-between align-items-center mb-3">
                <div>
                  <h2 className="text-xl font-bold text-900 m-0">Tren Kunjungan ({selectedPeriod === '7' ? '7 Hari' : selectedPeriod === '30' ? '30 Hari' : 'Bulan Ini'})</h2>
                  <span className="text-xs text-500">Grafik pergerakan jumlah kedatangan pasien klinik</span>
                </div>

                <div className="flex align-items-center gap-2">
                  <div className="surface-100 p-1 border-round-lg flex gap-1">
                    <Button
                      label="7 Hari"
                      className={`p-button-text p-button-xs py-1 px-2 text-xs border-round-md ${selectedPeriod === '7' ? 'bg-white shadow-1 text-primary font-bold' : 'text-600'}`}
                      onClick={() => setSelectedPeriod('7')}
                    />
                    <Button
                      label="30 Hari"
                      className={`p-button-text p-button-xs py-1 px-2 text-xs border-round-md ${selectedPeriod === '30' ? 'bg-white shadow-1 text-primary font-bold' : 'text-600'}`}
                      onClick={() => setSelectedPeriod('30')}
                    />
                    <Button
                      label="Bulan Ini"
                      className={`p-button-text p-button-xs py-1 px-2 text-xs border-round-md ${selectedPeriod === 'bulan' ? 'bg-white shadow-1 text-primary font-bold' : 'text-600'}`}
                      onClick={() => setSelectedPeriod('bulan')}
                    />
                  </div>

                  <Button
                    icon="pi pi-ellipsis-v"
                    className="p-button-text p-button-secondary p-button-rounded"
                    onClick={(e) => menuRef.current?.toggle(e)}
                  />
                </div>
              </div>

              {/* CHART AREA */}
              <div style={{ height: '320px', position: 'relative' }} className="mt-4">
                <Chart type="line" data={chartData} options={chartOptions} style={{ width: '100%', height: '100%' }} />
              </div>
            </div>

            {/* INSIGHT FOOTER BAR */}
            <div className="grid surface-50 border-round-lg p-3 mt-4 border-1 border-100 text-xs text-700">
              <div className="col-12 sm:col-4 flex align-items-center gap-2">
                <i className="pi pi-star-fill text-amber-500"></i>
                <span>Hari Puncak: <strong>Sabtu (145 Pasien)</strong></span>
              </div>
              <div className="col-12 sm:col-4 flex align-items-center gap-2">
                <i className="pi pi-chart-line text-blue-500"></i>
                <span>Rata-Rata: <strong>98 Pasien / hari</strong></span>
              </div>
              <div className="col-12 sm:col-4 flex align-items-center gap-2">
                <i className="pi pi-heart-fill text-pink-500"></i>
                <span>Terfavorit: <strong>Facial Glowing</strong></span>
              </div>
            </div>
          </div>
        </div>

        {/* RIGHT COLUMN: PASIEN PER RUANGAN / LAYANAN (30%) */}
        <div className="col-12 lg:col-4">
          <div className="surface-card p-4 border-round-xl shadow-1 border-1 border-200 h-full flex flex-column justify-content-between">
            <div>
              <div className="flex justify-content-between align-items-center mb-3">
                <h2 className="text-xl font-bold text-900 m-0">Pasien per Layanan</h2>
                <i className="pi pi-info-circle text-400"></i>
              </div>
              <p className="text-xs text-500 m-0 mb-4">Distribusi kunjungan berdasarkan kategori perawatan hari ini.</p>

              <div className="flex flex-column gap-4">
                {ruanganList.map((item, index) => (
                  <div key={index} className="flex flex-column gap-2">
                    <div className="flex justify-content-between align-items-center text-sm">
                      <span className="font-semibold text-800">{item.nama}</span>
                      <span className="font-bold text-900">{item.count}</span>
                    </div>
                    <ProgressBar
                      value={(item.count / item.max) * 100}
                      showValue={false}
                      style={{ height: '8px', borderRadius: '4px' }}
                      color={item.color}
                    />
                  </div>
                ))}
              </div>
            </div>

            <div className="mt-4 pt-3 border-top-1 border-200 text-center">
              <Link
                href="/pendaftaran-antrean/antrean"
                className="p-ripple text-primary font-bold text-sm no-underline hover:underline flex align-items-center justify-content-center gap-2 py-2 border-round-lg surface-hover transition-all"
              >
                <span>Lihat Detail Ruangan & Antrean</span>
                <i className="pi pi-arrow-right text-xs"></i>
              </Link>
            </div>
          </div>
        </div>
      </div>

      {/* BOTTOM ROW WIDGET: ANTREAN & STATUS TREATMENT REAL-TIME */}
      <div className="grid">
        <div className="col-12">
          <div className="surface-card p-4 border-round-xl shadow-1 border-1 border-200">
            <div className="flex flex-column sm:flex-row justify-content-between align-items-start sm:align-items-center mb-3 gap-2">
              <div>
                <h2 className="text-lg font-bold text-900 m-0">Status Treatment Berjalan</h2>
                <span className="text-xs text-500">Antrean pelayanan & perawatan di ruangan saat ini</span>
              </div>
              <Button
                label="Kelola Antrean"
                icon="pi pi-external-link"
                className="p-button-text p-button-sm p-button-primary"
                onClick={() => router.push('/pendaftaran-antrean/antrean')}
              />
            </div>

            <DataTable
              value={treatmentBerjalanData}
              responsiveLayout="scroll"
              className="p-datatable-sm"
              emptyMessage="Belum ada treatment berjalan"
            >
              <Column field="no_rm" header="No. RM" body={(r) => <span className="font-mono text-xs">{r.no_rm}</span>} />
              <Column field="nama_pasien" header="Nama Pasien" body={(r) => <span className="font-semibold text-900">{r.nama_pasien}</span>} />
              <Column field="layanan" header="Layanan Treatment" />
              <Column field="ruangan" header="Ruangan" body={(r) => <span className="text-600">{r.ruangan}</span>} />
              <Column field="dokter" header="Dokter / Penanggung Jawab" />
              <Column field="jam" header="Jam Masuk" />
              <Column field="status" header="Status" body={statusBodyTemplate} />
            </DataTable>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;