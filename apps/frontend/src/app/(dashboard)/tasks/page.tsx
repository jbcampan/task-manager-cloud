import { CheckCircle2, Clock, ListChecks, TriangleAlert } from 'lucide-react';

import { Button } from '@/components/ui/button';
import { StatCard } from '@/components/ui/stat-card';

// TODO (2.3): replace the static stats and the placeholder block below with
// live data fetched from GET /api/v1/tasks through the typed API client,
// plus the task table, filters and the create/edit drawer.
export default function TasksPage() {
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
          value="-"
          description="All tasks in your workspace"
        />
        <StatCard
          icon={Clock}
          iconClassName="bg-amber-100 text-amber-600"
          label="In Progress"
          value="-"
          description="Tasks currently in progress"
        />
        <StatCard
          icon={CheckCircle2}
          iconClassName="bg-green-100 text-green-600"
          label="Done"
          value="-"
          description="Tasks completed"
        />
        <StatCard
          icon={TriangleAlert}
          iconClassName="bg-red-100 text-red-600"
          label="Overdue"
          value="-"
          description="Tasks past due date"
        />
      </div>

      <div className="rounded-xl border border-slate-200 bg-white p-8 text-center text-sm text-slate-500 shadow-sm">
        Task list, filters and creation form will be implemented in Step 2.3.
      </div>
    </div>
  );
}
