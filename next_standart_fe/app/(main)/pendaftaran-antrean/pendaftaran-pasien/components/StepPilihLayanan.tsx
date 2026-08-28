'use client';

import React, { useState, useEffect } from 'react';
import { Button } from 'primereact/button';
import { Checkbox } from 'primereact/checkbox';
import { TabView, TabPanel } from 'primereact/tabview';
import { Tag } from 'primereact/tag';
import { ProgressSpinner } from 'primereact/progressspinner';
import { Toast } from 'primereact/toast';
import postData from '@/lib/axios/postData';
import { showError, showSuccess } from '@/lib/tools/generalTools';
import { confirmDialog, ConfirmDialog } from 'primereact/confirmdialog';
import { apiPasienLayananOptions, apiPasienAmbilAntrianLayanan } from './endpoints';

interface ServiceItem {
  jenis: 'layanan' | 'paket';
  kode_layanan: string;
  kode_kategori: string;
  nama_kategori: string;
  nama: string;
  harga: number;
  harga_asal?: number;
  is_promo?: boolean;
  kode_promo?: string;
  nama_promo?: string;
  jenis_diskon?: 'persen' | 'nominal';
  nilai_diskon?: number;
  durasi_menit: number;
  masa_berlaku_hari?: number;
  kode_ruangan?: string;
  nama_ruangan?: string;
}

interface RuanganGroup {
  kode_ruangan: string;
  nama_ruangan: string;
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
  const [ruangans, setRuangans] = useState<RuanganGroup[]>([]);
  // Map item yang dipilih: key = `${jenis}_${kode_layanan}`
  const [selectedMap, setSelectedMap] = useState<{ [key: string]: ServiceItem }>({});
  // Kode ruangan yang sedang aktif dipilih (null = belum ada yang dipilih)
  const [activeRuangan, setActiveRuangan] = useState<string | null>(null);

  useEffect(() => {
    fetchOptions();
  }, []);

  const fetchOptions = async () => {
    setLoading(true);
    try {
      const res = await postData(apiPasienLayananOptions);
      if (['00', '0000'].includes(res.data.status)) {
        setRuangans(res.data.data.ruangan_layanan || res.data.data.kategori_layanan || []);
      } else {
        showError(toast, res.data.message || 'Gagal memuat pilihan layanan');
      }
    } catch (error: any) {
      showError(toast, 'Terjadi kesalahan saat memuat daftar layanan');
    } finally {
      setLoading(false);
    }
  };

  /**
   * Toggle pilih/batal item layanan atau paket.
   * Aturan:
   * - Dalam 1 ruangan yang sama → boleh multi-select (centang banyak layanan / paket)
   * - Beda ruangan → tidak bisa dipilih selama ruangan lain masih aktif
   */
  const handleToggleItem = (item: ServiceItem) => {
    const key = `${item.jenis}_${item.kode_layanan}`;
    const targetRoomCode = item.kode_ruangan || 'LAINNYA';

    setSelectedMap((prev) => {
      const next = { ...prev };

      if (next[key]) {
        // Jika item sudah dipilih → deselect
        delete next[key];
        // Jika tidak ada yang tersisa → reset activeRuangan
        if (Object.keys(next).length === 0) {
          setActiveRuangan(null);
        }
        return next;
      }

      // Jika belum dipilih → cek apakah ruangan cocok
      if (activeRuangan !== null && activeRuangan !== targetRoomCode) {
        const activeRoomName = Object.values(prev)[0]?.nama_ruangan || activeRuangan;
        showError(
          toast,
          `Tidak bisa pilih layanan/paket dari ruangan berbeda. Saat ini aktif: ruangan "${activeRoomName}". Batalkan pilihan terlebih dahulu jika ingin berpindah ruangan.`
        );
        return prev;
      }

      // Ruangan sama atau belum ada yang dipilih → tambahkan
      next[key] = item;
      setActiveRuangan(targetRoomCode);
      return next;
    });
  };

  const handleClearSelection = () => {
    setSelectedMap({});
    setActiveRuangan(null);
  };

  const selectedList = Object.values(selectedMap);
  // totalHarga selalu pakai harga asli — diskon akan diterapkan di kasir
  const totalHarga = selectedList.reduce((sum, i) => sum + (i.harga_asal ?? i.harga), 0);
  const totalDurasi = selectedList.reduce((sum, i) => sum + i.durasi_menit, 0);
  const hasPromo = selectedList.some((i) => i.is_promo);

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

