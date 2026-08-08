# Incidents Encountered and Resolutions

A log of real problems hit while deploying and operating this project's infrastructure, kept as a
technical reference.

---

## 1. RDS refuses to create — `FreeTierRestrictionError`

**Context**: first `terraform apply` of the staging environment, creating the RDS instance.

**Error**

```
Error: creating RDS DB Instance (task-manager-staging-db): operation error RDS:
CreateDBInstance, https response error StatusCode: 400, RequestID:
9a43884e-6413-4bdc-87cd-2a94ba6cc9bc, api error FreeTierRestrictionError: The
specified backup retention period exceeds the maximum available to free tier
customers. To remove all limitations, upgrade your account plan.

  with module.rds.aws_db_instance.this,
  on ..\..\_modules\rds\main.tf line 21, in resource "aws_db_instance" "this":
  21: resource "aws_db_instance" "this" {
```

**Root cause**: the RDS module requested a `backup_retention_period` higher than what the AWS Free
Tier account allows. The error comes directly from the RDS API — Terraform is just relaying the
rejection, this isn't a Terraform syntax problem.

**Fix**: lower `backup_retention_period` to a Free-Tier-compatible value in `terraform.tfvars` —
consistent anyway with the broader choice of minimizing cost on a learning/demo environment rather
than treating it like a real production database with strict retention requirements.

**Lesson**: Free Tier quotas aren't always surfaced by a "clean-looking" module's default values —
they only show up against the real API at apply time. A `terraform plan` doesn't catch this since it
doesn't make a creation call. Since then: read the raw API error message first before assuming the
problem is in the Terraform code.

---

## 2. Pinned PostgreSQL minor version — broken by AWS retiring old releases

**Context**: a staging redeploy fails months after the first successful `apply`, with no changes to
any `.tf` file in between.

**Root cause**: the RDS module pinned an exact minor version (`engine_version = "16.4"`). AWS
periodically retires old PostgreSQL minor releases from RDS's available catalog — the version
available at the time of the first `apply` had since disappeared.

**Fix**: AWS documentation confirms only the major version needs to be specified. If
`engine_version` is set to just `"16"` (no minor part), RDS automatically resolves to the latest
available minor version at creation time — the recommended approach to avoid this class of breakage
recurring.

```hcl
# infra/_modules/rds/variables.tf
variable "engine_version" {
  description = "PostgreSQL engine version. Major version only (e.g. \"16\") - RDS automatically resolves this to the latest available minor version at creation time, avoiding hardcoded minor versions that AWS periodically retires."
  type        = string
  default     = "16"
}
```

**Lesson**: pinning an exact _minor_ version in infrastructure-as-code creates silent technical debt
— the code itself never changes, but its ability to actually run degrades over time due to an
external factor (the provider's catalog). Prefer pinning the major version alone when the provider
supports it, and reserve exact minor-version pinning for cases where exact compatibility is
genuinely required.

---

## 3. JWT secret stuck in a pending-deletion window after a `destroy`

**Context**: redeploying staging the day after a `terraform destroy`.

**Error**

```
Error: creating Secrets Manager Secret (task-manager-staging-jwt-secret):
operation error Secrets Manager: CreateSecret, https response error StatusCode:
400, RequestID: fc8a0b54-cf4a-4943-b4b3-0210d8da9166, InvalidRequestException:
You can't create this secret because a secret with this name is already
scheduled for deletion.

  with module.ecs.aws_secretsmanager_secret.jwt,
  on ..\..\_modules\ecs\secrets.tf line 9, in resource "aws_secretsmanager_secret" "jwt":
  9: resource "aws_secretsmanager_secret" "jwt" {
```

**Root cause**: Secrets Manager never deletes a secret immediately by default — it places it in a
pending-deletion state with a 30-day recovery window (a safeguard against accidental deletion). The
name stays "reserved" for that whole window, and AWS refuses to create a new secret with the same
name until the old one is permanently purged.

**Unblocked immediately with**:

```bash
aws secretsmanager delete-secret \
  --secret-id task-manager-staging-jwt-secret \
  --force-delete-without-recovery \
  --region eu-west-3
```

**Permanent fix**: since staging is meant for frequent `destroy`/`apply` cycles — unlike a real
production secret, which you'd actually want to be able to recover — the recovery window is disabled
for this specific secret, mirroring the `db_skip_final_snapshot = true` choice already made for RDS.

```hcl
# infra/_modules/ecs/secrets.tf
resource "aws_secretsmanager_secret" "jwt" {
  name = "${var.project_name}-${var.environment}-jwt-secret"
  # 0 = delete immediately on destroy, no 30-day recovery window. Appropriate
  # for staging where destroy/apply cycles are frequent - reconsider for a
  # real production secret you'd want to be able to recover.
  recovery_window_in_days = 0
  tags                     = var.tags
}
```

**Lesson**: AWS's "protect by default" behaviors (recovery windows, `deletion_protection`, final
snapshots) are designed for a stable real production, not for an environment that's deliberately
destroyed and recreated on a regular basis. They need to be consciously disabled where they don't
match the environment's actual usage pattern — and documented, so they don't get silently re-enabled
later on a secret that would actually need them. (The RDS master password, by contrast, is randomly
generated on every creation and never hits this kind of name collision.)

