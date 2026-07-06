'use client';

import { LayoutDashboard, ListTodo, LogOut, Settings, SquareCheckBig } from 'lucide-react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';

import { cn } from '@/lib/utils';

const navItems = [
  { href: '/tasks', label: 'Dashboard', icon: LayoutDashboard },
  { href: '/tasks', label: 'Tasks', icon: ListTodo },
  { href: '/settings', label: 'Settings', icon: Settings },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="flex h-screen w-60 shrink-0 flex-col justify-between border-r border-slate-200 bg-white px-4 py-6">
      <div>
        <div className="mb-8 flex items-center gap-2 px-2">
          <SquareCheckBig className="h-6 w-6 text-brand" />
          <span className="text-lg font-semibold text-slate-900">TaskFlow</span>
        </div>

        <nav className="flex flex-col gap-1">
          {navItems.map(({ href, label, icon: Icon }) => {
            const isActive = label === 'Dashboard' ? pathname.startsWith('/tasks') : false;

            return (
              <Link
                key={label}
                href={href}
                className={cn(
                  'flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors',
                  isActive ? 'bg-brand text-white' : 'text-slate-600 hover:bg-slate-100',
                )}
              >
                <Icon className="h-4 w-4" />
                {label}
              </Link>
            );
          })}
        </nav>
      </div>

      <button
        type="button"
        className="flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium text-red-500 hover:bg-red-50"
      >
        {/* TODO (2.2): clear the httpOnly session cookie via a server action and redirect to /login */}
        <LogOut className="h-4 w-4" />
        Logout
      </button>
    </aside>
  );
}
