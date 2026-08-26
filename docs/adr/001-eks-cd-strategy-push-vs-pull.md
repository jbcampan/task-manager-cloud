# ADR-004 — Deployment strategy: push (ECS) vs pull/GitOps (EKS)

## Status

Accepted — M4 (EKS migration)

## Context

Moving from ECS to EKS raised a question: how should new code actually get deployed to the cluster?
Two common approaches exist:

- **Push**: GitHub Actions applies changes directly to the cluster (kubectl), the same way the
  existing ECS pipeline updates services.
- **Pull / GitOps**: a tool that runs inside the cluster (ArgoCD) watches a Git repository and
  applies changes itself. The CI pipeline never touches the cluster directly — it only updates a
  file in Git.

## Decision

- **ECS keeps using push** (`cd-ecs.yml` / `deploy-ecs-reusable.yml`, unchanged). No reason to
  change something that already works well.
- **EKS uses pull/GitOps via ArgoCD**, but only for the app itself (backend and frontend
  Deployments/Services, in `argocd-apps/task-manager/`). Everything else (namespace, secrets,
  Ingress, network rules, monitoring) stays applied the "old" way, with Terraform + kubectl, because
  those parts don't change every time we ship new code.
- The database migration step stays a direct, CI-driven action (a Kubernetes Job applied and watched
  by the pipeline), not something ArgoCD manages. This keeps the "wait for it to finish, fail loudly
  if it doesn't" logic simple, the same way it already works for ECS.

## Alternatives considered

- **Push for everything (no ArgoCD)**: simpler, one less thing to run on the cluster. Rejected
  because ArgoCD/GitOps is the standard approach used by most teams running Kubernetes today, and it
  fits well with how the manifests were already organized (as versioned files).
- **ArgoCD managing everything, migration included**: rejected, adds more complexity than it's worth
  for a small staging project.

## Consequences

- Two different deployment styles exist side by side in the same repo — a deliberate choice, not an
  inconsistency: it shows both approaches working correctly.
- ArgoCD has no public web address — access is only through a local tunnel (`kubectl port-forward`),
  for both humans and the CI pipeline.
- The migration Job exists in two copies (one for Terraform, one for CI) on purpose — see
  `incidents.md`.
