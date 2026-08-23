variable "chart_version" {
  description = "argo-cd Helm chart version. Verify the current one with `helm search repo argo/argo-cd --versions` before relying on the default here."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace ArgoCD is installed into"
  type = string
  default = "argocd"
}