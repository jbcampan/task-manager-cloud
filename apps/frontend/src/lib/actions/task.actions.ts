'use server';

import { revalidatePath } from 'next/cache';

import { createTask } from '@/lib/api/tasks';
import { withSession } from '@/lib/session';
import type { CreateTaskPayload } from '@/lib/types/task';

interface ActionResult {
  error?: string;
}

/** Server Action: creates a task via POST /tasks and refreshes the /tasks page cache. */
export async function createTaskAction(payload: CreateTaskPayload): Promise<ActionResult> {
  try {
    await withSession((token) => createTask(token, payload));
  } catch (error) {
    // withSession already handles a 401 by redirecting - anything reaching here
    // is a real validation/server error to surface in the form.
    return { error: error instanceof Error ? error.message : 'Unable to create the task.' };
  }

  revalidatePath('/tasks');
  return {};
}
