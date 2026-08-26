'use client';

import React, { useState, useEffect } from 'react';
import { Button } from 'primereact/button';
import { InputText } from 'primereact/inputtext';
import { InputTextarea } from 'primereact/inputtextarea';
import { InputNumber } from 'primereact/inputnumber';
import { Dropdown } from 'primereact/dropdown';
import { Checkbox } from 'primereact/checkbox';
import { Tag } from 'primereact/tag';
import { Toast } from 'primereact/toast';
import { ProgressSpinner } from 'primereact/progressspinner';
import postData from '@/lib/axios/postData';
import { showError, showSuccess } from '@/lib/tools/generalTools';
import { AntrianLayananData, RuanganFormField } from './interfaces';

interface ActiveTreatmentPanelProps {
    activePatient: AntrianLayananData | null;
    nextWaitingPatient: AntrianLayananData | null;
    kodeRuangan: string;
    namaRuangan: string;
    toast: React.RefObject<Toast>;
    getGridData: () => void;
    handleAksi: (item: AntrianLayananData, customAksi?: string) => void;
    playChime: () => void;
    speakNomorLayanan: (noAntrian: string, namaPasien?: string, namaRuangan?: string) => void;
    onManageFormClick: () => void;
}

export const ActiveTreatmentPanel: React.FC<ActiveTreatmentPanelProps> = ({
    activePatient,
    nextWaitingPatient,
    kodeRuangan,
    namaRuangan,
    toast,
    getGridData,
    handleAksi,
    playChime,
    speakNomorLayanan,
    onManageFormClick,
}) => {
    const [fields, setFields] = useState<RuanganFormField[]>([]);
    const [loadingFields, setLoadingFields] = useState<boolean>(false);
    const [formData, setFormData] = useState<Record<string, any>>({});
    const [catatanPetugas, setCatatanPetugas] = useState<string>('');
    const [saving, setSaving] = useState<boolean>(false);

    useEffect(() => {
        if (kodeRuangan) {
            loadFormFields();
        }
    }, [kodeRuangan]);

    useEffect(() => {
        if (activePatient) {
            setCatatanPetugas(activePatient.catatan_petugas || '');
            if (activePatient.hasil_form) {
                try {
                    const parsed = typeof activePatient.hasil_form === 'string'
                        ? JSON.parse(activePatient.hasil_form)
                        : activePatient.hasil_form;
                    setFormData(parsed || {});
                } catch (_) {
                    setFormData({});
                }
            } else {
                setFormData({});
            }
        } else {
            setFormData({});
            setCatatanPetugas('');
        }
    }, [activePatient]);

    const loadFormFields = async () => {
        if (!kodeRuangan) return;
        setLoadingFields(true);
        try {
            const res = await postData('/master/ruangan-form-data', { kode_ruangan: kodeRuangan });
            setFields(res.data.data || []);
        } catch (_) {
            // silent fail
        } finally {
            setLoadingFields(false);
        }
    };

    const handleFieldChange = (key: string, value: any) => {
        setFormData((prev) => ({ ...prev, [key]: value }));
    };

    const handleSaveForm = async (targetStatus?: string) => {
        if (!activePatient) return;

        // Check mandatory fields
        for (const f of fields) {
            if (f.is_required && !formData[f.label_field]) {
                showError(toast, `Field '${f.label_field}' wajib diisi!`);
                return;
            }
        }

        setSaving(true);
        try {
            const payload: any = {
                kode_antrian_layanan: activePatient.kode_antrian_layanan,
                hasil_form: formData,
                catatan_petugas: catatanPetugas,
            };
            if (targetStatus) {
                payload.status_tindakan = targetStatus;
            }

            const res = await postData('/master/antrian-layanan-simpan-form', payload);
            showSuccess(toast, res.data.message || 'Catatan & form penanganan berhasil disimpan');
            getGridData();
        } catch (error: any) {
            showError(toast, error?.response?.data?.message || 'Gagal menyimpan catatan penanganan');
        } finally {
            setSaving(false);
        }
    };

    // ─── IF NO PATIENT IS CURRENTLY IN TREATMENT ─────────────────────────────
    if (!activePatient) {
        return (
            <div className="card shadow-2 border-round-xl p-4 mb-4 surface-card border-top-3 border-teal-500">
                <div className="flex flex-column md:flex-row align-items-center justify-content-between gap-3">
                    <div className="flex align-items-center gap-3">
                        <div className="w-4rem h-4rem border-round-circle bg-teal-50 flex align-items-center justify-content-center text-teal-600 text-3xl">
                            <i className="pi pi-user-plus" />
                        </div>
                        <div>
                            <span className="text-xs font-bold text-teal-700 bg-teal-100 px-2 py-1 border-round-md inline-block mb-1">
                                Sesi Penanganan Ruangan: {namaRuangan}
                            </span>
                            <h3 className="text-xl font-bold text-900 m-0">Belum Ada Pasien Yang Sedang Ditangani</h3>
                            <p className="text-xs text-500 m-0 mt-1">
                                {nextWaitingPatient
                                    ? `Pasien berikutnya: No. #${nextWaitingPatient.nomor_antrian} — ${nextWaitingPatient.nama_pasien} (${nextWaitingPatient.nama_layanan})`
                                    : 'Tidak ada antrean pasien yang sedang menunggu di ruangan ini.'}
                            </p>
                        </div>
                    </div>

                    <div className="flex align-items-center gap-2 flex-wrap">
                        <Button
                            label="⚙️ Form Ruangan"
                            icon="pi pi-cog"
                            outlined
                            size="small"
                            severity="help"
                            onClick={onManageFormClick}
                        />

                        {nextWaitingPatient && (
                            <Button
                                label={`📢 Panggil Pasien Next (#${nextWaitingPatient.nomor_antrian})`}
                                icon="pi pi-megaphone"
                                size="small"
                                className="font-bold bg-teal-600 border-none text-white"
                                onClick={() => handleAksi(nextWaitingPatient, 'dipanggil')}
                            />
                        )}
                    </div>
                </div>
            </div>
        );
    }

    // ─── ACTIVE PATIENT IN TREATMENT CARD & FORM EMBED ────────────────────────
    return (
        <div className="card shadow-3 border-round-xl p-0 mb-4 surface-card overflow-hidden border-2 border-teal-500">
            {/* ACTIVE PATIENT HEADER HERO */}
            <div className="p-4 bg-teal-700 text-white flex flex-column md:flex-row align-items-start md:align-items-center justify-content-between gap-3">
                <div className="flex align-items-center gap-3">
                    <div className="bg-white text-teal-900 border-round-xl px-4 py-2 text-center shadow-2">
                        <span className="text-xs font-bold block text-teal-600">NO. ANTREAN</span>
                        <span className="text-4xl font-black">{activePatient.nomor_antrian}</span>
                    </div>

                    <div>
                        <div className="flex align-items-center gap-2">
                            <Tag value="PASIEN SEDANG DITANGANI" severity="success" className="text-xs font-bold px-2" />
                            <span className="text-xs text-teal-100">Jam Datang: {activePatient.jam_datang || '-'}</span>
                        </div>
                        <h2 className="text-2xl font-black text-white m-0 mt-1 flex align-items-center gap-2">
                            {activePatient.nama_pasien || 'Pasien'}
                            <span className="text-sm font-normal text-teal-200">(RM: {activePatient.no_rm})</span>
                        </h2>
                        <p className="text-xs text-teal-100 m-0 mt-1 flex align-items-center gap-2">
                            <i className="pi pi-briefcase" />
                            <strong>Layanan:</strong> {activePatient.nama_layanan} | <strong>Ruangan:</strong> {namaRuangan}
                        </p>
                    </div>
                </div>

                {/* QUICK ACTION BUTTONS */}
                <div className="flex align-items-center gap-2 flex-wrap">
                    <Button
                        label="Panggil Ulang Suara"
                        icon="pi pi-volume-up"
                        outlined
                        size="small"
                        className="bg-white-alpha-20 text-white border-white-alpha-40 hover:bg-white-alpha-30"
                        onClick={() => {
                            playChime();
                            speakNomorLayanan(activePatient.nomor_antrian, activePatient.nama_pasien, namaRuangan);
                        }}
                    />

                    <Button
                        label="Pengaturan Form"
                        icon="pi pi-cog"
                        outlined
                        size="small"
                        className="bg-white-alpha-20 text-white border-white-alpha-40 hover:bg-white-alpha-30"
                        onClick={onManageFormClick}
                    />

                    <Button
                        label="Batalkan"
                        icon="pi pi-times-circle"
                        outlined
                        size="small"
                        severity="danger"
                        className="bg-red-500 text-white border-none hover:bg-red-600"
                        onClick={() => handleAksi(activePatient, 'batal')}
                    />
                </div>
            </div>

            {/* FORM INPUT DYNAMIC & CATATAN EMBEDDED DIRECTLY BELOW */}
            <div className="p-4 surface-card">
                <div className="flex flex-column sm:flex-row align-items-start sm:align-items-center justify-content-between gap-2 mb-4 pb-3 border-bottom-1 surface-border">
                    <div>
                        <h4 className="text-lg font-bold text-900 m-0 flex align-items-center gap-2">
                            <i className="pi pi-file-edit text-teal-600 text-xl" />
                            Form Penanganan & Catatan Ruangan ({namaRuangan})
                        </h4>
                        <span className="text-xs text-500 mt-1 block">
                            Isi form & catatan di bawah ini saat proses tindakan berlangsung
                        </span>
                    </div>

                    {fields.length > 0 && (
                        <Tag
                            value={`${fields.length} Field Isian Khusus`}
                            severity="info"
                            className="text-xs font-semibold"
                        />
                    )}
                </div>

                {loadingFields ? (
                    <div className="flex align-items-center justify-content-center py-5 surface-50 border-round-xl">
                        <ProgressSpinner style={{ width: '32px', height: '32px' }} />
                        <span className="ml-3 text-sm text-500 font-medium">Memuat form isian ruangan...</span>
                    </div>
                ) : (
                    <div className="flex flex-column gap-4">
                        {/* 1. SECTION FORM KHUSUS ISIAN RUANGAN */}
                        {fields.length > 0 && (
                            <div className="p-3 border-round-xl border-1 surface-border surface-50">
                                <span className="text-xs font-extrabold text-teal-800 uppercase tracking-wider block mb-3 flex align-items-center gap-2">
                                    <i className="pi pi-list-check text-teal-600" />
                                    ISIAN KHUSUS RUANGAN ({namaRuangan.toUpperCase()})
                                </span>

                                <div className="grid formgrid p-fluid">
                                    {fields.map((f, i) => {
                                        const val = formData[f.label_field] !== undefined ? formData[f.label_field] : '';
                                        const isReq = Boolean(f.is_required);

                                        let optionsList: string[] = [];
                                        if (f.tipe_field === 'select' && f.options) {
                                            optionsList = f.options.split(',').map((s) => s.trim());
                                        }

                                        const colSize = f.tipe_field === 'textarea' ? 'col-12' : 'col-12 md:col-6';

                                        return (
                                            <div key={f.id || i} className={`${colSize} mb-3`}>
                                                <label className="block text-xs font-bold text-700 mb-2 flex align-items-center justify-content-between">
                                                    <span>
                                                        {f.label_field} {isReq && <span className="text-red-500 font-bold">*</span>}
                                                    </span>
                                                    <span className="text-[10px] text-400 font-normal uppercase">({f.tipe_field})</span>
                                                </label>

                                                {f.tipe_field === 'textarea' ? (
                                                    <InputTextarea
                                                        value={val}
                                                        onChange={(e) => handleFieldChange(f.label_field, e.target.value)}
                                                        rows={3}
                                                        placeholder={`Masukkan ${f.label_field}...`}
                                                        className="w-full text-sm border-round-md shadow-1 bg-white"
                                                    />
                                                ) : f.tipe_field === 'number' ? (
                                                    <InputNumber
                                                        value={typeof val === 'number' ? val : null}
                                                        onValueChange={(e) => handleFieldChange(f.label_field, e.value)}
                                                        placeholder={`Masukkan ${f.label_field}`}
                                                        className="w-full text-sm border-round-md shadow-1 bg-white"
                                                        inputClassName="w-full text-sm border-round-md bg-white"
                                                    />
                                                ) : f.tipe_field === 'select' ? (
                                                    <Dropdown
                                                        value={val}
                                                        options={optionsList.map((o) => ({ label: o, value: o }))}
                                                        onChange={(e) => handleFieldChange(f.label_field, e.value)}
                                                        placeholder={`Pilih ${f.label_field}...`}
                                                        className="w-full text-sm border-round-md shadow-1 bg-white"
                                                    />
                                                ) : f.tipe_field === 'checkbox' ? (
                                                    <div className="flex align-items-center gap-2 p-2 surface-card border-1 surface-border border-round-md">
                                                        <Checkbox
                                                            checked={Boolean(val)}
                                                            onChange={(e) => handleFieldChange(f.label_field, e.checked)}
                                                        />
                                                        <span className="text-xs text-800 font-semibold">{f.label_field}</span>
                                                    </div>
                                                ) : (
                                                    <InputText
                                                        value={val}
                                                        onChange={(e) => handleFieldChange(f.label_field, e.target.value)}
                                                        placeholder={`Masukkan ${f.label_field}...`}
                                                        className="w-full text-sm border-round-md shadow-1 bg-white"
                                                    />
                                                )}
                                            </div>
                                        );
                                    })}
                                </div>
                            </div>
                        )}

                        {/* 2. SECTION CATATAN PETUGAS / OBSERVASI RUANGAN */}
                        <div className="p-3 border-round-xl border-1 surface-border bg-white shadow-1">
                            <label className="block text-xs font-extrabold text-teal-800 uppercase tracking-wider mb-2 flex align-items-center gap-2">
                                <i className="pi pi-pencil text-teal-600 text-sm" />
                                CATATAN PETUGAS & OBSERVASI TINDAKAN RUANGAN
                            </label>
                            <InputTextarea
                                value={catatanPetugas}
                                onChange={(e) => setCatatanPetugas(e.target.value)}
                                rows={4}
                                placeholder="Tuliskan rincian hasil tindakan, obat/alat yang digunakan, resep, atau catatan khusus observasi pasien saat berada di ruangan ini..."
                                className="w-full text-sm border-round-md bg-white border-300 focus:border-teal-500"
                            />
                        </div>
                    </div>
                )}

                {/* SAVE ACTION FOOTER BAR */}
                <div className="flex align-items-center justify-content-end gap-3 mt-4 pt-3 border-top-1 surface-border">
                    <Button
                        label="Simpan Draf Form"
                        icon="pi pi-save"
                        outlined
                        severity="info"
                        loading={saving}
                        onClick={() => handleSaveForm()}
                        className="font-bold text-xs border-round-md px-3"
                    />

                    <Button
                        label="✅ Simpan & Selesaikan Tindakan Pasien"
                        icon="pi pi-check-circle"
                        severity="success"
                        loading={saving}
                        onClick={() => handleSaveForm('selesai')}
                        className="font-bold text-xs bg-teal-600 border-none border-round-md px-4 py-2 text-white"
                    />
                </div>
            </div>
        </div>
    );
};
