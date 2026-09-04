import React, { useState, useEffect } from 'react';
import { useSearchParams } from 'next/navigation';
import { Button } from 'primereact/button';
import { confirmDialog, ConfirmDialog } from 'primereact/confirmdialog';
import { Tag } from 'primereact/tag';
import { Dropdown } from 'primereact/dropdown';
import { InputText } from 'primereact/inputtext';
import { IconField } from 'primereact/iconfield';
import { InputIcon } from 'primereact/inputicon';
import { DataTable } from 'primereact/datatable';
import { Column } from 'primereact/column';
import { Paginator, PaginatorPageChangeEvent } from 'primereact/paginator';
import { ProgressSpinner } from 'primereact/progressspinner';
import { Toast } from 'primereact/toast';
import { AntrianLayananData, State } from './interfaces';
import postData from '@/lib/axios/postData';
import { showError, showSuccess } from '@/lib/tools/generalTools';
import { apiEndpointPanggil, apiEndpointReset, apiEndpointData } from './endpoints';
import { getTzUser } from '@/lib/tools/dateTools';
import { ActiveTreatmentPanel } from './ActiveTreatmentPanel';
import { DrawerRiwayatPasien } from './DrawerRiwayatPasien';

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
    const [queueSearch, setQueueSearch] = useState<string>('');
    const [cardFirst, setCardFirst] = useState<number>(0);
    const [cardRows, setCardRows] = useState<number>(12);
    const [petugasJaga, setPetugasJaga] = useState<any[]>([]);

    useEffect(() => {
        setCardFirst(0);
    }, [selectedRuangan, statusFilter, queueSearch]);

    const [selectedPetugasJaga, setSelectedPetugasJaga] = useState<string>('');

    const loadPetugasJaga = async (kodeRuangan: string) => {
        try {
            const days = ['minggu', 'senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu'];
            const todayStr = days[new Date().getDay()];
            const res = await postData('/master/jadwal-karyawan-data', {
                kode_ruangan: kodeRuangan,
                hari: todayStr,
                status: 'aktif',
            });
            const list = res.data?.data || [];
            setPetugasJaga(list);
            if (list.length > 0) {
                setSelectedPetugasJaga(list[0].nama_karyawan);
            } else {
                setSelectedPetugasJaga('');
            }
        } catch (_) {
            setPetugasJaga([]);
            setSelectedPetugasJaga('');
        }
    };

    useEffect(() => {
        if (selectedRuangan) {
            loadPetugasJaga(selectedRuangan);
        }
    }, [selectedRuangan]);

    const [drawerRiwayatVisible, setDrawerRiwayatVisible] = useState<boolean>(false);
    const [selectedPatientForRiwayat, setSelectedPatientForRiwayat] = useState<AntrianLayananData | null>(null);

    const searchParams = useSearchParams();
    const typeParam = searchParams.get('type') || '';

    useEffect(() => {
        loadRuangan();
    }, [initialRuangan, typeParam]);

    const loadRuangan = async () => {
        setLoadingRuangan(true);
        try {
            const res = await postData('/master/ruangan-dropdown', {});
            const rawList: RuanganItem[] = res.data.data || [];

            let list = rawList;
            if (typeParam === 'konsul') {
                list = rawList.filter(
                    (r) => r.is_konsultasi === 1 || (r.nama_ruangan && r.nama_ruangan.toLowerCase().includes('konsul'))
                );
            } else if (typeParam === 'layanan') {
                list = rawList.filter((r) => !r.is_konsultasi || r.is_konsultasi === 0);
            }

            setRuanganList(list);
            if (initialRuangan && list.some((r) => r.kode_ruangan === initialRuangan)) {
                setSelectedRuangan(initialRuangan);
            } else if (list.length > 0) {
                setSelectedRuangan(list[0].kode_ruangan);
            } else {
                setSelectedRuangan('');
            }
        } catch (error) {
            showError(toast, 'Gagal memuat daftar ruangan');
        } finally {
            setLoadingRuangan(false);
        }
    };

    const handleAksi = (item: AntrianLayananData, customAksi?: string, skipFormValidation: boolean = false) => {
        const nextCfg = NEXT_AKSI[item.status];
        const targetAksi = customAksi || nextCfg?.aksi;
        if (!targetAksi) return;

        // Validasi form hanya berlaku saat di menu Tindakan / Konsultasi
        if (isLayananOrKonsul && targetAksi === 'selesai' && !skipFormValidation && !item.hasil_form) {
            showError(toast, 'Tindakan tidak dapat diselesaikan! Harap isi dan simpan form penanganan pasien terlebih dahulu.');
            return;
        }

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

    const [currentIndex, setCurrentIndex] = useState<number>(0);

    // Filter gridData based on selected room and search query
    const allGridData = state.gridData || [];
    const activeRoomObj = ruanganList.find((r) => r.kode_ruangan === selectedRuangan);
    const isKonsul = typeParam === 'konsul' || Boolean(activeRoomObj?.is_konsultasi);
    const isLayananOrKonsul = typeParam === 'layanan' || typeParam === 'konsul';

    // Base items for the room + search (for accurate pill count badges)
    const roomAllItems = allGridData.filter((item) => {
        const matchRoom = selectedRuangan
            ? (item.kode_ruangan === selectedRuangan || (!item.kode_ruangan && selectedRuangan === ruanganList[0]?.kode_ruangan))
            : true;
        const matchSearch = queueSearch
            ? (item.nama_pasien?.toLowerCase().includes(queueSearch.toLowerCase()) ||
               item.nomor_antrian?.toLowerCase().includes(queueSearch.toLowerCase()) ||
               item.no_rm?.toLowerCase().includes(queueSearch.toLowerCase()))
            : true;
        return matchRoom && matchSearch;
    });

    // Filtered by selected status pill
    const roomFilteredItems = roomAllItems.filter((item) => {
        return statusFilter ? item.status === statusFilter : true;
    });

    // Otomatis arahkan ke antrean pertama yang belum selesai (menunggu / dipanggil)
    useEffect(() => {
        if (roomFilteredItems.length > 0) {
            const firstUnfinishedIdx = roomFilteredItems.findIndex(
                (item) => item.status !== 'selesai' && item.status !== 'batal'
            );
            if (firstUnfinishedIdx !== -1) {
                setCurrentIndex(firstUnfinishedIdx);
            } else {
                setCurrentIndex(0);
            }
        } else {
            setCurrentIndex(0);
        }
    }, [selectedRuangan, statusFilter, queueSearch, state.gridData?.length]);

    const currentItem = roomFilteredItems[currentIndex] || roomFilteredItems[0] || null;

    const handleNextPatient = () => {
        if (currentIndex < roomFilteredItems.length - 1) {
            const nextIdx = currentIndex + 1;
            setCurrentIndex(nextIdx);
            const nextItem = roomFilteredItems[nextIdx];
            if (nextItem && nextItem.status === 'menunggu') {
                handleAksi(nextItem, 'dipanggil');
            }
        }
    };

    const handlePrevPatient = () => {
        if (currentIndex > 0) {
            setCurrentIndex(currentIndex - 1);
        }
    };

    const totalCount = roomAllItems.length;
    const mCount = roomAllItems.filter((i) => i.status === 'menunggu').length;
    const pCount = roomAllItems.filter((i) => i.status === 'dipanggil').length;
    const sCount = roomAllItems.filter((i) => i.status === 'selesai').length;
    const bCount = roomAllItems.filter((i) => i.status === 'batal').length;

    return (
        <div className="flex flex-column gap-3">
            <ConfirmDialog />

            {/* HEADER RUANGAN CARD SELECTOR — hanya tampil jika TIDAK dari sidebar spesifik */}
            {!initialRuangan && (
                <div className="surface-card border-round-xl border-1 surface-border shadow-1 p-3 md:p-4 mb-1">
                    <div className="flex flex-column sm:flex-row align-items-start sm:align-items-center justify-content-between gap-3 mb-3 pb-2 border-bottom-1 surface-border">
                        <div>
                            <h4 className="text-lg font-bold text-900 m-0 flex align-items-center gap-2">
                                <i className="pi pi-building text-teal-600" />
                                Ruangan Tindakan & Konsultasi
                            </h4>
                            <p className="text-500 text-xs m-0 mt-0.5">
                                Pilih ruangan untuk memantau dan memanggil nomor antrean pasien secara langsung.
                            </p>
                        </div>
                        <Button
                            label="Refresh"
                            icon="pi pi-refresh"
                            outlined
                            size="small"
                            severity="secondary"
                            onClick={getGridData}
                            loading={state.loadGrid}
                            className="font-semibold text-xs border-round-lg"
                        />
                    </div>

                    {loadingRuangan ? (
                        <div className="flex align-items-center justify-content-center py-4">
                            <ProgressSpinner style={{ width: '30px', height: '30px' }} />
                            <span className="ml-2 text-xs text-500">Memuat ruangan...</span>
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
                                            className={`p-3 border-round-xl border-2 cursor-pointer transition-all transition-duration-200 relative overflow-hidden ${
                                                isSelected
                                                    ? 'border-teal-500 bg-teal-50 shadow-2'
                                                    : 'surface-border surface-card hover:surface-50 shadow-1'
                                            }`}
                                            onClick={() => setSelectedRuangan(ruang.kode_ruangan)}
                                        >
                                            <div className="flex align-items-center justify-content-between mb-2">
                                                <Tag value={ruang.kode_ruangan} severity={isSelected ? 'success' : 'info'} className="text-xs font-bold" />
                                                {totalRuang > 0 && (
                                                    <span className="text-xs font-bold text-teal-700 bg-teal-100 px-2 py-0.5 border-round-md">
                                                        {totalRuang} Pasien
                                                    </span>
                                                )}
                                            </div>

                                            <h4 className="font-bold text-sm text-900 m-0 mb-2 flex align-items-center gap-1.5 text-truncate">
                                                <i className="pi pi-home text-teal-600 text-xs" />
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
                <div className="flex flex-column gap-3">
                    {/* CONTAINER UTAMA ANTREAN RUANGAN */}
                    <div className="surface-card border-round-xl border-1 surface-border shadow-1 p-3 md:p-4">
                        {/* ── HEADER RUANGAN TERPILIH & SEARCH TOOLBAR ── */}
                        <div className="flex flex-column md:flex-row align-items-start md:align-items-center justify-content-between gap-3 pb-3 border-bottom-1 surface-border">
                            <div>
                                <div className="flex align-items-center gap-2 mb-1">
                                    <Tag value={activeRoomObj?.kode_ruangan || selectedRuangan} severity="success" className="font-bold text-xs" />
                                    {selectedPetugasJaga && (
                                        <span className="text-xs text-600 font-medium flex align-items-center gap-1">
                                            <i className="pi pi-user text-teal-600 text-xs" />
                                            Petugas: <strong>{selectedPetugasJaga}</strong>
                                        </span>
                                    )}
                                </div>
                                <h3 className="text-2xl font-bold text-900 m-0 flex align-items-center gap-2">
                                    <i className="pi pi-building text-teal-600" />
                                    {activeRoomObj ? activeRoomObj.nama_ruangan : selectedRuangan}
                                </h3>
                            </div>

                            {/* SEARCH & RESET TOOLBAR (FORMAT PERSIS MASTER DATA) */}
                            <div className="flex align-items-center gap-2 w-full md:w-auto">
                                <IconField iconPosition="left" className="flex-1 md:w-18rem">
                                    <InputIcon className="pi pi-search" />
                                    <InputText
                                        value={queueSearch}
                                        onChange={(e) => setQueueSearch(e.target.value)}
                                        placeholder="Cari Data..."
                                        className="p-inputtext-sm w-full border-round-lg text-sm"
                                    />
                                </IconField>

                                <Button
                                    type="button"
                                    icon="pi pi-filter-slash"
                                    outlined
                                    severity="danger"
                                    tooltip="Reset Filter"
                                    tooltipOptions={{ position: 'bottom' }}
                                    className="border-round-lg flex-shrink-0"
                                    onClick={() => {
                                        setQueueSearch('');
                                        setStatusFilter('');
                                    }}
                                />

                                <Button
                                    type="button"
                                    icon="pi pi-refresh"
                                    outlined
                                    severity="success"
                                    tooltip="Refresh"
                                    tooltipOptions={{ position: 'bottom' }}
                                    className="border-round-lg flex-shrink-0"
                                    onClick={getGridData}
                                    loading={state.loadGrid}
                                />
                            </div>
                        </div>

                        {/* ── KETERANGAN STATUS (FORMAT & JARAK PERSIS MASTER DATA) ── */}
                        <div className="flex flex-wrap align-items-center gap-3 px-1 py-2 border-round-md surface-100 text-xs font-medium text-color-secondary mt-2">
                            <span className="flex align-items-center gap-1">
                                <i className="pi pi-info-circle" />
                                <span className="font-semibold">KETERANGAN STATUS:</span>
                            </span>

                            <span
                                className={`flex align-items-center gap-1 cursor-pointer transition-colors ${
                                    statusFilter === '' ? 'font-bold text-900' : 'hover:text-900'
                                }`}
                                onClick={() => setStatusFilter('')}
                            >
                                Semua ({totalCount})
                            </span>

                            <span
                                className={`flex align-items-center gap-1 cursor-pointer transition-colors ${
                                    statusFilter === 'menunggu' ? 'font-bold text-900' : 'hover:text-900'
                                }`}
                                onClick={() => setStatusFilter(statusFilter === 'menunggu' ? '' : 'menunggu')}
                            >
                                <span style={{ display: 'inline-block', width: '12px', height: '12px', borderRadius: '3px', backgroundColor: '#f59e0b', boxShadow: '0 1px 3px #f59e0b55' }} />
                                Menunggu ({mCount})
                            </span>

                            <span
                                className={`flex align-items-center gap-1 cursor-pointer transition-colors ${
                                    statusFilter === 'dipanggil' ? 'font-bold text-900' : 'hover:text-900'
                                }`}
                                onClick={() => setStatusFilter(statusFilter === 'dipanggil' ? '' : 'dipanggil')}
                            >
                                <span style={{ display: 'inline-block', width: '12px', height: '12px', borderRadius: '3px', backgroundColor: '#3b82f6', boxShadow: '0 1px 3px #3b82f655' }} />
                                Dipanggil ({pCount})
                            </span>

                            <span
                                className={`flex align-items-center gap-1 cursor-pointer transition-colors ${
                                    statusFilter === 'selesai' ? 'font-bold text-900' : 'hover:text-900'
                                }`}
                                onClick={() => setStatusFilter(statusFilter === 'selesai' ? '' : 'selesai')}
                            >
                                <span style={{ display: 'inline-block', width: '12px', height: '12px', borderRadius: '3px', backgroundColor: '#22c55e', boxShadow: '0 1px 3px #22c55e55' }} />
                                Selesai ({sCount})
                            </span>

                            {bCount > 0 && (
                                <span
                                    className={`flex align-items-center gap-1 cursor-pointer transition-colors ${
                                        statusFilter === 'batal' ? 'font-bold text-900' : 'hover:text-900'
                                    }`}
                                    onClick={() => setStatusFilter(statusFilter === 'batal' ? '' : 'batal')}
                                >
                                    <span style={{ display: 'inline-block', width: '12px', height: '12px', borderRadius: '3px', backgroundColor: '#ef4444', boxShadow: '0 1px 3px #ef444455' }} />
                                    Batal ({bCount})
                                </span>
                            )}
                        </div>

                        {/* ── WORKSPACE 2 KOLOM (SEJAJAR DI DESKTOP: SPOTLIGHT DI KIRI + TABEL ANTREAN DI KANAN) ── */}
                        <div className="grid pt-4">
                            {/* KOLOM 1: SPOTLIGHT KARTU PANGGILAN ANTREAN (KIRI) */}
                            <div className="col-12 lg:col-5 xl:col-5">
                                {!currentItem ? (
                                    <div className="flex flex-column align-items-center justify-content-center text-center p-6 border-round-xl surface-50 border-1 border-dashed surface-border" style={{ height: '480px' }}>
                                        <i className="pi pi-inbox text-5xl text-400 mb-3 block" />
                                        <h4 className="text-base font-bold text-700 m-0">Tidak Ada Antrean pada Kriteria Ini</h4>
                                        <p className="text-xs text-500 m-0 mt-1 max-w-20rem">
                                            Nomor antrean yang didaftarkan ke ruangan ini akan muncul secara otomatis di panel ini.
                                        </p>
                                    </div>
                                ) : (() => {
                                    const isDipanggil = currentItem.status === 'dipanggil';
                                    const isPaket = currentItem.jenis_layanan === 'paket';

                                    return (
                                        <div className="surface-50 border-round-xl border-1 surface-border p-3 flex flex-column shadow-1" style={{ height: '480px' }}>
                                            {/* Header Status & Sequence */}
                                            <div className="flex align-items-center justify-content-between gap-2 mb-2 flex-shrink-0">
                                                {currentItem.status === 'dipanggil' ? (
                                                    <Tag value="Sedang Dipanggil" icon="pi pi-volume-up" severity="info" className="font-bold text-xs px-3 py-1.5 border-round-pill" />
                                                ) : currentItem.status === 'menunggu' ? (
                                                    <Tag value="Menunggu Pemanggilan" icon="pi pi-clock" severity="warning" className="font-bold text-xs px-3 py-1.5 border-round-pill" />
                                                ) : currentItem.status === 'selesai' ? (
                                                    <Tag value="Tindakan Selesai" icon="pi pi-check-circle" severity="success" className="font-bold text-xs px-3 py-1.5 border-round-pill" />
                                                ) : (
                                                    <Tag value="Dibatalkan" icon="pi pi-times-circle" severity="danger" className="font-bold text-xs px-3 py-1.5 border-round-pill" />
                                                )}

                                                <span className="text-xs font-bold text-600 bg-white border-1 surface-border px-2.5 py-1 border-round-md">
                                                    Urutan {currentIndex + 1} dari {roomFilteredItems.length}
                                                </span>
                                            </div>

                                            {/* Antrean Info Card - Expands (flex-1) to fill middle space */}
                                            <div className="surface-card border-round-xl border-1 surface-border shadow-1 p-3 text-center flex-1 flex flex-column justify-content-center align-items-center my-1 overflow-hidden">
                                                <span className="text-xs font-bold text-500 uppercase tracking-widest block mb-1">
                                                    NOMOR ANTREAN
                                                </span>
                                                <div className="text-6xl sm:text-7xl font-black text-teal-700 my-1" style={{ lineHeight: 1 }}>
                                                    {currentItem.nomor_antrian}
                                                </div>

                                                <div className="text-2xl font-bold text-900 mt-2 mb-1 text-truncate px-2" title={currentItem.nama_pasien}>
                                                    {currentItem.nama_pasien || '-'}
                                                </div>

                                                <div className="flex flex-wrap align-items-center justify-content-center gap-2 text-xs text-600 mb-2">
                                                    {currentItem.no_rm && (
                                                        <span className="bg-surface-50 border-1 surface-border px-2 py-0.5 border-round">
                                                            No. RM: <strong>{currentItem.no_rm}</strong>
                                                        </span>
                                                    )}
                                                    {currentItem.jam_datang && (
                                                        <span className="bg-surface-50 border-1 surface-border px-2 py-0.5 border-round">
                                                            🕒 Datang: <strong>{currentItem.jam_datang}</strong>
                                                        </span>
                                                    )}
                                                </div>

                                                <Tag
                                                    value={`${isPaket ? 'Paket: ' : 'Layanan: '}${currentItem.nama_layanan || '-'}`}
                                                    icon={isPaket ? 'pi pi-box' : 'pi pi-sparkles'}
                                                    severity={isPaket ? 'warning' : 'info'}
                                                    className="font-bold text-xs px-3 py-1.5 border-round-pill max-w-full text-truncate"
                                                />
                                            </div>

                                            {/* Action Buttons Hub */}
                                            <div className="flex flex-column gap-2 flex-shrink-0 mt-1">
                                                {currentItem.status === 'menunggu' ? (
                                                    <Button
                                                        label="Panggil Pasien Ini"
                                                        icon="pi pi-megaphone"
                                                        size="large"
                                                        className="font-bold border-round-xl w-full py-3 text-base shadow-2 bg-teal-600 hover:bg-teal-700 border-none text-white"
                                                        onClick={() => handleAksi(currentItem, 'dipanggil')}
                                                    />
                                                ) : isDipanggil ? (
                                                    <div className="flex flex-column gap-2 w-full">
                                                        <Button
                                                            label="Selesaikan Penanganan"
                                                            icon="pi pi-check-circle"
                                                            severity="success"
                                                            size="large"
                                                            className="font-bold border-round-xl w-full py-3 text-base shadow-2"
                                                            onClick={() => handleAksi(currentItem, 'selesai')}
                                                        />

                                                        <div className="flex gap-2 w-full">
                                                            <Button
                                                                label="Panggil Ulang"
                                                                icon="pi pi-volume-up"
                                                                severity="info"
                                                                outlined
                                                                className="font-semibold border-round-lg flex-1 text-xs py-2"
                                                                onClick={() => {
                                                                    playChime();
                                                                    speakNomorLayanan(
                                                                        currentItem.nomor_antrian,
                                                                        currentItem.nama_pasien,
                                                                        currentItem.nama_ruangan || currentItem.nama_layanan
                                                                    );
                                                                }}
                                                            />
                                                            <Button
                                                                label="Batal"
                                                                icon="pi pi-times"
                                                                severity="danger"
                                                                outlined
                                                                className="font-semibold border-round-lg w-7rem text-xs py-2"
                                                                onClick={() => handleAksi(currentItem, 'batal')}
                                                            />
                                                        </div>
                                                    </div>
                                                ) : (
                                                    <div className="w-full">
                                                        {currentItem.status === 'selesai' ? (
                                                            <Button
                                                                label="Tindakan Selesai"
                                                                icon="pi pi-check-circle"
                                                                severity="success"
                                                                size="large"
                                                                className="font-bold border-round-xl w-full py-3 text-base shadow-1 pointer-events-none"
                                                            />
                                                        ) : (
                                                            <Button
                                                                label="Antrean Dibatalkan"
                                                                icon="pi pi-times-circle"
                                                                severity="danger"
                                                                size="large"
                                                                className="font-bold border-round-xl w-full py-3 text-base shadow-1 pointer-events-none"
                                                            />
                                                        )}
                                                    </div>
                                                )}

                                                {/* Navigator Prev / Next */}
                                                <div className="flex align-items-center justify-content-between gap-2 pt-2 border-top-1 surface-border">
                                                    <Button
                                                        label="Sebelumnya"
                                                        icon="pi pi-chevron-left"
                                                        outlined
                                                        size="small"
                                                        severity="secondary"
                                                        disabled={currentIndex === 0}
                                                        onClick={handlePrevPatient}
                                                        className="font-semibold border-round-lg text-xs"
                                                    />
                                                    <span className="text-xs text-600 font-bold">
                                                        {currentIndex + 1} dari {roomFilteredItems.length}
                                                    </span>
                                                    <Button
                                                        label="Berikutnya"
                                                        iconPos="right"
                                                        icon="pi pi-chevron-right"
                                                        outlined
                                                        size="small"
                                                        severity="secondary"
                                                        disabled={currentIndex >= roomFilteredItems.length - 1}
                                                        onClick={handleNextPatient}
                                                        className="font-semibold border-round-lg text-xs"
                                                    />
                                                </div>
                                            </div>
                                        </div>
                                    );
                                })()}
                            </div>

                            {/* KOLOM 2: DAFTAR SELURUH ANTREAN RUANGAN DALAM FORMAT TABEL MASTER DATA (KANAN) */}
                            <div className="col-12 lg:col-7 xl:col-7">
                                <div className="surface-card border-round-xl border-1 surface-border p-3 flex flex-column shadow-1" style={{ height: '480px' }}>
                                    {/* Table Top Header */}
                                    <div className="flex align-items-center justify-content-between mb-2 pb-2 border-bottom-1 surface-border flex-shrink-0">
                                        <span className="text-base font-bold text-900 flex align-items-center gap-2">
                                            <i className="pi pi-list text-teal-600" />
                                            Daftar Antrean Pasien
                                        </span>
                                    </div>

                                    {/* DATATABLE ANTREAN PASIEN DALAM WADAH FLEKSIBEL TERKUNCI */}
                                    <div className="flex-1 overflow-hidden flex flex-column">
                                        <DataTable
                                            value={roomFilteredItems}
                                            scrollable
                                            scrollHeight="flex"
                                            paginator
                                            rows={5}
                                            rowsPerPageOptions={[5, 10, 20]}
                                            className="p-datatable-sm text-xs flex-1 flex flex-column"
                                            emptyMessage="Data antrean tidak ditemukan."
                                        dataKey="kode_antrian_layanan"
                                        selectionMode="single"
                                        selection={currentItem}
                                        onSelectionChange={(e: any) => {
                                            if (e.value) {
                                                const idx = roomFilteredItems.findIndex((i) => i.kode_antrian_layanan === e.value.kode_antrian_layanan);
                                                if (idx !== -1) setCurrentIndex(idx);
                                            }
                                        }}
                                        rowClassName={(data) => ({
                                            'bg-teal-50 font-semibold cursor-pointer': data.kode_antrian_layanan === currentItem?.kode_antrian_layanan,
                                            'cursor-pointer': data.kode_antrian_layanan !== currentItem?.kode_antrian_layanan,
                                        })}
                                        paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                                        currentPageReportTemplate="Menampilkan {first} - {last} dari {totalRecords} data"
                                    >
                                        {/* Status Color Square Column */}
                                        <Column
                                            header=""
                                            headerStyle={{ width: '2.5rem' }}
                                            align="center"
                                            body={(r: AntrianLayananData) => {
                                                const color =
                                                    r.status === 'menunggu' ? '#f59e0b' :
                                                    r.status === 'dipanggil' ? '#3b82f6' :
                                                    r.status === 'selesai' ? '#22c55e' : '#ef4444';
                                                return (
                                                    <span
                                                        style={{
                                                            display: 'inline-block',
                                                            width: '12px',
                                                            height: '12px',
                                                            borderRadius: '3px',
                                                            backgroundColor: color,
                                                            boxShadow: `0 1px 3px ${color}55`,
                                                        }}
                                                        title={`Status: ${r.status}`}
                                                    />
                                                );
                                            }}
                                        />

                                        {/* Nomor Antrean Column */}
                                        <Column
                                            field="nomor_antrian"
                                            header="No. Antrean"
                                            sortable
                                            headerStyle={{ fontWeight: 'bold', width: '6.5rem' }}
                                            body={(r: AntrianLayananData) => (
                                                <span className="font-bold text-xs text-teal-800 bg-teal-100 px-2 py-0.5 border-round">
                                                    #{r.nomor_antrian}
                                                </span>
                                            )}
                                        />

                                        {/* Pasien Column */}
                                        <Column
                                            field="nama_pasien"
                                            header="Pasien"
                                            sortable
                                            headerStyle={{ fontWeight: 'bold' }}
                                            body={(r: AntrianLayananData) => (
                                                <div>
                                                    <div className="font-bold text-xs text-900">{r.nama_pasien || '-'}</div>
                                                    {r.no_rm && <div className="text-500 text-xs">RM: {r.no_rm}</div>}
                                                </div>
                                            )}
                                        />

                                        {/* Layanan Column */}
                                        <Column
                                            field="nama_layanan"
                                            header="Layanan / Tindakan"
                                            sortable
                                            headerStyle={{ fontWeight: 'bold' }}
                                            body={(r: AntrianLayananData) => {
                                                const isPaket = r.jenis_layanan === 'paket';
                                                return (
                                                    <div className="flex flex-column gap-0.5">
                                                        <span className="text-xs text-700">{r.nama_layanan || '-'}</span>
                                                        {isPaket && <Tag value="Paket" severity="warning" className="text-xs px-1.5 py-0" style={{ fontSize: '10px' }} />}
                                                    </div>
                                                );
                                            }}
                                        />

                                        {/* Status Tag Column */}
                                        <Column
                                            field="status"
                                            header="Status"
                                            sortable
                                            headerStyle={{ fontWeight: 'bold', width: '6.5rem' }}
                                            body={(r: AntrianLayananData) => {
                                                const sev =
                                                    r.status === 'menunggu' ? 'warning' :
                                                    r.status === 'dipanggil' ? 'info' :
                                                    r.status === 'selesai' ? 'success' : 'danger';
                                                const lbl =
                                                    r.status === 'menunggu' ? 'Menunggu' :
                                                    r.status === 'dipanggil' ? 'Dipanggil' :
                                                    r.status === 'selesai' ? 'Selesai' : 'Batal';
                                                return <Tag value={lbl} severity={sev} className="text-xs font-semibold px-2 py-0.5" />;
                                            }}
                                        />

                                        {/* Aksi Column */}
                                        <Column
                                            header="Aksi"
                                            align="center"
                                            headerStyle={{ width: '4.5rem', textAlign: 'center' }}
                                            body={(r: AntrianLayananData) => {
                                                const isSelected = r.kode_antrian_layanan === currentItem?.kode_antrian_layanan;
                                                return (
                                                    <Button
                                                        icon={isSelected ? "pi pi-check" : "pi pi-chevron-right"}
                                                        size="small"
                                                        outlined={!isSelected}
                                                        severity={isSelected ? undefined : "secondary"}
                                                        tooltip={isSelected ? "Sedang Ditampilkan" : "Pilih Antrean Ini"}
                                                        tooltipOptions={{ position: 'left' }}
                                                        className="p-button-sm border-round-md"
                                                        onClick={(e) => {
                                                            e.stopPropagation();
                                                            const idx = roomFilteredItems.findIndex((i) => i.kode_antrian_layanan === r.kode_antrian_layanan);
                                                            if (idx !== -1) setCurrentIndex(idx);
                                                        }}
                                                    />
                                                );
                                            }}
                                        />
                                    </DataTable>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                    {/* FORM PENANGANAN MEDIS & HASIL TREATMENT HANYA TAMPIL DI MENU TINDAKAN & KONSULTASI */}
                    {isLayananOrKonsul && Boolean(selectedRuangan) && (() => {
                        const selectedRuanganObj = ruanganList.find((r) => r.kode_ruangan === selectedRuangan);
                        const isRoomKonsul = Boolean(selectedRuanganObj?.is_konsultasi) || typeParam === 'konsul';
                        const activeDipanggilPatient =
                            roomFilteredItems.find((item) => item.status === 'dipanggil') ||
                            (currentItem?.status === 'dipanggil' ? currentItem : null);
                        const nextWaitingPatient = roomFilteredItems.find((item) => item.status === 'menunggu') || null;

                        return (
                            <ActiveTreatmentPanel
                                activePatient={activeDipanggilPatient}
                                nextWaitingPatient={nextWaitingPatient}
                                kodeRuangan={selectedRuangan}
                                namaRuangan={selectedRuanganObj?.nama_ruangan || selectedRuangan}
                                isKonsultasi={isRoomKonsul}
                                toast={toast}
                                getGridData={getGridData}
                                handleAksi={handleAksi}
                                playChime={playChime}
                                speakNomorLayanan={speakNomorLayanan}
                            />
                        );
                    })()}
                </div>
            )}

            {/* DRAWER PANEL RIWAYAT PASIEN */}
            <DrawerRiwayatPasien
                visible={drawerRiwayatVisible}
                onHide={() => setDrawerRiwayatVisible(false)}
                noRm={selectedPatientForRiwayat?.no_rm || ''}
                namaPasien={selectedPatientForRiwayat?.nama_pasien || ''}
                excludeKodeKunjungan={selectedPatientForRiwayat?.kode_kunjungan || ''}
                toast={toast}
            />
        </div>
    );
};
