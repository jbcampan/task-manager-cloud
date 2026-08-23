output "namespace" {
  description = "Namespace ArgoCD is installed into."
  value       = kubernetes_namespace_v1.argocd.metadata[0].name
}