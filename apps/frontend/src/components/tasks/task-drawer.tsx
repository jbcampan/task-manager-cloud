'use client';

import { zodResolver } from '@hookform/resolvers/zod';
import { useState } from 'react';
import { useForm } from 'react-hook-form';

import { Button } from '@/components/ui/button';
import { Drawer } from '@/components/ui/drawer';
import { Input } from '@/components/ui/input';
import { Select } from '@/components/ui/select';
import { Textarea } from '@/components/ui/textarea';
import { createTaskAction } from '@/lib/actions/task.actions';
import { taskSchema, type TaskFormValues } from '@/lib/schemas/task.schema';
import { PRIORITY_LABELS, STATUS_LABELS } from '@/lib/task-styles';
import { TaskPriority, TaskStatus } from '@/lib/types/task';

interface TaskDrawerProps {
  open: boolean;
  onClose: () => void;
}

const DEFAULT_VALUES: TaskFormValues = {
  title: '',
  description: '',
  status: TaskStatus.TODO,
  priority: TaskPriority.MEDIUM,
  dueDate: '',
};

export function TaskDrawer({ open, onClose }: TaskDrawerProps) {
  const [serverError, setServerError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<TaskFormValues>({ resolver: zodResolver(taskSchema), defaultValues: DEFAULT_VALUES });

  const handleClose = () => {
    setServerError(null);
    reset(DEFAULT_VALUES);
    onClose();
  };

  const onSubmit = async (values: TaskFormValues) => {
    setServerError(null);

    const result = await createTaskAction({
      title: values.title,
      description: values.description || undefined,
      status: values.status,
      priority: values.priority,
      // The <input type="date"> yields "YYYY-MM-DD"; the backend expects a full ISO 8601 date-time.
      dueDate: values.dueDate ? new Date(values.dueDate).toISOString() : undefined,
    });

    if (result.error) {
      setServerError(result.error);
      return;
    }

    reset(DEFAULT_VALUES);
    onClose();
  };

  return (
    <Drawer open={open} onClose={handleClose} title="New Task">
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
            {isSubmitting ? 'Creating…' : 'Create Task'}
          </Button>
        </div>
      </form>
    </Drawer>
  );
}
