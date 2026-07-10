'use client';

import { useState } from 'react';

import { TaskDrawer } from '@/components/tasks/task-drawer';
import { Button } from '@/components/ui/button';

/** Owns the open/closed state of the create drawer - kept separate from TasksPage, which stays a Server Component. */
export function NewTaskButton() {
  const [open, setOpen] = useState(false);

  return (
    <>
      <Button onClick={() => setOpen(true)}>+ New Task</Button>
      <TaskDrawer open={open} onClose={() => setOpen(false)} />
    </>
  );
}
