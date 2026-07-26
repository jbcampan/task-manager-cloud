# Backend — NestJS

REST API for the Task Manager application. See the [root README](../../README.md) for the overall
project context and architecture.

## Stack

NestJS + TypeScript, PostgreSQL via Prisma ORM, JWT auth via Passport.js + bcrypt, input validation
via class-validator/class-transformer, Swagger/OpenAPI.

## Run locally

```bash
# from the repository root — starts backend + postgres + adminer
docker compose up backend postgres adminer
```

Or standalone, against a local Postgres:

```bash
cd apps/backend
cp .env.example .env       # fill in DATABASE_URL, JWT_SECRET, etc.
npm install
npx prisma migrate dev     # applies migrations, generates the Prisma client
npm run start:dev
```

- API: `http://localhost:3001`
- Swagger UI: `http://localhost:3001/api/docs`
- Health checks: `GET /health/live` (liveness), `GET /health/ready` (readiness — checks DB
  connectivity)

## Common commands

```bash
npm run start:dev          # dev server with hot reload
npm run build               # production build (dist/)
npm run test                 # unit tests (Jest)
npm run test:e2e             # e2e tests against critical routes
npm run lint                 # ESLint

npx prisma migrate dev --name <description>   # create + apply a new migration
npx prisma migrate deploy                       # apply pending migrations only (used in CD, never in dev)
npx prisma studio                                 # browse the database
```

## Project layout

```
src/
├── auth/          # login, register, JWT/local strategies, guards, auth.service.spec.ts
├── tasks/          # CRUD, DTOs, tasks.service.spec.ts
├── users/          # Users module
├── health/          # Liveness/readiness health checks (@nestjs/terminus)
│   ├── health.controller.ts   # GET /health/live, GET /health/ready
│   ├── health.module.ts
│   └── prisma.health.ts        # Custom indicator: checks DB connectivity
├── prisma/          # PrismaService - injectable wrapper around Prisma Client
│   ├── prisma.module.ts        # Not to be confused with prisma/ below,
│   └── prisma.service.ts       # which holds the schema and migrations
├── common/          # Shared decorators, filters, interceptors
│                     # (input validation uses Nest's global ValidationPipe,
│                     #  registered in main.ts — no custom pipe needed)
├── app.module.ts
└── main.ts          # Bootstrap: Swagger, CORS, Helmet, global ValidationPipe, graceful shutdown hooks
prisma/
├── schema.prisma
└── migrations/       # One directory per migration — never edit an already-applied one
test/
├── app.e2e-spec.ts    # e2e tests against critical routes (auth, tasks)
└── jest-e2e.json       # Jest config for the e2e run (npm run test:e2e)
```

Unit tests (`*.service.spec.ts`) live next to the service they test (e.g.
`auth/auth.service.spec.ts`) rather than in a separate mirror tree — standard Jest/NestJS
convention, picked up automatically by `npm run test`.

## Notes

- **Never hand-edit a `migration.sql` file that has already run anywhere** (staging or prod). Prisma
  tracks applied migrations by checksum in the `_prisma_migrations` table; editing a past migration
  causes `migrate deploy` to refuse to continue. Always create a new migration instead.
- **Graceful shutdown** is enabled via `app.enableShutdownHooks()` in `main.ts` — required for
  zero-downtime rolling updates on ECS (and later, Kubernetes).
- The production Docker image removes `npm`/`npx`/`corepack` from the runtime stage entirely (see
  `Dockerfile`) to eliminate a known CVE in the bundled `tar` dependency of npm — the container only
  ever runs `node dist/main.js` at runtime.
