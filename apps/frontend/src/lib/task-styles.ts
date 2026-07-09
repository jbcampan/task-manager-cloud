import { TaskPriority, TaskStatus } from './types/task';

// Centralized so the table and the create/edit form
// always display the same labels and colors for a given enum value.
export const STATUS_LABELS: Record<TaskStatus, string> = {
  [TaskStatus.TODO]: 'To Do',
  [TaskStatus.IN_PROGRESS]: 'In Progress',
  [TaskStatus.DONE]: 'Done',
};

export const STATUS_BADGE_CLASSES: Record<TaskStatus, string> = {
  [TaskStatus.TODO]: 'bg-amber-50 text-amber-700',
  [TaskStatus.IN_PROGRESS]: 'bg-blue-50 text-blue-700',
  [TaskStatus.DONE]: 'bg-green-50 text-green-700',
};

export const PRIORITY_LABELS: Record<TaskPriority, string> = {
  [TaskPriority.LOW]: 'Low',
  [TaskPriority.MEDIUM]: 'Medium',
  [TaskPriority.HIGH]: 'High',
};

export const PRIORITY_BADGE_CLASSES: Record<TaskPriority, string> = {
  [TaskPriority.LOW]: 'bg-green-50 text-green-700',
  [TaskPriority.MEDIUM]: 'bg-amber-50 text-amber-700',
  [TaskPriority.HIGH]: 'bg-red-50 text-red-700',
};
