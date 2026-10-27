'use client';

import React, { useState, useEffect, useRef } from 'react';
import { Toast } from 'primereact/toast';
import { Button } from 'primereact/button';
import { InputText } from 'primereact/inputtext';
import { InputTextarea } from 'primereact/inputtextarea';
import { Divider } from 'primereact/divider';
import { Tag } from 'primereact/tag';
import { Dialog } from 'primereact/dialog';
import { ConfirmDialog, confirmDialog } from 'primereact/confirmdialog';
import postData from '@/lib/axios/postData';
import formUpload from '@/lib/axios/formData';
import { showError, showSuccess } from '@/lib/tools/generalTools';
import { useSession } from 'next-auth/react';

interface ClinicConfig {
    msNamaPerusahaan: string;
    msWaKlinik: string;
    msTeleponPerusahaan: string;
    msCatatanOtp: string;
}

interface WhatsAppStatus {
    status: 'connected' | 'qr_ready' | 'connecting' | 'disconnected';
    isConnected: boolean;
    connectedNumber: string | null;
    qrDataUrl: string | null;
    hasQr: boolean;
}

export default function MasterNomerKlinikPage() {
    const toast = useRef<Toast>(null);
    const { data: session } = useSession();

    // Form Configuration State
    const [config, setConfig] = useState<ClinicConfig>({
        msNamaPerusahaan: 'Klinik Kecantikan',
        msWaKlinik: '',
        msTeleponPerusahaan: '',
        msCatatanOtp: 'Berlaku selama 5 menit. Jangan berikan kode ini kepada siapa pun demi keamanan data rekam medis Anda.',
    });
    const [loadingConfig, setLoadingConfig] = useState<boolean>(true);
    const [saving, setSaving] = useState<boolean>(false);

    // WhatsApp Bot Engine State
    const [waStatus, setWaStatus] = useState<WhatsAppStatus>({
        status: 'disconnected',
        isConnected: false,
        connectedNumber: null,
        qrDataUrl: null,
        hasQr: false,
    });
    const [loadingWa, setLoadingWa] = useState<boolean>(false);

    // Test Send Dialog State
    const [showTestDialog, setShowTestDialog] = useState<boolean>(false);
    const [testPhone, setTestPhone] = useState<string>('');
    const [testSending, setTestSending] = useState<boolean>(false);

    // 1. Ambil Data Konfigurasi Nomor Klinik dari DB
    const loadConfig = async () => {
        setLoadingConfig(true);
        try {
            const res = await postData('/setup/config-data', {
                kode: ['msNamaPerusahaan', 'msWaKlinik', 'msTeleponPerusahaan', 'msCatatanOtp']
            });

            const data = res?.data?.data || {};
            setConfig({
                msNamaPerusahaan: data.msNamaPerusahaan || 'Klinik Kecantikan',
                msWaKlinik: data.msWaKlinik || '',
                msTeleponPerusahaan: data.msTeleponPerusahaan || '',
                msCatatanOtp: data.msCatatanOtp || 'Berlaku selama 5 menit. Jangan berikan kode ini kepada siapa pun demi keamanan data rekam medis Anda.',
            });
        } catch (err: any) {
            showError(toast, err?.message || 'Gagal memuat konfigurasi nomor klinik');
        } finally {
            setLoadingConfig(false);
        }
    };

    // 2. Ambil Live Status WhatsApp Bot Engine
    const loadWaStatus = async () => {
        try {
            const res = await postData('/setup/whatsapp/status', {});
            const data = res?.data?.data || {};
            setWaStatus({
                status: data.status || 'disconnected',
                isConnected: Boolean(data.isConnected),
                connectedNumber: data.connectedNumber || null,
                qrDataUrl: data.qrDataUrl || null,
                hasQr: Boolean(data.hasQr),
            });
        } catch (_) {
            // Fallback status if offline
            setWaStatus(prev => ({ ...prev, isConnected: false, status: 'disconnected' }));
        }
    };

    // 3. Simpan Perubahan Nomor Klinik oleh Super Admin
    const handleSaveConfig = async () => {
        if (!config.msWaKlinik.trim()) {
            showError(toast, 'Nomor WhatsApp Resmi Klinik wajib diisi!');
            return;
        }

        setSaving(true);
        try {
            const formData = new FormData();
            const keys = ['msNamaPerusahaan', 'msWaKlinik', 'msTeleponPerusahaan', 'msCatatanOtp'];
            const values = [
                config.msNamaPerusahaan.trim(),
                config.msWaKlinik.trim(),
                config.msTeleponPerusahaan.trim(),
                config.msCatatanOtp.trim(),
            ];

            formData.append('kode', JSON.stringify(keys));
            formData.append('keterangan', JSON.stringify(values));

            await formUpload('/setup/config-create', formData, { 'X-Level': '1' });
            showSuccess(toast, 'Nomor WhatsApp Klinik & Konfigurasi OTP berhasil disimpan!');
            await loadConfig();
        } catch (err: any) {
            showError(toast, err?.message || 'Gagal menyimpan konfigurasi');
        } finally {
            setSaving(false);
        }
    };

    // 4. Putuskan Sesi WhatsApp Bot (Logout) untuk Ganti Nomor
    const confirmDisconnect = () => {
        confirmDialog({
            message: 'Apakah Anda yakin ingin memutuskan tautan nomor WhatsApp bot ini? Anda perlu melakukan scan QR Code kembali dengan nomor klinik yang baru.',
            header: 'Konfirmasi Putuskan Sesi WhatsApp',
            icon: 'pi pi-exclamation-triangle',
            acceptClassName: 'p-button-danger',
            acceptLabel: 'Ya, Putuskan & Tautkan Nomor Baru',
            rejectLabel: 'Batal',
            accept: async () => {
                setLoadingWa(true);
                try {
                    const res = await postData('/setup/whatsapp/disconnect', {});
                    showSuccess(toast, res?.data?.message || 'Sesi WhatsApp berhasil diputuskan');
                    await loadWaStatus();
                } catch (err: any) {
                    showError(toast, err?.message || 'Gagal memutuskan sesi WhatsApp');
                } finally {
                    setLoadingWa(false);
                }
            }
        });
    };

    // 5. Uji Coba Pengiriman Pesan WhatsApp OTP
    const handleSendTestMessage = async () => {
        if (!testPhone.trim()) {
            showError(toast, 'Masukkan nomor HP tujuan untuk pengujian');
            return;
        }

        setTestSending(true);
        try {
            const previewMsg = `*[${config.msNamaPerusahaan}]*\nIni adalah pesan uji coba dari Master Nomer Klinik.\nKode OTP Simulasi: *${Math.floor(100000 + Math.random() * 900000)}*.\n\nNomor Resmi Klinik: *${config.msWaKlinik || '-'}*\n${config.msCatatanOtp}`;

            const res = await postData('/setup/whatsapp/test-send', {
                targetPhone: testPhone.trim(),
                message: previewMsg
            });

            showSuccess(toast, res?.data?.message || 'Pesan uji coba berhasil terkirim!');
            setShowTestDialog(false);
        } catch (err: any) {
            const msg = err?.response?.data?.message || err?.message || 'Gagal mengirim pesan uji coba';
            showError(toast, msg);
        } finally {
            setTestSending(false);
        }
    };

    // Auto-polling status WhatsApp bot setiap 3 detik agar QR selalu live
    useEffect(() => {
        loadConfig();
        loadWaStatus();

        const interval = setInterval(() => {
            loadWaStatus();
        }, 3000);

        return () => clearInterval(interval);
    }, []);

    // Format preview message
    const previewOtpCode = '839215';
    const cleanConfigPhone = config.msWaKlinik.replace(/[^0-9]/g, '');
    const cleanActiveBot = (waStatus.connectedNumber || '').replace(/[^0-9]/g, '');
    const isBotNumberMatching = cleanConfigPhone && cleanActiveBot && (
        cleanConfigPhone.endsWith(cleanActiveBot.slice(-9)) || cleanActiveBot.endsWith(cleanConfigPhone.slice(-9))
    );

    return (
        <div className="grid">
            <Toast ref={toast} position="top-right" />
            <ConfirmDialog />

            {/* HEADER UTAMA */}
            <div className="col-12">
                <div className="card shadow-1 border-round-xl p-4 mb-3 bg-white border-1 surface-border">
                    <div className="flex flex-column md:flex-row md:align-items-center md:justify-content-between gap-3">
                        <div className="flex align-items-center gap-3">
                            <div className="flex align-items-center justify-content-center bg-green-100 border-round-xl p-3" style={{ width: '56px', height: '56px' }}>
                                <i className="pi pi-whatsapp text-green-600 text-3xl font-bold"></i>
                            </div>
                            <div>
                                <h2 className="text-2xl font-bold text-900 m-0">Master Nomer Klinik</h2>
                                <p className="text-500 text-sm mt-1 mb-0">
                                    Konfigurasi nomor resmi klinik & gateway pengiriman kode OTP verifikasi WhatsApp pasien.
                                </p>
                            </div>
                        </div>
                        <div className="flex gap-2">
                            <Button
                                label="Refresh Status"
                                icon="pi pi-refresh"
                                severity="secondary"
                                outlined
                                onClick={loadWaStatus}
                                loading={loadingWa}
                                className="font-semibold"
                            />
                            <Button
                                label="Tes Kirim WhatsApp"
                                icon="pi pi-send"
                                severity="info"
                                onClick={() => {
                                    setTestPhone(config.msWaKlinik);
                                    setShowTestDialog(true);
                                }}
                                disabled={!waStatus.isConnected}
                                className="font-semibold"
                            />
                        </div>
                    </div>
                </div>
            </div>

            {/* STATUS LIVE BOT GATEWAY */}
            <div className="col-12 lg:col-5">
                <div className="card shadow-1 border-round-xl p-4 bg-white border-1 surface-border h-full flex flex-column justify-content-between">
                    <div>
                        <div className="flex align-items-center justify-content-between mb-3">
                            <h3 className="text-lg font-bold text-900 m-0 flex align-items-center gap-2">
                                <i className="pi pi-bolt text-yellow-600"></i>
                                Status Gateway WhatsApp
                            </h3>
                            {waStatus.isConnected ? (
                                <Tag severity="success" value="● TERHUBUNG" className="px-3 py-1 font-bold text-sm" />
                            ) : waStatus.hasQr ? (
                                <Tag severity="warning" value="⏳ MENUNGGU SCAN" className="px-3 py-1 font-bold text-sm" />
                            ) : (
                                <Tag severity="danger" value="✕ BELUM TERHUBUNG" className="px-3 py-1 font-bold text-sm" />
                            )}
                        </div>

                        <Divider className="my-3" />

                        {waStatus.isConnected ? (
                            <div className="text-center py-4">
                                <div className="inline-flex align-items-center justify-content-center bg-green-50 border-circle p-4 mb-3" style={{ width: '90px', height: '90px', border: '2px solid #22c55e' }}>
                                    <i className="pi pi-check text-green-600 text-4xl font-bold"></i>
                                </div>
                                <h4 className="text-xl font-bold text-900 mb-1">WhatsApp Bot Aktif!</h4>
                                <p className="text-600 text-sm mb-3">
                                    Backend klinik Anda siap mengirimkan kode OTP secara langsung ke pasien (100% Gratis).
                                </p>
                                <div className="bg-green-50 border-1 border-green-200 border-round-xl p-3 inline-block max-w-full mb-3">
                                    <span className="text-xs text-green-700 font-semibold uppercase block">Nomor WhatsApp Bot Aktif</span>
                                    <span className="text-xl font-extrabold text-green-900">+{waStatus.connectedNumber}</span>
                                </div>

                                {isBotNumberMatching ? (
                                    <div className="flex align-items-center justify-content-center gap-2 text-green-700 text-xs font-semibold">
                                        <i className="pi pi-check-circle"></i>
                                        <span>Nomor WhatsApp Bot sesuai dengan Nomor Master Klinik</span>
                                    </div>
                                ) : (
                                    <div className="bg-blue-50 border-round-lg p-2 text-blue-700 text-xs text-left mt-2">
                                        <i className="pi pi-info-circle mr-1"></i>
                                        Bot aktif menggunakan nomor <strong>+{waStatus.connectedNumber}</strong>. Jika ingin berganti ke nomor klinik <strong>{config.msWaKlinik || 'lain'}</strong>, gunakan tombol di bawah untuk tautkan nomor baru.
                                    </div>
                                )}
                            </div>
                        ) : waStatus.hasQr && waStatus.qrDataUrl ? (
                            <div className="text-center py-2">
                                <h4 className="text-base font-bold text-900 mb-1">Scan QR Code dengan WhatsApp</h4>
                                <p className="text-500 text-xs mb-3">
                                    Buka WhatsApp di HP Klinik &gt; Perangkat Tertaut &gt; Tautkan Perangkat.
                                </p>
                                <div className="inline-block p-3 bg-white shadow-2 border-round-xl border-1 surface-border mb-3">
                                    {/* eslint-disable-next-line @next/next/no-img-element */}
                                    <img
                                        src={waStatus.qrDataUrl}
                                        alt="Scan QR WhatsApp Bot"
                                        style={{ width: '220px', height: '220px', display: 'block' }}
                                    />
                                </div>
                                <p className="text-xs text-500 m-0">
                                    <i className="pi pi-spin pi-spinner mr-1"></i>
                                    QR Code diperbarui secara otomatis. Arahkan kamera HP Anda sekarang.
                                </p>
                            </div>
                        ) : (
                            <div className="text-center py-5">
                                <i className="pi pi-spin pi-spinner text-4xl text-primary mb-3"></i>
                                <h4 className="text-base font-bold text-900 mb-1">Menyiapkan Sesi WhatsApp...</h4>
                                <p className="text-500 text-xs">
                                    Sedang menginisialisasi modul WhatsApp backend. QR Code akan muncul sebentar lagi.
                                </p>
                            </div>
                        )}
                    </div>

                    <div className="pt-3 border-top-1 surface-border mt-3">
                        {waStatus.isConnected ? (
                            <Button
                                label="Putuskan Sesi / Ganti Nomor WhatsApp"
                                icon="pi pi-power-off"
                                severity="danger"
                                outlined
                                onClick={confirmDisconnect}
                                loading={loadingWa}
                                className="w-full font-semibold"
                            />
                        ) : (
                            <Button
                                label="Muat Ulang QR Code"
                                icon="pi pi-refresh"
                                severity="secondary"
                                onClick={loadWaStatus}
                                loading={loadingWa}
                                className="w-full font-semibold"
                            />
                        )}
                    </div>
                </div>
            </div>

            {/* FORM PENGATURAN MASTER NOMOR KLINIK & PREVIEW */}
            <div className="col-12 lg:col-7">
                <div className="card shadow-1 border-round-xl p-4 bg-white border-1 surface-border">
                    <h3 className="text-lg font-bold text-900 m-0 flex align-items-center gap-2 mb-3">
                        <i className="pi pi-sliders-h text-primary"></i>
                        Pengaturan Nomor Klinik & Format OTP
                    </h3>
                    <p className="text-500 text-sm mt-0 mb-4">
                        Nomor dan nama yang diatur di sini akan menjadi identitas resmi klinik saat pasien menerima pesan OTP di WhatsApp.
                    </p>

                    <div className="p-fluid grid formgrid align-items-start">
                        {/* 1. NOMOR WHATSAPP RESMI KLINIK */}
                        <div className="col-12 md:col-6 mb-5">
                            <label className="font-bold text-800 text-sm block mb-2">
                                Nomor WhatsApp Resmi Klinik (Pengirim OTP)*
                            </label>
                            <div className="relative w-full flex align-items-center">
                                <i
                                    className="pi pi-whatsapp text-green-600 text-lg absolute"
                                    style={{ left: '1rem', top: '50%', transform: 'translateY(-50%)', zIndex: 2, pointerEvents: 'none' }}
                                />
                                <InputText
                                    value={config.msWaKlinik}
                                    onChange={(e) => setConfig({ ...config, msWaKlinik: e.target.value })}
                                    placeholder="Contoh: 081335086375"
                                    className="w-full font-bold text-green-800"
                                    style={{ paddingLeft: '2.85rem', height: '44px', borderRadius: '8px' }}
                                    disabled={loadingConfig}
                                />
                            </div>
                            <small className="text-xs mt-2 block line-height-2" style={{ color: '#64748b' }}>
                                Pasien akan melihat nomor ini sebagai pengirim pesan OTP verifikasi rekam medis.
                            </small>
                        </div>

                        {/* 2. NAMA BRAND / KLINIK */}
                        <div className="col-12 md:col-6 mb-5">
                            <label className="font-bold text-800 text-sm block mb-2">
                                Nama Klinik (Header Pesan)*
                            </label>
                            <div className="relative w-full flex align-items-center">
                                <i
                                    className="pi pi-building text-primary text-lg absolute"
                                    style={{ left: '1rem', top: '50%', transform: 'translateY(-50%)', zIndex: 2, pointerEvents: 'none' }}
                                />
                                <InputText
                                    value={config.msNamaPerusahaan}
                                    onChange={(e) => setConfig({ ...config, msNamaPerusahaan: e.target.value })}
                                    placeholder="Contoh: Klinik Kecantikan Utama"
                                    className="w-full text-900"
                                    style={{ paddingLeft: '2.85rem', height: '44px', borderRadius: '8px' }}
                                    disabled={loadingConfig}
                                />
                            </div>
                            <small className="text-xs mt-2 block line-height-2" style={{ color: '#64748b' }}>
                                Ditampilkan di baris pertama pesan: *[Nama Klinik]*.
                            </small>
                        </div>

                        {/* 3. NOMOR TELEPON HOTLINE / CS */}
                        <div className="col-12 md:col-6 mb-5">
                            <label className="font-bold text-800 text-sm block mb-2">
                                Nomor Telepon Hotline / CS (Opsional)
                            </label>
                            <div className="relative w-full flex align-items-center">
                                <i
                                    className="pi pi-phone text-blue-600 text-lg absolute"
                                    style={{ left: '1rem', top: '50%', transform: 'translateY(-50%)', zIndex: 2, pointerEvents: 'none' }}
                                />
                                <InputText
                                    value={config.msTeleponPerusahaan}
                                    onChange={(e) => setConfig({ ...config, msTeleponPerusahaan: e.target.value })}
                                    placeholder="Contoh: (021) 555-1234 atau 081234567890"
                                    className="w-full text-900"
                                    style={{ paddingLeft: '2.85rem', height: '44px', borderRadius: '8px' }}
                                    disabled={loadingConfig}
                                />
                            </div>
                            <small className="text-xs mt-2 block line-height-2" style={{ color: '#64748b' }}>
                                Nomor bantuan alternatif jika pasien mengalami kendala.
                            </small>
                        </div>

                        {/* HELPER CARD SAMPING HOTLINE */}
                        <div className="col-12 md:col-6 mb-5">
                            <label className="font-bold text-transparent text-sm block mb-2 select-none">
                                Informasi Tambahan
                            </label>
                            <div
                                className="p-3 border-round-lg surface-50 border-1 surface-border flex align-items-center gap-3"
                                style={{ height: '44px' }}
                            >
                                <i className="pi pi-info-circle text-primary text-base"></i>
                                <span className="text-xs text-600 line-height-2">
                                    Kontak bantuan akan disematkan di bawah pesan OTP.
                                </span>
                            </div>
                        </div>

                        {/* 4. FOOTER CATATAN KEAMANAN OTP */}
                        <div className="col-12 mb-4">
                            <label className="font-bold text-800 text-sm block mb-2">
                                Catatan Keamanan / Footer Pesan OTP
                            </label>
                            <InputTextarea
                                value={config.msCatatanOtp}
                                onChange={(e) => setConfig({ ...config, msCatatanOtp: e.target.value })}
                                rows={2}
                                autoResize
                                placeholder="Masukkan catatan keamanan OTP..."
                                className="w-full text-900 p-3"
                                style={{ borderRadius: '8px' }}
                                disabled={loadingConfig}
                            />
                            <small className="text-xs mt-2 block line-height-2" style={{ color: '#64748b' }}>
                                Pesan peringatan keamanan data rekam medis bagi pasien.
                            </small>
                        </div>
                    </div>

                    <Divider className="my-4" />

                    {/* LIVE PREVIEW PESAN WHATSAPP PASIEN */}
                    <div className="mb-4">
                        <div className="flex align-items-center justify-content-between mb-3">
                            <label className="font-bold text-800 text-sm m-0 flex align-items-center gap-2">
                                <i className="pi pi-eye text-primary"></i>
                                <span>Live Preview Pesan WhatsApp yang Diterima Pasien:</span>
                            </label>
                            <span className="text-xs text-600 bg-gray-100 px-2.5 py-1 border-round-md font-medium border-1 surface-border">
                                Tampilan Chat Pasien
                            </span>
                        </div>
                        <div
                            className="p-4 border-round-xl border-1 surface-border flex justify-content-start"
                            style={{
                                background: '#eef2f5',
                                backgroundImage: 'radial-gradient(#cbd5e1 1.2px, transparent 1.2px)',
                                backgroundSize: '16px 16px'
                            }}
                        >
                            <div
                                className="bg-white shadow-2 border-1 surface-border w-full"
                                style={{
                                    borderRadius: '16px 16px 16px 4px',
                                    padding: '1.25rem',
                                    maxWidth: '460px',
                                    boxShadow: '0 4px 14px rgba(0,0,0,0.06)'
                                }}
                            >
                                {/* Header Preview */}
                                <div className="flex align-items-center gap-2 mb-3 pb-2 border-bottom-1 surface-border">
                                    <div
                                        className="flex align-items-center justify-content-center border-circle"
                                        style={{ width: '32px', height: '32px', background: '#dcfce7', color: '#16a34a' }}
                                    >
                                        <i className="pi pi-whatsapp font-bold text-base"></i>
                                    </div>
                                    <div className="overflow-hidden">
                                        <div className="text-xs font-bold text-green-700 uppercase tracking-wide">
                                            *{config.msNamaPerusahaan || 'Klinik Kecantikan'}*
                                        </div>
                                        <div className="text-400 text-xs">Pesan Resmi Sistem Rekam Medis</div>
                                    </div>
                                </div>

                                {/* Body Teks */}
                                <div className="text-sm text-800 line-height-3 mb-2">
                                    Halo Pasien,
                                    <br />
                                    Kode OTP Verifikasi Rekam Medis Anda adalah:
                                </div>

                                {/* Pill-shaped OTP Badge */}
                                <div className="my-3 text-center">
                                    <div
                                        className="inline-flex align-items-center justify-content-center px-4 py-2 border-round-3xl shadow-1"
                                        style={{
                                            backgroundColor: '#f0fdf4',
                                            border: '1.5px solid #86efac',
                                            gap: '0.5rem'
                                        }}
                                    >
                                        <i className="pi pi-lock text-green-600 text-sm"></i>
                                        <span
                                            className="font-mono font-bold text-xl text-green-800"
                                            style={{ letterSpacing: '0.15em' }}
                                        >
                                            *{previewOtpCode}*
                                        </span>
                                    </div>
                                </div>

                                {/* Detail Kontak Tambahan */}
                                {(config.msWaKlinik || config.msTeleponPerusahaan) && (
                                    <div className="text-xs text-700 surface-50 border-round-lg p-2.5 my-2 border-1 surface-border line-height-3">
                                        {config.msWaKlinik && (
                                            <div className="flex align-items-center gap-2 mb-1">
                                                <i className="pi pi-check-circle text-green-600"></i>
                                                <span>Nomor Resmi WhatsApp Klinik: <strong>*{config.msWaKlinik}*</strong></span>
                                            </div>
                                        )}
                                        {config.msTeleponPerusahaan && (
                                            <div className="flex align-items-center gap-2">
                                                <i className="pi pi-phone text-blue-600"></i>
                                                <span>Hotline Layanan CS: <strong>{config.msTeleponPerusahaan}</strong></span>
                                            </div>
                                        )}
                                    </div>
                                )}

                                {/* Catatan Keamanan / Footer Pesan */}
                                <div className="text-xs text-500 mt-3 pt-2 border-top-1 surface-border font-italic line-height-2">
                                    {config.msCatatanOtp || 'Berlaku selama 5 menit. Jangan berikan kode ini kepada siapa pun demi keamanan data rekam medis Anda.'}
                                </div>

                                {/* Timestamp & Checkmark */}
                                <div className="flex justify-content-end align-items-center gap-1 mt-2 text-400 text-xs">
                                    <span>11:35 WIB</span>
                                    <i className="pi pi-check text-blue-500 text-xs font-bold" style={{ fontSize: '11px' }}></i>
                                    <i className="pi pi-check text-blue-500 text-xs font-bold -ml-2" style={{ fontSize: '11px' }}></i>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* FOOTER ACTION BUTTONS & SETTINGS */}
                    <div
                        className="flex flex-wrap align-items-center justify-content-end gap-3 mt-4 pt-3 border-top-1 surface-border"
                        style={{ padding: '1rem 0 0.5rem 0' }}
                    >
                        <Button
                            label="Simpan Pengaturan Nomor Klinik"
                            icon="pi pi-check"
                            severity="success"
                            onClick={handleSaveConfig}
                            loading={saving || loadingConfig}
                            className="font-bold px-4 border-round-lg shadow-2"
                            style={{ height: '44px' }}
                        />
                        <Button
                            icon="pi pi-cog"
                            severity="success"
                            rounded
                            tooltip="Pengaturan Tampilan & Tema"
                            tooltipOptions={{ position: 'top' }}
                            onClick={() => {
                                const btn = document.querySelector('.layout-config-button') as HTMLButtonElement;
                                if (btn) {
                                    btn.click();
                                }
                            }}
                            className="shadow-2 p-button-rounded"
                            style={{ width: '44px', height: '44px', minWidth: '44px' }}
                        />
                    </div>
                </div>
            </div>

            {/* MODAL UJI COBA PENGIRIMAN PESAN WHATSAPP */}
            <Dialog
                header="Uji Coba Pengiriman Pesan WhatsApp OTP"
                visible={showTestDialog}
                style={{ width: '90vw', maxWidth: '480px' }}
                onHide={() => setShowTestDialog(false)}
                footer={
                    <div className="flex justify-content-end gap-2">
                        <Button label="Batal" severity="secondary" text onClick={() => setShowTestDialog(false)} />
                        <Button
                            label="Kirim Pesan Uji Coba Sekarang"
                            icon="pi pi-send"
                            severity="success"
                            onClick={handleSendTestMessage}
                            loading={testSending}
                            className="font-bold"
                        />
                    </div>
                }
            >
                <div className="p-fluid">
                    <p className="text-600 text-sm mb-3">
                        Kirimkan pesan uji coba langsung ke nomor WhatsApp Anda untuk memverifikasi bahwa bot pengirim berjalan dengan baik.
                    </p>
                    <div className="mb-4">
                        <label className="font-bold text-800 text-sm block mb-2">
                            Nomor WhatsApp Tujuan Uji Coba*
                        </label>
                        <div className="relative w-full flex align-items-center">
                            <i
                                className="pi pi-phone text-primary text-lg absolute"
                                style={{ left: '1rem', top: '50%', transform: 'translateY(-50%)', zIndex: 2, pointerEvents: 'none' }}
                            />
                            <InputText
                                value={testPhone}
                                onChange={(e) => setTestPhone(e.target.value)}
                                placeholder="Contoh: 081335086375"
                                className="w-full font-bold"
                                style={{ paddingLeft: '2.85rem', height: '44px', borderRadius: '8px' }}
                            />
                        </div>
                        <small className="text-xs mt-2 block line-height-2" style={{ color: '#64748b' }}>
                            Gunakan format 08... atau 628...
                        </small>
                    </div>

                    <div className="bg-blue-50 border-1 border-blue-200 border-round-lg p-3 text-blue-900 text-xs">
                        <i className="pi pi-info-circle mr-2 font-bold"></i>
                        Pesan akan dikirim langsung menggunakan WhatsApp Bot klinik (nomor bot aktif: <strong>+{waStatus.connectedNumber || 'Belum Terhubung'}</strong>).
                    </div>
                </div>
            </Dialog>

            <style jsx global>{`
                /* Sembunyikan fixed floating layout-config-button saat di halaman ini agar digantikan oleh tombol settings terpadu di footer */
                .layout-config-button {
                    display: none !important;
                }
            `}</style>
        </div>
    );
}
