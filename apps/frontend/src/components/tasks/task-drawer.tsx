'use client';

import { zodResolver } from '@hookform/resolvers/zod';
import { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';

import { Button } from '@/components/ui/button';
import { Drawer } from '@/components/ui/drawer';
import { Input } from '@/components/ui/input';
import { Select } from '@/components/ui/select';
import { Textarea } from '@/components/ui/textarea';
import { createTaskAction, updateTaskAction } from '@/lib/actions/task.actions';
import { taskSchema, type TaskFormValues } from '@/lib/schemas/task.schema';
import { PRIORITY_LABELS, STATUS_LABELS } from '@/lib/task-styles';
import { TaskPriority, TaskStatus, type Task } from '@/lib/types/task';

interface TaskDrawerProps {
  open: boolean;
  onClose: () => void;
  /** Absent = create mode. Present = edit mode, pre-fills and submits via updateTaskAction. */
  task?: Task;
}

function buildDefaultValues(task?: Task): TaskFormValues {
  return {
    title: task?.title ?? '',
    description: task?.description ?? '',
    status: task?.status ?? TaskStatus.TODO,
    priority: task?.priority ?? TaskPriority.MEDIUM,
    // ISO string from the API ("2026-07-08T00:00:00.000Z") sliced down to the
    // "YYYY-MM-DD" shape an <input type="date"> expects.
    dueDate: task?.dueDate ? task.dueDate.slice(0, 10) : '',
  };
}

export function TaskDrawer({ open, onClose, task }: TaskDrawerProps) {
  const isEditing = Boolean(task);
  const [serverError, setServerError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<TaskFormValues>({
    resolver: zodResolver(taskSchema),
    defaultValues: buildDefaultValues(task),
  });

  // Re-sync the form with this task's data every time the drawer opens - the
  // component itself stays mounted between opens/closes (for the slide animation),
  // so `defaultValues` alone would only apply once, on first mount.
  useEffect(() => {
    if (open) {
      reset(buildDefaultValues(task));
    }
  }, [open, task, reset]);

  const handleClose = () => {
    setServerError(null);
    onClose();
  };

  const onSubmit = async (values: TaskFormValues) => {
    setServerError(null);

    const payload = {
      title: values.title,
      description: values.description || undefined,
      status: values.status,
      priority: values.priority,
      dueDate: values.dueDate ? new Date(values.dueDate).toISOString() : undefined,
    };

    // Narrowing on `task` directly (rather than the derived `isEditing` boolean)
    // lets TypeScript prove `task` is defined in this branch - no `!` needed.
    const result = task
      ? await updateTaskAction(task.id, payload)
      : await createTaskAction(payload);

    if (result.error) {
      setServerError(result.error);
      return;
    }

    onClose();
  };

  return (
    <Drawer open={open} onClose={handleClose} title={isEditing ? 'Edit Task' : 'New Task'}>
      <form onSubmit={handleSubmit(onSubmit)} noValidate className="flex flex-col gap-5">
        {serverError && (
          <p role="alert" className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-600">
            {serverError}
          </p>
        )}

        <div>
          <label htmlFor="title" className="mb-1.5 block text-sm font-medium text-slate-700">
            Title
          </label>
          <Input id="title" placeholder="e.g. Deploy backend to ECS" {...register('title')} />
          {errors.title && <p className="mt-1 text-xs text-red-600">{errors.title.message}</p>}
        </div>

        <div>
          <label htmlFor="description" className="mb-1.5 block text-sm font-medium text-slate-700">
            Description
          </label>
          <Textarea
            id="description"
            rows={4}
            placeholder="Describe the task…"
            {...register('description')}
          />
          {errors.description && (
            <p className="mt-1 text-xs text-red-600">{errors.description.message}</p>
          )}
        </div>

        <div>
          <label htmlFor="priority" className="mb-1.5 block text-sm font-medium text-slate-700">
            Priority
          </label>
          <Select id="priority" {...register('priority')}>
            {Object.values(TaskPriority).map((priority) => (
              <option key={priority} value={priority}>
                {PRIORITY_LABELS[priority]}
              </option>
            ))}
          </Select>
        </div>

        <div>
          <label htmlFor="status" className="mb-1.5 block text-sm font-medium text-slate-700">
            Status
          </label>
          <Select id="status" {...register('status')}>
            {Object.values(TaskStatus).map((status) => (
              <option key={status} value={status}>
                {STATUS_LABELS[status]}
              </option>
            ))}
          </Select>
        </div>

        <div>
          <label htmlFor="dueDate" className="mb-1.5 block text-sm font-medium text-slate-700">
            Due date
          </label>
          <Input id="dueDate" type="date" {...register('dueDate')} />
        </div>

        <div className="mt-2 flex justify-end gap-3">
          <Button type="button" variant="secondary" onClick={handleClose}>
            Cancel
          </Button>
          <Button type="submit" disabled={isSubmitting}>
            {isSubmitting
              ? isEditing
                ? 'Saving…'
                : 'Creating…'
              : isEditing
                ? 'Save Changes'
                : 'Create Task'}
          </Button>
        </div>
      </form>
    </Drawer>
  );
}
