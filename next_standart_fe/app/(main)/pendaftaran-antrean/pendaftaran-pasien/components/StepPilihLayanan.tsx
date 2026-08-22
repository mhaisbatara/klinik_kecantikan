'use client';

import React, { useState, useEffect } from 'react';
import { Button } from 'primereact/button';
import { Card } from 'primereact/card';
import { Checkbox } from 'primereact/checkbox';
import { TabView, TabPanel } from 'primereact/tabview';
import { Tag } from 'primereact/tag';
import { ProgressSpinner } from 'primereact/progressspinner';
import { Toast } from 'primereact/toast';
import postData from '@/lib/axios/postData';
import { showError, showSuccess } from '@/lib/tools/generalTools';
import { apiPasienLayananOptions, apiPasienAmbilAntrianLayanan } from './endpoints';

interface ServiceItem {
  jenis: 'layanan' | 'paket';
  kode_layanan: string;
  kode_kategori: string;
  nama_kategori: string;
  nama: string;
  harga: number;
  durasi_menit: number;
  masa_berlaku_hari?: number;
  kode_ruangan?: string;
  nama_ruangan?: string;
}

interface CategoryGroup {
  kode_kategori: string;
  nama_kategori: string;
  deskripsi: string;
  items: ServiceItem[];
}

interface PasienInfo {
  no_rm: string;
  nama: string;
  nik?: string;
  no_hp?: string;
}

interface Props {
  pasienData: PasienInfo;
  toast: React.RefObject<Toast>;
  onSuccess: (resultData: any) => void;
  onBack: () => void;
}

