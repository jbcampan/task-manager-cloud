import type { LucideIcon } from 'lucide-react';
import type { InputHTMLAttributes } from 'react';
import { forwardRef } from 'react';

import { cn } from '@/lib/utils';

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  icon?: LucideIcon;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ className, icon: Icon, ...props }, ref) => {
    return (
      <div className="relative">
        {Icon && (
          <Icon className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
        )}
        <input
          ref={ref}
          className={cn(
            'h-11 w-full rounded-lg border border-slate-300 text-sm text-slate-900 placeholder:text-slate-400',
            'focus:border-brand focus:outline-none focus:ring-1 focus:ring-brand',
            Icon ? 'pl-10 pr-3' : 'px-3',
            className,
          )}
          {...props}
        />
      </div>
    );
  },
);

Input.displayName = 'Input';
