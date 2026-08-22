'use client';

import React, { useState, useEffect, useRef } from 'react';
import { DataTable, DataTableStateEvent } from 'primereact/datatable';
import { Column } from 'primereact/column';
import { InputText } from 'primereact/inputtext';
import { Button } from 'primereact/button';
import { Tag } from 'primereact/tag';
import { Toast } from 'primereact/toast';
import { IconField } from 'primereact/iconfield';
import { InputIcon } from 'primereact/inputicon';
import postData from '@/lib/axios/postData';
import { showError, showSuccess } from '@/lib/tools/generalTools';
import { formatDateSystem } from '@/lib/tools/dateTools';
import { apiPasienCari } from './endpoints';
import { StepPilihLayanan } from './StepPilihLayanan';
import { KarcisAntrianModal } from './dialogs/KarcisAntrianModal';
import { KarcisAntrianLayananModal } from './dialogs/KarcisAntrianLayananModal';

export interface Pasien {
  id: number;
  no_rm: string;
  nama: string;
  nik?: string;
  no_hp?: string;
  tanggal_lahir?: string;
  jenis_kelamin?: string;
  golongan_darah?: string;
  agama?: string;
  status_perkawinan?: string;
  kewarganegaraan?: string;
  pekerjaan?: string;
  provinsi?: string;
  kota_kabupaten?: string;
  kecamatan?: string;
  kelurahan_desa?: string;
  patokan?: string;
  alergi?: string;
  status?: string;
  created_at?: string;
  updated_at?: string;
}

interface Props {
  toast: React.RefObject<Toast>;
  onRefreshVisits?: () => void;
}

