'use client';

import React, { useState } from 'react';
import { Skeleton } from 'primereact/skeleton';

export interface ActivityItem {
  id: string;
  kategori: 'transaksi' | 'kunjungan' | 'booking' | string;
  judul: string;
  deskripsi: string;
  status: string;
  waktu: string;
  badge: string;
  badgeSeverity?: string;
  nama_cabang?: string;
}

interface BranchActivityFeedProps {
  activities: ActivityItem[];
  loading?: boolean;
  subtitle?: string;
}

export const BranchActivityFeed: React.FC<BranchActivityFeedProps> = ({
  activities = [],
  loading = false,
  subtitle,
}) => {
  const [activeFilter, setActiveFilter] = useState<'all' | 'transaksi' | 'kunjungan' | 'booking'>('all');

  const filteredActivities = activities.filter((act) => {
    if (activeFilter === 'all') return true;
    return act.kategori === activeFilter;
  });

  return (
    <div
      className="clinic-panel bg-white"
      style={{ padding: '24px', marginBottom: '24px' }}
    >
      <div className="flex flex-column md:flex-row justify-content-between align-items-start md:align-items-center gap-3 mb-4 pb-3 border-bottom-1 surface-border">
        <div>
          <div className="flex align-items-center gap-2 mb-1">
            <span
              style={{
                width: '8px',
                height: '8px',
                borderRadius: '50%',
                backgroundColor: '#10b981',
                boxShadow: '0 0 0 3px rgba(16, 185, 129, 0.2)',
                display: 'inline-block',
              }}
            />
            <h2 className="clinic-card-title text-base font-bold text-900 m-0">
              Tracking Seluruh Aktivitas Cabang
            </h2>
            <span className="clinic-pill clinic-pill-emerald ml-1">
              Live Feed
            </span>
          </div>
          <p className="text-xs m-0" style={{ color: '#6F7A74' }}>
            {subtitle || 'Monitoring real-time transaksi kasir, kunjungan pasien & reservasi booking di Klinik Cabang Utama'}
          </p>
        </div>

        {/* Segmented Filter Pills */}
        <div
          className="flex p-1 border-round-lg"
          style={{
            backgroundColor: '#F3F4F6',
            border: '1px solid #E5E7EB',
          }}
        >
          {[
            { id: 'all', label: `Semua (${activities.length})` },
            { id: 'transaksi', label: 'Transaksi' },
            { id: 'kunjungan', label: 'Kunjungan' },
            { id: 'booking', label: 'Booking' },
          ].map((tab) => {
            const isTabActive = activeFilter === tab.id;
            return (
              <button
                key={tab.id}
                type="button"
                onClick={() => setActiveFilter(tab.id as any)}
                className="text-xs font-semibold px-3 py-1.5 border-round-md transition-all border-none cursor-pointer"
                style={{
                  backgroundColor: isTabActive ? '#FFFFFF' : 'transparent',
                  color: isTabActive ? 'var(--primary-700, #047857)' : '#6F7A74',
                  fontWeight: isTabActive ? 700 : 500,
                  boxShadow: isTabActive ? '0 1px 3px rgba(0,0,0,0.08)' : 'none',
                }}
              >
                {tab.label}
              </button>
            );
          })}
        </div>
      </div>

      {/* Activity Timeline List */}
      {loading && activities.length === 0 ? (
        <div className="flex flex-column gap-2">
          {Array.from({ length: 4 }).map((_, idx) => (
            <div
              key={idx}
              className="p-3 border-round-lg flex align-items-center justify-content-between"
              style={{ border: '1px solid #F1F5F9', backgroundColor: '#FAFCFB' }}
            >
              <div className="flex align-items-center gap-3">
                <Skeleton width="38px" height="38px" className="border-round-lg" />
                <div>
                  <Skeleton width="180px" height="14px" className="mb-2" />
                  <Skeleton width="260px" height="12px" />
                </div>
              </div>
              <div className="flex flex-column align-items-end gap-1">
                <Skeleton width="120px" height="14px" />
                <Skeleton width="60px" height="12px" />
              </div>
            </div>
          ))}
        </div>
      ) : filteredActivities.length === 0 ? (
        <div className="text-center py-6">
          <div
            className="w-3rem h-3rem border-round-circle mx-auto flex align-items-center justify-content-center mb-3"
            style={{ backgroundColor: '#F3F4F6', color: '#9AA39D' }}
          >
            <i className="pi pi-inbox text-xl" />
          </div>
          <h4 className="text-sm font-semibold text-800 m-0 mb-1">Belum Ada Aktivitas</h4>
          <p className="text-xs text-500 m-0">Belum ada aktivitas tercatat pada kategori ini di cabang.</p>
        </div>
      ) : (
        <div
          className="flex flex-column gap-2 overflow-y-auto pr-1"
          style={{ maxHeight: '420px' }}
        >
          {filteredActivities.map((act) => {
            let iconName = 'pi-clock';
            let iconColor = '#6F7A74';
            let iconBg = '#F3F4F6';
            let pillClass = 'clinic-pill-emerald';

            if (act.kategori === 'transaksi') {
              iconName = 'pi-wallet';
              iconColor = '#047857';
              iconBg = '#ECFDF5';
              pillClass = 'clinic-pill-emerald';
            } else if (act.kategori === 'kunjungan') {
              iconName = 'pi-user';
              iconColor = '#1D4ED8';
              iconBg = '#EFF6FF';
              pillClass = 'clinic-pill-role-perawat';
            } else if (act.kategori === 'booking') {
              iconName = 'pi-calendar';
              iconColor = '#6D28D9';
              iconBg = '#F5F3FF';
              pillClass = 'clinic-pill-role-terapis';
            }

            const formattedTime = act.waktu
              ? new Date(act.waktu).toLocaleString('id-ID', {
                  day: 'numeric',
                  month: 'short',
                  year: 'numeric',
                  hour: '2-digit',
                  minute: '2-digit',
                })
              : '-';

            const isPositiveStatus = ['lunas', 'selesai', 'aktif'].includes(String(act.status).toLowerCase());

            return (
              <div
                key={act.id}
                className="clinic-table-row flex align-items-center justify-content-between p-3 border-round-lg transition-all"
                style={{
                  border: '1px solid #F1F5F9',
                  backgroundColor: '#FAFCFB',
                }}
              >
                <div className="flex align-items-center gap-3">
                  <div
                    className="border-round-lg flex align-items-center justify-content-center flex-shrink-0"
                    style={{
                      width: '38px',
                      height: '38px',
                      backgroundColor: iconBg,
                      color: iconColor,
                    }}
                  >
                    <i className={`pi ${iconName} text-base`} />
                  </div>
                  <div>
                    <div className="flex align-items-center gap-2 mb-1">
                      <span className="font-bold text-xs" style={{ color: '#202A26' }}>
                        {act.judul}
                      </span>
                      <span
                        className={`clinic-pill ${pillClass}`}
                        style={{ height: '20px', fontSize: '10px', padding: '2px 8px' }}
                      >
                        {act.badge}
                      </span>
                    </div>
                    <p className="text-xs m-0" style={{ color: '#6F7A74' }}>
                      {act.deskripsi}
                    </p>
                  </div>
                </div>

                <div className="text-right flex flex-column align-items-end flex-shrink-0 pl-3">
                  <span className="text-xs font-semibold tabular-nums" style={{ color: '#202A26' }}>
                    {formattedTime} WIB
                  </span>
                  <span
                    className="text-xs font-medium capitalize mt-1 inline-flex align-items-center gap-1"
                    style={{
                      color: isPositiveStatus ? '#047857' : '#B3873F',
                    }}
                  >
                    <span
                      style={{
                        width: '5px',
                        height: '5px',
                        borderRadius: '50%',
                        backgroundColor: isPositiveStatus ? '#10b981' : '#f59e0b',
                      }}
                    />
                    {act.status}
                  </span>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};

export default BranchActivityFeed;
