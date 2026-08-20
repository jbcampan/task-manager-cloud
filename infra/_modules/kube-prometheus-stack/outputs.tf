output "namespace" {
  description = "Namespace the monitoring stack is deployed into - consumed by (Ingress) to target the Grafana Service."
  value       = kubernetes_namespace_v1.monitoring.metadata[0].name
}

output "helm_release_name" {
  description = "Helm release name - Kubernetes object names in this stack are prefixed with this value (e.g. <name>-grafana)."
  value       = helm_release.kube_prometheus_stack.name
}