  const confirmTakeQueue = (customItems?: ServiceItem[]) => {
    const itemsToSubmit = customItems !== undefined ? customItems : selectedList;

    if (itemsToSubmit.length === 0) {
      confirmDialog({
        message: (
          <div className="flex flex-column align-items-center text-center gap-2 py-2">
            <i className="pi pi-question-circle text-orange-500 text-5xl mb-2" />
            <h3 className="font-bold text-xl m-0 text-900">Pendaftaran Tanpa Layanan</h3>
            <p className="text-color-secondary text-sm m-0">
              Apakah Anda yakin ingin mendaftarkan kunjungan pasien <strong>{pasienData.nama}</strong> ({pasienData.no_rm}) tanpa mengambil layanan medis/paket?
            </p>
          </div>
        ) as any,
        header: 'Konfirmasi Pendaftaran Kunjungan',
        icon: 'pi pi-exclamation-triangle',
        acceptLabel: 'Ya, Selesaikan',
        rejectLabel: 'Batal',
        acceptClassName: 'p-button-secondary font-bold',
        rejectClassName: 'p-button-outlined p-button-secondary',
        accept: () => handleProcessSubmit(itemsToSubmit),
      });
      return;
    }

    const combinedNama = itemsToSubmit.map((i) => i.nama).join(', ');

    confirmDialog({
      message: (
        <div className="flex flex-column text-left gap-3 py-1">
          <div className="flex align-items-center gap-3 bg-blue-50 p-3 border-round-xl border-1 border-blue-100">
            <i className="pi pi-user text-blue-600 text-3xl" />
            <div>
              <span className="text-xs text-500 block">Pasien</span>
              <span className="font-bold text-blue-900 text-base">{pasienData.nama}</span>
              <span className="text-xs text-blue-700 block">No. RM: {pasienData.no_rm}</span>
            </div>
          </div>

          <div>
            <span className="text-xs font-semibold text-color-secondary block mb-1">
              LAYANAN / PAKET TERPILIH ({itemsToSubmit.length}):
            </span>
            <div className="surface-100 p-3 border-round-lg border-1 surface-border">
              <div className="font-bold text-900 text-sm mb-1">{combinedNama}</div>
              <div className="text-xs text-500 flex justify-content-between align-items-center pt-2 border-top-1 surface-border mt-2">
                <span>Estimasi Biaya:</span>
                <div className="flex flex-column align-items-end gap-1">
                  <span className="font-extrabold text-blue-600 text-base">{formatRupiah(totalHarga)}</span>
                  {hasPromo && (
                    <span className="text-xs text-rose-500 font-semibold">* Diskon promo diterapkan di kasir</span>
                  )}
                </div>
              </div>
            </div>
          </div>

          <p className="text-sm text-700 m-0">
            Apakah Anda yakin ingin menerbitkan nomor antrean tindakan untuk pasien ini?
          </p>
        </div>
      ) as any,
      header: 'Konfirmasi Ambil Nomor Antrean',
      icon: 'pi pi-ticket',
      acceptLabel: 'Ya, Terbitkan Antrean',
      rejectLabel: 'Batal',
      acceptClassName: 'p-button-primary font-bold',
      rejectClassName: 'p-button-outlined p-button-secondary',
      accept: () => handleProcessSubmit(itemsToSubmit),
    });
  };

