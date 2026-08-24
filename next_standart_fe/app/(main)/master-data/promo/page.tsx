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
import { Calendar } from 'primereact/calendar';
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

    const [dialogVisible, setDialogVisible] = useState<boolean>(false);
    const [isEdit, setIsEdit] = useState<boolean>(false);
    const [submitted, setSubmitted] = useState<boolean>(false);
    const [formData, setFormData] = useState<any>({
        kode_promo: '',
        nama: '',
        jenis_diskon: 'persen',
        nilai_diskon: 0,
        tanggal_mulai: null,
        tanggal_selesai: null,
        status: 'aktif',
    });
    const [saving, setSaving] = useState<boolean>(false);

    const loadData = async () => {
        setLoading(true);
        try {
            const res = await postData('/master/promo-data', { page, perPage: rows, keyword });
            setData(res.data.data || []);
            setTotalRecords(res.data.total_data || 0);
        } catch (error: any) {
            showError(toast, error?.response?.data?.message || 'Gagal memuat data promo');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadData();
    }, [page, rows, keyword]);

    const handleOpenCreate = () => {
        setIsEdit(false);
        setSubmitted(false);
        setFormData({
            kode_promo: '',
            nama: '',
            jenis_diskon: 'persen',
            nilai_diskon: 0,
            tanggal_mulai: null,
            tanggal_selesai: null,
            status: 'aktif'
        });
        setDialogVisible(true);
    };

    const handleOpenEdit = (rowData: any) => {
        setIsEdit(true);
        setSubmitted(false);
        setFormData({
            ...rowData,
            nilai_diskon: parseFloat(rowData.nilai_diskon) || 0,
            tanggal_mulai: rowData.tanggal_mulai ? new Date(rowData.tanggal_mulai) : null,
            tanggal_selesai: rowData.tanggal_selesai ? new Date(rowData.tanggal_selesai) : null,
        });
        setDialogVisible(true);
    };

    const handleSave = async () => {
        setSubmitted(true);
        if (!formData.nama || !formData.nama.trim() || !formData.tanggal_mulai || !formData.tanggal_selesai) {
            showError(toast, 'Harap lengkapi semua bidang wajib!');
            return;
        }
        setSaving(true);
        try {
            const payload = {
                ...formData,
                tanggal_mulai: new Date(formData.tanggal_mulai).toISOString().slice(0, 10),
                tanggal_selesai: new Date(formData.tanggal_selesai).toISOString().slice(0, 10)
            };
            const endpoint = isEdit ? '/master/promo-update' : '/master/promo-create';
            const res = await postData(endpoint, payload);
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
            message: `Apakah Anda yakin ingin menghapus ${codes.length} data promo ini?`,
            header: 'Konfirmasi Hapus',
            icon: 'pi pi-exclamation-triangle',
            acceptLabel: 'Ya, Hapus',
            rejectLabel: 'Batal',
            acceptClassName: 'p-button-danger',
            accept: async () => {
                try {
                    const res = await postData('/master/promo-delete', { kode_promo: codes });
                    showSuccess(toast, res.data.message || 'Berhasil dihapus');
                    setSelectedRows([]);
                    loadData();
                } catch (error: any) {
                    showError(toast, error?.response?.data?.message || 'Gagal menghapus data');
                }
            }
        });
    };

    const formatCurrency = (val: number) => {
        return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(val);
    };

    return (
        <div className="p-4">
            <Toast ref={toast} />
            <ConfirmDialog />

            <div className="card border-round-xl p-4 shadow-1 surface-card mb-4">
                {/* Page Header */}
                <div className="mb-4 pb-3 border-bottom-1 surface-border">
                    <h3 className="text-2xl font-bold text-900 flex align-items-center gap-2 mb-1">
                        <i className="pi pi-percentage text-purple-600 text-2xl" />
                        Kelola Data Promo & Diskon
                    </h3>
                    <p className="text-500 text-sm m-0">
                        Tambah, edit, atau nonaktifkan promo dan diskon klinik kecantikan.
                    </p>
                </div>

                <div className="flex flex-row flex-wrap align-items-center justify-content-between gap-3 mb-3">
                    <div className="flex flex-row flex-wrap align-items-center gap-2">
                        <Button
                            size="small"
                            label="Baru"
                            icon="pi pi-plus"
                            outlined
                            severity="success"
                            className="border-round-md font-semibold px-3"
                            onClick={handleOpenCreate}
                        />
                        <Divider layout="vertical" className="m-0 h-2rem" />
                        <Button
                            size="small"
                            label="Cetak"
                            icon="pi pi-print"
                            outlined
                            className="border-round-md font-semibold px-3 border-purple-600 text-purple-600"
                            onClick={() => window.print()}
                        />
                        <Divider layout="vertical" className="m-0 h-2rem" />
                        <Button
                            size="small"
                            label="Refresh"
                            icon="pi pi-refresh"
                            outlined
                            className="border-round-md font-semibold px-3 border-purple-600 text-purple-600"
                            loading={loading}
                            onClick={loadData}
                        />
                        {selectedRows.length > 0 && (
                            <>
                                <Divider layout="vertical" className="m-0 h-2rem" />
                                <Button
                                    size="small"
                                    label={`Hapus (${selectedRows.length})`}
                                    icon="pi pi-trash"
                                    severity="danger"
                                    outlined
                                    className="border-round-md font-semibold px-3"
                                    onClick={() => handleDelete(selectedRows.map((r) => r.kode_promo))}
                                />
                            </>
                        )}
                    </div>

                    
                </div>

                {/* Box Keterangan Status Legend */}
                <div className="surface-100 p-2 px-3 border-round-md flex align-items-center gap-4 text-xs font-semibold text-700 mb-4 border-1 surface-border">
                    <span className="flex align-items-center gap-1">
                        <i className="pi pi-info-circle text-primary text-sm"></i>
                        KETERANGAN STATUS:
                    </span>
                    <span className="flex align-items-center gap-2">
                        <span className="w-1rem h-1rem border-round bg-green-500 inline-flex align-items-center justify-content-center text-white text-xs">
                            <i className="pi pi-check" style={{ fontSize: '0.6rem' }}></i>
                        </span>
                        Aktif
                    </span>
                    <span className="flex align-items-center gap-2">
                        <span className="w-1rem h-1rem border-round bg-red-500 inline-flex align-items-center justify-content-center text-white text-xs">
                            <i className="pi pi-times" style={{ fontSize: '0.6rem' }}></i>
                        </span>
                        Tidak Aktif
                    </span>
                </div>

                {/* Section Title */}
                

                <div className="flex flex-row flex-wrap align-items-center justify-content-between gap-3 mb-3">
                    <h4 className="text-xl font-bold text-900 m-0">Tabel Data</h4>
                    <div className="flex align-items-center gap-2 w-full md:w-22rem">
                    <IconField iconPosition="left" className="w-full">
                        <InputIcon className="pi pi-search" />
                        <InputText value={keyword} onChange={(e) => setKeyword(e.target.value)} placeholder="Cari Data..." className="w-full text-sm border-round-md" />
                    </IconField>
                    <Button
                        icon="pi pi-filter-slash"
                        outlined
                        severity="danger"
                        className="border-round-md p-button-sm flex-shrink-0"
                        tooltip="Reset Filter"
                        onClick={() => setKeyword('')}
                    />
                </div>
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
                    dataKey="kode_promo"
                    className="p-datatable-sm"
                    emptyMessage="Data promo tidak ditemukan."
                    responsiveLayout="scroll"
                >
                    <Column selectionMode="multiple" headerStyle={{ width: '3rem' }}></Column>
                    <Column
                        header="Status"
                        headerStyle={{ width: '4rem' }}
                        body={(r) => (
                            <span
                                className={`w-2rem h-2rem border-round inline-flex align-items-center justify-content-center text-white shadow-1 ${r.status === 'aktif' ? 'bg-green-500' : 'bg-red-500'}`}
                                tooltip={r.status === 'aktif' ? 'Status: Aktif' : 'Status: Tidak Aktif'}
                            >
                                <i className={`pi ${r.status === 'aktif' ? 'pi-check' : 'pi-times'}`} style={{ fontSize: '0.8rem' }}></i>
                            </span>
                        )}
                    ></Column>
                    <Column field="kode_promo" header="Kode" sortable headerStyle={{ fontWeight: 'bold' }}></Column>
                    <Column field="nama" header="Nama Promo" sortable headerStyle={{ fontWeight: 'bold' }}></Column>
                    <Column
                        field="jenis_diskon"
                        header="Jenis Diskon"
                        body={(r) => <Tag value={r.jenis_diskon.toUpperCase()} severity={r.jenis_diskon === 'persen' ? 'info' : 'warning'} />}
                    ></Column>
                    <Column
                        field="nilai_diskon"
                        header="Nilai Diskon"
                        body={(r) => r.jenis_diskon === 'persen' ? `${parseFloat(r.nilai_diskon)}%` : formatCurrency(parseFloat(r.nilai_diskon))}
                    ></Column>
                    <Column field="tanggal_mulai" header="Tgl Mulai" body={(r) => r.tanggal_mulai ? new Date(r.tanggal_mulai).toLocaleDateString('id-ID') : '-'}></Column>
                    <Column field="tanggal_selesai" header="Tgl Selesai" body={(r) => r.tanggal_selesai ? new Date(r.tanggal_selesai).toLocaleDateString('id-ID') : '-'}></Column>
                    <Column
                        header="Aksi"
                        body={(r) => (
                            <div className="flex gap-2 justify-content-center">
                                <Button icon="pi pi-pencil" outlined severity="success" className="p-button-sm border-round-md" onClick={() => handleOpenEdit(r)} tooltip="Edit" />
                                <Button icon="pi pi-trash" outlined severity="danger" className="p-button-sm border-round-md" onClick={() => handleDelete([r.kode_promo])} tooltip="Hapus" />
                            </div>
                        )}
                    ></Column>
                </DataTable>
            </div>

            <Dialog header={isEdit ? 'Edit Data Promo' : 'Tambah Data Promo'} visible={dialogVisible} style={{ width: '500px' }} modal onHide={() => setDialogVisible(false)}>
                <div className="flex flex-column gap-3 pt-2">
                    {isEdit && (
                        <div>
                            <label className="block text-sm font-semibold mb-1">Kode Promo</label>
                            <InputText value={formData.kode_promo} disabled className="w-full text-sm border-round-md" />
                        </div>
                    )}
                    <div>
                        <label className="block text-sm font-semibold mb-1">Nama Promo *</label>
                        <InputText
                            value={formData.nama}
                            onChange={(e) => setFormData({ ...formData, nama: e.target.value })}
                            placeholder="contoh : Promo Diskon Merdeka 50%"
                            className={`w-full text-sm border-round-md ${submitted && !formData.nama?.trim() ? 'p-invalid' : ''}`}
                        />
                        {submitted && !formData.nama?.trim() && (
                            <small className="p-error text-red-500 text-xs block mt-1">Nama promo wajib diisi.</small>
                        )}
                    </div>
                    <div className="grid">
                        <div className="col-6">
                            <label className="block text-sm font-semibold mb-1">Jenis Diskon *</label>
                            <Dropdown
                                value={formData.jenis_diskon}
                                options={[{ label: 'Persen (%)', value: 'persen' }, { label: 'Nominal (Rp)', value: 'nominal' }]}
                                onChange={(e) => setFormData({ ...formData, jenis_diskon: e.value })}
                                className="w-full text-sm border-round-md"
                            />
                        </div>
                        <div className="col-6">
                            <label className="block text-sm font-semibold mb-1">Nilai Diskon *</label>
                            <InputNumber
                                value={formData.nilai_diskon}
                                onValueChange={(e) => setFormData({ ...formData, nilai_diskon: e.value || 0 })}
                                prefix={formData.jenis_diskon === 'nominal' ? 'Rp ' : ''}
                                suffix={formData.jenis_diskon === 'persen' ? ' %' : ''}
                                className="w-full text-sm border-round-md"
                            />
                        </div>
                    </div>
                    <div className="grid">
                        <div className="col-6">
                            <label className="block text-sm font-semibold mb-1">Tanggal Mulai *</label>
                            <Calendar
                                value={formData.tanggal_mulai}
                                onChange={(e) => setFormData({ ...formData, tanggal_mulai: e.value })}
                                dateFormat="dd/mm/yy"
                                placeholder="Pilih tanggal..."
                                className={`w-full text-sm border-round-md ${submitted && !formData.tanggal_mulai ? 'p-invalid' : ''}`}
                                showIcon
                            />
                            {submitted && !formData.tanggal_mulai && (
                                <small className="p-error text-red-500 text-xs block mt-1">Tanggal mulai wajib diisi.</small>
                            )}
                        </div>
                        <div className="col-6">
                            <label className="block text-sm font-semibold mb-1">Tanggal Selesai *</label>
                            <Calendar
                                value={formData.tanggal_selesai}
                                onChange={(e) => setFormData({ ...formData, tanggal_selesai: e.value })}
                                dateFormat="dd/mm/yy"
                                placeholder="Pilih tanggal..."
                                className={`w-full text-sm border-round-md ${submitted && !formData.tanggal_selesai ? 'p-invalid' : ''}`}
                                showIcon
                            />
                            {submitted && !formData.tanggal_selesai && (
                                <small className="p-error text-red-500 text-xs block mt-1">Tanggal selesai wajib diisi.</small>
                            )}
                        </div>
                    </div>
                    <div className="surface-50 p-3 border-round-md border-1 surface-border">
                        <div className="flex align-items-center justify-content-between mb-2">
                            <span className="font-bold text-sm text-900">Status Promo</span>
                            <InputSwitch
                                checked={formData.status === 'aktif'}
                                onChange={(e) => setFormData({ ...formData, status: e.value ? 'aktif' : 'nonaktif' })}
                            />
                        </div>
                        <span className="text-xs text-600 block">
                            <strong>Status: {formData.status === 'aktif' ? 'Aktif' : 'Non-aktif'}</strong>. {formData.status === 'aktif' ? 'Promo aktif dan dapat digunakan dalam seluruh transaksi.' : 'Promo dinonaktifkan dari transaksi.'}
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
