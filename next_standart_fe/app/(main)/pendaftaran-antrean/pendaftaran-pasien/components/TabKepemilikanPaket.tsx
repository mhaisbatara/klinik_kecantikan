'use client';

import React, { useEffect, useState, useCallback } from 'react';
import { DataTable } from 'primereact/datatable';
import { Column } from 'primereact/column';
import { Button } from 'primereact/button';
import { InputText } from 'primereact/inputtext';
import { IconField } from 'primereact/iconfield';
import { InputIcon } from 'primereact/inputicon';
import { Tag } from 'primereact/tag';
import { ProgressBar } from 'primereact/progressbar';
import { Dialog } from 'primereact/dialog';
import { confirmDialog, ConfirmDialog } from 'primereact/confirmdialog';
import postData from '@/lib/axios/postData';
import { showError, showSuccess } from '@/lib/tools/generalTools';
import { apiPasienKepemilikanPaket, apiPasienAmbilAntrianLayanan } from './endpoints';
import { KarcisAntrianLayananModal } from './dialogs/KarcisAntrianLayananModal';

interface DetailKepemilikan {
  kode_detail_kepemilikan_paket_layanan: string;
  kode_layanan: string;
  nama_layanan: string;
  sesi_total: number;
  sesi_terpakai: number;
  sisa_sesi: number;
}

interface KepemilikanPaket {
  id: number;
  kode_kepemilikan_paket_layanan: string;
  no_rm: string;
  nama_pasien: string;
  no_hp_pasien?: string;
  kode_paket_layanan: string;
  nama_paket: string;
  tipe_paket?: string;
  tanggal_beli: string;
  tanggal_expired: string;
  status: 'aktif' | 'habis' | 'expired' | string;
  total_sesi: number;
  total_terpakai: number;
  sisa_sesi: number;
  details: DetailKepemilikan[];
}

interface TabKepemilikanPaketProps {
  toast?: any;
  refreshTrigger?: number;
}

