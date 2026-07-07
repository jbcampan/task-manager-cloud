'use client';

import { Eye, EyeOff, Lock } from 'lucide-react';
import type { InputHTMLAttributes } from 'react';
import { forwardRef, useState } from 'react';

import { cn } from '@/lib/utils';

type PasswordInputProps = InputHTMLAttributes<HTMLInputElement>;

export const PasswordInput = forwardRef<HTMLInputElement, PasswordInputProps>(
  ({ className, ...props }, ref) => {
    const [visible, setVisible] = useState(false);

    return (
      <div className="relative">
        <Lock className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
        <input
          ref={ref}
          type={visible ? 'text' : 'password'}
          className={cn(
            'h-11 w-full rounded-lg border border-slate-300 pl-10 pr-10 text-sm text-slate-900 placeholder:text-slate-400',
            'focus:border-brand focus:outline-none focus:ring-1 focus:ring-brand',
            className,
          )}
          {...props}
        />
        <button
          type="button"
          onClick={() => setVisible((v) => !v)}
          aria-label={visible ? 'Hide password' : 'Show password'}
          className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
        >
          {visible ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
        </button>
      </div>
    );
  },
);

PasswordInput.displayName = 'PasswordInput';
