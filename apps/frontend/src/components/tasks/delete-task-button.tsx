'use client';

import { Trash2 } from 'lucide-react';
import { useState } from 'react';

import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { deleteTaskAction } from '@/lib/actions/task.actions';
import type { Task } from '@/lib/types/task';

/** Owns the confirmation dialog, and deletion state for a single task row. */
export function DeleteTaskButton({ task }: { task: Task }) {
  const [open, setOpen] = useState(false);
  const [isDeleting, setIsDeleting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleConfirm = async () => {
    setIsDeleting(true);
    setError(null);

    const result = await deleteTaskAction(task.id);

    if (result.error) {
      setError(result.error);
      setIsDeleting(false);
      return;
    }

    setIsDeleting(false);
    setOpen(false);
  };

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        aria-label="Delete task"
        className="rounded-lg p-1.5 text-slate-500 hover:bg-red-50 hover:text-red-600"
      >
        <Trash2 className="h-4 w-4" />
      </button>

      <ConfirmDialog
        open={open}
        title="Delete task"
        description={`Are you sure you want to delete "${task.title}"? This action cannot be undone.`}
        confirmLabel="Delete"
        isLoading={isDeleting}
        onConfirm={handleConfirm}
        onCancel={() => setOpen(false)}
      />
      {/* Kept minimal on purpose: a failed deletion is rare (network/401 already handled
          by withSession) - an inline message below the row action is enough, no need
          for the dialog's own error banner pattern used in the create/edit form. */}
      {error && <p className="mt-1 text-xs text-red-600">{error}</p>}
    </>
  );
}