export const TabPendaftaranLama: React.FC<Props> = ({ toast, onRefreshVisits }) => {
  // Step state: 1 = Cari & Pilih Pasien, 2 = Pilih Layanan & Paket Treatment
  const [step, setStep] = useState<number>(1);
  const [selectedPasien, setSelectedPasien] = useState<Pasien | null>(null);

  // Data & Table state
  const [data, setData] = useState<Pasien[]>([]);
  const [loading, setLoading] = useState(false);
  const [totalRecords, setTotalRecords] = useState(0);

  // Pagination & Search
  const [page, setPage] = useState(1);
  const [rows, setRows] = useState(10);
  const [first, setFirst] = useState(0);
  const [searchVal, setSearchVal] = useState('');
  const [keyword, setKeyword] = useState('');
  const searchTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  // Success Modals
  const [karcisVisible, setKarcisVisible] = useState(false);
  const [ticketData, setTicketData] = useState<any>(null);
  const [antrianLayananModalVisible, setAntrianLayananModalVisible] = useState(false);
  const [antrianLayananData, setAntrianLayananData] = useState<any>(null);

  const fetchPasienData = async () => {
    setLoading(true);
    try {
      const payload = {
        page,
        perPage: rows,
        keyword: keyword.trim(),
      };

      const res = await postData(apiPasienCari, payload);
      if (['00', '0000'].includes(res.data.status)) {
        setData(res.data.data || []);
        setTotalRecords(res.data.total_data || 0);
      } else {
        showError(toast, res.data.message || 'Gagal memuat data pasien');
      }
    } catch (error: any) {
      showError(toast, 'Terjadi kesalahan saat memuat master data pasien');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPasienData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [page, rows, keyword]);

  const onPageChange = (event: DataTableStateEvent) => {
    setFirst(event.first);
    setRows(event.rows);
    setPage((event.page || 0) + 1);
  };

  const handleSelectPasien = (pasien: Pasien) => {
    setSelectedPasien(pasien);
    setStep(2);
  };

  const handleLayananSuccess = (resultData: any) => {
    if (resultData.antrian_layanan && resultData.antrian_layanan.length > 0) {
      setAntrianLayananData(resultData);
      setAntrianLayananModalVisible(true);
    } else {
      setTicketData({
        no_rm: resultData.no_rm,
        nama: resultData.nama_pasien,
        kode_kunjungan: resultData.kode_kunjungan,
        nomor_antrian: resultData.nomor_antrian_awal,
        kode_antrian: resultData.kode_antrian_awal,
        tanggal_kunjungan: resultData.tanggal_kunjungan,
        jam_datang: resultData.jam_datang,
      });
      setKarcisVisible(true);
    }

    if (onRefreshVisits) onRefreshVisits();
    setStep(1);
    setSelectedPasien(null);
  };

  const noRmBodyTemplate = (rowData: Pasien) => {
    return <Tag value={rowData.no_rm} severity="info" className="font-bold text-xs" />;
  };

  const jenisKelaminBodyTemplate = (rowData: Pasien) => {
    if (!rowData.jenis_kelamin) return <span className="text-400 font-italic">-</span>;
    const isMale = rowData.jenis_kelamin === 'L';
    return (
      <Tag
        value={isMale ? 'Laki-Laki' : 'Perempuan'}
        severity={isMale ? 'warning' : 'success'}
        className="text-xs px-2 py-1"
      />
    );
  };

  const actionBodyTemplate = (rowData: Pasien) => {
    return (
      <Button
        label="Pilih & Layanan"
        icon="pi pi-check-circle"
        size="small"
        severity="success"
        className="border-round-md font-medium text-xs px-3"
        onClick={() => handleSelectPasien(rowData)}
      />
    );
  };

  const headerTemplate = (
    <div className="flex flex-wrap align-items-center justify-content-between gap-2">
      <span className="text-xl font-bold text-900">Cari Pasien Terdaftar</span>
      <div className="flex align-items-center gap-2 ml-auto w-full md:w-auto">
        <span className="p-input-icon-left w-full md:w-22rem">
          <IconField iconPosition="left">
            <InputIcon className="pi pi-search" />
            <InputText
              value={searchVal}
              className="w-full text-sm"
              placeholder="Cari Nama Pasien / No. RM / NIK..."
              onChange={(e) => {
                const value = e.target.value;
                setSearchVal(value);
                if (searchTimeoutRef.current) clearTimeout(searchTimeoutRef.current);
                searchTimeoutRef.current = setTimeout(() => {
                  setKeyword(value);
                  setPage(1);
                  setFirst(0);
                }, 400);
              }}
            />
          </IconField>
        </span>
        <Button
          type="button"
          icon="pi pi-filter-slash"
          outlined
          severity="danger"
          tooltip="Reset Filter"
          tooltipOptions={{ position: 'bottom' }}
          onClick={() => {
            setSearchVal('');
            setKeyword('');
            setPage(1);
            setFirst(0);
          }}
        />
      </div>
    </div>
  );

  if (step === 2 && selectedPasien) {
    return (
      <>
        <StepPilihLayanan
          pasienData={selectedPasien}
          toast={toast}
          onSuccess={handleLayananSuccess}
          onBack={() => {
            setStep(1);
            setSelectedPasien(null);
          }}
        />

        <KarcisAntrianModal
          visible={karcisVisible}
          onHide={() => setKarcisVisible(false)}
          data={ticketData}
        />

        <KarcisAntrianLayananModal
          visible={antrianLayananModalVisible}
          onHide={() => setAntrianLayananModalVisible(false)}
          data={antrianLayananData}
        />
      </>
    );
  }

  return (
    <>
      <div className="card border-round-xl p-4 shadow-1 surface-card mb-4">
        {/* SUBHEADER TITLE */}
        <div className="mb-4">
          <h3 className="text-2xl font-bold text-900 flex align-items-center gap-2 mb-1">
            <i className="pi pi-users text-teal-600 text-2xl" />
            Pendaftaran Pasien Lama
          </h3>
          <p className="text-500 text-sm m-0">
            Cari nama atau No. RM pasien terdaftar di klinik, pilih pasien, lalu tentukan layanan/paket treatment.
          </p>
        </div>

        {/* DATA TABLE PASIEN LAMA UNTUK PENDAFTARAN */}
        <DataTable
          value={data}
          scrollable
          lazy
          paginator
          first={first}
          rows={rows}
          totalRecords={totalRecords}
          onPage={onPageChange}
          header={headerTemplate}
          loading={loading}
          dataKey="no_rm"
          emptyMessage="Data Pasien Tidak Ditemukan"
          rowsPerPageOptions={[10, 25, 50]}
          className="p-datatable-sm p-datatable-gridlines"
          paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
          currentPageReportTemplate="Menampilkan {first} - {last} dari {totalRecords} data pasien"
        >
          <Column field="no_rm" header="No. RM" body={noRmBodyTemplate} align="center" sortable style={{ minWidth: '8rem' }} />
          <Column field="nama" header="Nama Pasien" className="font-bold text-900" sortable style={{ minWidth: '13rem' }} />
          <Column field="nik" header="NIK" align="center" style={{ minWidth: '10rem' }} body={(r: Pasien) => r.nik || '-'} />
          <Column field="no_hp" header="No. HP" align="center" style={{ minWidth: '10rem' }} body={(r: Pasien) => r.no_hp || '-'} />
          <Column field="tanggal_lahir" header="Tgl Lahir" align="center" style={{ minWidth: '8rem' }} body={(r: Pasien) => r.tanggal_lahir || '-'} />
          <Column header="L/P" body={jenisKelaminBodyTemplate} align="center" style={{ minWidth: '7rem' }} />
          <Column field="kota_kabupaten" header="Kota / Alamat" style={{ minWidth: '12rem' }} body={(r: Pasien) => r.kota_kabupaten || r.provinsi || '-'} />
          <Column header="Aksi Pendaftaran" body={actionBodyTemplate} align="center" frozen alignFrozen="right" style={{ minWidth: '11rem' }} />
        </DataTable>
      </div>

      <KarcisAntrianModal
        visible={karcisVisible}
        onHide={() => setKarcisVisible(false)}
        data={ticketData}
      />

      <KarcisAntrianLayananModal
        visible={antrianLayananModalVisible}
        onHide={() => setAntrianLayananModalVisible(false)}
        data={antrianLayananData}
      />
    </>
  );
};
