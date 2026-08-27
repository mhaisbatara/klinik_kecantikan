'use client';

import React, { useState, useEffect } from 'react';
import { Button } from 'primereact/button';
import { confirmDialog, ConfirmDialog } from 'primereact/confirmdialog';
import { Tag } from 'primereact/tag';
import { Dropdown } from 'primereact/dropdown';
import { ProgressSpinner } from 'primereact/progressspinner';
import { Toast } from 'primereact/toast';
import { AntrianLayananData, State } from './interfaces';
import postData from '@/lib/axios/postData';
import { showError, showSuccess } from '@/lib/tools/generalTools';
import { apiEndpointPanggil, apiEndpointReset, apiEndpointData } from './endpoints';
import { getTzUser } from '@/lib/tools/dateTools';
import { DialogManageFormRuangan } from './DialogManageFormRuangan';
import { DialogIsiFormPenanganan } from './DialogIsiFormPenanganan';
import { ActiveTreatmentPanel } from './ActiveTreatmentPanel';

interface PanelAntrianRuanganProps {
    state: State;
    setState: React.Dispatch<React.SetStateAction<State>>;
    toast: React.RefObject<Toast>;
    getGridData: () => void;
    initialRuangan?: string;
}

interface RuanganItem {
    kode_ruangan: string;
    nama_ruangan: string;
    is_konsultasi?: number;
}

// ─── Audio Chime ─────────────────────────────────────────────────────────────
const playChime = () => {
    try {
        const AudioCtx = window.AudioContext || (window as any).webkitAudioContext;
        if (!AudioCtx) return;
        const ctx = new AudioCtx();
        const notes = [523.25, 659.25]; // C5 → E5
        notes.forEach((freq, i) => {
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.type = 'sine';
            osc.frequency.value = freq;
            const t = ctx.currentTime + i * 0.4;
            gain.gain.setValueAtTime(0, t);
            gain.gain.linearRampToValueAtTime(0.45, t + 0.05);
            gain.gain.linearRampToValueAtTime(0, t + 0.45);
            osc.start(t);
            osc.stop(t + 0.5);
        });
    } catch (_) {
        console.warn('AudioContext tidak tersedia');
    }
};

// ─── TTS Panggilan Suara ─────────────────────────────────────────────────────
const speakNomorLayanan = (noAntrian: string, namaPasien?: string, namaRuangan?: string) => {
    try {
        if (!('speechSynthesis' in window)) return;
        window.speechSynthesis.cancel();

        let teks = `Nomor antrian ${noAntrian}`;
        if (namaPasien && namaPasien !== '-') {
            teks += `, ${namaPasien}`;
        }
        if (namaRuangan && namaRuangan !== '-') {
            teks += `, silakan menuju ke ${namaRuangan}`;
        } else {
            teks += `, silakan menuju ke ruang tindakan`;
        }

        const utter = new SpeechSynthesisUtterance(teks);
        utter.lang = 'id-ID';
        utter.rate = 0.85;
        utter.pitch = 1.05;
        utter.volume = 1;

        const speak = () => {
            const voices = window.speechSynthesis.getVoices();
            const idVoice = voices.find((v) => v.lang === 'id-ID' || v.lang.startsWith('id'));
            if (idVoice) utter.voice = idVoice;
            window.speechSynthesis.speak(utter);
        };

        if (window.speechSynthesis.getVoices().length > 0) {
            setTimeout(speak, 900);
        } else {
            window.speechSynthesis.onvoiceschanged = () => {
                setTimeout(speak, 900);
            };
        }
    } catch (_) {
        console.warn('TTS Error');
    }
};

const STATUS_CONFIG: Record<string, { bg: string; border: string; color: string; shadow: string; cursor: string; label: string }> = {
    menunggu: {
        bg: 'linear-gradient(135deg, #fef9c3, #fde68a)',
        border: '#f59e0b', color: '#92400e',
        shadow: '0 4px 12px rgba(245,158,11,0.25)', cursor: 'pointer', label: '⏳ Menunggu'
    },
    dipanggil: {
        bg: 'linear-gradient(135deg, #dbeafe, #bfdbfe)',
        border: '#2563eb', color: '#1e40af',
        shadow: '0 4px 14px rgba(37,99,235,0.35)', cursor: 'pointer', label: '📢 Dipanggil'
    },
    selesai: {
        bg: 'linear-gradient(135deg, #dcfce7, #bbf7d0)',
        border: '#16a34a', color: '#14532d',
        shadow: '0 2px 8px rgba(22,163,74,0.15)', cursor: 'default', label: '✅ Selesai'
    },
    batal: {
        bg: 'linear-gradient(135deg, #fee2e2, #fca5a5)',
        border: '#dc2626', color: '#7f1d1d',
        shadow: '0 2px 8px rgba(220,38,38,0.15)', cursor: 'default', label: '❌ Batal'
    },
};

