'use client';

import { useEffect, useRef, useState } from 'react';
import postData from '@/lib/axios/postData';
import { Toast } from 'primereact/toast';
import { DataTable } from 'primereact/datatable';
import { Column } from 'primereact/column';
import { Button } from 'primereact/button';
import { InputText } from 'primereact/inputtext';
import { InputNumber } from 'primereact/inputnumber';
import { Dialog } from 'primereact/dialog';
import { Tag } from 'primereact/tag';
import { Dropdown } from 'primereact/dropdown';
import { Divider } from 'primereact/divider';
import { InputSwitch } from 'primereact/inputswitch';
import { confirmDialog, ConfirmDialog } from 'primereact/confirmdialog';
import { IconField } from 'primereact/iconfield';
import { InputIcon } from 'primereact/inputicon';
import { showError, showSuccess } from '@/lib/tools/generalTools';

const Page = () => {
    const toast = useRef<Toast>(null);

    const [data, setData] = useState<any[]>([]);
    const [loading, setLoading] = useState<boolean>(false);
    const [totalRecords, setTotalRecords] = useState<number>(0);
    const [page, setPage] = useState<number>(1);
    const [rows, setRows] = useState<number>(10);
    const [keyword, setKeyword] = useState<string>('');
    const [selectedRows, setSelectedRows] = useState<any[]>([]);

    const [karyawanOptions, setKaryawanOptions] = useState<any[]>([]);
    const [ruanganOptions, setRuanganOptions] = useState<any[]>([]);
    const [dialogVisible, setDialogVisible] = useState<boolean>(false);
    const [isEdit, setIsEdit] = useState<boolean>(false);
    const [submitted, setSubmitted] = useState<boolean>(false);
    const [formData, setFormData] = useState<any>({
        kode_jadwal: '',
        no_sip: '',
        kode_ruangan: '',
        hari: 'senin',
        jam_mulai: '08:00',
        jam_selesai: '16:00',
        kuota: 10,
        status: 'aktif',
    });
    const [saving, setSaving] = useState<boolean>(false);

    const hariOptions = [
        { label: 'Senin', value: 'senin' },
        { label: 'Selasa', value: 'selasa' },
        { label: 'Rabu', value: 'rabu' },
        { label: 'Kamis', value: 'kamis' },
        { label: 'Jumat', value: 'jumat' },
        { label: 'Sabtu', value: 'sabtu' },
        { label: 'Minggu', value: 'minggu' },
    ];

    const loadRuangan = async () => {
        try {
            const res = await postData('/master/ruangan-dropdown', {});
            const list = (res.data.data || []).map((r: any) => ({
                label: `${r.nama_ruangan} (${r.kode_ruangan})`,
                value: r.kode_ruangan
            }));
            setRuanganOptions(list);
        } catch (error) {
            console.error('Gagal memuat list ruangan:', error);
        }
    };

    const loadKaryawan = async () => {
        try {
            const res = await postData('/master/karyawan-data', { page: 1, perPage: 100 });
            const list = (res.data.data || []).map((k: any) => ({
                label: `${k.nama} (${k.jabatan?.toUpperCase()}) - ${k.no_sip}`,
                value: k.no_sip
            }));
            setKaryawanOptions(list);
        } catch (error) {
            console.error('Gagal memuat list karyawan:', error);
        }
    };

    const loadData = async () => {
        setLoading(true);
        try {
            const res = await postData('/master/jadwal-karyawan-data', { page, perPage: rows, keyword });
            setData(res.data.data || []);
            setTotalRecords(res.data.total_data || 0);
        } catch (error: any) {
            showError(toast, error?.response?.data?.message || 'Gagal memuat data jadwal karyawan');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadKaryawan();
        loadRuangan();
    }, []);

    useEffect(() => {
        loadData();
    }, [page, rows, keyword]);

    const handleOpenCreate = () => {
        setIsEdit(false);
        setSubmitted(false);
        setFormData({
            kode_jadwal: '',
            no_sip: karyawanOptions.length > 0 ? karyawanOptions[0].value : '',
            kode_ruangan: '',
            hari: 'senin',
            jam_mulai: '08:00',
            jam_selesai: '16:00',
            kuota: 10,
            status: 'aktif'
        });
        setDialogVisible(true);
    };

    const handleOpenEdit = (rowData: any) => {
        setIsEdit(true);
        setSubmitted(false);
        setFormData({
            ...rowData,
            kuota: parseInt(rowData.kuota) || 0
        });
        setDialogVisible(true);
    };

    const handleSave = async () => {
        setSubmitted(true);
        if (!formData.no_sip || !formData.hari || !formData.jam_mulai?.trim() || !formData.jam_selesai?.trim()) {
            showError(toast, 'Harap lengkapi seluruh bidang wajib!');
            return;
        }
        setSaving(true);
        try {
            const endpoint = isEdit ? '/master/jadwal-karyawan-update' : '/master/jadwal-karyawan-create';
            const res = await postData(endpoint, formData);
            showSuccess(toast, res.data.message || 'Berhasil disimpan');
            setDialogVisible(false);
            loadData();
        } catch (error: any) {
            showError(toast, error?.response?.data?.message || 'Gagal menyimpan data');
        } finally {
            setSaving(false);
        }
    };

    const handleDelete = (codes: string[]) => {
        confirmDialog({
            message: `Apakah Anda yakin ingin menghapus ${codes.length} jadwal karyawan ini?`,
            header: 'Konfirmasi Hapus',
            icon: 'pi pi-exclamation-triangle',
            acceptLabel: 'Ya, Hapus',
            rejectLabel: 'Batal',
            acceptClassName: 'p-button-danger',
            accept: async () => {
                try {
                    const res = await postData('/master/jadwal-karyawan-delete', { kode_jadwal: codes });
                    showSuccess(toast, res.data.message || 'Berhasil dihapus');
                    setSelectedRows([]);
                    loadData();
                } catch (error: any) {
                    showError(toast, error?.response?.data?.message || 'Gagal menghapus data');
                }
            }
        });
    };

    return (
        <div className="p-4">
            <Toast ref={toast} />
            <ConfirmDialog />

            <div className="card border-round-xl p-4 shadow-1 surface-card mb-4">
                {/* Page Header */}
                <div className="mb-4">
                    <h3 className="text-2xl font-bold text-900 flex align-items-center gap-2 mb-1">
                        <i className="pi pi-calendar text-purple-600 text-2xl" />
                        Kelola Jadwal Karyawan & Dokter
                    </h3>
                    <p className="text-500 text-sm m-0">
                        Atur jadwal kerja, hari operasional, dan kuota pasien untuk setiap karyawan.
                    </p>
                </div>

                <div className="flex flex-row flex-wrap align-items-center gap-2 mb-4">
                    <Button
                        size="small"
                        label="Baru"
                        icon="pi pi-plus"
                        outlined
                        severity="success"
                        className="border-round-md font-medium px-3"
                        onClick={handleOpenCreate}
                    />
                    <Divider layout="vertical" className="m-0 h-2rem" />
                    <Button
                        size="small"
                        label="Cetak"
                        icon="pi pi-print"
                        outlined
                        className="border-round-md font-medium px-3 border-purple-600 text-purple-600"
                        onClick={() => window.print()}
                    />
                    <Divider layout="vertical" className="m-0 h-2rem" />
                    <Button
                        size="small"
                        label={`Hapus${selectedRows.length > 0 ? ` (${selectedRows.length})` : ''}`}
                        icon="pi pi-trash"
                        severity="danger"
                        outlined
                        disabled={selectedRows.length === 0}
                        className="border-round-md font-medium px-3"
                        onClick={() => { if (selectedRows.length < 1) return; handleDelete(selectedRows.map((r) => r.kode_jadwal)); }}
                    />
                    <Divider layout="vertical" className="m-0 h-2rem" />
                    <Button
                        size="small"
                        label="Refresh"
                        icon="pi pi-refresh"
                        outlined
                        severity="success"
                        className="border-round-md font-medium px-3"
                        loading={loading}
                        onClick={loadData}
                    />
                </div>



                <DataTable
                    value={data}
                    loading={loading}
                    paginator
                    rows={rows}
                    totalRecords={totalRecords}
                    lazy
                    first={(page - 1) * rows}
                    onPage={(e) => { setPage((e.page || 0) + 1); setRows(e.rows); }}
                    selection={selectedRows}
                    onSelectionChange={(e) => setSelectedRows(e.value as any[])}
                    dataKey="kode_jadwal"
                    className="p-datatable-sm"
                    emptyMessage="Data jadwal tidak ditemukan."
                    responsiveLayout="scroll"
                    rowsPerPageOptions={[10, 25, 50]}
                    paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                    currentPageReportTemplate="Menampilkan {first} - {last} dari {totalRecords} data"
                    header={
                        <div className="flex flex-column gap-3">
                            <div className="flex flex-wrap align-items-center justify-content-between gap-2">
                                <span className="text-xl font-bold">Data Jadwal Karyawan & Dokter</span>
                                <div className="flex align-items-center gap-2 ml-auto w-full md:w-auto">
                                    <IconField iconPosition="left" className="w-full md:w-20rem">
                                        <InputIcon className="pi pi-search" />
                                        <InputText value={keyword} onChange={(e) => setKeyword(e.target.value)} placeholder="Cari Data..." className="w-full text-sm" />
                                    </IconField>
                                    <Button
                                        type="button"
                                        icon="pi pi-filter-slash"
                                        outlined
                                        severity="danger"
                                        tooltip="Reset Filter"
                                        tooltipOptions={{ position: 'bottom' }}
                                        onClick={() => setKeyword('')}
                                    />
                                </div>
                            </div>
                            <div className="flex flex-wrap align-items-center gap-3 px-1 py-2 border-round-md surface-100 text-xs font-medium text-color-secondary">
                                <span className="flex align-items-center gap-1">
                                    <i className="pi pi-info-circle" />
                                    <span className="font-semibold">KETERANGAN STATUS:</span>
                                </span>
                                <span className="flex align-items-center gap-1">
                                    <span style={{ display:'inline-block', width:'12px', height:'12px', borderRadius:'3px', backgroundColor:'#22c55e', boxShadow:'0 1px 3px #22c55e55' }} />
                                    Aktif
                                </span>
                                <span className="flex align-items-center gap-1">
                                    <span style={{ display:'inline-block', width:'12px', height:'12px', borderRadius:'3px', backgroundColor:'#ef4444', boxShadow:'0 1px 3px #ef444455' }} />
                                    Tidak Aktif
                                </span>
                            </div>
                        </div>
                    }
                >
                    <Column selectionMode="multiple" headerStyle={{ width: '3rem' }}></Column>
                    <Column
                        header=""
                        headerStyle={{ width: '3rem' }}
                        align="center"
                        body={(r) => (
                            <span
                                style={{
                                    display: 'inline-block',
                                    width: '14px',
                                    height: '14px',
                                    borderRadius: '3px',
                                    backgroundColor: r.status === 'aktif' ? '#22c55e' : '#ef4444',
                                    boxShadow: r.status === 'aktif' ? '0 1px 3px #22c55e55' : '0 1px 3px #ef444455'
                                }}
                                title={r.status === 'aktif' ? 'Status: Aktif' : 'Status: Tidak Aktif'}
                            />
                        )}
                    ></Column>
                    <Column field="kode_jadwal" header="Kode" sortable headerStyle={{ fontWeight: 'bold' }}></Column>
                    <Column field="nama_karyawan" header="Nama Karyawan/Dokter" body={(r) => r.nama_karyawan ? `${r.nama_karyawan} (${r.jabatan?.toUpperCase()})` : r.no_sip} sortable headerStyle={{ fontWeight: 'bold' }}></Column>
                    <Column field="no_sip" header="No. SIP" body={(r) => r.no_sip || '-'}></Column>
                    <Column
                        field="nama_ruangan"
                        header="Ruangan"
                        body={(r) => r.nama_ruangan ? (
                            <span className="flex align-items-center gap-1 text-xs">
                                <i className="pi pi-building text-purple-500 text-xs" />
                                <span className="font-medium">{r.nama_ruangan}</span>
                            </span>
                        ) : <span className="text-400 text-xs">-</span>}
                        headerStyle={{ fontWeight: 'bold' }}
                    ></Column>
                    <Column field="hari" header="Hari" body={(r) => <Tag value={r.hari?.toUpperCase()} severity="info" />}></Column>
                    <Column header="Jam Kerja" body={(r) => `${r.jam_mulai} - ${r.jam_selesai}`}></Column>
                    <Column field="kuota" header="Kuota Pasien" body={(r) => `${r.kuota} Pasien`}></Column>
                    <Column
                        header="Aksi"
                        align="center"
                        headerStyle={{ width: '8rem', textAlign: 'center' }}
                        body={(r) => (
                            <div className="flex align-items-center justify-content-center gap-2">
                                <Button icon="pi pi-pencil" outlined severity="success" className="p-button-sm border-round-md" onClick={() => handleOpenEdit(r)} tooltip="Edit" />
                                <Button icon="pi pi-trash" outlined severity="danger" className="p-button-sm border-round-md" onClick={() => handleDelete([r.kode_jadwal])} tooltip="Hapus" />
                            </div>
                        )}
                    ></Column>
                </DataTable>
            </div>

            <Dialog header={isEdit ? 'Edit Jadwal Karyawan' : 'Tambah Jadwal Karyawan'} visible={dialogVisible} style={{ width: '500px' }} modal onHide={() => setDialogVisible(false)}>
                <div className="flex flex-column gap-3 pt-2">
                    {isEdit && (
                        <div>
                            <label className="block text-sm font-semibold mb-1">Kode Jadwal</label>
                            <InputText value={formData.kode_jadwal} disabled className="w-full text-sm border-round-md" />
                        </div>
                    )}
                    <div>
                        <label className="block text-sm font-semibold mb-1">Karyawan / Dokter *</label>
                        <Dropdown
                            value={formData.no_sip}
                            options={karyawanOptions}
                            onChange={(e) => setFormData({ ...formData, no_sip: e.value })}
                            placeholder="Pilih Karyawan/Dokter..."
                            filter
                            className={`w-full text-sm border-round-md ${submitted && !formData.no_sip ? 'p-invalid' : ''}`}
                        />
                        {submitted && !formData.no_sip && (
                            <small className="p-error text-red-500 text-xs block mt-1">Karyawan/Dokter wajib dipilih.</small>
                        )}
                    </div>
                    <div>
                        <label className="block text-sm font-semibold mb-1">Ruangan</label>
                        <Dropdown
                            value={formData.kode_ruangan || null}
                            options={ruanganOptions}
                            onChange={(e) => setFormData({ ...formData, kode_ruangan: e.value })}
                            placeholder="Pilih Ruangan (opsional)..."
                            filter
                            showClear
                            className="w-full text-sm border-round-md"
                        />
                        <small className="text-400 text-xs block mt-1">Opsional — Ruangan tempat karyawan/dokter bertugas</small>
                    </div>
                    <div className="grid">
                        <div className="col-6">
                            <label className="block text-sm font-semibold mb-1">Hari *</label>
                            <Dropdown
                                value={formData.hari}
                                options={hariOptions}
                                onChange={(e) => setFormData({ ...formData, hari: e.value })}
                                className="w-full text-sm border-round-md"
                            />
                        </div>
                        <div className="col-6">
                            <label className="block text-sm font-semibold mb-1">Kuota Pasien *</label>
                            <InputNumber
                                value={formData.kuota}
                                onValueChange={(e) => setFormData({ ...formData, kuota: e.value || 0 })}
                                min={0}
                                className="w-full text-sm border-round-md"
                            />
                        </div>
                    </div>
                    <div className="grid">
                        <div className="col-6">
                            <label className="block text-sm font-semibold mb-1">Jam Mulai (HH:mm) *</label>
                            <InputText
                                value={formData.jam_mulai}
                                onChange={(e) => setFormData({ ...formData, jam_mulai: e.target.value })}
                                placeholder="contoh : 08:00"
                                className={`w-full text-sm border-round-md ${submitted && !formData.jam_mulai?.trim() ? 'p-invalid' : ''}`}
                            />
                            {submitted && !formData.jam_mulai?.trim() && (
                                <small className="p-error text-red-500 text-xs block mt-1">Jam mulai wajib diisi.</small>
                            )}
                        </div>
                        <div className="col-6">
                            <label className="block text-sm font-semibold mb-1">Jam Selesai (HH:mm) *</label>
                            <InputText
                                value={formData.jam_selesai}
                                onChange={(e) => setFormData({ ...formData, jam_selesai: e.target.value })}
                                placeholder="contoh : 16:00"
                                className={`w-full text-sm border-round-md ${submitted && !formData.jam_selesai?.trim() ? 'p-invalid' : ''}`}
                            />
                            {submitted && !formData.jam_selesai?.trim() && (
                                <small className="p-error text-red-500 text-xs block mt-1">Jam selesai wajib diisi.</small>
                            )}
                        </div>
                    </div>
                    <div className="surface-50 p-3 border-round-md border-1 surface-border">
                        <div className="flex align-items-center justify-content-between mb-2">
                            <span className="font-bold text-sm text-900">Status Jadwal</span>
                            <InputSwitch
                                checked={formData.status === 'aktif'}
                                onChange={(e) => setFormData({ ...formData, status: e.value ? 'aktif' : 'nonaktif' })}
                            />
                        </div>
                        <span className="text-xs text-600 block">
                            <strong>Status: {formData.status === 'aktif' ? 'Aktif' : 'Non-aktif'}</strong>. {formData.status === 'aktif' ? 'Jadwal aktif dan dapat digunakan dalam pendaftaran.' : 'Jadwal dinonaktifkan.'}
                        </span>
                    </div>
                </div>
                <div className="flex justify-content-end gap-2 mt-4">
                    <Button label="Batal" icon="pi pi-times" text onClick={() => setDialogVisible(false)} />
                    <Button label="Simpan" icon="pi pi-check" loading={saving} onClick={handleSave} className="bg-primary border-none" />
                </div>
            </Dialog>
        </div>
    );
};

export default Page;
