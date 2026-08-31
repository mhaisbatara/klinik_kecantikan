'use client';

import React, { useState, useEffect, useRef } from 'react';
import { Toast } from 'primereact/toast';
import { Calendar } from 'primereact/calendar';
import { Dropdown } from 'primereact/dropdown';
import { Button } from 'primereact/button';
import { Tag } from 'primereact/tag';
import { ProgressSpinner } from 'primereact/progressspinner';
import { Paginator } from 'primereact/paginator';
import { Image } from 'primereact/image';
import postData from '@/lib/axios/postData';
import { showError, showSuccess } from '@/lib/tools/generalTools';

interface PasienOption {
  no_rm: string;
  nama: string;
  nik?: string;
  no_hp?: string;
  tanggal_lahir?: string;
  jenis_kelamin?: string;
  alergi?: string;
}

interface KaryawanInfo {
  kode_karyawan: string;
  nama: string;
  jabatan: string;
}

interface RekamMedisDetail {
  kode_rekam_medis: string | null;
  no_sip: string | null;
  keluhan: string;
  diagnosa: string;
  tindakan: string;
  catatan: string;
  dokter_penanggung_jawab: KaryawanInfo | null;
  data_form?: any;
  formatted_data_form?: Array<{ key: string; label: string; value: any }>;
  fotos?: Array<{ id?: number; tipe: string; url_foto: string }>;
}

interface LayananDetail {
  kode_antrian_layanan: string;
  nama_layanan: string;
  jenis_layanan: string;
  harga: number;
  kode_ruangan: string;
  nama_ruangan: string;
  status: string;
  dipanggil_at: string | null;
  selesai_at: string | null;
  catatan_tindakan?: string | null;
  catatan_petugas?: string | null;
  catatan_hasil_treatment?: string | null;
  petugas: KaryawanInfo | null;
  rekam_medis: RekamMedisDetail | null;
}

interface KunjunganRecord {
  kode_kunjungan: string;
  no_rm: string;
  nama_pasien: string;
  tanggal_kunjungan: string;
  jam_datang: string;
  status_kunjungan: string;
  layanan: LayananDetail[];
}

const formatRupiah = (val: number) =>
  new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(val || 0);

const formatDateIndo = (dateStr: string) => {
  if (!dateStr) return '-';
  try {
    const d = new Date(dateStr);
    return new Intl.DateTimeFormat('id-ID', { day: 'numeric', month: 'long', year: 'numeric' }).format(d);
  } catch (_) {
    return dateStr;
  }
};

const getImgSrc = (path?: string) => {
  if (!path) return '';
  if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('data:')) {
    return path;
  }
  const beUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';
  const baseUrl = beUrl.replace(/\/api\/v1\/?$/, '').replace(/\/$/, '');
  return `${baseUrl}${path.startsWith('/') ? '' : '/'}${path}`;
};

const getJabatanBadge = (jabatan?: string) => {
  const j = (jabatan || '').toLowerCase();
  if (j === 'dokter') return 'bg-purple-100 text-purple-800 border-purple-200 border-1 font-bold px-2 py-0.5 border-round-md text-xs';
  if (j === 'perawat') return 'bg-blue-100 text-blue-800 border-blue-200 border-1 font-bold px-2 py-0.5 border-round-md text-xs';
  if (j === 'terapis') return 'bg-teal-100 text-teal-800 border-teal-200 border-1 font-bold px-2 py-0.5 border-round-md text-xs';
  if (j === 'kasir') return 'bg-amber-100 text-amber-800 border-amber-200 border-1 font-bold px-2 py-0.5 border-round-md text-xs';
  if (j === 'apoteker') return 'bg-emerald-100 text-emerald-800 border-emerald-200 border-1 font-bold px-2 py-0.5 border-round-md text-xs';
  return 'bg-slate-100 text-slate-800 border-slate-200 border-1 font-bold px-2 py-0.5 border-round-md text-xs';
};

