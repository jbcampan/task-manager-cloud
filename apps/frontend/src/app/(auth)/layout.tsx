import { SquareCheckBig } from 'lucide-react';
import type { ReactNode } from 'react';

export default function AuthLayout({ children }: { children: ReactNode }) {
  return (
    <div className="relative flex min-h-screen flex-col items-center justify-center overflow-hidden bg-slate-50 px-4 py-12">
      {/* Decorative background wave - purely visual, no semantic content */}
      <svg
        aria-hidden="true"
        className="pointer-events-none absolute inset-x-0 bottom-0 h-64 w-full text-slate-100"
        viewBox="0 0 1440 320"
        preserveAspectRatio="none"
      >
        <path
          fill="currentColor"
          d="M0,192L80,181.3C160,171,320,149,480,154.7C640,160,800,192,960,197.3C1120,203,1280,181,1360,170.7L1440,160L1440,320L0,320Z"
        />
      </svg>

      <div className="relative z-10 flex w-full max-w-md flex-col items-center">
        <div className="mb-8 flex items-center gap-2">
          <SquareCheckBig className="h-8 w-8 text-brand" />
          <span className="text-2xl font-semibold text-slate-900">TaskFlow</span>
        </div>

        <div className="w-full rounded-2xl border border-slate-200 bg-white p-8 shadow-sm">
          {children}
        </div>

        <p className="mt-8 text-center text-xs text-slate-400">
          © {new Date().getFullYear()} TaskFlow. All rights reserved.
          <br />
          <a href="#" className="hover:text-slate-600 hover:underline">
            Privacy Policy
          </a>{' '}
          ·{' '}
          <a href="#" className="hover:text-slate-600 hover:underline">
            Terms of Service
          </a>
        </p>
      </div>
    </div>
  );
}
