import type { ReactNode } from 'react';

import { Sidebar } from '@/components/layout/sidebar';

// TODO (2.2): protect this route group in src/middleware.ts — read the httpOnly
// session cookie and redirect unauthenticated requests to /login.
export default function DashboardLayout({ children }: { children: ReactNode }) {
  return (
    <div className="flex min-h-screen bg-slate-50">
      <Sidebar />
      <main className="flex-1 overflow-y-auto p-8">{children}</main>
    </div>
  );
}
