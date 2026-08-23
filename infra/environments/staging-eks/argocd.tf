module "argocd" {
  source = "../../_modules/argocd"

  chart_version = "10.3.3" # verified with `helm search repo argo/argo-cd --versions`

  # Same reasoning as alb_controller/external_secrets/kube_prometheus_stack
  # in main.tf - node group and cluster networking must be ready first.
  depends_on = [module.eks]
}

# The Application CRD itself - the workload-specific part, so it lives here
# at the environment level rather than inside the (generic, reusable)
# argocd module, same split as k8s-manifests.tf vs _modules/eks.
#

resource "kubectl_manifest" "task_manager_application" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "task-manager"
      namespace = module.argocd.namespace
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.git_repo_url
        targetRevision = "main"
        path           = "argocd-apps/task-manager"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "task-manager"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=false",
        ]
      }
    }
  })

  depends_on = [module.argocd]
}