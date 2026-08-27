/* eslint-disable @next/next/no-img-element */
'use client'
import React, { useContext, useEffect, useRef, useState } from 'react';
import AppMenuitem from './AppMenuitem';
import { LayoutContext } from './context/layoutcontext';
import { MenuProvider } from './context/menucontext';
import { useSession } from 'next-auth/react';
import postData from '@/lib/axios/postData';
import { InputText } from 'primereact/inputtext';
import { AppMenuItem } from '@/types';
import { Skeleton } from 'primereact/skeleton';
import { InputIcon } from 'primereact/inputicon';
import { IconField } from 'primereact/iconfield';
import Link from 'next/link';
import { usePathname, useSearchParams } from 'next/navigation';

interface MenuState {
    searchVal: string;
    filteredMenu: AppMenuItem[];
    load: boolean;
    menu: AppMenuItem[];
}

interface RuanganItem {
    kode_ruangan: string;
    nama_ruangan: string;
}

const AppMenu = () => {
    const { data: session } = useSession();
    const { layoutConfig } = useContext(LayoutContext);
    const searchRef = useRef<HTMLInputElement>(null);
    const lastPressTime = useRef<number>(0);
    const pathname = usePathname();
    const searchParams = useSearchParams();
    const activeRuangan = searchParams.get('ruangan') || '';

    const [state, setState] = useState<MenuState>({
        searchVal: "",
        filteredMenu: [],
        load: true,
        menu: []
    });

    const [ruanganList, setRuanganList] = useState<RuanganItem[]>([]);
    const [loadRuangan, setLoadRuangan] = useState<boolean>(true);

    useEffect(() => {
        getMenu(session?.user?.user_code || 'USR000000');
    }, [session]);

    useEffect(() => {
        fetchRuangan();
    }, []);

    const fetchRuangan = async () => {
        setLoadRuangan(true);
        try {
            const res = await postData('/master/ruangan-dropdown', {});
            setRuanganList(res.data.data || []);
        } catch (_) {
            // silent fail - sidebar tetap tampil tanpa ruangan
        } finally {
            setLoadRuangan(false);
        }
    };

    const getMenu = async (user_code: string) => {
        setState(prev => ({ ...prev, load: true }));
        try {
            const { data: vaData } = await postData('/setup/nav/user-data', { user_code: user_code });

            if (!vaData?.data) {
                throw new Error('Invalid menu data');
            }

            const menu: AppMenuItem[] = JSON.parse(JSON.stringify(vaData.data));
            const menu2: AppMenuItem[] = JSON.parse(JSON.stringify(vaData.data));

            setState(prev => ({
                ...prev,
                filteredMenu: menu2,
                menu: menu
            }));
        } catch (error) {
            console.error("Error loading menu:", error);
            setState(prev => ({
                ...prev,
                filteredMenu: [],
                menu: []
            }));
        } finally {
            setState(prev => ({ ...prev, load: false }));
        }
    };

    useEffect(() => {
        const handleKeyDown = (e: KeyboardEvent) => {
            if (e.ctrlKey && e.key.toLowerCase() === "f") {
                const now = Date.now();

                if (now - lastPressTime.current < 1000) {
                    lastPressTime.current = 0;
                    return;
                }

                e.preventDefault();
                lastPressTime.current = now;
                searchRef.current?.focus();
                searchRef.current?.select();
            }
        };

        window.addEventListener("keydown", handleKeyDown);
        return () => window.removeEventListener("keydown", handleKeyDown);
    }, []);

    const searchMenuByLabel = (
        menu: AppMenuItem[] | undefined,
        keyword: string,
        parentIndexes: number[] = []
    ): AppMenuItem[] => {
        if (!Array.isArray(menu) || menu.length === 0) return [];

        const lowerKeyword = keyword?.toLowerCase() || "";

        if (!lowerKeyword.trim()) {
            return menu.map((item, idx) => {
                const newItem: AppMenuItem = {
                    ...item,
                    indexPath: [...parentIndexes, idx],
                };

                if (item.items && item.items.length > 0) {
                    newItem.items = searchMenuByLabel(item.items, "", [...parentIndexes, idx]);
                }

                return newItem;
            });
        }

        return menu
            .map((item, idx): AppMenuItem | null => {
                const isMatch = item.label?.toLowerCase().includes(lowerKeyword);
                const childMatches = searchMenuByLabel(item.items || [], keyword, [...parentIndexes, idx]);

                if (isMatch) {
                    const newItem: AppMenuItem = {
                        ...item,
                        indexPath: [...parentIndexes, idx]
                    };
                    if (item.items && item.items.length > 0) {
                        newItem.items = childMatches;
                    }
                    return newItem;
                } else if (childMatches.length > 0) {
                    const newItem: AppMenuItem = {
                        ...item,
                        indexPath: [...parentIndexes, idx]
                    };
                    if (item.items && item.items.length > 0) {
                        newItem.items = childMatches;
                    }
                    return newItem;
                }

                return null;
            })
            .filter((item): item is AppMenuItem => item !== null);
    };

    useEffect(() => {
        const filtered = searchMenuByLabel(state.menu, state.searchVal);
        setState(prev => ({ ...prev, filteredMenu: filtered }));
    }, [state.menu, state.searchVal]);

    return (
        <MenuProvider>
            <div
                style={{
                    display: "flex",
                    width: "100%",
                    justifyContent: "center",
                    alignItems: "center",
                    position: "sticky",
                    top: "0",
                    padding: "10px 0",
                    zIndex: "9999"
                }}
            >
                <span className="block w-full p-input-icon-left">
                    <IconField iconPosition="left">
                        <InputIcon className="pi pi-search" />
                        <InputText
                            type="search"
                            ref={searchRef}
                            className="w-full"
                            value={state.searchVal}
                            onChange={(e: React.ChangeEvent<HTMLInputElement>) => {
                                const keyword = e.target.value;
                                const filtered = searchMenuByLabel(state.menu, keyword);
                                setState(prev => ({
                                    ...prev,
                                    searchVal: keyword,
                                    filteredMenu: filtered
                                }));
                            }}
                            placeholder="Search..."
                        />
                    </IconField>
                </span>
            </div>
            <ul className="layout-menu">
                {state.load
                    ? [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1].map((item, i) => (
                        <li key={i} className="my-3">
                            <Skeleton className="py-4" />
                        </li>
                    ))
                    : (() => {
                        // Split tepat setelah "Pendaftaran & Antrean" dan sebelum "Master Data & User"
                        // Label dari DB: "Master Data & User"
                        const splitIdx = state.filteredMenu.findIndex((item) =>
                            item.label && item.label.toLowerCase().includes('master data & user')
                        );

                        const topItems = splitIdx === -1 ? state.filteredMenu : state.filteredMenu.slice(0, splitIdx);
                        const bottomItems = splitIdx === -1 ? [] : state.filteredMenu.slice(splitIdx);

                        const renderItem = (item: AppMenuItem, i: number) =>
                            !item.separator ? (
                                <AppMenuitem
                                    load={state.load}
                                    item={item}
                                    root={true}
                                    index={i}
                                    key={item.label || i}
                                />
                            ) : (
                                <li className="menu-separator" key={`separator-${i}`}></li>
                            );

                        return (
                            <>
                                {topItems.map((item, i) => renderItem(item, i))}

                                {/* ── LAYANAN PER RUANGAN ── */}
                                <li className="layout-root-menuitem" key="layanan-ruangan-section">
                                    <div className="layout-menuitem-root-text">LAYANAN</div>
                                    <ul>
                                        {loadRuangan ? (
                                            [1, 2, 3].map((_, i) => (
                                                <li key={i} className="my-2">
                                                    <Skeleton className="py-3" />
                                                </li>
                                            ))
                                        ) : ruanganList.length === 0 ? (
                                            <li className="px-3 py-2">
                                                <span className="text-xs text-color-secondary">Belum ada ruangan</span>
                                            </li>
                                        ) : (
                                            ruanganList.map((ruang) => {
                                                const href = `/pendaftaran-antrean/antrean?ruangan=${ruang.kode_ruangan}`;
                                                const isActive =
                                                    pathname === '/pendaftaran-antrean/antrean' &&
                                                    activeRuangan === ruang.kode_ruangan;

                                                return (
                                                    <li key={ruang.kode_ruangan} className={isActive ? 'active-menuitem' : ''}>
                                                        <Link
                                                            href={href}
                                                            className={`p-ripple flex align-items-center gap-2${isActive ? ' active-route' : ''}`}
                                                            style={{ padding: '0.75rem 1.25rem', borderRadius: '6px', transition: 'background 0.2s' }}
                                                        >
                                                            <i
                                                                className="layout-menuitem-icon pi pi-home"
                                                                style={{ color: isActive ? 'var(--primary-color)' : undefined }}
                                                            />
                                                            <span
                                                                className="layout-menuitem-text"
                                                                style={{
                                                                    overflow: 'hidden',
                                                                    whiteSpace: 'nowrap',
                                                                    textOverflow: 'ellipsis',
                                                                    fontWeight: isActive ? 700 : undefined,
                                                                    color: isActive ? 'var(--primary-color)' : undefined,
                                                                }}
                                                                title={ruang.nama_ruangan}
                                                            >
                                                                {ruang.nama_ruangan}
                                                            </span>
                                                        </Link>
                                                    </li>
                                                );
                                            })
                                        )}
                                    </ul>
                                </li>

                                {/* ── KASIR ── */}
                                <li className="layout-root-menuitem" key="kasir-section">
                                    <div className="layout-menuitem-root-text">KASIR</div>
                                    <ul>
                                        <li className={pathname === '/kasir' ? 'active-menuitem' : ''}>
                                            <Link
                                                href="/kasir"
                                                className={`p-ripple flex align-items-center gap-2${pathname === '/kasir' ? ' active-route' : ''}`}
                                                style={{ padding: '0.75rem 1.25rem', borderRadius: '6px', transition: 'background 0.2s' }}
                                            >
                                                <i
                                                    className="layout-menuitem-icon pi pi-calculator"
                                                    style={{ color: pathname === '/kasir' ? 'var(--primary-color)' : undefined }}
                                                />
                                                <span
                                                    className="layout-menuitem-text"
                                                    style={{
                                                        fontWeight: pathname === '/kasir' ? 700 : undefined,
                                                        color: pathname === '/kasir' ? 'var(--primary-color)' : undefined,
                                                    }}
                                                >
                                                    Kasir
                                                </span>
                                            </Link>
                                        </li>
                                    </ul>
                                </li>

                                {bottomItems.map((item, i) => renderItem(item, topItems.length + i))}
                            </>
                        );
                    })()
                }
            </ul>

        </MenuProvider>
    );
};

export default AppMenu;