---

## 4. Session cookie not persisted on an HTTP-only ALB

**Context**: after a full successful deployment, registration and login both work, but the session
is lost on every page refresh or navigation between protected routes.

**Root cause**: the session cookie was set with `secure: process.env.NODE_ENV === 'production'`. In
the AWS environment (`NODE_ENV=production`), the cookie was therefore marked `Secure` — which tells
the browser to only ever send it back over an HTTPS connection. But the ALB serves HTTP only (no ACM
certificate/domain in front of it), so the browser received the cookie fine on login but never sent
it back on subsequent requests.

**Fix**: decouple the `secure` attribute from `NODE_ENV` and drive it from a dedicated
`COOKIE_SECURE` environment variable, propagated from Terraform through to the frontend container
(`false` for as long as there's no HTTPS in front of the ALB).

```typescript
// apps/frontend/src/lib/auth.ts
secure: process.env.COOKIE_SECURE === 'true',
```

**Lesson**: `NODE_ENV` answers "which build/optimization mode?", not "is this connection encrypted?"
— conflating the two is an easy mistake to make while testing locally, where prod-mode and HTTPS are
often toggled together. A bug that only shows up in a deployed environment, never locally, is a
decent hint to look at infrastructure (networking, TLS) rather than pure application code.

---

## Why these four share a common thread

Three of the four incidents (RDS Free Tier limits, the JWT secret, the pinned PostgreSQL version)
trace back to the same deliberate choice: optimize staging/prod for fast, cheap `destroy`/`apply`
cycles rather than long-term stability the way a real production environment would be. That choice
has a cost in occasional friction — the kind documented here — which is better understood and
explainable than pretended away.

---

## 5. EKS node group stuck in `CREATING` — instance type not Free Tier eligible

**Context**: first `terraform apply` of the M1.2 node group (`t3.medium`, then retried with
`ON_DEMAND` instead of `SPOT`). The node group stayed in `CREATING` for tens of minutes with the
underlying Auto Scaling Group's desired capacity never reached - `0` EC2 instances running against a
desired count of `2`.

**Root cause**: AWS accounts created on or after July 15, 2025 are restricted to a fixed list of
Free-Tier-eligible instance types (`t3.micro`, `t3.small`, `t4g.micro`, `t4g.small`,
`c7i-flex.large`, `m7i-flex.large`) - unlike the older Free Tier model, usage beyond this list isn't
billed at standard rates, it's rejected outright at the EC2 API level
(`InvalidParameterCombination: "The specified instance type is not eligible for Free Tier"`). The
initial hypothesis (a Spot-specific issue) was ruled out: `ON_DEMAND` failed with the exact same
error, confirming the restriction applies to the instance type itself, independent of purchase
option.

**Fix**: `node_instance_types` changed to `["m7i-flex.large"]` - Free-Tier-eligible (i.e. AWS allows
launching it at all on this restricted account), x86_64 (no AMI change needed), and with
meaningfully more headroom (8 GiB RAM) than the also-eligible `t3.small` (2 GiB). Note "eligible" is
not "equal cost": m7i-flex.large runs ~4x more per hour than t3.small, both drawing down the same
sign-up credit pool - an acceptable tradeoff here since the absolute difference is a few cents per
apply/verify/destroy session, dwarfed by the EKS control plane's own hourly cost.

**Lesson**: same failure-mode class as incident #1 (RDS `FreeTierRestrictionError`) - an
account-level restriction enforced only by the real API, invisible to `terraform plan`, and easy to
misdiagnose as a symptom of the wrong mechanism (Spot capacity here, backup retention syntax there)
before checking the raw error message. Worth checking Free-Tier-eligible instance types
(`aws ec2 describe-instance-types --filters Name=free-tier-eligible,Values=true`) before choosing
any EC2-backed instance type on a newer AWS account, the same way engine/backup-retention defaults
were checked against RDS's real limits in incident #1.
