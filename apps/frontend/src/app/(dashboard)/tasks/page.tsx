import { CheckCircle2, Clock, ListChecks, TriangleAlert } from 'lucide-react';

import { TaskTable } from '@/components/tasks/task-table';
import { Button } from '@/components/ui/button';
import { StatCard } from '@/components/ui/stat-card';
import { getTasks } from '@/lib/api/tasks';
import { withSession } from '@/lib/session';
import { computeTaskStats } from '@/lib/tasks-stats';

// TODO: status filter tabs (Commit 3), "New Task" drawer (Commit 4).
export default async function TasksPage() {
  const tasks = await withSession((token) => getTasks(token));
  const stats = computeTaskStats(tasks);

  return (
    <div>
      <div className="mb-6 flex items-center justify-between">
        <h1 className="text-2xl font-semibold text-slate-900">My Tasks</h1>
        <Button>+ New Task</Button>
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

      <TaskTable tasks={tasks} />
    </div>
  );
}
