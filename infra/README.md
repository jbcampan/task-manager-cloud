# Infrastructure — Terraform

Terraform code provisioning the AWS infrastructure for the Task Manager Cloud-Native project. See
the [root README](../README.md) for the overall architecture diagram and project context.

## Layout

```
infra/
├── bootstrap/                # One-time setup: S3 bucket for all Terraform state
├── shared/                   # Resources shared across all environments:
│                             # ECR repositories, GitHub OIDC provider
├── _modules/                 # Reusable modules, instantiated per environment
│   ├── vpc/                  # VPC, public/private subnets, NAT Gateway, security groups
│   ├── rds/                  # PostgreSQL instance, subnet group
│   ├── ecs/                  # Cluster, task definitions, services, ALB, JWT secret
│   ├── s3/                   # Uploads bucket
│   ├── cloudwatch/           # Log groups, CPU/memory alarms, dashboard, SNS topic
│   └── iam-oidc/             # OIDC-trusted deploy role, scoped per environment
└── environments/
    ├── staging/               # Deployed continuously during development
    └── prod/                  # Same modules, deployed on demand for testing only
```

Each environment directory is a fully independent Terraform root module with its own state — an
`apply`/`destroy` in one environment can never affect the other.

## `bootstrap/` — the one module that has to run first

`infra/bootstrap` provisions exactly one thing: the S3 bucket that every other module's state lives
in (`aws_s3_bucket.tfstate`), with versioning, AES256 server-side encryption, and public access
fully blocked. `prevent_destroy` is set on the bucket itself — a safeguard against ever accidentally
deleting the thing every other environment's state depends on.

This creates an unavoidable chicken-and-egg problem: the bucket that hosts remote state can't itself
be created _into_ that same remote state before it exists. `bootstrap/` is therefore the one module
in this codebase that keeps its own state **local** (no `backend.tf`) rather than in S3 — a
deliberate, permanent exception, not a temporary bootstrapping step to migrate away from later. Its
local `terraform.tfstate` should be treated carefully (kept out of version control, backed up
separately) precisely because it isn't protected by the same S3 versioning it grants to everything
else.

**Apply order, top to bottom, each depending on the previous one's output**:

```
infra/bootstrap    → creates the S3 bucket
infra/shared        → creates ECR repos + the GitHub OIDC provider,
                       state stored in that bucket (shared/terraform.tfstate)
infra/environments/* → reference infra/shared's outputs via
                       data.terraform_remote_state, state stored in the
                       same bucket (staging/terraform.tfstate, prod/terraform.tfstate)
```

Note that the GitHub OIDC provider (`aws_iam_openid_connect_provider`) lives in `shared/`, not in
`bootstrap/` — `bootstrap/` is deliberately kept to the single responsibility of hosting state,
nothing else.

## State backend

State is stored in S3 (bucket declared per-environment in each `backend.tf`, one state file per
environment key: `staging/terraform.tfstate`, `prod/terraform.tfstate`, `shared/terraform.tfstate`).
Locking uses Terraform's native `use_lockfile` (S3 conditional writes), no DynamoDB table required —
this requires Terraform >= 1.14. The one exception is `bootstrap/`, whose own state stays local —
see above for why.

## Environment naming: two different "environment" values

This is the single most common source of confusion in this codebase, worth reading before touching
anything:

- **`var.environment`** (`"staging"` / `"prod"`) drives **AWS resource naming** — ECS cluster name,
  service names, IAM role names, log group names, all follow `${project_name}-${environment}`.
- **`var.github_environment`** (`"staging"` / `"production"`) is the name of the **GitHub
  Environment** that must exist in the repo's Settings, and is what the `iam-oidc` module's trust
  policy checks against (`repo:owner/repo:environment:<value>`). It is also what gates manual
  approval on production deployments.

Staging happens to use the same string (`"staging"`) for both, which hides the distinction.
Production does not: `var.environment = "prod"` but `var.github_environment = "production"`. Getting
this wrong produces either an OIDC `AssumeRoleWithWebIdentity` rejection, or a
`DescribeTaskDefinition` failure on a resource name that doesn't exist — see `docs/incidents.md` in
the project root for a real example.

## Cost-related choices specific to `prod`

Unlike a real production environment, `infra/environments/prod` is meant to be spun up punctually to
demonstrate the deployment flow, then destroyed — not left running. It is configured accordingly:

- `db_deletion_protection = false` — `terraform destroy` must succeed without a manual override.
- `db_skip_final_snapshot = true` — no final RDS snapshot is kept on destroy.
- `recovery_window_in_days = 0` on the JWT secret — no 30-day Secrets Manager recovery window, so
  re-applying right after a destroy doesn't collide with a secret name still pending deletion.

These are deliberate choices for a personal/learning project, not defaults recommended for a real
production database — see the "Key Architectural Decisions" section of the root README.

## Common commands

```bash
# Initialize (once per environment, or after adding a module)
cd infra/environments/staging   # or prod
terraform init

# Preview changes
terraform plan -var-file=terraform.tfvars -out=tfplan

# Apply
terraform apply tfplan

# List everything currently tracked in this environment's state
terraform state list

# Tear down (safe: only affects this environment's state)
terraform destroy -var-file=terraform.tfvars
```

## GitHub Actions configuration

The CD pipeline (`.github/workflows/cd.yml` + `.github/workflows/deploy-reusable.yml`) reads GitHub
Actions **variables** (not secrets — none of these values are sensitive, they're ARNs and resource
names) from two scopes:

**Repository variables** (`Settings → Secrets and variables → Actions → Variables`), shared across
environments:

| Variable                  | Source                                                                                      |
| ------------------------- | ------------------------------------------------------------------------------------------- |
| `ECR_BACKEND_REPOSITORY`  | `shared` state output `ecr_backend_repository_url`                                          |
| `ECR_FRONTEND_REPOSITORY` | `shared` state output `ecr_frontend_repository_url`                                         |
| `PROD_INFRA_READY`        | `true` only while `prod` is actually deployed — keeps `deploy-prod` a clean no-op otherwise |

**Per-Environment variables** (`Settings → Environments → staging` /
`production → Environment variables`), one full set per environment:

| Variable                | Source (Terraform output in that environment)                                                           |
| ----------------------- | ------------------------------------------------------------------------------------------------------- |
| `DEPLOY_ROLE_ARN`       | `deploy_role_arn`                                                                                       |
| `PROJECT_NAME`          | `"task-manager"`                                                                                        |
| `ENVIRONMENT`           | `"staging"` or `"prod"` — **not** `"production"`, see above                                             |
| `ECS_CLUSTER`           | `ecs_cluster_name`                                                                                      |
| `ECS_BACKEND_SERVICE`   | `"task-manager-<environment>-backend"`                                                                  |
| `ECS_FRONTEND_SERVICE`  | `"task-manager-<environment>-frontend"`                                                                 |
| `PRIVATE_SUBNET_IDS`    | `private_subnet_ids`, comma-separated: `terraform output -json private_subnet_ids \| jq -r 'join(",")'` |
| `ECS_SECURITY_GROUP_ID` | `ecs_security_group_id`                                                                                 |
| `APP_URL`               | `app_url`                                                                                               |

The `production` Environment additionally needs a **required reviewer** configured
(`Settings → Environments → production → Deployment protection rules`) — this is what makes the CD
pipeline pause for manual approval before deploying to prod.
