import { TaskStatus, type Task } from './types/task';

export interface TaskStats {
  total: number;
  inProgress: number;
  done: number;
  overdue: number;
}

/** Computes the dashboard stat cards from the task list - no separate API call needed. */
export function computeTaskStats(tasks: Task[]): TaskStats {
  const now = new Date();

  return {
    total: tasks.length,
    inProgress: tasks.filter((t) => t.status === TaskStatus.IN_PROGRESS).length,
    done: tasks.filter((t) => t.status === TaskStatus.DONE).length,
    overdue: tasks.filter(
      (t) => t.status !== TaskStatus.DONE && t.dueDate !== null && new Date(t.dueDate) < now,
    ).length,
  };
}
