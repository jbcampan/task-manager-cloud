import { CheckCircle2, Clock, ListChecks, TriangleAlert } from 'lucide-react';

import { NewTaskButton } from '@/components/tasks/new-task-button';
import { StatusTabs } from '@/components/tasks/status-tabs';
import { TaskTable } from '@/components/tasks/task-table';
import { StatCard } from '@/components/ui/stat-card';
import { getTasks } from '@/lib/api/tasks';
import { withSession } from '@/lib/session';
import { computeTaskStats } from '@/lib/tasks-stats';
import { TaskStatus } from '@/lib/types/task';

interface TasksPageProps {
  searchParams: { status?: string };
}

// Narrows the raw query string to a real TaskStatus, ignoring unknown/invalid values
// (e.g. someone editing the URL by hand) rather than letting them reach the API.
function parseStatusParam(value?: string): TaskStatus | undefined {
  return value && Object.values(TaskStatus).includes(value as TaskStatus)
    ? (value as TaskStatus)
    : undefined;
}

export default async function TasksPage({ searchParams }: TasksPageProps) {
  const activeStatus = parseStatusParam(searchParams.status);

  // Stats always reflect the full task list, regardless of the active filter tab -
  // otherwise "Overdue" would show 0 while viewing the "Done" tab, which would be misleading.
  const [allTasks, filteredTasks] = await withSession(async (token) => {
    const all = await getTasks(token);
    const filtered = activeStatus ? all.filter((t) => t.status === activeStatus) : all;
    return [all, filtered] as const;
  });

  const stats = computeTaskStats(allTasks);

  return (
    <div>
      <div className="mb-6 flex items-center justify-between">
        <h1 className="text-2xl font-semibold text-slate-900">My Tasks</h1>
        <NewTaskButton />
      </div>

      <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard
          icon={ListChecks}
          iconClassName="bg-blue-100 text-blue-600"
          label="Total tasks"
          value={stats.total}
          description="All tasks in your workspace"
        />
        <StatCard
          icon={Clock}
          iconClassName="bg-amber-100 text-amber-600"
          label="In Progress"
          value={stats.inProgress}
          description="Tasks currently in progress"
        />
        <StatCard
          icon={CheckCircle2}
          iconClassName="bg-green-100 text-green-600"
          label="Done"
          value={stats.done}
          description="Tasks completed"
        />
        <StatCard
          icon={TriangleAlert}
          iconClassName="bg-red-100 text-red-600"
          label="Overdue"
          value={stats.overdue}
          description="Tasks past due date"
        />
      </div>

      <StatusTabs activeStatus={activeStatus} />
      <TaskTable tasks={filteredTasks} />
    </div>
  );
}
