'use client';

import React, { useState, useRef } from 'react';
import { Button } from 'primereact/button';
import { Toast } from 'primereact/toast';
import { ProgressSpinner } from 'primereact/progressspinner';
import postData from '@/lib/axios/postData';
import { showError, showSuccess } from '@/lib/tools/generalTools';

interface FormRuanganFotoUploaderProps {
    value?: {
        before?: string;
        after?: string;
    } | null;
    onChange: (newValue: { before?: string; after?: string }) => void;
    labelField: string;
    isRequired?: boolean;
    toast?: React.RefObject<Toast> | any;
}

export const FormRuanganFotoUploader: React.FC<FormRuanganFotoUploaderProps> = ({
    value,
    onChange,
    labelField,
    isRequired = false,
    toast,
}) => {
    const [uploadingBefore, setUploadingBefore] = useState<boolean>(false);
    const [uploadingAfter, setUploadingAfter] = useState<boolean>(false);

    const fileInputBeforeRef = useRef<HTMLInputElement>(null);
    const fileInputAfterRef = useRef<HTMLInputElement>(null);

    const handleFileSelect = async (
        e: React.ChangeEvent<HTMLInputElement>,
        prefix: 'before' | 'after'
    ) => {
        const file = e.target.files?.[0];
        if (!file) return;

        if (!file.type.startsWith('image/')) {
            showError(toast, 'File harus berupa gambar (JPG, PNG, WEBP, dll)');
            return;
        }

        const setUploading = prefix === 'before' ? setUploadingBefore : setUploadingAfter;
        setUploading(true);

        try {
            const base64 = await convertFileToBase64(file);
            const res = await postData('/master/ruangan-form-upload-foto', {
                image_base64: base64,
                file_name: file.name,
                prefix,
            });

            if (res?.data?.status === 200 || res?.status === 200) {
                const filePath = res.data?.data?.file_path || res.data?.file_path;
                const updatedVal = {
                    before: value?.before || '',
                    after: value?.after || '',
                    [prefix]: filePath,
                };
                onChange(updatedVal);
                showSuccess(toast, `Foto ${prefix === 'before' ? 'Sebelum' : 'Sesudah'} berhasil diunggah`);
            } else {
                showError(toast, res?.data?.message || 'Gagal mengunggah foto');
            }
        } catch (error: any) {
            showError(toast, error?.response?.data?.message || 'Gagal mengunggah foto');
        } finally {
            setUploading(false);
            if (e.target) e.target.value = '';
        }
    };

    const convertFileToBase64 = (file: File): Promise<string> => {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.readAsDataURL(file);
            reader.onload = () => resolve(reader.result as string);
            reader.onerror = (error) => reject(error);
        });
    };

    const handleRemove = (prefix: 'before' | 'after') => {
        const updatedVal = {
            before: value?.before || '',
            after: value?.after || '',
            [prefix]: '',
        };
        onChange(updatedVal);
    };

    const getImgSrc = (path?: string) => {
        if (!path) return '';
        if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('data:')) {
            return path;
        }
        const beUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000';
        const baseUrl = beUrl.replace(/\/$/, '');
        return `${baseUrl}${path.startsWith('/') ? '' : '/'}${path}`;
    };

    return (
        <div className="surface-card p-3 border-round border-1 surface-border mb-2">
            <div className="flex align-items-center justify-content-between mb-3">
                <label className="text-xs font-bold text-800 uppercase flex align-items-center gap-1">
                    <span>📷 {labelField}</span>
                    {isRequired && <span className="text-red-500 font-bold">*</span>}
                </label>
            </div>

            <div className="grid">
                {/* BEFORE FOTO */}
                <div className="col-12 md:col-6">
                    <div className="border-1 surface-border border-round p-2 text-center bg-gray-50 flex flex-column align-items-center justify-content-center min-h-10rem relative">
                        <span className="text-xs font-bold text-600 mb-2">FOTO SEBELUM (BEFORE)</span>
                        {value?.before ? (
                            <div className="relative w-full flex flex-column align-items-center">
                                <img
                                    src={getImgSrc(value.before)}
                                    alt="Before"
                                    className="max-w-full border-round shadow-1"
                                    style={{ maxHeight: '160px', objectFit: 'cover' }}
                                />
                                <div className="flex gap-2 mt-2">
                                    <Button
                                        type="button"
                                        icon="pi pi-pencil"
                                        label="Ganti"
                                        className="p-button-outlined p-button-sm text-xs p-button-secondary"
                                        onClick={() => fileInputBeforeRef.current?.click()}
                                    />
                                    <Button
                                        type="button"
                                        icon="pi pi-trash"
                                        label="Hapus"
                                        className="p-button-outlined p-button-sm text-xs p-button-danger"
                                        onClick={() => handleRemove('before')}
                                    />
                                </div>
                            </div>
                        ) : (
                            <div>
                                {uploadingBefore ? (
                                    <div className="flex flex-column align-items-center">
                                        <ProgressSpinner style={{ width: '30px', height: '30px' }} />
                                        <span className="text-xs text-500 mt-2">Mengunggah...</span>
                                    </div>
                                ) : (
                                    <Button
                                        type="button"
                                        icon="pi pi-upload"
                                        label="Unggah Foto Before"
                                        className="p-button-sm p-button-outlined text-xs p-button-info"
                                        onClick={() => fileInputBeforeRef.current?.click()}
                                    />
                                )}
                            </div>
                        )}
                        <input
                            ref={fileInputBeforeRef}
                            type="file"
                            accept="image/*"
                            className="hidden"
                            onChange={(e) => handleFileSelect(e, 'before')}
                        />
                    </div>
                </div>

                {/* AFTER FOTO */}
                <div className="col-12 md:col-6">
                    <div className="border-1 surface-border border-round p-2 text-center bg-gray-50 flex flex-column align-items-center justify-content-center min-h-10rem relative">
                        <span className="text-xs font-bold text-600 mb-2">FOTO SESUDAH (AFTER)</span>
                        {value?.after ? (
                            <div className="relative w-full flex flex-column align-items-center">
                                <img
                                    src={getImgSrc(value.after)}
                                    alt="After"
                                    className="max-w-full border-round shadow-1"
                                    style={{ maxHeight: '160px', objectFit: 'cover' }}
                                />
                                <div className="flex gap-2 mt-2">
                                    <Button
                                        type="button"
                                        icon="pi pi-pencil"
                                        label="Ganti"
                                        className="p-button-outlined p-button-sm text-xs p-button-secondary"
                                        onClick={() => fileInputAfterRef.current?.click()}
                                    />
                                    <Button
                                        type="button"
                                        icon="pi pi-trash"
                                        label="Hapus"
                                        className="p-button-outlined p-button-sm text-xs p-button-danger"
                                        onClick={() => handleRemove('after')}
                                    />
                                </div>
                            </div>
                        ) : (
                            <div>
                                {uploadingAfter ? (
                                    <div className="flex flex-column align-items-center">
                                        <ProgressSpinner style={{ width: '30px', height: '30px' }} />
                                        <span className="text-xs text-500 mt-2">Mengunggah...</span>
                                    </div>
                                ) : (
                                    <Button
                                        type="button"
                                        icon="pi pi-upload"
                                        label="Unggah Foto After"
                                        className="p-button-sm p-button-outlined text-xs p-button-success"
                                        onClick={() => fileInputAfterRef.current?.click()}
                                    />
                                )}
                            </div>
                        )}
                        <input
                            ref={fileInputAfterRef}
                            type="file"
                            accept="image/*"
                            className="hidden"
                            onChange={(e) => handleFileSelect(e, 'after')}
                        />
                    </div>
                </div>
            </div>
        </div>
    );
};

export default FormRuanganFotoUploader;
