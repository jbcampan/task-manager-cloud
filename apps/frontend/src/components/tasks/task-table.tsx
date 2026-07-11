import { CalendarDays, Trash2 } from 'lucide-react';

import { EditTaskButton } from '@/components/tasks/edit-task-button';
import { Badge } from '@/components/ui/badge';
import {
  PRIORITY_BADGE_CLASSES,
  PRIORITY_LABELS,
  STATUS_BADGE_CLASSES,
  STATUS_LABELS,
} from '@/lib/task-styles';
import type { Task } from '@/lib/types/task';
import { formatDate } from '@/lib/utils';

interface TaskTableProps {
  tasks: Task[];
}

export function TaskTable({ tasks }: TaskTableProps) {
  if (tasks.length === 0) {
    return (
      <div className="rounded-xl border border-slate-200 bg-white p-8 text-center text-sm text-slate-500 shadow-sm">
        No tasks yet. Create your first task to get started.
      </div>
    );
  }

  return (
    <div className="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
      <table className="w-full text-left text-sm">
        <thead className="border-b border-slate-200 bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
          <tr>
            <th className="px-4 py-3 font-medium">Task</th>
            <th className="px-4 py-3 font-medium">Priority</th>
            <th className="px-4 py-3 font-medium">Status</th>
            <th className="px-4 py-3 font-medium">Due Date</th>
            <th className="px-4 py-3 font-medium text-right">Actions</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-slate-100">
          {tasks.map((task) => (
            <tr key={task.id} className="hover:bg-slate-50">
              <td className="max-w-xs px-4 py-3">
                <p className="font-medium text-slate-900">{task.title}</p>
                {task.description && (
                  <p className="mt-0.5 truncate text-xs text-slate-500">{task.description}</p>
                )}
              </td>
              <td className="px-4 py-3">
                <Badge
                  label={PRIORITY_LABELS[task.priority]}
                  className={PRIORITY_BADGE_CLASSES[task.priority]}
                />
              </td>
              <td className="px-4 py-3">
                <Badge
                  label={STATUS_LABELS[task.status]}
                  className={STATUS_BADGE_CLASSES[task.status]}
                />
              </td>
              <td className="px-4 py-3 text-slate-500">
                {task.dueDate ? (
                  <span className="inline-flex items-center gap-1.5">
                    <CalendarDays className="h-3.5 w-3.5" />
                    {formatDate(task.dueDate)}
                  </span>
                ) : (
                  '-'
                )}
              </td>
              <td className="px-4 py-3">
                <div className="flex justify-end gap-1">
                  <EditTaskButton task={task} />
                  <button
                    type="button"
                    disabled
                    aria-label="Delete task"
                    className="cursor-not-allowed rounded-lg p-1.5 text-slate-300"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
