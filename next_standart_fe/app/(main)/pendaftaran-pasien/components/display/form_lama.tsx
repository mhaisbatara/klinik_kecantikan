'use client';

import { useState } from 'react';
import { Button } from 'primereact/button';
import { Dropdown } from 'primereact/dropdown';
import { AutoComplete, AutoCompleteCompleteEvent } from 'primereact/autocomplete';
import { SelectButton } from 'primereact/selectbutton';
import { Panel } from 'primereact/panel';
import { confirmDialog, ConfirmDialog } from 'primereact/confirmdialog';
import { FormLamaProps, PasienOption } from '../../interfaces';
import postData from '@/lib/axios/postData';
import { showError, showSuccess } from '@/lib/tools/generalTools';
import { apiEndpointCreate, apiEndpointPasienSearch } from '../../endpoints';
import { getTzUser } from '@/lib/tools/dateTools';

const FormLama = ({ state, setState, toast }: FormLamaProps) => {
    const [jenisLayananCategory, setJenisLayananCategory] = useState<'layanan' | 'paket'>('layanan');
    const [selectedPasien, setSelectedPasien] = useState<PasienOption | null>(null);
    const [filteredPasiens, setFilteredPasiens] = useState<PasienOption[]>([]);
    const [kodeLayanan, setKodeLayanan] = useState('');

    const searchPasien = async (event: AutoCompleteCompleteEvent) => {
        try {
            const res = await postData(apiEndpointPasienSearch, { query: event.query });
            setFilteredPasiens(res.data?.data || []);
        } catch (error) {
            setFilteredPasiens([]);
        }
    };

    const executeSave = async () => {
        setState((p) => ({ ...p, load: true }));
        try {
            const body = {
                is_pasien_baru: false,
                no_rm: selectedPasien!.no_rm,
                jenis_layanan: jenisLayananCategory,
                kode_layanan: kodeLayanan,
                tz: getTzUser(),
            };

            const res = await postData(apiEndpointCreate, body, { 'X-Level': '1' });
            showSuccess(toast, res.data?.message || 'Pendaftaran Pasien Lama berhasil disimpan');
            setSelectedPasien(null);
            setKodeLayanan('');
        } catch (error: any) {
            const errObj = error?.response?.data || error;
            showError(toast, errObj?.message || 'Gagal menyimpan pendaftaran');
        } finally {
            setState((p) => ({ ...p, load: false }));
        }
    };

    const handleSave = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!selectedPasien || !selectedPasien.no_rm) {
            showError(toast, 'Harap cari & pilih pasien terdaftar terlebih dahulu.');
            return;
        }
        if (!kodeLayanan) {
            showError(toast, 'Harap pilih Layanan atau Paket Layanan.');
            return;
        }

        confirmDialog({
            message: `Apakah Anda yakin ingin mendaftarkan pasien ${selectedPasien.nama} (${selectedPasien.no_rm}) dengan layanan/paket terpilih?`,
            header: 'Konfirmasi Pendaftaran Pasien',
            icon: 'pi pi-question-circle',
            acceptLabel: 'Ya, Daftarkan',
            rejectLabel: 'Batal',
            acceptClassName: 'p-button-info font-bold',
            accept: executeSave,
        });
    };

    const layananOptions = state.layananOptions.map((l) => {
        const kat = l.nama_kategori ? `[${l.nama_kategori}] ` : '';
        const durasi = l.durasi_menit ? ` (${l.durasi_menit} menit)` : '';
        return {
            label: `${kat}${l.nama} - Rp ${parseFloat(l.harga || '0').toLocaleString('id-ID')}${durasi}`,
            value: l.kode_layanan,
        };
    });

    const paketOptions = state.paketOptions.map((p) => {
        const kat = p.nama_kategori ? `[${p.nama_kategori}] ` : '';
        const masa = p.masa_berlaku_hari ? ` (${p.masa_berlaku_hari} Hari)` : '';
        const detailStr = p.detail_paket && p.detail_paket.length > 0
            ? ` - Detail: ${p.detail_paket.map((d) => `${d.jumlah_sesi}x ${d.nama_layanan}`).join(', ')}`
            : '';
        return {
            label: `${kat}${p.nama} - Rp ${parseFloat(p.harga || '0').toLocaleString('id-ID')}${masa}${detailStr}`,
            value: p.kode_layanan,
        };
    });

    const selectedPaketDetail = jenisLayananCategory === 'paket'
        ? state.paketOptions.find((p) => p.kode_layanan === kodeLayanan)
        : null;

    const pasienTemplate = (item: PasienOption) => {
        return (
            <div className="flex flex-column gap-1 py-1">
                <div className="font-bold text-sm">
                    {item.nama} <span className="text-color-secondary font-normal">({item.no_rm})</span>
                </div>
                <div className="text-xs text-color-secondary">
                    No HP: {item.no_hp || '-'} | NIK: {item.nik || '-'}
                </div>
            </div>
        );
    };

    return (
        <form onSubmit={handleSave} className="flex flex-column gap-4">
            <ConfirmDialog />
            <div className="mb-2">
                <h3 className="text-lg font-bold m-0 text-900">Form Pendaftaran Pasien Lama</h3>
                <p className="text-color-secondary text-sm m-0">
                    Cari pasien terdaftar yang pernah berkunjung, lalu daftarkan kunjungan & layanan medis/paket hari ini.
                </p>
            </div>

            {/* 1. Pencarian Pasien Terdaftar */}
            <Panel header="1. Pencarian Pasien Terdaftar" toggleable>
                <div className="flex flex-column gap-3 p-fluid">
                    <div className="field">
                        <label className="font-semibold text-sm">
                            Ketik Nama, No. RM, NIK, atau No. HP Pasien <span className="text-red-500">*</span>
                        </label>
                        <AutoComplete
                            value={selectedPasien}
                            suggestions={filteredPasiens}
                            completeMethod={searchPasien}
                            field="nama"
                            itemTemplate={pasienTemplate}
                            selectedItemTemplate={(item) => (item ? `${item.nama} - (${item.no_rm})` : '')}
                            onChange={(e) => setSelectedPasien(e.value)}
                            placeholder="Mulai mengetik untuk mencari data pasien..."
                            className="p-inputtext-sm"
                            dropdown
                        />
                    </div>

                    {selectedPasien && selectedPasien.no_rm && (
                        <div className="p-3 surface-100 border-round grid text-sm border-1 surface-border">
                            <div className="col-12 md:col-4"><strong>No. Rekam Medis:</strong> {selectedPasien.no_rm}</div>
                            <div className="col-12 md:col-4"><strong>Nama Pasien:</strong> {selectedPasien.nama}</div>
                            <div className="col-12 md:col-4"><strong>No. Handphone:</strong> {selectedPasien.no_hp || '-'}</div>
                            <div className="col-12 md:col-4"><strong>NIK:</strong> {selectedPasien.nik || '-'}</div>
                            <div className="col-12 md:col-4"><strong>Jenis Kelamin:</strong> {selectedPasien.jenis_kelamin === 'P' ? 'Perempuan' : 'Laki-laki'}</div>
                            <div className="col-12 md:col-4"><strong>Tanggal Lahir:</strong> {selectedPasien.tanggal_lahir || '-'}</div>
                        </div>
                    )}
                </div>
            </Panel>

            {/* 2. Pilihan Layanan Medis / Paket Layanan */}
            <Panel header="2. Pilihan Layanan Medis / Paket Kecantikan" toggleable>
                <div className="flex flex-column gap-3 p-fluid">
                    <div>
                        <label className="font-semibold text-sm mb-2 block">
                            Kategori Pilihan Layanan <span className="text-red-500">*</span>
                        </label>
                        <SelectButton
                            value={jenisLayananCategory}
                            options={[
                                { label: 'Layanan Biasa (mst_layanan)', value: 'layanan' },
                                { label: 'Paket Layanan (mst_paket_layanan)', value: 'paket' },
                            ]}
                            onChange={(e) => {
                                if (e.value) {
                                    setJenisLayananCategory(e.value);
                                    setKodeLayanan('');
                                }
                            }}
                        />
                    </div>

                    {jenisLayananCategory === 'layanan' ? (
                        <div className="field">
                            <label className="font-semibold text-sm">
                                Pilih Layanan Medis / Treatment <span className="text-red-500">*</span>
                            </label>
                            <Dropdown
                                value={kodeLayanan}
                                options={layananOptions}
                                onChange={(e) => setKodeLayanan(e.value)}
                                placeholder="Pilih Layanan Biasa"
                                className="p-inputtext-sm"
                                filter
                                filterBy="label"
                            />
                        </div>
                    ) : (
                        <div className="field">
                            <label className="font-semibold text-sm">
                                Pilih Paket Layanan Kecantikan <span className="text-red-500">*</span>
                            </label>
                            <Dropdown
                                value={kodeLayanan}
                                options={paketOptions}
                                onChange={(e) => setKodeLayanan(e.value)}
                                placeholder="Pilih Paket Layanan"
                                className="p-inputtext-sm"
                                filter
                                filterBy="label"
                            />
                        </div>
                    )}

                    {selectedPaketDetail && selectedPaketDetail.detail_paket && selectedPaketDetail.detail_paket.length > 0 && (
                        <div className="p-3 surface-100 border-round border-1 surface-border">
                            <div className="font-bold text-sm text-900 mb-2">Rincian Sesi Paket ({selectedPaketDetail.nama}):</div>
                            <ul className="m-0 pl-3 text-sm text-700">
                                {selectedPaketDetail.detail_paket.map((det, idx) => (
                                    <li key={idx} className="mb-1">
                                        <strong>{det.jumlah_sesi}x</strong> {det.nama_layanan} <span className="text-color-secondary">[{det.nama_kategori || 'Kategori'}]</span>
                                    </li>
                                ))}
                            </ul>
                        </div>
                    )}
                </div>
            </Panel>

            {/* Action Buttons */}
            <div className="flex justify-content-end gap-2 mt-3">
                <Button
                    type="submit"
                    severity="info"
                    label="Simpan & Daftarkan Pasien Lama"
                    icon="pi pi-check"
                    loading={state.load}
                />
            </div>
        </form>
    );
};

export default FormLama;