const getStatusKunjunganSeverity = (status?: string) => {
  const s = (status || '').toLowerCase();
  if (s === 'selesai') return 'success';
  if (s === 'berlangsung') return 'info';
  if (s === 'batal') return 'danger';
  return 'secondary';
};

const getStatusAntrianSeverity = (status?: string) => {
  const s = (status || '').toLowerCase();
  if (s === 'selesai') return 'success';
  if (s === 'dipanggil') return 'info';
  if (s === 'menunggu') return 'warning';
  if (s === 'batal') return 'danger';
  return 'secondary';
};

const renderFormattedContent = (text?: string | null) => {
  if (!text || text === '-' || text.trim() === '') return '-';

  const imgRegex = /(https?:\/\/[^\s"'<>]+|\/uploads\/[^\s"'<>]+)/gi;
  const matches = text.match(imgRegex);

  return (
    <div>
      <div className="white-space-pre-wrap">{text}</div>
      {matches && matches.length > 0 && (
        <div className="flex align-items-center gap-3 mt-2 flex-wrap">
          {matches.map((url, idx) => (
            <div key={idx} className="text-center">
              <span className="block text-[10px] font-bold text-teal-700 mb-1">Foto Lampiran #{idx + 1}</span>
              <Image
                src={getImgSrc(url)}
                alt={`Foto Lampiran ${idx + 1}`}
                width="110"
                height="110"
                preview
                className="border-round-lg overflow-hidden shadow-1 border-2 border-teal-500 cursor-pointer"
                imageClassName="w-full h-full object-cover border-round-lg"
              />
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

const renderDataFormDinamis = (rm: any, item?: any) => {
  const rawForm: Array<{ key: string; label: string; value: any; type?: string }> = rm?.formatted_data_form || [];
  const fotos: Array<{ tipe: string; url_foto: string }> = rm?.fotos || [];
  const catTindakan = item?.catatan_tindakan || rm?.catatan_tindakan || null;
  const catPetugas = item?.catatan_petugas || rm?.catatan_petugas || null;
  const catHasil = item?.catatan_hasil_treatment || rm?.catatan_hasil_treatment || null;

  // Key yang sudah di-render terpisah agar tidak duplikat
  const ignoredKeys = [
    'catatan_tindakan',
    'catatan_tindakan_alat_digunakan',
    'catatan_petugas',
    'catatan_hasil_treatment',
    'foto_before_after',
    'foto_before',
    'foto_after',
  ];

  const seenKeys = new Set<string>();
  const formattedForm = rawForm.filter((f) => {
    if (!f.key || ignoredKeys.includes(f.key.toLowerCase())) return false;
    if (seenKeys.has(f.key.toLowerCase())) return false;
    seenKeys.add(f.key.toLowerCase());
    return true;
  });

  if (formattedForm.length === 0 && fotos.length === 0 && !catTindakan && !catPetugas && !catHasil) {
    return null;
  }

  const beforeFotos = fotos.filter((f) => f.tipe === 'before');
  const afterFotos = fotos.filter((f) => f.tipe === 'after');

  return (
    <div className="mt-3 flex flex-column gap-3">
      {/* CARD: ISIAN KHUSUS FORM RUANGAN */}
      {formattedForm.length > 0 && (
        <div className="surface-card p-3 border-round-xl border-1 surface-border shadow-1">
          <div className="flex align-items-center justify-content-between mb-3 pb-2 border-bottom-1 surface-border">
            <span className="text-xs font-extrabold text-teal-800 uppercase tracking-wider flex align-items-center gap-2 m-0">
              <i className="pi pi-th-large text-teal-600 text-sm" />
              ISIAN KHUSUS FORM RUANGAN ({item?.nama_ruangan || 'RUANGAN'})
            </span>
            <span className="bg-teal-600 text-white font-extrabold text-[10px] px-2 py-0.5 border-round-md">
              {formattedForm.length} Field
            </span>
          </div>

          <div className="flex flex-column gap-3">
            {formattedForm.map((fItem, idx) => (
              <div key={idx} className="bg-white p-3 border-round-lg border-1 surface-border shadow-2xs">
                <div className="mb-1.5">
                  <label className="text-xs font-extrabold text-slate-700 uppercase tracking-wide m-0">
                    {fItem.label}
                  </label>
                </div>
                <div className="bg-slate-50 p-2.5 border-round-lg border-1 surface-border text-slate-900 font-medium text-xs white-space-pre-wrap">
                  {typeof fItem.value === 'object' ? JSON.stringify(fItem.value) : String(fItem.value || '-')}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* CARD: CATATAN TINDAKAN RUANGAN */}
      {catTindakan && (
        <div className="surface-card p-3 border-round-xl border-1 surface-border shadow-1">
          <div className="flex align-items-center gap-2 mb-2 pb-2 border-bottom-1 surface-border">
            <i className="pi pi-briefcase text-teal-600 text-sm" />
            <span className="text-xs font-extrabold text-teal-800 uppercase tracking-wider">
              Catatan Tindakan Ruangan
            </span>
          </div>
          <div className="bg-teal-50/60 p-3 border-round-lg border-1 border-teal-200 text-teal-950 font-medium text-xs white-space-pre-wrap">
            {catTindakan}
          </div>
        </div>
      )}

      {/* CARD: CATATAN PETUGAS & OBSERVASI */}
      {catPetugas && (
        <div className="surface-card p-3 border-round-xl border-1 surface-border shadow-1">
          <div className="flex align-items-center gap-2 mb-2 pb-2 border-bottom-1 surface-border">
            <i className="pi pi-user-edit text-emerald-600 text-sm" />
            <span className="text-xs font-extrabold text-emerald-800 uppercase tracking-wider">
              Catatan &amp; Observasi Petugas Ruangan
            </span>
          </div>
          <div className="bg-emerald-50/60 p-3 border-round-lg border-1 border-emerald-200 text-emerald-950 font-medium text-xs white-space-pre-wrap">
            {catPetugas}
          </div>
        </div>
      )}

      {/* CARD: CATATAN HASIL TREATMENT */}
      {catHasil && (
        <div className="surface-card p-3 border-round-xl border-1 surface-border shadow-1">
          <div className="flex align-items-center gap-2 mb-2 pb-2 border-bottom-1 surface-border">
            <i className="pi pi-check-circle text-indigo-600 text-sm" />
            <span className="text-xs font-extrabold text-indigo-800 uppercase tracking-wider">
              Catatan Hasil Treatment (Pasca Tindakan)
            </span>
          </div>
          <div className="bg-indigo-50/60 p-3 border-round-lg border-1 border-indigo-200 text-indigo-950 font-medium text-xs white-space-pre-wrap">
            {catHasil}
          </div>
        </div>
      )}

      {/* CARD: GALERI FOTO BEFORE / AFTER */}
      {fotos.length > 0 && (
        <div className="surface-card p-3 border-round-xl border-1 surface-border shadow-1">
          <div className="flex align-items-center justify-content-between mb-2 pb-2 border-bottom-1 surface-border">
            <span className="text-xs font-extrabold text-slate-700 uppercase tracking-wider flex align-items-center gap-2">
              <i className="pi pi-images text-teal-600 text-sm" />
              Dokumentasi Foto Before / After
            </span>
            <span className="text-[10px] text-slate-400 font-semibold">Klik foto untuk memperbesar</span>
          </div>
          <div className="flex align-items-center gap-3 flex-wrap bg-slate-50 p-3 border-round-lg border-1 surface-border">
            {beforeFotos.map((f, idx) => (
              <div key={`before-${idx}`} className="text-center flex flex-column align-items-center">
                <span className="block text-[10px] font-bold text-slate-600 mb-1.5 bg-slate-200 px-2 py-0.5 border-round-md">
                  📷 Foto Before (Sebelum)
                </span>
                <Image
                  src={getImgSrc(f.url_foto)}
                  alt="Foto Before"
                  width="120"
                  height="120"
                  preview
                  className="border-round-lg overflow-hidden shadow-1 border-2 border-slate-300 hover:scale-105 transition-all cursor-pointer"
                  imageClassName="w-full h-full object-cover border-round-lg"
                />
              </div>
            ))}
            {afterFotos.map((f, idx) => (
              <div key={`after-${idx}`} className="text-center flex flex-column align-items-center">
                <span className="block text-[10px] font-bold text-teal-800 mb-1.5 bg-teal-100 px-2 py-0.5 border-round-md">
                  ✨ Foto After (Sesudah)
                </span>
                <Image
                  src={getImgSrc(f.url_foto)}
                  alt="Foto After"
                  width="120"
                  height="120"
                  preview
                  className="border-round-lg overflow-hidden shadow-2 border-2 border-teal-500 hover:scale-105 transition-all cursor-pointer"
                  imageClassName="w-full h-full object-cover border-round-lg"
                />
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

const RekamMedisPage = () => {
  const toast = useRef<Toast>(null);

  // Pasien selection state
  const [pasienList, setPasienList] = useState<PasienOption[]>([]);
  const [loadingPasien, setLoadingPasien] = useState(false);
  const [selectedPasien, setSelectedPasien] = useState<PasienOption | null>(null);

  // Date Filters & Pagination
  const [tanggalDari, setTanggalDari] = useState<Date | null>(null);
  const [tanggalSampai, setTanggalSampai] = useState<Date | null>(null);
  const [page, setPage] = useState(1);
  const [perPage, setPerPage] = useState(10);
  const [totalRecords, setTotalRecords] = useState(0);

  // Data Records & Expansion state
  const [records, setRecords] = useState<KunjunganRecord[]>([]);
  const [loadingRecords, setLoadingRecords] = useState(false);
  const [expandedVisits, setExpandedVisits] = useState<Record<string, boolean>>({});

  useEffect(() => {
    fetchPasienList();
  }, []);

  const fetchPasienList = async () => {
    setLoadingPasien(true);
    try {
      const res = await postData('/master/pendaftaran-pasien-cari', { page: 1, perPage: 100 });
      if (['00', '0000'].includes(res?.data?.status)) {
        setPasienList(res.data.data || []);
      }
    } catch (_) {
      // silent fail
    } finally {
      setLoadingPasien(false);
    }
  };

  const fetchRekamMedis = async (pNoRm?: string, pPage = 1) => {
    const targetRm = pNoRm !== undefined ? pNoRm : selectedPasien?.no_rm;

    if (!targetRm) {
      setRecords([]);
      setTotalRecords(0);
      return;
    }

    setLoadingRecords(true);
    try {
      const formatDateParam = (d: Date | null) => {
        if (!d) return undefined;
        const year = d.getFullYear();
        const month = String(d.getMonth() + 1).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
      };

      const payload = {
        no_rm: targetRm,
        page: pPage,
        perPage: perPage,
        tanggal_dari: formatDateParam(tanggalDari),
        tanggal_sampai: formatDateParam(tanggalSampai),
      };

      const res = await postData('/master/pasien-rekam-medis', payload);
      if (['00', '0000'].includes(res?.data?.status)) {
        const dataList: KunjunganRecord[] = res.data.data || [];
        setRecords(dataList);
        setTotalRecords(res.data.total_data || 0);
        setPage(pPage);

        // Auto-expand first visit if exists
        if (dataList.length > 0) {
          const initialMap: Record<string, boolean> = {};
          dataList.forEach((k, idx) => {
            initialMap[k.kode_kunjungan] = idx === 0;
          });
          setExpandedVisits(initialMap);
        } else {
          setExpandedVisits({});
        }
      } else {
        showError(toast, res?.data?.message || 'Gagal memuat rekam medis');
      }
    } catch (err: any) {
      showError(toast, err?.response?.data?.message || err?.message || 'Gagal terhubung ke server');
    } finally {
      setLoadingRecords(false);
    }
  };

  const handleSelectPasien = (pasien: PasienOption | null) => {
    setSelectedPasien(pasien);
    fetchRekamMedis(pasien?.no_rm, 1);
  };

  const handleResetFilter = () => {
    setTanggalDari(null);
    setTanggalSampai(null);
    setSelectedPasien(null);
    setRecords([]);
    setTotalRecords(0);
    fetchPasienList();
  };

  const toggleExpand = (kode_kunjungan: string) => {
    setExpandedVisits((prev) => ({
      ...prev,
      [kode_kunjungan]: !prev[kode_kunjungan],
    }));
  };

  return (
    <>
      <Toast ref={toast} position="top-right" />

      {/* PAGE HEADER */}
      <div className="card p-0 mb-3 border-round-xl surface-border shadow-1 overflow-hidden">
        <div className="p-4 bg-teal-50 border-bottom-1 surface-border">
          <h2 className="text-2xl font-bold flex align-items-center gap-2 mb-1 text-teal-900">
            <i className="pi pi-folder-open text-teal-600 text-2xl" />
            Riwayat Rekam Medis Pasien
          </h2>
          <p className="text-color-secondary m-0 text-sm">
            Timeline rekam medis pasien, anamnesa/SOAP dokter penanggung jawab, dan sesi treatment per ruangan.
          </p>
        </div>
      </div>

      {/* SEARCH & FILTER BAR */}
      <div className="surface-card p-3 border-round-xl border-1 surface-border shadow-1 mb-3 flex flex-column gap-3">
        <div className="grid formgrid p-fluid align-items-end">
          {/* Select Pasien Dropdown */}
          <div className="col-12 md:col-5">
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wide mb-1">
              Pilih Pasien (Nama / No. RM)
            </label>
            <Dropdown
              value={selectedPasien}
              options={pasienList}
              onChange={(e) => handleSelectPasien(e.value)}
              optionLabel="nama"
              placeholder="Cari & Pilih Pasien..."
              filter
              filterBy="nama,no_rm,nik,no_hp"
              filterPlaceholder="Cari Nama / No. RM..."
              showClear
              loading={loadingPasien}
              className="p-inputtext-sm border-round-lg text-xs"
              valueTemplate={(opt: PasienOption) => (
                opt ? (
                  <div className="flex align-items-center justify-content-between w-full py-0.5">
                    <span className="font-bold text-xs text-slate-900">{opt.nama}</span>
                    <span className="text-[11px] text-teal-700 font-semibold bg-teal-50 px-2 py-0.5 border-round-md">
                      RM: {opt.no_rm}
                    </span>
                  </div>
                ) : null
              )}
              itemTemplate={(opt: PasienOption) => (
                <div className="flex align-items-center justify-content-between w-full py-1">
                  <div>
                    <div className="font-bold text-xs text-slate-900 mb-0.5">{opt.nama}</div>
                    <div className="text-[11px] text-slate-500">NIK: {opt.nik || '-'} | HP: {opt.no_hp || '-'}</div>
                  </div>
                  <span className="text-[11px] text-teal-700 font-semibold bg-teal-50 px-2 py-0.5 border-round-md">
                    RM: {opt.no_rm}
                  </span>
                </div>
              )}
            />
          </div>

          {/* Date Filter: Dari */}
          <div className="col-6 md:col-3">
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wide mb-1">
              Tanggal Dari
            </label>
            <Calendar
              value={tanggalDari}
              onChange={(e) => setTanggalDari(e.value as Date)}
              dateFormat="yy-mm-dd"
              showIcon
              placeholder="YYYY-MM-DD"
              className="p-inputtext-sm border-round-lg text-xs"
            />
          </div>

          {/* Date Filter: Sampai */}
          <div className="col-6 md:col-3">
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wide mb-1">
              Tanggal Sampai
            </label>
            <Calendar
              value={tanggalSampai}
              onChange={(e) => setTanggalSampai(e.value as Date)}
              dateFormat="yy-mm-dd"
              showIcon
              placeholder="YYYY-MM-DD"
              className="p-inputtext-sm border-round-lg text-xs"
            />
          </div>

          {/* Action Buttons */}
          <div className="col-12 md:col-1 flex gap-2 justify-content-end">
            <Button
              icon="pi pi-filter"
              severity="success"
              onClick={() => fetchRekamMedis(undefined, 1)}
              disabled={!selectedPasien}
              tooltip="Filter Data"
              className="bg-teal-600 border-none border-round-lg shadow-1"
            />
            <Button
              icon="pi pi-refresh"
              severity="secondary"
              outlined
              onClick={handleResetFilter}
              tooltip="Reset Filter"
              className="border-round-lg"
            />
          </div>
        </div>
      </div>

      {/* SELECTED PASIEN SUMMARY CARD */}
      {selectedPasien && (
        <div className="surface-card p-3 border-round-xl border-1 surface-border shadow-1 mb-3 flex flex-wrap align-items-center justify-content-between gap-3 bg-teal-50/40">
          <div className="flex align-items-center gap-3">
            <div className="w-3rem h-3rem border-circle bg-teal-600 text-white font-black text-xl flex align-items-center justify-content-center shadow-1">
              {selectedPasien.nama ? selectedPasien.nama.charAt(0).toUpperCase() : 'P'}
            </div>
            <div>
              <div className="flex align-items-center gap-2">
                <span className="font-extrabold text-base text-slate-900">{selectedPasien.nama}</span>
                <span className="text-xs font-bold text-teal-800 bg-teal-100 px-2 py-0.5 border-round-md">
                  RM: {selectedPasien.no_rm}
                </span>
              </div>
              <div className="text-xs text-slate-500 flex flex-wrap gap-3 mt-1">
                <span>NIK: {selectedPasien.nik || '-'}</span>
                <span>Gender: {selectedPasien.jenis_kelamin || '-'}</span>
                <span>Tgl Lahir: {selectedPasien.tanggal_lahir ? formatDateIndo(selectedPasien.tanggal_lahir) : '-'}</span>
                <span>No. HP: {selectedPasien.no_hp || '-'}</span>
              </div>
            </div>
          </div>

          {selectedPasien.alergi && (
            <div className="bg-rose-50 border-1 border-rose-200 text-rose-800 px-3 py-1.5 border-round-lg text-xs font-semibold flex align-items-center gap-1.5">
              <i className="pi pi-exclamation-triangle text-rose-600" />
              <span>Alergi: {selectedPasien.alergi}</span>
            </div>
          )}
        </div>
      )}

      {/* VISITS TIMELINE CONTENT */}
      {loadingRecords ? (
        <div className="flex flex-column align-items-center justify-content-center py-6 surface-card border-round-xl border-1 surface-border">
          <ProgressSpinner style={{ width: '36px', height: '36px' }} />
          <span className="text-xs text-slate-500 font-medium mt-2">Memuat riwayat rekam medis...</span>
        </div>
      ) : records.length === 0 ? (
        <div className="surface-card border-round-xl border-1 surface-border p-6 text-center">
          <i className="pi pi-inbox text-4xl text-300 mb-2" />
          <div className="font-bold text-slate-700 text-sm">Tidak Ada Riwayat Kunjungan</div>
          <p className="text-xs text-slate-400 m-0 mt-1">
            {selectedPasien
              ? `Pasien ${selectedPasien.nama} (${selectedPasien.no_rm}) belum memiliki catatan rekam medis pada filter tanggal ini.`
              : 'Silakan pilih pasien di atas untuk melihat riwayat rekam medis.'}
          </p>
        </div>
      ) : (
        <div className="flex flex-column gap-3">
          {records.map((record) => {
            const isExpanded = Boolean(expandedVisits[record.kode_kunjungan]);

            return (
              <div
                key={record.kode_kunjungan}
                className="surface-card border-round-xl border-1 surface-border shadow-1 hover:shadow-2 transition-all overflow-hidden"
              >
                {/* VISIT HEADER */}
                <div
                  onClick={() => toggleExpand(record.kode_kunjungan)}
                  className="p-3 bg-white border-bottom-1 surface-border cursor-pointer flex align-items-center justify-content-between gap-3 user-select-none hover:bg-slate-50 transition-all"
                >
                  <div className="flex align-items-center gap-3 flex-wrap">
                    {record.nama_pasien && (
                      <div className="flex align-items-center gap-1.5 font-bold text-xs text-slate-800 bg-teal-50 border-1 border-teal-200 px-2.5 py-1 border-round-lg">
                        <i className="pi pi-user text-teal-600 text-xs" />
                        <span>{record.nama_pasien}</span>
                        <span className="text-[10px] text-teal-800 font-bold bg-teal-100 px-1.5 py-0.25 border-round-md">
                          RM: {record.no_rm}
                        </span>
                      </div>
                    )}

                    <div className="flex align-items-center gap-1.5">
                      <i className="pi pi-calendar text-teal-600 text-sm" />
                      <span className="font-extrabold text-sm text-slate-900">
                        {formatDateIndo(record.tanggal_kunjungan)}
                      </span>
                    </div>

                    <div className="flex align-items-center gap-1 text-xs text-slate-500 font-medium">
                      <i className="pi pi-clock text-slate-400" />
                      <span>{record.jam_datang} WIB</span>
                    </div>

                    <span className="text-xs font-mono font-bold text-slate-600 bg-slate-100 px-2 py-0.5 border-round-md">
                      {record.kode_kunjungan}
                    </span>

                    <Tag
                      value={record.status_kunjungan.toUpperCase()}
                      severity={getStatusKunjunganSeverity(record.status_kunjungan)}
                      className="text-[10px] font-extrabold px-2 py-0.5"
                    />
                  </div>

                  <div className="flex align-items-center gap-2 flex-shrink-0">
                    <span className="text-xs text-slate-400 font-medium hidden md:inline">
                      {record.layanan.length} Treatment
                    </span>
                    <Button
                      icon={isExpanded ? 'pi pi-chevron-up' : 'pi pi-chevron-down'}
                      rounded
                      text
                      severity="secondary"
                      className="w-2rem h-2rem"
                    />
                  </div>
                </div>

                {/* EXPANDED CONTENT */}
                {isExpanded && (
                  <div className="p-3 flex flex-column gap-3 bg-slate-50/50">
                    {record.layanan.length === 0 ? (
                      <div className="text-xs text-slate-400 italic py-2 text-center">
                        Tidak ada catatan treatment pada kunjungan ini.
                      </div>
                    ) : (
                      record.layanan.map((item, lIdx) => {
                        const rm = item.rekam_medis;
                        const dpjpOrPetugas = rm?.dokter_penanggung_jawab || item.petugas;
                        return (
                          <div key={lIdx} className="surface-card p-0 border-round-xl border-1 surface-border shadow-1 overflow-hidden">
                            {/* SESI HEADER */}
                            <div className="bg-teal-50 p-3 border-bottom-1 surface-border flex align-items-center justify-content-between flex-wrap gap-2">
                              <div>
                                <div className="flex align-items-center gap-2 mb-1">
                                  <i className="pi pi-building text-teal-600" />
                                  <span className="font-extrabold text-sm text-slate-900">{item.nama_ruangan}</span>
                                  <Tag
                                    value={item.status.toUpperCase()}
                                    severity={getStatusAntrianSeverity(item.status)}
                                    className="text-[9px] font-extrabold px-1.5 py-0.5 ml-2"
                                  />
                                </div>
                                <div className="text-xs text-slate-600 font-medium">
                                  <span className="font-bold">Layanan:</span> {item.nama_layanan}
                                </div>
                              </div>
                              <div className="text-right">
                                {dpjpOrPetugas ? (
                                  <div className="flex align-items-center gap-1.5 justify-content-end">
                                    <span className="text-xs text-slate-500 font-medium">Dokter / Petugas:</span>
                                    <span className={getJabatanBadge(dpjpOrPetugas.jabatan)}>
                                      {dpjpOrPetugas.nama}
                                    </span>
                                  </div>
                                ) : (
                                  <div className="text-xs text-slate-400 italic">Dokter / Petugas: -</div>
                                )}
                                {item.selesai_at && (
                                  <div className="text-[11px] text-slate-400 font-medium mt-1">
                                    Selesai: {String(item.selesai_at).slice(11, 16)}
                                  </div>
                                )}
                              </div>
                            </div>
                            
                            {/* SOAP NOTE */}
                            <div className="p-3 flex flex-column gap-3">
                              <div className="flex align-items-center justify-content-between flex-wrap gap-2 pb-2 border-bottom-1 surface-border">
                                <div className="flex align-items-center gap-2">
                                  <i className="pi pi-file-edit text-purple-600 text-base" />
                                  <span className="font-extrabold text-xs text-slate-800 uppercase tracking-wide">
                                    Catatan Rekam Medis (SOAP)
                                  </span>
                                </div>
                              </div>

                              {rm && (
                                rm.kode_rekam_medis ||
                                (rm.keluhan && rm.keluhan !== '-') ||
                                (rm.diagnosa && rm.diagnosa !== '-') ||
                                (rm.tindakan && rm.tindakan !== '-') ||
                                (rm.catatan && rm.catatan !== '-')
                              ) ? (
                                <div className="grid text-xs">
                                  {/* Keluhan */}
                                  <div className="col-12 md:col-6 mb-2">
                                    <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1">
                                      Keluhan / Anamnesa
                                    </label>
                                    <div className="bg-slate-50 p-2.5 border-round-lg border-1 surface-border text-slate-800 font-medium">
                                      {renderFormattedContent(rm.keluhan)}
                                    </div>
                                  </div>

                                  {/* Diagnosa */}
                                  <div className="col-12 md:col-6 mb-2">
                                    <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1">
                                      Diagnosa / Problem
                                    </label>
                                    <div className="bg-slate-50 p-2.5 border-round-lg border-1 surface-border text-slate-800 font-medium">
                                      {renderFormattedContent(rm.diagnosa)}
                                    </div>
                                  </div>

                                  {/* Tindakan */}
                                  <div className="col-12 md:col-6 mb-2">
                                    <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1">
                                      Tindakan / Resep
                                    </label>
                                    <div className="bg-slate-50 p-2.5 border-round-lg border-1 surface-border text-slate-800 font-medium">
                                      {renderFormattedContent(rm.tindakan)}
                                    </div>
                                  </div>

                                  {/* Catatan Dokter */}
                                  <div className="col-12 md:col-6 mb-2">
                                    <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1">
                                      Catatan Evaluasi / Edukasi / Ruangan
                                    </label>
                                    <div className="bg-slate-50 p-2.5 border-round-lg border-1 surface-border text-slate-800 font-medium">
                                      {renderFormattedContent(rm.catatan)}
                                    </div>
                                  </div>
                                </div>
                              ) : (
                                !((rm?.formatted_data_form && rm.formatted_data_form.length > 0) || item.catatan_tindakan || item.catatan_petugas || item.catatan_hasil_treatment || (rm?.fotos && rm.fotos.length > 0)) && (
                                  <div className="text-xs text-teal-800 font-medium bg-teal-50/60 p-2.5 border-round-lg border-1 border-teal-100 flex align-items-center gap-2 mb-1">
                                    <i className="pi pi-info-circle text-teal-600" />
                                    <span>Penanganan &amp; pemeriksaan pasien tercatat pada Form Pelayanan Ruangan.</span>
                                  </div>
                                )
                              )}

                              {renderDataFormDinamis(rm, item)}
                            </div>
                          </div>
                        );
                      })
                    )}
                  </div>
                )}
              </div>
            );
          })}

          {/* PAGINATION BAR */}
          {totalRecords > perPage && (
            <div className="surface-card border-round-xl border-1 surface-border p-2 mt-2 shadow-1">
              <Paginator
                first={(page - 1) * perPage}
                rows={perPage}
                totalRecords={totalRecords}
                onPageChange={(e) => fetchRekamMedis(undefined, e.page + 1)}
                className="p-paginator-sm"
              />
            </div>
          )}
        </div>
      )}
    </>
  );
};

export default RekamMedisPage;
