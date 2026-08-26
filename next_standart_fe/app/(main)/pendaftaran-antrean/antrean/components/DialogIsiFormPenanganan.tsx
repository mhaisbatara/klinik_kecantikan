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

interface DialogIsiFormPenangananProps {
    visible: boolean;
    onHide: () => void;
    antrianData: AntrianLayananData | null;
    toast: React.RefObject<Toast>;
    getGridData: () => void;
}

export const DialogIsiFormPenanganan: React.FC<DialogIsiFormPenangananProps> = ({
    visible,
    onHide,
    antrianData,
    toast,
    getGridData,
}) => {
    const [fields, setFields] = useState<RuanganFormField[]>([]);
    const [loadingFields, setLoadingFields] = useState<boolean>(false);
    const [formData, setFormData] = useState<Record<string, any>>({});
    const [catatanPetugas, setCatatanPetugas] = useState<string>('');
    const [saving, setSaving] = useState<boolean>(false);

    useEffect(() => {
        if (visible && antrianData?.kode_ruangan) {
            loadFormFields();
        }
        if (visible && antrianData) {
            // Load existing saved form data if available
            setCatatanPetugas(antrianData.catatan_petugas || '');
            if (antrianData.hasil_form) {
                try {
                    const parsed = typeof antrianData.hasil_form === 'string'
                        ? JSON.parse(antrianData.hasil_form)
                        : antrianData.hasil_form;
                    setFormData(parsed || {});
                } catch (_) {
                    setFormData({});
                }
            } else {
                setFormData({});
            }
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

    const handleSave = async (targetStatus?: string) => {
        if (!antrianData) return;

        // Check required fields
        for (const f of fields) {
            if (f.is_required && !formData[f.label_field]) {
                showError(toast, `Field '${f.label_field}' wajib diisi!`);
                return;
            }
        }

        setSaving(true);
        try {
            const payload: any = {
                kode_antrian_layanan: antrianData.kode_antrian_layanan,
                hasil_form: formData,
                catatan_petugas: catatanPetugas,
            };
            if (targetStatus) {
                payload.status_tindakan = targetStatus;
            }

            const res = await postData('/master/antrian-layanan-simpan-form', payload);
            showSuccess(toast, res.data.message || 'Catatan penanganan berhasil disimpan');
            getGridData();
            onHide();
        } catch (error: any) {
            showError(toast, error?.response?.data?.message || 'Gagal menyimpan catatan penanganan');
        } finally {
            setSaving(false);
        }
    };

    if (!antrianData) return null;

    return (
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
            visible={visible}
            style={{ width: '680px' }}
            modal
            onHide={onHide}
            className="p-fluid"
        >
            <div className="p-3 bg-teal-50 border-round-xl mb-4 border-1 border-teal-200 flex align-items-center justify-content-between">
                <div>
                    <span className="text-xs text-teal-700 block font-semibold">Status Penanganan Pasien</span>
                    <Tag
                        value={antrianData.status?.toUpperCase()}
                        severity={
                            antrianData.status === 'dipanggil'
                                ? 'info'
                                : antrianData.status === 'selesai'
                                ? 'success'
                                : 'warning'
                        }
                        className="text-xs font-bold mt-1"
                    />
                </div>
                <div className="text-right">
                    <span className="text-xs text-teal-700 block font-semibold">Waktu Datang</span>
                    <span className="text-sm font-bold text-teal-900">{antrianData.jam_datang || '-'}</span>
                </div>
            </div>

            {loadingFields ? (
                <div className="flex align-items-center justify-content-center py-5">
                    <ProgressSpinner style={{ width: '35px', height: '35px' }} />
                    <span className="ml-2 text-sm text-500">Memuat isian form...</span>
                </div>
            ) : (
                <div className="flex flex-column gap-3">
                    {/* DYNAMIC FORM FIELDS FOR THIS ROOM */}
                    {fields.length > 0 && (
                        <div className="surface-card p-3 border-round-xl border-1 surface-border">
                            <h5 className="text-sm font-bold text-900 mb-3 flex align-items-center gap-2 border-bottom-1 surface-border pb-2">
                                <i className="pi pi-list text-teal-600" />
                                Form Khusus Ruangan ({antrianData.nama_ruangan})
                            </h5>

                            <div className="flex flex-column gap-3">
                                {fields.map((f, i) => {
                                    const val = formData[f.label_field] !== undefined ? formData[f.label_field] : '';
                                    const isReq = Boolean(f.is_required);

                                    let optionsList: string[] = [];
                                    if (f.tipe_field === 'select' && f.options) {
                                        optionsList = f.options.split(',').map((s) => s.trim());
                                    }

                                    return (
                                        <div key={f.id || i}>
                                            <label className="block text-xs font-bold mb-1 text-800">
                                                {f.label_field} {isReq && <span className="text-red-500">*</span>}
                                            </label>

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
                                                    inputClassName="w-full text-sm"
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
                                        </div>
                                    );
                                })}
                            </div>
                        </div>
                    )}

                    {/* CATATAN PETUGAS RUANGAN */}
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
            )}

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

                    {antrianData.status !== 'selesai' && (
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
    );
};
