'use client';

import React, { useState, useEffect } from 'react';
import { Dialog } from 'primereact/dialog';
import { Button } from 'primereact/button';
import { InputText } from 'primereact/inputtext';
import { InputTextarea } from 'primereact/inputtextarea';
import { InputNumber } from 'primereact/inputnumber';
import { Dropdown } from 'primereact/dropdown';
import { Checkbox } from 'primereact/checkbox';
import { Toast } from 'primereact/toast';
import { ProgressSpinner } from 'primereact/progressspinner';
import { Tag } from 'primereact/tag';
import postData from '@/lib/axios/postData';
import { showError, showSuccess } from '@/lib/tools/generalTools';
import { AntrianLayananData, RuanganFormField } from './interfaces';
import { FormRuanganFotoUploader } from './FormRuanganFotoUploader';
import { RekomendasiTreatmentPanel, RekomendasiItem } from './RekomendasiTreatmentPanel';
import { DialogHasilTerbitAntrian } from './DialogHasilTerbitAntrian';

interface DialogIsiFormPenangananProps {
    visible: boolean;
    onHide: () => void;
    antrianData: AntrianLayananData | null;
    isKonsultasi?: boolean;
    toast: React.RefObject<Toast>;
    getGridData: () => void;
}

export const DialogIsiFormPenanganan: React.FC<DialogIsiFormPenangananProps> = ({
    visible,
    onHide,
    antrianData,
    isKonsultasi = false,
    toast,
    getGridData,
}) => {
    const [fields, setFields] = useState<RuanganFormField[]>([]);
    const [loadingFields, setLoadingFields] = useState<boolean>(false);
    const [formData, setFormData] = useState<Record<string, any>>({});
    const [catatanPetugas, setCatatanPetugas] = useState<string>('');
    const [rekomendasiItems, setRekomendasiItems] = useState<RekomendasiItem[]>([]);
    const [saving, setSaving] = useState<boolean>(false);

    useEffect(() => {
        if (visible && antrianData?.kode_ruangan) {
            loadFormFields();
        }
        if (visible && antrianData) {
            // Form data dipindahkan ke trx_rekam_medis; form dimulai kosong setiap sesi baru
            setCatatanPetugas('');
            setFormData({});
            setRekomendasiItems([]);
        }
    }, [visible, antrianData]);

    const loadFormFields = async () => {
        if (!antrianData?.kode_ruangan) return;
        setLoadingFields(true);
        try {
            const res = await postData('/master/ruangan-form-data', { kode_ruangan: antrianData.kode_ruangan });
            setFields(res.data.data || []);
        } catch (error) {
            showError(toast, 'Gagal memuat format form ruangan');
        } finally {
            setLoadingFields(false);
        }
    };

    const handleFieldChange = (key: string, value: any) => {
        setFormData((prev) => ({ ...prev, [key]: value }));
    };

    // Modal Sukses Terbit Antrean & Transaksi
    const [showHasilModal, setShowHasilModal] = useState<boolean>(false);
    const [hasilAntrianList, setHasilAntrianList] = useState<any[]>([]);
    const [hasilTransaksiDraft, setHasilTransaksiDraft] = useState<any | null>(null);
    const [hasilKodeKunjungan, setHasilKodeKunjungan] = useState<string>('');

    const executeSave = async (targetStatus?: string) => {
        if (!antrianData) return;
        setSaving(true);
        try {
            const payload: any = {
                kode_antrian_layanan: antrianData.kode_antrian_layanan,
                hasil_form: formData,
                catatan_petugas: catatanPetugas,
                rekomendasi_items: rekomendasiItems,
            };
            if (targetStatus) {
                payload.status_tindakan = targetStatus;
            }

            const res = await postData('/master/antrian-layanan-simpan-rekomendasi', payload);
            showSuccess(toast, res.data.message || 'Catatan & rekomendasi penanganan berhasil disimpan');
            getGridData();
            onHide();

            const antrianBaru = res.data?.data?.antrian_layanan_baru || [];
            const trxDraft = res.data?.data?.transaksi_draft || null;
            const kodeKunjungan = res.data?.data?.kode_kunjungan || '';

            if (antrianBaru.length > 0 || trxDraft) {
                setHasilAntrianList(antrianBaru);
                setHasilTransaksiDraft(trxDraft);
                setHasilKodeKunjungan(kodeKunjungan);
                setShowHasilModal(true);
            }
        } catch (error: any) {
            showError(toast, error?.response?.data?.message || 'Gagal menyimpan catatan & rekomendasi penanganan');
        } finally {
            setSaving(false);
        }
    };

    // State Konfirmasi Simpan
    const [showConfirmModal, setShowConfirmModal] = useState<boolean>(false);
    const [targetStatusToSave, setTargetStatusToSave] = useState<string | undefined>(undefined);

    const handleSave = (targetStatus?: string) => {
        if (!antrianData) return;

        // Check required fields
        for (const f of fields) {
            if (f.is_required) {
                const val = formData[f.label_field];
                if (f.tipe_field === 'upload_foto') {
                    const hasBefore = val && typeof val === 'object' && val.before;
                    const hasAfter = val && typeof val === 'object' && val.after;
                    if (!hasBefore && !hasAfter) {
                        showError(toast, `Field '${f.label_field}' wajib mengunggah foto!`);
                        return;
                    }
                } else if (!val) {
                    showError(toast, `Field '${f.label_field}' wajib diisi!`);
                    return;
                }
            }
        }

        setTargetStatusToSave(targetStatus);
        setShowConfirmModal(true);
    };

    const handleConfirmAccept = () => {
        setShowConfirmModal(false);
        executeSave(targetStatusToSave);
    };

    if (!antrianData) return null;

    return (
        <>
            <Dialog
                header={
                    <div className="flex align-items-center gap-3">
                        <span className="text-2xl font-black text-teal-800 bg-teal-100 px-3 py-1 border-round-lg">
                            #{antrianData.nomor_antrian}
                        </span>
                        <div>
                            <span className="text-xl font-bold block">{antrianData.nama_pasien || 'Pasien'}</span>
                            <span className="text-xs text-500 font-normal">
                                RM: {antrianData.no_rm} | Ruangan: {antrianData.nama_ruangan || antrianData.kode_ruangan} | Layanan: {antrianData.nama_layanan}
                            </span>
                        </div>
                    </div>
                }
                visible={visible && !showHasilModal}
                style={{ width: '680px' }}
                modal
                onHide={onHide}
                className="p-fluid"
            >
                <div className="p-3 bg-teal-50 border-round-xl mb-4 border-1 border-teal-200 flex align-items-center justify-content-between">
                    <div>
                        <span className="text-xs text-teal-700 block font-semibold">Status Penanganan Pasien</span>
                        <Tag
                            value={(antrianData.status || 'menunggu').toUpperCase()}
                            severity={antrianData.status === 'dipanggil' ? 'warning' : 'info'}
                            className="text-xs font-bold mt-1"
                        />
                    </div>
                    <div className="text-right">
                        <span className="text-xs text-500 block">Jam Datang</span>
                        <span className="text-sm font-bold text-700">{antrianData.jam_datang || '-'}</span>
                    </div>
                </div>

                <div className="flex flex-column gap-4">
                    {loadingFields ? (
                        <div className="flex align-items-center justify-content-center py-4">
                            <ProgressSpinner style={{ width: '30px', height: '30px' }} />
                            <span className="ml-2 text-xs text-500">Memuat isian form...</span>
                        </div>
                    ) : fields.length > 0 && (
                        <div className="surface-card p-3 border-round-xl border-1 surface-border">
                            <label className="block text-xs font-bold text-700 uppercase tracking-wider mb-3 pb-2 border-bottom-1 surface-border flex align-items-center justify-content-between">
                                <span>ISIAN KHUSUS RUANGAN ({antrianData.nama_ruangan || antrianData.kode_ruangan})</span>
                                <Tag value={`${fields.length} Field`} severity="info" className="text-[10px]" />
                            </label>

                            <div className="grid formgrid p-fluid">
                                {fields.map((f) => {
                                    const val = formData[f.label_field];
                                    const isFoto = f.tipe_field === 'upload_foto';
                                    const colSize = isFoto ? 'col-12' : 'col-12 md:col-6';
                                    const optionsList = f.opsi_select ? f.opsi_select.split(',').map((o) => o.trim()) : [];

                                    return (
                                        <div key={f.id} className={`${colSize} mb-3`}>
                                            <label className="block text-xs font-semibold text-700 mb-1">
                                                {f.label_field}
                                                {f.is_required && <span className="text-red-500 ml-1">*</span>}
                                                <span className="text-[10px] text-400 font-normal uppercase ml-1">
                                                    ({f.tipe_field})
                                                </span>
                                            </label>

                                            {isFoto ? (
                                                <FormRuanganFotoUploader
                                                    value={val}
                                                    onChange={(newVal) => handleFieldChange(f.label_field, newVal)}
                                                />
                                            ) : (
                                                <>
                                                    {f.tipe_field === 'textarea' ? (
                                                        <InputTextarea
                                                            value={val}
                                                            onChange={(e) => handleFieldChange(f.label_field, e.target.value)}
                                                            rows={3}
                                                            placeholder={`Masukkan ${f.label_field}...`}
                                                            className="w-full text-sm shadow-1 border-round-md"
                                                        />
                                                    ) : f.tipe_field === 'number' ? (
                                                        <InputNumber
                                                            value={typeof val === 'number' ? val : null}
                                                            onValueChange={(e) => handleFieldChange(f.label_field, e.value)}
                                                            placeholder={`Masukkan ${f.label_field}`}
                                                            className="w-full text-sm shadow-1 border-round-md"
                                                        />
                                                    ) : f.tipe_field === 'select' ? (
                                                        <Dropdown
                                                            value={val}
                                                            options={optionsList.map((o) => ({ label: o, value: o }))}
                                                            onChange={(e) => handleFieldChange(f.label_field, e.value)}
                                                            placeholder={`Pilih ${f.label_field}...`}
                                                            className="w-full text-sm shadow-1 border-round-md"
                                                        />
                                                    ) : f.tipe_field === 'checkbox' ? (
                                                        <div className="flex align-items-center gap-2 p-2 surface-card border-1 surface-border border-round-md">
                                                            <Checkbox
                                                                checked={Boolean(val)}
                                                                onChange={(e) => handleFieldChange(f.label_field, e.checked)}
                                                            />
                                                            <span className="text-xs text-700 font-semibold">{f.label_field}</span>
                                                        </div>
                                                    ) : (
                                                        <InputText
                                                            value={val}
                                                            onChange={(e) => handleFieldChange(f.label_field, e.target.value)}
                                                            placeholder={`Masukkan ${f.label_field}...`}
                                                            className="w-full text-sm shadow-1 border-round-md"
                                                        />
                                                    )}
                                                </>
                                            )}
                                        </div>
                                    );
                                })}
                            </div>
                        </div>
                    )}

                    {isKonsultasi && (
                        <RekomendasiTreatmentPanel
                            toast={toast}
                            selectedItems={rekomendasiItems}
                            onChangeSelectedItems={setRekomendasiItems}
                        />
                    )}

                    <div className="surface-card p-3 border-round-xl border-1 surface-border">
                        <label className="block text-xs font-bold mb-2 text-800 flex align-items-center gap-2">
                            <i className="pi pi-pencil text-teal-600" />
                            Catatan Petugas / Observasi Ruangan
                        </label>
                        <InputTextarea
                            value={catatanPetugas}
                            onChange={(e) => setCatatanPetugas(e.target.value)}
                            rows={4}
                            placeholder="Tuliskan catatan hasil tindakan, obat/alat yang digunakan, atau observasi pasien..."
                            className="w-full text-sm shadow-1 border-round-md"
                        />
                    </div>
                </div>

                <div className="flex align-items-center justify-content-between gap-2 mt-4 pt-3 border-top-1 surface-border">
                    <Button label="Tutup" outlined severity="secondary" onClick={onHide} size="small" />

                    <div className="flex gap-2">
                        <Button
                            label="Simpan Form"
                            icon="pi pi-save"
                            outlined
                            severity="info"
                            loading={saving}
                            onClick={() => handleSave()}
                            size="small"
                        />

                        {antrianData.status === 'dipanggil' && (
                            <Button
                                label="Simpan & Selesaikan Tindakan"
                                icon="pi pi-check-circle"
                                severity="success"
                                loading={saving}
                                onClick={() => handleSave('selesai')}
                                size="small"
                            />
                        )}
                    </div>
                </div>
            </Dialog>

            <Dialog
                visible={showConfirmModal && !showHasilModal}
                onHide={() => setShowConfirmModal(false)}
                header="Konfirmasi Penanganan & Rekomendasi"
                style={{ width: '480px' }}
                modal
                className="p-fluid"
                footer={
                    <div className="flex justify-content-end gap-2">
                        <Button
                            label="Batal"
                            icon="pi pi-times"
                            className="p-button-outlined p-button-secondary text-xs"
                            onClick={() => setShowConfirmModal(false)}
                        />
                        <Button
                            label="Ya, Simpan & Terbitkan"
                            icon="pi pi-check"
                            className="p-button-success font-bold text-xs"
                            onClick={handleConfirmAccept}
                        />
                    </div>
                }
            >
                <div className="flex flex-column gap-3 py-1 text-left">
                    <div className="p-3 border-round-xl" style={{ background: '#f0fdfa', border: '1.5px solid #99f6e4' }}>
                        <span className="text-[10px] font-bold uppercase block" style={{ color: '#0d9488' }}>Pasien Aktif</span>
                        <span className="font-extrabold text-sm block" style={{ color: '#134e4a' }}>{antrianData?.nama_pasien || 'Pasien'}</span>
                        <span className="text-xs" style={{ color: '#0f766e' }}>No. RM: {antrianData?.no_rm} | Ruangan: {antrianData?.nama_ruangan || antrianData?.kode_ruangan}</span>
                    </div>

                    <div className="flex flex-column gap-2">
                        {rekomendasiItems.filter((i) => ['layanan', 'paket_layanan'].includes(i.jenis)).length > 0 && (
                            <div className="p-3 border-round-xl text-xs" style={{ background: '#f0fdfa', border: '1.5px solid #5eead4' }}>
                                <span className="font-bold block mb-1" style={{ color: '#0f766e' }}>
                                    <i className="pi pi-ticket mr-1" />
                                    Menerbitkan {rekomendasiItems.filter((i) => ['layanan', 'paket_layanan'].includes(i.jenis)).length} Nomor Antrean Layanan:
                                </span>
                                <span className="font-semibold" style={{ color: '#115e59' }}>{rekomendasiItems.filter((i) => ['layanan', 'paket_layanan'].includes(i.jenis)).map((l) => l.nama).join(', ')}</span>
                            </div>
                        )}

                        {rekomendasiItems.filter((i) => ['produk', 'paket_produk'].includes(i.jenis)).length > 0 && (
                            <div className="p-3 border-round-xl text-xs" style={{ background: '#fffbeb', border: '1.5px solid #fcd34d' }}>
                                <span className="font-bold block mb-1" style={{ color: '#b45309' }}>
                                    <i className="pi pi-shopping-bag mr-1" />
                                    Memasukkan {rekomendasiItems.filter((i) => ['produk', 'paket_produk'].includes(i.jenis)).length} Produk ke Draf Transaksi Kasir:
                                </span>
                                <span className="font-semibold" style={{ color: '#78350f' }}>{rekomendasiItems.filter((i) => ['produk', 'paket_produk'].includes(i.jenis)).map((p) => `${p.nama} (${p.qty || 1}x)`).join(', ')}</span>
                            </div>
                        )}
                    </div>

                    <p className="text-xs text-gray-700 m-0">
                        Apakah Anda yakin ingin menyimpan hasil penanganan &amp; menerbitkan nomor antrean/transaksi untuk pasien ini?
                    </p>
                </div>
            </Dialog>

            <DialogHasilTerbitAntrian
                visible={showHasilModal}
                onHide={() => {
                    setShowHasilModal(false);
                    onHide();
                }}
                pasienNama={antrianData.nama_pasien}
                noRm={antrianData.no_rm}
                kodeKunjungan={hasilKodeKunjungan}
                antrianList={hasilAntrianList}
                transaksiDraft={hasilTransaksiDraft}
            />
        </>
    );
};
