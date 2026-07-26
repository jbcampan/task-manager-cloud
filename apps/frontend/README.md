# Frontend — Next.js

Web client for the Task Manager application. See the [root README](../../README.md) for the overall
project context and architecture.

## Stack

Next.js 14 (App Router) + TypeScript + Tailwind CSS. Auth session stored in an httpOnly cookie, set
server-side by a Route Handler that forwards credentials to the backend.

## Run locally

```bash
# from the repository root — starts frontend + backend + postgres
docker compose up
```

Or standalone, against a running backend:

```bash
cd apps/frontend
cp .env.example .env   # set API_URL and COOKIE_SECURE=false for local dev
npm install
npm run dev
```

- App: `http://localhost:3000`

## Common commands

```bash
npm run dev      # dev server with hot reload
npm run build     # production build (standalone output)
npm run start      # run the production build locally
npm run lint       # ESLint
```

## Project layout

```
src/
├── app/
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   ├── register/page.tsx
│   │   └── layout.tsx        # Redirects away if already authenticated
│   ├── (dashboard)/
│   │   ├── tasks/page.tsx
│   │   ├── settings/page.tsx
│   │   └── layout.tsx         # Protected: redirects to /login if no session
│   ├── layout.tsx               # Root layout
│   └── page.tsx                  # Redirects to /tasks
├── components/
│   ├── ui/                        # Generic building blocks: button, input, badge, drawer, checkbox, confirm-dialog...
│   ├── auth/                       # login-form.tsx, register-form.tsx
│   ├── tasks/                       # task-table, task-drawer, status-tabs, new/edit/delete-task-button
│   └── layout/                       # sidebar.tsx
├── lib/
│   ├── actions/                       # Next.js Server Actions ('use server') — see Notes below
│   │   ├── auth.actions.ts
│   │   └── task.actions.ts
│   ├── api/
│   │   └── tasks.ts                    # Typed fetch calls to the backend's /tasks routes
│   ├── schemas/                         # Zod validation schemas — see Notes below
│   │   ├── auth.schema.ts
│   │   └── task.schema.ts
│   ├── types/                            # Shared TS types: auth.ts, task.ts
│   ├── api.ts                             # Base typed fetch wrapper, calls the backend at API_URL
│   ├── auth.ts                             # Session cookie helpers (set/get/clear)
│   ├── session.ts                           # withSession() — server-side helper reading the cookie
│   │                                        # and redirecting to /login on a 401 from the backend
│   ├── constants.ts
│   ├── task-styles.ts
│   ├── tasks-stats.ts
│   └── utils.ts
└── middleware.ts                            # Route protection — see Notes below
```

## Notes

- **Mutations go through Next.js Server Actions (`'use server'`), not client-side fetch calls.**
  `lib/actions/auth.actions.ts` and `lib/actions/task.actions.ts` run entirely on the Next.js
  server: they call the backend, set/clear the session cookie or call `revalidatePath`, and
  `redirect()` — the browser never talks to the backend directly.
- **Validation is duplicated by design, not by accident.** `lib/schemas/*.schema.ts` are Zod schemas
  that intentionally mirror the backend's class-validator DTOs (e.g. `task.schema.ts`'s `title`
  length limit matches `CreateTaskDto`'s). The Zod schema gives instant client-side feedback; the
  backend DTO remains the actual source of truth and is validated again independently on every
  request — the frontend check is a UX convenience, not a security boundary.
- **Route protection is layered, not enforced in a single place:**
  1. `middleware.ts` runs first, on the edge, and only checks whether the session cookie is
     _present_ — redirecting to `/login` if a protected path (`/tasks`, `/settings`) is hit without
     one, or away from `/login`/`/register` if already signed in. It never inspects the JWT itself.
  2. Real authorization happens server-side, inside Server Actions, via `lib/session.ts`'s
     `withSession()` helper: it reads the cookie, calls the backend, and if the backend responds
     `401` (expired/invalid JWT), it redirects to `/login` — the same outcome as the middleware, but
     based on the backend's actual validation rather than the cookie merely existing.

  In short: `middleware.ts` is a fast UX gate against obviously-unauthenticated requests; the NestJS
  `JwtAuthGuard` on the backend is the actual security boundary. This mirrors the same principle as
  the Zod/class-validator duplication above — client-side checks improve the experience, server-side
  checks are what actually protects the data.

- **`COOKIE_SECURE`, not `NODE_ENV`, controls the session cookie's `Secure` attribute**
  (`lib/auth.ts`). The ALB currently serves HTTP only (no ACM certificate/domain in front of it), so
  a cookie marked `Secure` would never be sent back by the browser even with `NODE_ENV=production`.
  Keep `COOKIE_SECURE=false` until HTTPS is added — see `docs/incidents.md` at the project root for
  the full story.
- The production Docker image uses Next.js's `standalone` output (`next.config.ts`) and removes
  `npm`/`npx`/`corepack` from the runtime stage, same as the backend — the container only ever runs
  `node apps/frontend/server.js`.
- The frontend calls the backend at `API_URL`, same-origin behind the ALB's path-based routing
  (`/api/*`) — no cross-origin requests, no CORS configuration needed for that path in normal
  operation.