export const TabKepemilikanPaket: React.FC<TabKepemilikanPaketProps> = ({ toast, refreshTrigger = 0 }) => {
  const [dataList, setDataList] = useState<KepemilikanPaket[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [totalRecords, setTotalRecords] = useState<number>(0);

  const [page, setPage] = useState<number>(1);
  const [rows, setRows] = useState<number>(10);
  const [first, setFirst] = useState<number>(0);

  const [searchVal, setSearchVal] = useState<string>('');
  const [appliedKeyword, setAppliedKeyword] = useState<string>('');

  const [selectedItem, setSelectedItem] = useState<KepemilikanPaket | null>(null);
  const [dialogDetailVisible, setDialogDetailVisible] = useState<boolean>(false);

  const [antrianLayananModalVisible, setAntrianLayananModalVisible] = useState(false);
  const [antrianLayananData, setAntrianLayananData] = useState<any>(null);

  const loadData = useCallback(async () => {
    setLoading(true);
    try {
      const res = await postData(apiPasienKepemilikanPaket, {
        page,
        perPage: rows,
        keyword: appliedKeyword.trim(),
      });

      if (['00', '0000'].includes(res.data.status)) {
        setDataList(res.data.data || []);
        setTotalRecords(res.data.total_data || 0);
      } else {
        showError(toast, res.data.message || 'Gagal memuat data kepemilikan paket');
      }
    } catch (err: any) {
      showError(toast, err?.response?.data?.message || 'Terjadi kesalahan sistem saat memuat data paket pasien');
    } finally {
      setLoading(false);
    }
  }, [page, rows, appliedKeyword, toast]);

  useEffect(() => {
    loadData();
  }, [loadData, refreshTrigger]);

  const handleSearchSubmit = (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    setPage(1);
    setFirst(0);
    setAppliedKeyword(searchVal);
  };

  const handleClearSearch = () => {
    setSearchVal('');
    setAppliedKeyword('');
    setPage(1);
    setFirst(0);
  };

  const handleOpenDetail = (item: KepemilikanPaket) => {
    setSelectedItem(item);
    setDialogDetailVisible(true);
  };

  const handleConfirmClaim = (item: KepemilikanPaket, detailItem?: DetailKepemilikan) => {
    const targetDetail = detailItem || (item.details || []).find((d) => d.sisa_sesi > 0) || item.details[0];
    if (!targetDetail || targetDetail.sisa_sesi <= 0) {
      showError(toast, 'Sesi layanan paket ini sudah habis');
      return;
    }

    confirmDialog({
      message: (
        <div className="flex flex-column gap-3 py-1">
          <div className="text-center pb-2 border-bottom-1 surface-border">
            <i className="pi pi-ticket text-emerald-500 text-4xl mb-2" />
            <h4 className="font-extrabold text-xl text-900 m-0">Klaim 1 Sesi Paket Layanan?</h4>
            <p className="text-sm text-500 m-0 mt-1">
              Pasien <strong>{item.nama_pasien}</strong> ({item.no_rm})
            </p>
          </div>

          <div className="surface-100 p-3 border-round-xl text-sm">
            <div className="flex justify-content-between mb-2">
              <span className="text-500">Nama Paket:</span>
              <span className="font-bold text-amber-700">{item.nama_paket}</span>
            </div>
            <div className="flex justify-content-between mb-2">
              <span className="text-500">Layanan Diklaim:</span>
              <span className="font-bold text-blue-700">{targetDetail.nama_layanan || targetDetail.kode_layanan}</span>
            </div>
            <div className="flex justify-content-between">
              <span className="text-500">Sisa Sesi Saat Ini:</span>
              <Tag value={`${targetDetail.sisa_sesi} Sesi`} severity="info" className="font-bold" />
            </div>
          </div>
        </div>
      ),
      header: 'Konfirmasi Klaim Sesi Paket',
      acceptLabel: 'Ya, Terbitkan Antrean Klaim',
      rejectLabel: 'Batal',
      acceptClassName: 'p-button-success font-bold px-4',
      rejectClassName: 'p-button-outlined p-button-secondary',
      accept: async () => {
        try {
          const res = await postData(apiPasienAmbilAntrianLayanan, {
            no_rm: item.no_rm,
            items: [
              {
                jenis_layanan: 'klaim_paket',
                kode_layanan: targetDetail.kode_layanan,
                kode_kepemilikan_paket_layanan: item.kode_kepemilikan_paket_layanan,
              },
            ],
          });

          if (['00', '0000'].includes(res.data.status)) {
            showSuccess(toast, res.data.message || 'Klaim sesi berhasil diterbitkan');
            setAntrianLayananData(res.data.data);
            setAntrianLayananModalVisible(true);
            setDialogDetailVisible(false);
            loadData();
          } else {
            showError(toast, res.data.message || 'Gagal mengklaim sesi paket');
          }
        } catch (error: any) {
          showError(toast, error?.response?.data?.message || 'Terjadi kesalahan saat klaim sesi paket');
        }
      },
    });
  };

  // Column templates matching Pendaftaran Pasien table
  const noRmBodyTemplate = (rowData: KepemilikanPaket) => (
    <Tag value={rowData.no_rm} severity="info" className="font-bold px-2 py-1 text-xs border-round-md" />
  );

  const pasienBodyTemplate = (rowData: KepemilikanPaket) => (
    <div>
      <span className="font-bold text-900 block text-sm">{rowData.nama_pasien || '-'}</span>
      {rowData.no_hp_pasien && <span className="text-xs text-500 block">HP: {rowData.no_hp_pasien}</span>}
    </div>
  );

  const paketBodyTemplate = (rowData: KepemilikanPaket) => (
    <div>
      <span className="font-bold text-900 block text-sm">{rowData.nama_paket || rowData.kode_paket_layanan}</span>
      <span className="text-xs text-500 font-mono block">Kode: {rowData.kode_kepemilikan_paket_layanan}</span>
    </div>
  );

  const progresSesiTemplate = (rowData: KepemilikanPaket) => {
    const total = rowData.total_sesi || 1;
    const terpakai = rowData.total_terpakai || 0;
    const percent = Math.min(100, Math.round((terpakai / total) * 100));

    return (
      <div className="w-full max-w-12rem">
        <div className="flex justify-content-between text-xs font-semibold mb-1">
          <span>{terpakai} / {total} Sesi Terpakai</span>
          <span>{percent}%</span>
        </div>
        <ProgressBar value={percent} showValue={false} style={{ height: '7px' }} color={percent === 100 ? '#ef4444' : '#3b82f6'} />
      </div>
    );
  };

  const sisaSesiTemplate = (rowData: KepemilikanPaket) => {
    const sisa = rowData.sisa_sesi;
    let severity: 'success' | 'warning' | 'danger' = 'success';
    if (sisa === 0) severity = 'danger';
    else if (sisa === 1) severity = 'warning';

    return <Tag value={`${sisa} Sesi Tersisa`} severity={severity} className="font-bold text-xs px-2 py-1 border-round-md" />;
  };

  const tanggalBodyTemplate = (rowData: KepemilikanPaket) => (
    <div className="text-xs">
      <span className="text-500 block">Beli: {rowData.tanggal_beli || '-'}</span>
      <span className="font-bold text-900 block">Expired: {rowData.tanggal_expired || '-'}</span>
    </div>
  );

  const statusBodyTemplate = (rowData: KepemilikanPaket) => {
    const st = (rowData.status || '').toLowerCase();
    let severity: 'success' | 'warning' | 'danger' | 'info' = 'info';
    let label = rowData.status;

    if (st === 'aktif') {
      severity = 'success';
      label = 'Aktif';
    } else if (st === 'habis') {
      severity = 'warning';
      label = 'Habis';
    } else if (st === 'expired') {
      severity = 'danger';
      label = 'Expired';
    }

    return <Tag value={label.toUpperCase()} severity={severity} className="font-bold text-xs px-2 py-1 border-round-md" />;
  };

  const actionBodyTemplate = (rowData: KepemilikanPaket) => (
    <div className="flex align-items-center justify-content-center gap-1">
      {rowData.status === 'aktif' && rowData.sisa_sesi > 0 && (
        <Button
          icon="pi pi-ticket"
          label="Klaim Sesi"
          size="small"
          severity="success"
          className="text-xs font-bold border-round-md"
          onClick={(e) => {
            e.stopPropagation();
            handleConfirmClaim(rowData);
          }}
        />
      )}
      <Button
        icon="pi pi-eye"
        label="Detail Sesi"
        size="small"
        outlined
        severity="info"
        className="text-xs font-semibold border-round-md"
        onClick={(e) => {
          e.stopPropagation();
          handleOpenDetail(rowData);
        }}
      />
    </div>
  );

  return (
    <>
      <ConfirmDialog />

      <KarcisAntrianLayananModal
        visible={antrianLayananModalVisible}
        onHide={() => setAntrianLayananModalVisible(false)}
        data={antrianLayananData}
      />

      {/* 1. SEPARATED LARGE SEARCH CARD */}
      <div className="card p-4 mb-4 border-round-xl surface-card shadow-1 mt-3">
        <div className="mb-4 pb-3 border-bottom-1 surface-border">
          <h2 className="text-2xl font-bold flex align-items-center gap-2 mb-1 text-900">
            <i className="pi pi-box text-blue-600 text-3xl" />
            Data Kepemilikan Paket Pasien
          </h2>
          <p className="text-color-secondary m-0 text-sm">
            Cari data pasien terdaftar yang memiliki paket layanan aktif / multi-sesi beserta rincian sisa sesinya.
          </p>
        </div>

        {/* SEARCH BAR CARD */}
        <div className="surface-50 p-4 border-round-xl border-1 surface-border">
          <label className="block text-base font-bold text-900 mb-2 flex align-items-center gap-2">
            <i className="pi pi-search text-blue-600 text-xl" />
            Cari Kepemilikan Paket (No. RM / NIK / Nama Pasien / Nama Paket)
          </label>
          <form onSubmit={handleSearchSubmit} className="flex flex-column sm:flex-row gap-2 w-full">
            <div className="flex-1">
              <IconField iconPosition="left" className="w-full">
                <InputIcon className="pi pi-search text-lg" />
                <InputText
                  value={searchVal}
                  onChange={(e) => setSearchVal(e.target.value)}
                  placeholder="Masukkan No. RM, NIK, Nama Pasien, atau Nama Paket..."
                  className="w-full text-base p-inputtext-lg border-round-lg"
                />
              </IconField>
            </div>
            <div className="flex gap-2">
              <Button
                type="submit"
                label="Cari"
                icon="pi pi-search"
                severity="info"
                size="large"
                className="font-bold border-round-lg px-4 flex-1 sm:flex-initial text-base"
              />
              {searchVal && (
                <Button
                  type="button"
                  icon="pi pi-times"
                  severity="secondary"
                  outlined
                  size="large"
                  tooltip="Reset Pencarian"
                  className="border-round-lg"
                  onClick={handleClearSearch}
                />
              )}
            </div>
          </form>
        </div>
      </div>

      {/* 2. DATATABLE CONTAINER CARD */}
      <div className="card border-round-xl p-4 shadow-1 surface-card mb-4">
        {/* DATATABLE */}
        <DataTable
          value={dataList}
          loading={loading}
          lazy
          paginator
          first={first}
          rows={rows}
          totalRecords={totalRecords}
          onPage={(e) => {
            setFirst(e.first);
            setRows(e.rows);
            setPage((e.page || 0) + 1);
          }}
          dataKey="kode_kepemilikan_paket_layanan"
          emptyMessage="Data Kepemilikan Paket Pasien Tidak Ditemukan"
          rowsPerPageOptions={[10, 25, 50]}
          rowHover
          onRowClick={(e) => handleOpenDetail(e.data as KepemilikanPaket)}
          style={{ cursor: 'pointer' }}
          paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
          currentPageReportTemplate="Menampilkan {first} - {last} dari {totalRecords} data kepemilikan paket"
        >
          <Column field="no_rm" header="No. RM" body={noRmBodyTemplate} align="center" sortable style={{ minWidth: '8rem' }} />
          <Column field="nama_pasien" header="Nama Pasien" body={pasienBodyTemplate} sortable style={{ minWidth: '12rem' }} />
          <Column field="nama_paket" header="Paket Layanan" body={paketBodyTemplate} sortable style={{ minWidth: '14rem' }} />
          <Column header="Progres Sesi" body={progresSesiTemplate} style={{ minWidth: '12rem' }} />
          <Column header="Sisa Sesi" body={sisaSesiTemplate} align="center" style={{ minWidth: '10rem' }} />
          <Column header="Masa Berlaku" body={tanggalBodyTemplate} align="center" style={{ minWidth: '11rem' }} />
          <Column header="Status" body={statusBodyTemplate} align="center" style={{ minWidth: '8rem' }} />
          <Column header="Aksi" body={actionBodyTemplate} align="center" style={{ minWidth: '14rem' }} />
        </DataTable>
      </div>

      {/* DIALOG DETAIL SESI */}
      <Dialog
        visible={dialogDetailVisible}
        onHide={() => setDialogDetailVisible(false)}
        header={
          <div className="flex align-items-center gap-2">
            <i className="pi pi-list text-blue-600 text-xl" />
            <span className="font-bold text-lg">Rincian Sesi Layanan Paket</span>
          </div>
        }
        modal
        style={{ width: '100%', maxWidth: '650px' }}
      >
        {selectedItem && (
          <div className="flex flex-column gap-3 py-1">
            <div className="surface-100 p-3 border-round-xl border-1 surface-border flex justify-content-between align-items-center">
              <div>
                <span className="text-xs text-500 block">Pasien</span>
                <span className="font-bold text-900 text-base">{selectedItem.nama_pasien}</span>
                <span className="text-xs text-blue-600 block font-medium">No. RM: {selectedItem.no_rm}</span>
              </div>
              <div className="text-right">
                <span className="text-xs text-500 block">Paket</span>
                <span className="font-bold text-amber-700 block">{selectedItem.nama_paket}</span>
                <Tag value={selectedItem.status.toUpperCase()} severity={selectedItem.status === 'aktif' ? 'success' : 'danger'} className="text-[10px] mt-1 font-bold" />
              </div>
            </div>

            <h5 className="font-bold text-sm text-900 m-0 mb-1">Rincian Sesi Per Layanan:</h5>
            <DataTable value={selectedItem.details} className="p-datatable-sm" responsiveLayout="scroll">
              <Column field="kode_layanan" header="Kode" className="font-mono text-xs" style={{ width: '100px' }} />
              <Column field="nama_layanan" header="Nama Layanan" className="font-bold text-xs" />
              <Column field="sesi_total" header="Total" className="text-center text-xs" style={{ width: '80px' }} />
              <Column field="sesi_terpakai" header="Terpakai" className="text-center text-xs" style={{ width: '90px' }} />
              <Column
                header="Sisa Sesi"
                body={(det: DetailKepemilikan) => (
                  <Tag value={`${det.sisa_sesi} Sesi`} severity={det.sisa_sesi > 0 ? 'info' : 'danger'} className="text-xs font-bold" />
                )}
                style={{ width: '100px', textAlign: 'center' }}
              />
              <Column
                header="Aksi Klaim"
                body={(det: DetailKepemilikan) => (
                  det.sisa_sesi > 0 && selectedItem.status === 'aktif' ? (
                    <Button
                      icon="pi pi-ticket"
                      label="Klaim"
                      size="small"
                      severity="success"
                      className="text-xs font-bold py-1 px-2 border-round-md"
                      onClick={() => handleConfirmClaim(selectedItem, det)}
                    />
                  ) : (
                    <span className="text-xs text-400 font-semibold">Habis</span>
                  )
                )}
                style={{ width: '100px', textAlign: 'center' }}
              />
            </DataTable>
          </div>
        )}
      </Dialog>
    </>
  );
};