export const StepPilihLayanan: React.FC<Props> = ({
  pasienData,
  toast,
  onSuccess,
  onBack,
}) => {
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [categories, setCategories] = useState<CategoryGroup[]>([]);
  const [paketItems, setPaketItems] = useState<ServiceItem[]>([]);
  const [selectedMap, setSelectedMap] = useState<{ [key: string]: ServiceItem }>({});

  useEffect(() => {
    fetchOptions();
  }, []);

  const fetchOptions = async () => {
    setLoading(true);
    try {
      const res = await postData(apiPasienLayananOptions);
      if (['00', '0000'].includes(res.data.status)) {
        setCategories(res.data.data.kategori_layanan || []);
        setPaketItems(res.data.data.paket_layanan || []);
      } else {
        showError(toast, res.data.message || 'Gagal memuat pilihan layanan');
      }
    } catch (error: any) {
      showError(toast, 'Terjadi kesalahan saat memuat daftar layanan');
    } finally {
      setLoading(false);
    }
  };

  const handleToggleItem = (item: ServiceItem) => {
    const key = `${item.jenis}_${item.kode_layanan}`;
    setSelectedMap((prev) => {
      const next = { ...prev };
      if (next[key]) {
        delete next[key];
      } else {
        next[key] = item;
      }
      return next;
    });
  };

  const selectedList = Object.values(selectedMap);
  const totalHarga = selectedList.reduce((sum, i) => sum + i.harga, 0);
  const totalDurasi = selectedList.reduce((sum, i) => sum + i.durasi_menit, 0);

  const formatRupiah = (val: number) => {
    return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(val);
  };

  const handleProcessSubmit = async (customItems?: ServiceItem[]) => {
    const itemsToSubmit = customItems !== undefined ? customItems : selectedList;

    setSubmitting(true);
    try {
      const itemsPayload = itemsToSubmit.map((item) => ({
        jenis_layanan: item.jenis,
        kode_layanan: item.kode_layanan,
        kode_ruangan: item.kode_ruangan,
        nama_ruangan: item.nama_ruangan,
      }));

      const res = await postData(apiPasienAmbilAntrianLayanan, {
        no_rm: pasienData.no_rm,
        items: itemsPayload,
      });

      if (['00', '0000'].includes(res.data.status)) {
        showSuccess(toast, res.data.message || 'Pendaftaran kunjungan & antrean berhasil diterbitkan');
        onSuccess(res.data.data);
      } else {
        showError(toast, res.data.message || 'Gagal memproses pendaftaran kunjungan');
      }
    } catch (error: any) {
      const msg = error?.response?.data?.message || 'Terjadi kesalahan sistem';
      showError(toast, msg);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="grid">
      {/* PASIEN INFO HEADER */}
      <div className="col-12">
        <div className="surface-card p-4 border-round-xl border-1 surface-border shadow-1 mb-4">
          <div className="flex flex-column md:flex-row align-items-start md:align-items-center justify-content-between gap-3 border-bottom-1 surface-border pb-3 mb-3">
            <div>
              <div className="flex align-items-center gap-2 mb-1">
                <Button
                  icon="pi pi-arrow-left"
                  className="p-button-rounded p-button-text p-button-secondary p-button-sm"
                  onClick={onBack}
                  tooltip="Kembali ke Pencarian Pasien"
                />
                <h3 className="text-xl font-bold text-900 m-0">Langkah 2: Pilih Layanan & Paket Treatment</h3>
              </div>
              <p className="text-500 text-sm m-0 ml-6">
                Pilih satu atau beberapa layanan/paket untuk menerbitkan nomor antrean tindakan pasien.
              </p>
            </div>

            <div className="flex align-items-center gap-2 bg-blue-50 p-3 border-round-xl border-1 border-blue-100 w-full md:w-auto">
              <i className="pi pi-user text-blue-600 text-2xl" />
              <div>
                <span className="text-xs text-500 block">Pasien Terdaftar</span>
                <span className="font-extrabold text-blue-900 text-base">{pasienData.nama}</span>
                <span className="text-xs text-blue-700 block font-semibold">No. RM: {pasienData.no_rm}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* OPTIONS CONTAINER */}
      <div className="col-12 mb-8">
        {loading ? (
          <div className="flex flex-column align-items-center justify-content-center p-5 surface-card border-round-xl">
            <ProgressSpinner style={{ width: '50px', height: '50px' }} />
            <span className="mt-3 text-500 font-medium">Memuat pilihan layanan & paket...</span>
          </div>
        ) : (
          <TabView className="p-tabview-custom">
            {/* TABS KATEGORI LAYANAN */}
            {categories.map((kat) => (
              <TabPanel key={kat.kode_kategori} header={kat.nama_kategori} leftIcon="pi pi-sparkles mr-2">
                <div className="grid">
                  {kat.items.map((item) => {
                    const key = `${item.jenis}_${item.kode_layanan}`;
                    const isSelected = !!selectedMap[key];

                    return (
                      <div key={item.kode_layanan} className="col-12 md:col-6 lg:col-4">
                        <div
                          className={`surface-card p-3 border-round-xl border-1 shadow-1 cursor-pointer transition-all transition-duration-200 ${
                            isSelected ? 'border-blue-500 bg-blue-50 shadow-2' : 'surface-border hover:border-300'
                          }`}
                          onClick={() => handleToggleItem(item)}
                        >
                          <div className="flex align-items-start gap-3">
                            <Checkbox
                              checked={isSelected}
                              onChange={() => handleToggleItem(item)}
                              className="mt-1"
                            />
                            <div className="w-full">
                              <div className="flex align-items-center justify-content-between gap-1 mb-1">
                                <Tag value={item.kode_layanan} severity="info" className="text-xs" />
                                <span className="text-xs text-500 flex align-items-center gap-1">
                                  <i className="pi pi-clock" /> {item.durasi_menit} mnt
                                </span>
                              </div>
                              <h4 className="font-bold text-900 text-base m-0 mb-1">{item.nama}</h4>
                              <div className="flex align-items-center gap-1 text-xs text-teal-700 font-semibold mb-2">
                                <i className="pi pi-building text-teal-500" />
                                <span>{item.nama_ruangan ? `${item.kode_ruangan ? item.kode_ruangan + ' - ' : ''}${item.nama_ruangan}` : (item.kode_ruangan || 'Ruang Treatment')}</span>
                              </div>
                              <div className="text-base font-extrabold text-blue-600">
                                {formatRupiah(item.harga)}
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </TabPanel>
            ))}

            {/* TAB PAKET LAYANAN */}
            <TabPanel header={`Paket Layanan (${paketItems.length})`} leftIcon="pi pi-box mr-2">
              <div className="grid">
                {paketItems.map((item) => {
                  const key = `${item.jenis}_${item.kode_layanan}`;
                  const isSelected = !!selectedMap[key];

                  return (
                    <div key={item.kode_layanan} className="col-12 md:col-6 lg:col-4">
                      <div
                        className={`surface-card p-3 border-round-xl border-1 shadow-1 cursor-pointer transition-all transition-duration-200 ${
                          isSelected ? 'border-amber-500 bg-amber-50 shadow-2' : 'surface-border hover:border-300'
                        }`}
                        onClick={() => handleToggleItem(item)}
                      >
                        <div className="flex align-items-start gap-3">
                          <Checkbox
                            checked={isSelected}
                            onChange={() => handleToggleItem(item)}
                            className="mt-1"
                          />
                          <div className="w-full">
                            <div className="flex align-items-center justify-content-between gap-1 mb-1">
                              <Tag value="PAKET" severity="warning" className="text-xs font-bold" />
                              {item.masa_berlaku_hari && (
                                <span className="text-xs text-500">Masa berlaku {item.masa_berlaku_hari} hr</span>
                              )}
                            </div>
                            <h4 className="font-bold text-900 text-base m-0 mb-1">{item.nama}</h4>
                            <div className="flex align-items-center gap-1 text-xs text-teal-700 font-semibold mb-2">
                              <i className="pi pi-building text-teal-500" />
                              <span>{item.nama_ruangan ? `${item.kode_ruangan ? item.kode_ruangan + ' - ' : ''}${item.nama_ruangan}` : (item.kode_ruangan || 'Ruang Treatment')}</span>
                            </div>
                            <div className="text-base font-extrabold text-amber-700">
                              {formatRupiah(item.harga)}
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </TabPanel>
          </TabView>
        )}
      </div>

      {/* FIXED / STICKY BOTTOM SUMMARY BAR */}
      <div
        className="fixed bottom-0 left-0 right-0 surface-card border-top-1 surface-border p-3 shadow-5 flex align-items-center justify-content-between"
        style={{ zIndex: 1000 }}
      >
        <div className="flex align-items-center gap-4 pl-3">
          <div>
            <span className="text-xs text-500 block">Layanan Dipilih:</span>
            <span className="font-extrabold text-900 text-lg">{selectedList.length} Item</span>
          </div>
          <div className="hidden sm:block border-left-1 surface-border pl-4">
            <span className="text-xs text-500 block">Total Estimasi Durasi:</span>
            <span className="font-bold text-700 text-base flex align-items-center gap-1">
              <i className="pi pi-clock text-blue-500" /> {totalDurasi} Menit
            </span>
          </div>
          <div className="border-left-1 surface-border pl-4">
            <span className="text-xs text-500 block">Total Estimasi Biaya:</span>
            <span className="font-extrabold text-blue-600 text-xl">{formatRupiah(totalHarga)}</span>
          </div>
        </div>

        <div className="flex align-items-center gap-2 pr-3">
          <Button
            label="Selesai Tanpa Layanan"
            icon="pi pi-times"
            className="p-button-outlined p-button-secondary border-round-lg text-sm"
            onClick={() => handleProcessSubmit([])}
            disabled={submitting}
          />
          <Button
            label={`Ambil Nomor Antrean Layanan (${selectedList.length})`}
            icon="pi pi-ticket"
            className="p-button-primary border-round-lg font-bold p-button-lg"
            onClick={() => handleProcessSubmit()}
            loading={submitting}
            disabled={selectedList.length === 0}
          />
        </div>
      </div>
    </div>
  );
};
