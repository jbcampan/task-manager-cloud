import Link from 'next/link';

import { STATUS_LABELS } from '@/lib/task-styles';
import { TaskStatus } from '@/lib/types/task';
import { cn } from '@/lib/utils';

interface StatusTabsProps {
  /** Currently active tab - undefined means "All". */
  activeStatus?: TaskStatus;
}

const TABS: { label: string; status?: TaskStatus }[] = [
  { label: 'All', status: undefined },
  { label: STATUS_LABELS[TaskStatus.TODO], status: TaskStatus.TODO },
  { label: STATUS_LABELS[TaskStatus.IN_PROGRESS], status: TaskStatus.IN_PROGRESS },
  { label: STATUS_LABELS[TaskStatus.DONE], status: TaskStatus.DONE },
];

export function StatusTabs({ activeStatus }: StatusTabsProps) {
  return (
    <div className="mb-4 flex gap-1 rounded-lg border border-slate-200 bg-white p-1 shadow-sm w-fit">
      {TABS.map(({ label, status }) => {
        const isActive = activeStatus === status;
        const href = status ? `/tasks?status=${status}` : '/tasks';

        return (
          <Link
            key={label}
            href={href}
            className={cn(
              'rounded-md px-4 py-1.5 text-sm font-medium transition-colors',
              isActive ? 'bg-brand text-white' : 'text-slate-600 hover:bg-slate-100',
            )}
          >
            {label}
          </Link>
        );
      })}
    </div>
  );
}
