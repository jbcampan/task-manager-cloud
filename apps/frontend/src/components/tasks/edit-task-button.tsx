'use client';

import { Pencil } from 'lucide-react';
import { useState } from 'react';

import { TaskDrawer } from '@/components/tasks/task-drawer';
import type { Task } from '@/lib/types/task';

/** Owns the open/closed state of this row's edit drawer - one instance per task row. */
export function EditTaskButton({ task }: { task: Task }) {
  const [open, setOpen] = useState(false);

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        aria-label="Edit task"
        className="rounded-lg p-1.5 text-slate-500 hover:bg-slate-100 hover:text-slate-700"
      >
        <Pencil className="h-4 w-4" />
      </button>
      <TaskDrawer open={open} onClose={() => setOpen(false)} task={task} />
    </>
  );
}
