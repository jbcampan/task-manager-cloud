import { NextResponse } from 'next/server';
import client from 'prom-client';

declare global {
  // eslint-disable-next-line no-var
  var __prometheusRegister: client.Registry | undefined;
}

// A Next.js server process is long-lived under `next start` in this
// containerized deployment, so a Registry created once at module load
// time persists across requests. Guarded against Next.js dev-server
// hot-reload creating duplicate metric registrations, which prom-client
// throws on.
const register = globalThis.__prometheusRegister ?? new client.Registry();
if (!globalThis.__prometheusRegister) {
  client.collectDefaultMetrics({ register });
  globalThis.__prometheusRegister = register;
}

// Without this, Next.js may statically optimize this route at build time
// since it uses no dynamic APIs (cookies, headers) - which would freeze
// the response instead of recomputing live metrics on every scrape.
export const dynamic = 'force-dynamic';

export async function GET() {
  const metrics = await register.metrics();
  return new NextResponse(metrics, {
    status: 200,
    headers: { 'Content-Type': register.contentType },
  });
}
