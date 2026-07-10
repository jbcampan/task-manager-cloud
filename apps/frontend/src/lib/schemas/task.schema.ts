import { z } from 'zod';

import { TaskPriority, TaskStatus } from '@/lib/types/task';

const taskStatusValues = Object.values(TaskStatus) as [TaskStatus, ...TaskStatus[]];
const taskPriorityValues = Object.values(TaskPriority) as [TaskPriority, ...TaskPriority[]];

// Mirrors the constraints of the backend CreateTaskDto (tasks/dto/create-task.dto.ts).
// description/dueDate stay plain strings here (possibly empty) - the empty case is
// converted to `undefined` when building the API payload, not inside the schema.
export const taskSchema = z.object({
  title: z.string().min(1, 'Title is required.').max(200, 'Title must be at most 200 characters.'),
  description: z.string().max(2000, 'Description must be at most 2000 characters.'),
  status: z.enum(taskStatusValues),
  priority: z.enum(taskPriorityValues),
  dueDate: z.string(),
});

export type TaskFormValues = z.infer<typeof taskSchema>;
