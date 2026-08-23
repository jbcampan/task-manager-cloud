resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "this" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name

  values = [yamlencode({
    server = {
      # No TLS termination inside the chart - there is no public exposure
      # (no Ingress, no LoadBalancer Service) to protect in the first
      # place; access is kubectl port-forward only, by humans and by CI
      # alike (port-forward tunnels through the EKS API server connection,
      # not through the pod network, so this works without any public
      # endpoint). Running plain HTTP behind that tunnel avoids fighting
      #  a self-signed cert with the argocd CLI on every command.
      insecure = true
      ingress = {
        enabled = false
      }
      service = {
        type = "ClusterIP"
      }
    }

    # Dex (SSO) and the notifications controller are extra pods this
    # single-app staging project has no use for - disabling both trims
    # pod count on the already resource-constrained SPOT node group
    # (same reasoning as disabling unused kube-prometheus-stack
    # components). ApplicationSet is unused too: one static
    # Application (task-manager) doesn't need a generator.
    dex = {
      enabled = false
    }
    notifications = {
      enabled = false
    }
    applicationSet = {
      enabled = false
    }

    configs = {
      # Enables a local "ci" account (distinct from "admin") that
      # authenticates via API key instead of username/password - this is
      # the account GitHub Actions will use.
      cm = {
        "accounts.ci" = "apiKey"
      }
      # Scoped to exactly what the CD pipeline needs: trigger and check
      # the sync of the task-manager Application, nothing else (no
      # access to other Applications, no admin operations). The "default"
      # AppProject prefix is used because no dedicated AppProject is
      # created for this single-app project.
      rbac = {
        "policy.csv" = <<-EOT
          p, role:ci-sync, applications, sync, default/task-manager, allow
          p, role:ci-sync, applications, get, default/task-manager, allow
          g, ci, role:ci-sync
        EOT
      }
    }
  })]
}