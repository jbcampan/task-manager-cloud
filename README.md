# Task Manager Cloud-Native

A fullstack, cloud-native Task Manager built with Next.js 14, NestJS, PostgreSQL, and deployed on
AWS ECS Fargate with a complete CI/CD pipeline via GitHub Actions.

## Tech Stack

| Layer    | Technology                                                            |
| -------- | --------------------------------------------------------------------- |
| Frontend | Next.js 14 · TypeScript · Tailwind CSS (App Router)                   |
| Backend  | NestJS · TypeScript · Prisma ORM                                      |
| Database | PostgreSQL 16                                                         |
| Auth     | JWT · bcrypt · Passport.js                                            |
| Dev      | Docker · Docker Compose                                               |
| Cloud    | AWS ECS Fargate · RDS · ALB · ECR · S3 · CloudWatch · Secrets Manager |
| IaC      | Terraform                                                             |
| CI/CD    | GitHub Actions (OIDC — no static AWS keys)                            |

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                        AWS VPC                           │
│  ┌─────────────────┐       ┌──────────────────────────┐ │
│  │  Public Subnets │       │     Private Subnets      │ │
│  │                 │       │                          │ │
│  │  ┌───────────┐  │       │  ┌────────┐ ┌────────┐  │ │
│  │  │    ALB    │──┼───────┼──│ ECS    │ │  RDS   │  │ │
│  │  └───────────┘  │       │  │Fargate │ │Postgres│  │ │
│  │                 │       │  └────────┘ └────────┘  │ │
│  └─────────────────┘       └──────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
```

## Project Structure

```
task-manager-cloud/
├── apps/
│   ├── frontend/          # Next.js 14 App Router
│   └── backend/           # NestJS API
├── infra/                 # Terraform modules (VPC, ECS, RDS, S3, CloudWatch)
│   ├── modules/
│   └── environments/      # staging / prod
├── .github/workflows/     # CI (lint+test) + CD (build+deploy)
├── docker-compose.yml     # Local dev stack
└── docker-compose.prod.yml
```

## Getting Started

### Prerequisites

- Node.js >= 20
- Docker & Docker Compose
- AWS CLI configured (for infra)
- Terraform >= 1.6

### Local Development

```bash
# Clone & install dependencies
git clone <repo-url>
cd task-manager-cloud
npm install

# Copy and fill environment variables
cp apps/backend/.env.example apps/backend/.env
cp apps/frontend/.env.example apps/frontend/.env

# Start the full local stack (API + PostgreSQL + Adminer)
docker compose up -d

# Or run services individually
npm run dev:backend    # NestJS on :3001
npm run dev:frontend   # Next.js on :3000
```

### API Documentation

Swagger UI is available at `http://localhost:3001/api` when the backend is running.

### Infrastructure

```bash
cd infra/environments/staging
cp terraform.tfvars.example terraform.tfvars
# Fill terraform.tfvars

terraform init
terraform plan
terraform apply
```

## CI/CD Pipeline

| Trigger        | Workflow | Steps                                        |
| -------------- | -------- | -------------------------------------------- |
| Pull Request   | `ci.yml` | Lint → Tests → Build                         |
| Push to `main` | `cd.yml` | Build → Scan (Trivy) → Push ECR → Deploy ECS |

GitHub Actions uses OIDC to authenticate with AWS — no static credentials stored in secrets.

## Contributing

Commits follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(backend): add task priority field
fix(frontend): correct auth redirect loop
chore(infra): upgrade terraform aws provider
```

## License

MIT
