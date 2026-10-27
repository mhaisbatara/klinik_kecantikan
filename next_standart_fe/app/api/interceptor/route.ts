/**
 * @copyright (c) 2026 PT Marstech Global (info@marstech.co.id)
 * @project Standard
 * @file page.tsx
 * @description File untuk route API untuk interceptor route global (get, post, put)
 */

import { NextRequest, NextResponse } from 'next/server';
import { clearSessionCookies } from '@/lib/tools/serverTools';
import axios from 'axios';
import { formatDateISO, formatDateSystem } from '@/lib/tools/dateTools';
import { auth } from '@/lib/tools/authTools';
import { getBackendApiUrl } from '@/lib/tools/apiConfig';

interface CustomHeaders {
    'x-endpoint'?: string;
    'x-custom-header'?: string;
    'x-level'?: string;
    'x-credential'?: string;
    'x-kode-cabang'?: string;
}

const handleRequest = async (request: NextRequest, method: 'GET' | 'POST' | 'PUT') => {
    try {
        const session = await auth();

        if (!session || !session.access_token || session.error === "AccessTokenExpired") {
            await clearSessionCookies();
            return NextResponse.json(
                { status: 99, message: 'Sesi Anda telah berakhir. Harap login kembali.', datetime: formatDateSystem(new Date()) },
                { status: 401 }
            );
        }

        return await proxyCRUD(request, session.access_token, method);

    } catch (error: any) {
        console.error("BFF Interceptor Error:", error);

        const isUnauthorized = error.response?.status === 401 || error.status === 401;
        if (isUnauthorized) {
            await clearSessionCookies();
        }

        const errorMessage = error.response?.data?.message || error.message || 'Internal server error';
        return NextResponse.json(
            { status: '99', message: errorMessage, datetime: formatDateSystem(new Date()), data: error.response?.data || null },
            { status: error.response?.status || 500 }
        );
    }
};

export const GET = async (request: NextRequest) => handleRequest(request, 'GET');
export const POST = async (request: NextRequest) => handleRequest(request, 'POST');
export const PUT = async (request: NextRequest) => handleRequest(request, 'PUT');

async function proxyCRUD(request: NextRequest, accessToken: string, method: 'GET' | 'POST' | 'PUT') {
    const url = new URL(request.url);
    const endpoint = request.headers.get('x-endpoint') || url.searchParams.get('endpoint');

    try {
        const headers: CustomHeaders = {};

        request.headers.forEach((value, key) => {
            if (key.toLowerCase().startsWith('x-')) {
                headers[key.toLowerCase() as keyof CustomHeaders] = value;
            }
        });

        if (!endpoint) {
            return NextResponse.json(
                { status: '99', message: 'Endpoint not specified', datetime: formatDateSystem(new Date()) },
                { status: 500 }
            );
        }

        let body: any = {};
        if (method !== 'GET') {
            body = await request.json().catch(() => ({}));
        }

        let customHeader: Record<string, any> = {};
        if (headers['x-custom-header']) {
            try {
                customHeader = JSON.parse(headers['x-custom-header']);
            } catch (e) {
                console.error('Failed to parse x-custom-header:', e);
            }
        }

        let requestHeaders: Record<string, string> = {
            'Content-Type': 'application/json',
            'X-Timestamp': formatDateISO(new Date()) as string,
            'Authorization': `Bearer ${accessToken}`,
            ...customHeader,
        };

        if (headers['x-kode-cabang']) {
            requestHeaders['X-Kode-Cabang'] = headers['x-kode-cabang'];
        }

        delete requestHeaders['X-Level'];
        const apiUrl = getBackendApiUrl();
        const targetUrl = `${apiUrl}${endpoint}`;

        let result;
        if (method === 'GET') {
            result = await axios.get(targetUrl, { headers: requestHeaders });
        } else if (method === 'PUT') {
            result = await axios.put(targetUrl, body, { headers: requestHeaders });
        } else {
            result = await axios.post(targetUrl, body, { headers: requestHeaders });
        }

        return NextResponse.json(result.data);

    } catch (err: any) {
        console.error(`BFF Interceptor proxyCRUD error [${method} ${endpoint}]:`, err?.response?.status, err?.response?.data || err?.message);
        if (err?.response?.status === 401) {
            await clearSessionCookies();
            return NextResponse.json(
                err?.response?.data || { error: 'Unauthorized' },
                { status: 401 }
            );
        }

        const resStatus = err?.response?.status || 500;
        const resData = err?.response?.data || {
            status: '99',
            message: err?.message || 'Internal server error',
            datetime: formatDateSystem(new Date()),
        };

        return NextResponse.json(resData, { status: resStatus });
    }
}