'use client';

import postData from '@/lib/axios/postData';
import { Toast } from 'primereact/toast';
import { useEffect, useRef, useState } from 'react';
import { showError } from '@/lib/tools/generalTools';
import { FilterMatchMode } from 'primereact/api';
import { useSession } from 'next-auth/react';
import { DataTableStateEvent } from 'primereact/datatable';
import { State } from './components/interfaces';
import { apiEndpointData } from './components/endpoints';
import { PanelAntrianRuangan } from './components/PanelAntrianRuangan';
import { TableAntrianLayanan } from './components/table_antrian_layanan';
import { TabPanel, TabView } from 'primereact/tabview';

const AntreanLayananPage = () => {
    const toast = useRef<Toast>(null);
    const { data: session } = useSession();

    const [state, setState] = useState<State>({
        load: false,
        loadGrid: false,
        data: [],
        gridData: [],
        searchVal: '',
        filters: { global: { value: null, matchMode: FilterMatchMode.CONTAINS } },
        session: null,
        first: 0,
        rows: 10,
        page: 1,
        keyword: '',
        totalData: 0,
        sortField: 'nomor_antrian',
        sortOrder: 'asc',
        activeTab: 0,
        autoRefresh: true,
        filterJenis: '',
    });

    const getData = async (apiEndpoint: string) => {
        setState((p) => ({ ...p, load: true }));
        try {
            const oPayload = {
                page: state.page,
                perPage: state.rows,
                keyword: state.keyword,
                jenis_layanan: state.filterJenis || undefined,
                sortField: state.sortField,
                sortOrder: state.sortOrder,
            };
            const res = await postData(apiEndpoint, oPayload);
            setState((p) => ({
                ...p,
                data: res.data.data || [],
                totalData: res.data.total_data || 0,
            }));
        } catch (error: any) {
            const e = error?.response?.data || error;
            showError(toast, e?.message || 'Terjadi kesalahan saat memuat data antrean');
        } finally {
            setState((p) => ({ ...p, load: false }));
        }
    };

    const getGridData = async () => {
        setState((p) => ({ ...p, loadGrid: true }));
        try {
            const res = await postData(apiEndpointData, {
                sortField: 'nomor_antrian',
                sortOrder: 'asc',
            });
            setState((p) => ({ ...p, gridData: res.data.data || [] }));
        } catch (error: any) {
            const e = error?.response?.data || error;
            showError(toast, e?.message || 'Terjadi kesalahan saat memuat grid antrean');
        } finally {
            setState((p) => ({ ...p, loadGrid: false }));
        }
    };

    const onLazyLoad = (event: DataTableStateEvent) => {
        setState((prev) => {
            const newPage = typeof event.page === 'number' ? event.page + 1 : prev.page;
            return {
                ...prev,
                first: event.first,
                rows: event.rows,
                page: newPage,
                sortField: event.sortField || prev.sortField,
                sortOrder: event.sortOrder
                    ? event.sortOrder === 1
                        ? 'asc'
                        : 'desc'
                    : prev.sortOrder,
            };
        });
    };

    useEffect(() => {
        getData(apiEndpointData);
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [state.page, state.rows, state.sortField, state.sortOrder, state.keyword, state.filterJenis]);

    useEffect(() => {
        getGridData();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    useEffect(() => {
        if (session) setState((prev) => ({ ...prev, session }));
    }, [session]);

    return (
        <>
            <Toast ref={toast} position="top-right" />

            {/* Title Card Header */}
            <div className="card p-0 mb-3 border-round-xl surface-border shadow-1 overflow-hidden">
                <div className="p-4 bg-teal-50 border-bottom-1 surface-border">
                    <h2 className="text-3xl font-bold flex align-items-center gap-2 mb-1 text-teal-900">
                        <i className="pi pi-ticket text-teal-600 text-3xl" />
                        Panel Antrean Tindakan Pasien per Ruangan
                    </h2>
                    <p className="text-color-secondary m-0 text-sm">
                        Kelola dan panggil nomor antrean tindakan pasien berdasar lokasi ruangan tindakan secara real-time.
                    </p>
                </div>
            </div>

            {/* TabView Main Container */}
            <TabView
                activeIndex={state.activeTab}
                onTabChange={(e) => setState((p) => ({ ...p, activeTab: e.index }))}
            >
                <TabPanel
                    header="Antrean per Ruangan"
                    leftIcon="pi pi-building mr-2 text-teal-600 font-bold"
                >
                    <PanelAntrianRuangan
                        state={state}
                        setState={setState}
                        toast={toast}
                        getGridData={getGridData}
                    />
                </TabPanel>

                <TabPanel
                    header="Riwayat & Tabel Data"
                    leftIcon="pi pi-list mr-2"
                >
                    <TableAntrianLayanan
                        state={state}
                        setState={setState}
                        toast={toast}
                        getData={getData}
                        getGridData={getGridData}
                        onLazyLoad={onLazyLoad}
                    />
                </TabPanel>
            </TabView>
        </>
    );
};

export default AntreanLayananPage;