  /**
   * Render card item layanan / paket.
   */
  const renderItemCard = (item: ServiceItem) => {
    const key = `${item.jenis}_${item.kode_layanan}`;
    const isSelected = !!selectedMap[key];
    const isPaket = item.jenis === 'paket';
    const itemRoomCode = item.kode_ruangan || 'LAINNYA';
    const isDisabled = activeRuangan !== null && !isSelected && activeRuangan !== itemRoomCode;

    const colorScheme = isPaket ? 'amber' : 'blue';
    const selectedBorder = isPaket ? 'border-amber-500 bg-amber-50 shadow-2' : 'border-blue-500 bg-blue-50 shadow-2';
    const disabledStyle = isDisabled ? 'opacity-40 cursor-not-allowed' : 'cursor-pointer hover:border-300';

    return (
      <div key={`${item.jenis}_${item.kode_layanan}`} className="col-12 md:col-6 lg:col-4">
        <div
          className={`surface-card p-3 border-round-xl border-1 shadow-1 transition-all transition-duration-200 select-none ${
            isSelected ? selectedBorder : `surface-border ${disabledStyle}`
          }`}
          style={{ userSelect: 'none', WebkitUserSelect: 'none' }}
          onClick={() => {
            if (!isDisabled) handleToggleItem(item);
          }}
          title={isDisabled ? `Tidak bisa dipilih — ruangan aktif: ${Object.values(selectedMap)[0]?.nama_ruangan || activeRuangan}` : ''}
        >
          <div className="flex align-items-start gap-3">
            <Checkbox
              checked={isSelected}
              disabled={isDisabled}
              onChange={() => {
                if (!isDisabled) handleToggleItem(item);
              }}
              className="mt-1"
            />
            <div className="w-full">
              <div className="flex align-items-center justify-content-between gap-1 mb-1">
                <div className="flex align-items-center gap-1 flex-wrap">
                  {item.is_promo && (
                    <Tag value={`🔥 PROMO ${item.jenis_diskon === 'persen' ? `-${item.nilai_diskon}%` : ''}`} severity="danger" className="text-xs font-bold" />
                  )}
                  {isPaket ? (
                    <Tag value="PAKET LAYANAN" severity="warning" className="text-xs font-bold" />
                  ) : (
                    <Tag value={item.nama_kategori || item.kode_layanan} severity="info" className="text-xs font-bold" />
                  )}
                </div>
                {!isPaket ? (
                  <span className="text-xs text-500 flex align-items-center gap-1">
                    <i className="pi pi-clock" /> {item.durasi_menit} mnt
                  </span>
                ) : (
                  item.masa_berlaku_hari ? (
                    <span className="text-xs text-500">Masa berlaku {item.masa_berlaku_hari} hr</span>
                  ) : (
                    <span className="text-xs text-500 flex align-items-center gap-1">
                      <i className="pi pi-clock" /> {item.durasi_menit} mnt
                    </span>
                  )
                )}
              </div>
              
              <h4 className="font-bold text-900 text-base m-0 mb-1">{item.nama}</h4>

              {/* NAMA RUANGAN EXPLICITLY SHOWN WITH ICON & TEXT */}
              <div className="flex align-items-center gap-1 text-xs text-teal-700 font-semibold mb-2">
                <i className="pi pi-building text-teal-500" />
                <span>{item.nama_ruangan ? `${item.kode_ruangan ? item.kode_ruangan + ' - ' : ''}${item.nama_ruangan}` : 'Ruang Treatment'}</span>
                {item.nama_promo && <span className="text-rose-500 font-bold ml-1">• {item.nama_promo}</span>}
              </div>

              <div>
                <span className={`text-base font-extrabold ${isPaket ? 'text-amber-700' : 'text-blue-600'}`}>
                  {formatRupiah(item.harga_asal ?? item.harga)}
                </span>
              </div>

              {isDisabled && (
                <div className="text-xs text-red-400 mt-1 flex align-items-center gap-1">
                  <i className="pi pi-lock" />
                  <span>Ganti ruangan untuk memilih ini</span>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    );
  };

  return (
    <div className="grid">
      <ConfirmDialog />
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
                <h3 className="text-xl font-bold text-900 m-0">Langkah 2: Pilih Layanan &amp; Paket Treatment</h3>
              </div>
              <p className="text-500 text-sm m-0 ml-6">
                Pilih satu atau beberapa layanan/paket <strong>dalam ruangan yang sama</strong> untuk menerbitkan nomor antrean.
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

          {/* INFO RUANGAN AKTIF */}
          {activeRuangan && selectedList.length > 0 && (
            <div className="flex align-items-center justify-content-between flex-wrap gap-2 p-3 bg-blue-50 border-round-lg border-1 border-blue-200">
              <div className="flex align-items-center gap-2">
                <i className="pi pi-check-circle text-blue-600 text-lg" />
                <div>
                  <span className="text-xs text-500 block">Ruangan Aktif</span>
                  <span className="font-bold text-blue-800 text-sm">
                    {selectedList[0]?.nama_ruangan || activeRuangan}
                  </span>
                  <span className="text-xs text-blue-600 ml-2">
                    ({selectedList.length} layanan/paket dipilih)
                  </span>
                </div>
              </div>
              <Button
                label="Batalkan Semua Pilihan"
                icon="pi pi-times"
                size="small"
                severity="danger"
                outlined
                className="border-round-lg text-xs"
                onClick={handleClearSelection}
              />
            </div>
          )}
        </div>
      </div>

      {/* OPTIONS CONTAINER */}
      <div className="col-12 mb-8">
        {loading ? (
          <div className="flex flex-column align-items-center justify-content-center p-5 surface-card border-round-xl">
            <ProgressSpinner style={{ width: '50px', height: '50px' }} />
            <span className="mt-3 text-500 font-medium">Memuat pilihan layanan &amp; paket per ruangan...</span>
          </div>
        ) : (
          <TabView className="p-tabview-custom">
            {/* TABS RUANGAN LAYANAN & PAKET */}
            {ruangans.map((ruang) => {
              const isRuangActive = activeRuangan === ruang.kode_ruangan;
              const isRuangDisabled = activeRuangan !== null && activeRuangan !== ruang.kode_ruangan;
              const ruangSelectedCount = ruang.items.filter(
                (item) => !!selectedMap[`${item.jenis}_${item.kode_layanan}`]
              ).length;
              const roomTitle = ruang.nama_ruangan
                ? `${ruang.nama_ruangan} (${ruang.kode_ruangan})`
                : `Ruangan ${ruang.kode_ruangan}`;
              const countSuffix = ruangSelectedCount > 0 ? ` (${ruangSelectedCount})` : '';
              const tabHeaderString = `${roomTitle}${countSuffix}`;

              return (
                <TabPanel
                  key={ruang.kode_ruangan}
                  header={tabHeaderString}
                  leftIcon={`pi ${isRuangActive ? 'pi-check-circle' : 'pi-building'} mr-2`}
                >
                  {isRuangDisabled && (
                    <div className="flex align-items-center gap-2 p-3 mb-3 bg-orange-50 border-round-lg border-1 border-orange-200">
                      <i className="pi pi-info-circle text-orange-500" />
                      <span className="text-sm text-orange-700">
                        Ruangan ini tidak bisa dipilih karena Anda sudah memilih layanan/paket dari ruangan <strong>{selectedList[0]?.nama_ruangan || activeRuangan}</strong>.
                        Batalkan semua pilihan terlebih dahulu untuk berpindah ruangan.
                      </span>
                    </div>
                  )}
                  {ruang.items.length === 0 ? (
                    <div className="flex flex-column align-items-center justify-content-center p-5 surface-card border-round-xl border-1 surface-border my-3 text-center">
                      <i className="pi pi-inbox text-400 text-4xl mb-2" />
                      <span className="text-700 font-bold block text-base">{roomTitle}</span>
                      <span className="text-500 text-sm mt-1">Belum ada layanan atau paket yang tersedia di ruangan ini.</span>
                    </div>
                  ) : (
                    <div className="grid">
                      {ruang.items.map((item) => renderItemCard(item))}
                    </div>
                  )}
                </TabPanel>
              );
            })}
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
            <span className="text-xs text-500 block">Dipilih:</span>
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
          {selectedList.length > 0 && (
            <div className="hidden md:block border-left-1 surface-border pl-4">
              <span className="text-xs text-500 block">Ruangan Aktif:</span>
              <span className="font-bold text-green-700 text-sm flex align-items-center gap-1">
                <i className="pi pi-check-circle text-green-500" />
                {selectedList[0]?.nama_ruangan || activeRuangan}
              </span>
            </div>
          )}
        </div>

        <div className="flex align-items-center gap-2 pr-3">
          <Button
            label="Selesai Tanpa Layanan"
            icon="pi pi-times"
            className="p-button-outlined p-button-secondary border-round-lg text-sm"
            onClick={() => confirmTakeQueue([])}
            disabled={submitting}
          />
          <Button
            label={`Ambil Nomor Antrean (${selectedList.length})`}
            icon="pi pi-ticket"
            className="p-button-primary border-round-lg font-bold p-button-lg"
            onClick={() => confirmTakeQueue()}
            loading={submitting}
            disabled={selectedList.length === 0}
          />
        </div>
      </div>
    </div>
  );
};