const NEXT_AKSI: Record<string, { aksi: string; label: string; pesan: string }> = {
    menunggu: { aksi: 'dipanggil', label: 'Panggil ke Ruangan', pesan: 'Panggil pasien ini ke ruang tindakan?' },
    dipanggil: { aksi: 'selesai', label: 'Selesaikan Tindakan', pesan: 'Tandai tindakan di ruangan ini selesai?' },
};

export const PanelAntrianRuangan: React.FC<PanelAntrianRuanganProps> = ({
    state,
    setState,
    toast,
    getGridData,
    initialRuangan,
}) => {
    const [ruanganList, setRuanganList] = useState<RuanganItem[]>([]);
    const [selectedRuangan, setSelectedRuangan] = useState<string>('');
    const [loadingRuangan, setLoadingRuangan] = useState<boolean>(true);
    const [statusFilter, setStatusFilter] = useState<string>('');

    // State for Custom Form Dialogs
    const [manageFormVisible, setManageFormVisible] = useState<boolean>(false);
    const [isiFormVisible, setIsiFormVisible] = useState<boolean>(false);
    const [selectedAntrianForForm, setSelectedAntrianForForm] = useState<AntrianLayananData | null>(null);

    useEffect(() => {
        loadRuangan();
    }, [initialRuangan]);

    const loadRuangan = async () => {
        setLoadingRuangan(true);
        try {
            const res = await postData('/master/ruangan-dropdown', {});
            const list: RuanganItem[] = res.data.data || [];
            setRuanganList(list);
            // Jika ada initialRuangan dari URL, gunakan itu; jika tidak, gunakan ruangan pertama
            if (initialRuangan && list.some((r) => r.kode_ruangan === initialRuangan)) {
                setSelectedRuangan(initialRuangan);
            } else if (list.length > 0) {
                setSelectedRuangan(list[0].kode_ruangan);
            }
        } catch (error) {
            showError(toast, 'Gagal memuat daftar ruangan');
        } finally {
            setLoadingRuangan(false);
        }
    };

    const handleAksi = (item: AntrianLayananData, customAksi?: string) => {
        const nextCfg = NEXT_AKSI[item.status];
        const targetAksi = customAksi || nextCfg?.aksi;
        if (!targetAksi) return;

        const isDipanggil = targetAksi === 'dipanggil';
        const isBatal = targetAksi === 'batal';

        confirmDialog({
            message: customAksi === 'batal'
                ? `Batalkan antrean #${item.nomor_antrian} untuk pasien ${item.nama_pasien || ''}?`
                : (nextCfg?.pesan || 'Lanjutkan aksi?'),
            header: isDipanggil ? '📢 Panggil ke Ruangan' : isBatal ? '❌ Batalkan Antrean' : 'Konfirmasi Aksi',
            icon: isDipanggil ? 'pi pi-megaphone' : isBatal ? 'pi pi-times-circle' : 'pi pi-exclamation-triangle',
            acceptLabel: isDipanggil ? 'Panggil Sekarang' : isBatal ? 'Ya, Batalkan' : 'Ya, Lanjutkan',
            rejectLabel: 'Batal',
            acceptClassName: isBatal ? 'p-button-danger' : 'p-button-primary',
            accept: async () => {
                try {
                    const res = await postData(apiEndpointPanggil, {
                        kode_antrian_layanan: item.kode_antrian_layanan,
                        aksi: targetAksi,
                        status: targetAksi,
                        tz: getTzUser(),
                    });
                    showSuccess(toast, res.data.message || 'Status antrean berhasil diperbarui');
                    getGridData();

                    if (isDipanggil) {
                        playChime();
                        speakNomorLayanan(item.nomor_antrian, item.nama_pasien, item.nama_ruangan || item.nama_layanan);
                    }
                } catch (error: any) {
                    showError(toast, error?.response?.data?.message || 'Gagal mengubah status antrean');
                }
            },
        });
    };

    // Filter gridData based on selected room and status filter
    const allGridData = state.gridData || [];
    const activeRoomObj = ruanganList.find((r) => r.kode_ruangan === selectedRuangan);

    const roomFilteredItems = allGridData.filter((item) => {
        const matchRoom = selectedRuangan
            ? (item.kode_ruangan === selectedRuangan || (!item.kode_ruangan && selectedRuangan === ruanganList[0]?.kode_ruangan))
            : true;
        const matchStatus = statusFilter ? item.status === statusFilter : true;
        return matchRoom && matchStatus;
    });

    // Patient currently called ('dipanggil') in room or selected for inspection
    const activeDipanggilPatient = roomFilteredItems.find((i) => i.status === 'dipanggil')
        || (selectedAntrianForForm && selectedAntrianForForm.kode_ruangan === selectedRuangan ? selectedAntrianForForm : null);

    // Next waiting patient in room
    const nextWaitingPatient = roomFilteredItems.find((i) => i.status === 'menunggu') || null;

    const mCount = roomFilteredItems.filter((i) => i.status === 'menunggu').length;
    const pCount = roomFilteredItems.filter((i) => i.status === 'dipanggil').length;
    const sCount = roomFilteredItems.filter((i) => i.status === 'selesai').length;
    const bCount = roomFilteredItems.filter((i) => i.status === 'batal').length;

    return (
        <div>
            <ConfirmDialog />

            {/* HEADER RUANGAN CARD SELECTOR — hanya tampil jika TIDAK dari sidebar */}
            {!initialRuangan && (
            <div className="card shadow-1 border-round-xl p-4 mb-4 surface-card">
                <div className="flex flex-column md:flex-row align-items-start md:align-items-center justify-content-between gap-3 mb-3 border-bottom-1 surface-border pb-3">
                    <div>
                        <h4 className="text-xl font-bold text-900 m-0 flex align-items-center gap-2">
                            <i className="pi pi-building text-teal-600 text-2xl" />
                            Antrean per Ruangan Tindakan
                        </h4>
                        <p className="text-500 text-xs m-0 mt-1">
                            Pilih salah satu ruangan di bawah ini untuk melihat dan memanggil nomor antrean di ruangan tersebut.
                        </p>
                    </div>

                    <Button
                        label="Refresh Data"
                        icon="pi pi-refresh"
                        outlined
                        size="small"
                        severity="secondary"
                        onClick={getGridData}
                        loading={state.loadGrid}
                    />
                </div>

                {loadingRuangan ? (
                    <div className="flex align-items-center justify-content-center py-4">
                        <ProgressSpinner style={{ width: '35px', height: '35px' }} />
                        <span className="ml-2 text-sm text-500">Memuat daftar ruangan...</span>
                    </div>
                ) : (
                    <div className="grid">
                        {ruanganList.map((ruang) => {
                            const isSelected = ruang.kode_ruangan === selectedRuangan;
                            const roomItems = allGridData.filter((i) => i.kode_ruangan === ruang.kode_ruangan);
                            const totalRuang = roomItems.length;
                            const mRuang = roomItems.filter((i) => i.status === 'menunggu').length;
                            const pRuang = roomItems.filter((i) => i.status === 'dipanggil').length;

                            return (
                                <div key={ruang.kode_ruangan} className="col-12 sm:col-6 md:col-4 lg:col-3">
                                    <div
                                        className={`p-3 border-round-xl border-2 cursor-pointer transition-all transition-duration-200 ${
                                            isSelected
                                                ? 'border-teal-500 bg-teal-50 shadow-3'
                                                : 'surface-border surface-card hover:border-300 shadow-1'
                                        }`}
                                        onClick={() => setSelectedRuangan(ruang.kode_ruangan)}
                                    >
                                        <div className="flex align-items-center justify-content-between mb-2">
                                            <Tag value={ruang.kode_ruangan} severity={isSelected ? 'success' : 'info'} className="text-xs font-bold" />
                                            {totalRuang > 0 && (
                                                <span className="text-xs font-bold text-teal-700 bg-teal-100 px-2 py-1 border-round-md">
                                                    {totalRuang} Antrean
                                                </span>
                                            )}
                                        </div>

                                        <h4 className="font-extrabold text-base text-900 m-0 mb-2 flex align-items-center gap-2">
                                            <i className="pi pi-home text-teal-600" />
                                            {ruang.nama_ruangan}
                                        </h4>

                                        <div className="flex align-items-center gap-2 text-xs">
                                            <span className="text-amber-700 font-semibold">⏳ Menunggu: {mRuang}</span>
                                            <span className="text-blue-700 font-semibold">📢 Call: {pRuang}</span>
                                        </div>
                                    </div>
                                </div>
                            );
                        })}
                    </div>
                )}
            </div>
            )}

            {/* DETAIL ANTREAN UNTUK RUANGAN TERPILIH */}
            {selectedRuangan && (
                <div className="flex flex-column gap-4">
                    {/* 1. DAFTAR KARTU NOMOR ANTREAN PASIEN RUANGAN */}
                    <div className="card shadow-1 border-round-xl p-4 surface-card border-top-3 border-teal-500 mb-0">
                        <div className="flex flex-column gap-3 mb-4 border-bottom-1 surface-border pb-3">
                            {/* ROW 1: TITLE & ACTION BUTTONS */}
                            <div className="flex flex-column sm:flex-row align-items-start sm:align-items-center justify-content-between gap-3">
                                <div>
                                    <span className="text-xs text-500 font-medium block uppercase tracking-wider mb-1">
                                        {initialRuangan ? 'Layanan Ruangan' : 'Ruangan Terpilih'}
                                    </span>
                                    <h3 className="text-2xl font-extrabold text-teal-900 m-0 flex align-items-center gap-2">
                                        <i className="pi pi-building text-teal-600 text-2xl" />
                                        {activeRoomObj ? activeRoomObj.nama_ruangan : selectedRuangan}
                                    </h3>
                                </div>

                                <div className="flex align-items-center gap-2">
                                    <Button
                                        label="Pengaturan Form Ruangan"
                                        icon="pi pi-cog"
                                        outlined
                                        size="small"
                                        severity="help"
                                        className="font-bold text-xs border-round-lg"
                                        onClick={() => setManageFormVisible(true)}
                                    />
                                    <Button
                                        label="Refresh Data"
                                        icon="pi pi-refresh"
                                        outlined
                                        size="small"
                                        severity="secondary"
                                        className="font-bold text-xs border-round-lg"
                                        onClick={getGridData}
                                        loading={state.loadGrid}
                                    />
                                </div>
                            </div>

                            {/* ROW 2: FILTER DROPDOWN & STATUS BADGES */}
                            <div className="flex flex-column lg:flex-row align-items-start lg:align-items-center justify-content-between gap-3 pt-1">
                                <Dropdown
                                    value={statusFilter}
                                    options={[
                                        { label: 'Semua Status', value: '' },
                                        { label: '⏳ Menunggu', value: 'menunggu' },
                                        { label: '📢 Dipanggil', value: 'dipanggil' },
                                        { label: '✅ Selesai', value: 'selesai' },
                                        { label: '❌ Batal', value: 'batal' },
                                    ]}
                                    onChange={(e) => setStatusFilter(e.value)}
                                    placeholder="Filter Status"
                                    className="p-inputtext-sm w-full sm:w-14rem border-round-lg"
                                />

                                <div className="flex gap-2 flex-wrap align-items-center">
                                    {[
                                        { color: '#d97706', bg: '#fef3c7', border: '#fde68a', iconBg: '#f59e0b', label: 'Menunggu',  count: mCount },
                                        { color: '#2563eb', bg: '#dbeafe', border: '#bfdbfe', iconBg: '#3b82f6', label: 'Dipanggil', count: pCount },
                                        { color: '#16a34a', bg: '#dcfce7', border: '#86efac', iconBg: '#22c55e', label: 'Selesai',   count: sCount },
                                        { color: '#dc2626', bg: '#fee2e2', border: '#fca5a5', iconBg: '#ef4444', label: 'Batal',     count: bCount },
                                        { color: '#4b5563', bg: '#f3f4f6', border: '#d1d5db', iconBg: '#6b7280', label: 'Total',     count: roomFilteredItems.length },
                                    ].map((item) => (
                                        <div
                                            key={item.label}
                                            className="flex align-items-center gap-2 px-3.5 border-round-md text-xs font-bold shadow-1 cursor-default"
                                            style={{
                                                backgroundColor: item.bg,
                                                border: `1px solid ${item.border}`,
                                                color: item.color,
                                                height: '28px',
                                            }}
                                        >
                                            <span
                                                style={{
                                                    display: 'inline-block',
                                                    width: '13px',
                                                    height: '13px',
                                                    borderRadius: '3.5px',
                                                    backgroundColor: item.iconBg,
                                                    flexShrink: 0,
                                                    boxShadow: `0 1px 2px ${item.iconBg}44`,
                                                }}
                                            />
                                            <span style={{ fontSize: '0.75rem', lineHeight: '1' }}>
                                                {item.label}: <strong className="text-xs font-black">{item.count}</strong>
                                            </span>
                                        </div>
                                    ))}
                                </div>
                            </div>

                            {/* BARIS KETERANGAN STATUS LEGEND */}
                            <div className="flex align-items-center gap-3 px-3 py-2 border-round-lg surface-100 text-600 text-xs font-semibold flex-wrap border-1 surface-border mt-3">
                                <span className="flex align-items-center gap-1 text-700 font-extrabold uppercase tracking-wider" style={{ fontSize: '0.7rem' }}>
                                    <i className="pi pi-info-circle text-teal-600 text-xs" />
                                    KETERANGAN STATUS:
                                </span>
                                <span className="flex align-items-center gap-1.5" style={{ fontSize: '0.7rem' }}>
                                    <span style={{ width: '10px', height: '10px', borderRadius: '3px', backgroundColor: '#f59e0b', display: 'inline-block' }} />
                                    <span className="text-600 font-medium">Menunggu = klik kartu untuk panggil</span>
                                </span>
                                <span className="flex align-items-center gap-1.5" style={{ fontSize: '0.7rem' }}>
                                    <span style={{ width: '10px', height: '10px', borderRadius: '3px', backgroundColor: '#3b82f6', display: 'inline-block' }} />
                                    <span className="text-600 font-medium">Dipanggil = pasien sedang ditangani</span>
                                </span>
                                <span className="flex align-items-center gap-1.5" style={{ fontSize: '0.7rem' }}>
                                    <span style={{ width: '10px', height: '10px', borderRadius: '3px', backgroundColor: '#22c55e', display: 'inline-block' }} />
                                    <span className="text-600 font-medium">Selesai = tindakan selesai</span>
                                </span>
                                <span className="flex align-items-center gap-1.5" style={{ fontSize: '0.7rem' }}>
                                    <span style={{ width: '10px', height: '10px', borderRadius: '3px', backgroundColor: '#ef4444', display: 'inline-block' }} />
                                    <span className="text-600 font-medium">Batal = antrean dibatalkan</span>
                                </span>
                            </div>
                        </div>

                        {roomFilteredItems.length === 0 ? (
                            <div className="text-center py-6 text-500 border-1 border-dashed border-round-xl surface-50">
                                <i className="pi pi-inbox text-5xl mb-3 text-400 block" />
                                <p className="font-bold text-base m-0 text-700">Belum Ada Nomor Antrean pada Ruangan Ini</p>
                                <p className="text-xs text-500 m-0 mt-1">Nomor antrean yang didaftarkan ke ruangan ini akan muncul di sini secara otomatis.</p>
                            </div>
                        ) : (
                            <div
                                style={{
                                    display: 'grid',
                                    gridTemplateColumns: 'repeat(auto-fill, minmax(210px, 1fr))',
                                    gap: '14px',
                                }}
                            >
                                {roomFilteredItems.map((item) => {
                                    const cfg = STATUS_CONFIG[item.status] || STATUS_CONFIG.menunggu;
                                    const isDipanggil = item.status === 'dipanggil';
                                    const isPaket = item.jenis_layanan === 'paket';

                                    return (
                                        <div key={item.kode_antrian_layanan} style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
                                            <button
                                                onClick={() => {
                                                    if (item.status === 'menunggu') {
                                                        handleAksi(item, 'dipanggil');
                                                    } else {
                                                        setSelectedAntrianForForm(item);
                                                    }
                                                }}
                                                title={`No. ${item.nomor_antrian} — ${item.nama_pasien} (${item.nama_layanan})`}
                                                style={{
                                                    minHeight: '140px',
                                                    borderRadius: '14px',
                                                    border: `2px solid ${cfg.border}`,
                                                    background: cfg.bg,
                                                    color: cfg.color,
                                                    cursor: 'pointer',
                                                    transition: 'all 0.2s cubic-bezier(0.4, 0, 0.2, 1)',
                                                    boxShadow: cfg.shadow,
                                                    display: 'flex',
                                                    flexDirection: 'column',
                                                    alignItems: 'center',
                                                    justifyContent: 'center',
                                                    padding: '12px 10px',
                                                    textAlign: 'center',
                                                    width: '100%',
                                                    position: 'relative',
                                                    overflow: 'hidden',
                                                }}
                                                onMouseEnter={(e) => {
                                                    (e.currentTarget as HTMLButtonElement).style.transform = 'translateY(-4px)';
                                                }}
                                                onMouseLeave={(e) => {
                                                    (e.currentTarget as HTMLButtonElement).style.transform = 'translateY(0)';
                                                }}
                                            >
                                                <div className="text-3xl font-black mb-1" style={{ lineHeight: 1 }}>
                                                    {item.nomor_antrian}
                                                </div>
                                                <div className="text-xs font-bold text-truncate w-full px-1 mb-1" title={item.nama_pasien}>
                                                    {item.nama_pasien || '-'}
                                                </div>

                                                <div
                                                    className="text-xs font-semibold px-2 py-1 border-round-md mb-1 text-truncate w-full"
                                                    style={{
                                                        background: 'rgba(255,255,255,0.85)',
                                                        color: cfg.color,
                                                        border: `1px solid ${cfg.border}44`,
                                                    }}
                                                    title={item.nama_layanan}
                                                >
                                                    {isPaket ? '📦 ' : '💆 '} {item.nama_layanan || '-'}
                                                </div>

                                                <div className="mt-1">
                                                    <span
                                                        style={{
                                                            fontSize: '0.7rem',
                                                            fontWeight: 'bold',
                                                            padding: '2px 8px',
                                                            borderRadius: '10px',
                                                            background: 'rgba(255,255,255,0.75)',
                                                            color: cfg.color,
                                                            border: `1px solid ${cfg.border}44`,
                                                        }}
                                                    >
                                                        {cfg.label}
                                                    </span>
                                                </div>
                                            </button>

                                            {isDipanggil && (
                                                <button
                                                    onClick={() => {
                                                        playChime();
                                                        speakNomorLayanan(item.nomor_antrian, item.nama_pasien, item.nama_ruangan || item.nama_layanan);
                                                    }}
                                                    title={`Panggil ulang antrean ${item.nomor_antrian}`}
                                                    style={{
                                                        padding: '6px 0',
                                                        fontSize: '0.75rem',
                                                        fontWeight: '700',
                                                        borderRadius: '8px',
                                                        border: '1.5px solid #2563eb',
                                                        background: '#eff6ff',
                                                        color: '#1d4ed8',
                                                        cursor: 'pointer',
                                                        transition: 'all 0.15s ease',
                                                        width: '100%',
                                                        display: 'flex',
                                                        alignItems: 'center',
                                                        justifyContent: 'center',
                                                        gap: '4px',
                                                    }}
                                                >
                                                    🔁 Panggil Ulang Suara
                                                </button>
                                            )}
                                        </div>
                                    );
                                })}
                            </div>
                        )}
                    </div>

                    {/* 2. PANEL PENANGANAN PASIEN AKTIF & FORM ISIAN (HANYA DITAMPILKAN DI MENU PANEL LAYANAN RUANGAN) */}
                    {Boolean(initialRuangan) && (() => {
                        const selectedRuanganObj = ruanganList.find(r => r.kode_ruangan === selectedRuangan);
                        const isKonsultasi = Boolean(selectedRuanganObj?.is_konsultasi);
                        return (
                            <ActiveTreatmentPanel
                                activePatient={activeDipanggilPatient}
                                nextWaitingPatient={nextWaitingPatient}
                                kodeRuangan={selectedRuangan}
                                namaRuangan={activeRoomObj?.nama_ruangan || selectedRuangan}
                                isKonsultasi={isKonsultasi}
                                toast={toast}
                                getGridData={getGridData}
                                handleAksi={handleAksi}
                                playChime={playChime}
                                speakNomorLayanan={speakNomorLayanan}
                                onManageFormClick={() => setManageFormVisible(true)}
                            />
                        );
                    })()}
                </div>
            )}

            {/* DIALOG PENGATURAN FORM CUSTOM RUANGAN */}
            <DialogManageFormRuangan
                visible={manageFormVisible}
                onHide={() => setManageFormVisible(false)}
                kodeRuangan={selectedRuangan}
                namaRuangan={activeRoomObj?.nama_ruangan || selectedRuangan}
                toast={toast}
            />

            {/* DIALOG ISIAN FORM PENANGANAN PASIEN & CATATAN */}
            <DialogIsiFormPenanganan
                visible={isiFormVisible}
                onHide={() => setIsiFormVisible(false)}
                antrianData={selectedAntrianForForm}
                isKonsultasi={Boolean(ruanganList.find(r => r.kode_ruangan === selectedRuangan)?.is_konsultasi)}
                toast={toast}
                getGridData={getGridData}
            />
        </div>
    );
};
