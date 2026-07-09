import 'server-only';

import { apiFetch } from '@/lib/api';
import type { CreateTaskPayload, Task, TaskStatus, UpdateTaskPayload } from '@/lib/types/task';

export function getTasks(token: string, status?: TaskStatus): Promise<Task[]> {
  const query = status ? `?status=${status}` : '';
  return apiFetch<Task[]>(`/tasks${query}`, { method: 'GET', token });
}

export function createTask(token: string, payload: CreateTaskPayload): Promise<Task> {
  return apiFetch<Task>('/tasks', {
    method: 'POST',
    body: JSON.stringify(payload),
    token,
  });
}

export function updateTask(token: string, id: string, payload: UpdateTaskPayload): Promise<Task> {
  return apiFetch<Task>(`/tasks/${id}`, {
    method: 'PATCH',
    body: JSON.stringify(payload),
    token,
  });
}

export function deleteTask(token: string, id: string): Promise<Task> {
  return apiFetch<Task>(`/tasks/${id}`, { method: 'DELETE', token });
}
