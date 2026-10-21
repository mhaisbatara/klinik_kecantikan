/**
 * @file apiConfig.ts
 * @description Helper terpusat untuk URL API backend
 */

export const getBackendApiUrl = (): string => {
    let url = process.env.API_URL || process.env.NEXT_PUBLIC_URL_API || process.env.NEXT_PUBLIC_API_BASE_URL || '';

    // Jika kosong atau masih berupa placeholder bawaan template
    if (!url || url.includes('<') || url.includes('>')) {
        return 'http://127.0.0.1:8000/api/v1';
    }

    url = url.endsWith('/') ? url.slice(0, -1) : url;

    // Normalisasi localhost ke 127.0.0.1 untuk mencegah ECONNREFUSED IPv6 (::1) pada Windows
    url = url.replace('//localhost:', '//127.0.0.1:');

    if (!url.endsWith('/api/v1')) {
        url = `${url}/api/v1`;
    }

    return url;
};
