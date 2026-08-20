variable "namespace" {
  description = "Kubernetes namespace for the monitoring stack."
  type        = string
  default     = "monitoring"
}

variable "chart_version" {
  description = "kube-prometheus-stack Helm chart version. Verify the current one with `helm search repo prometheus-community/kube-prometheus-stack --versions` before relying on the default here - this chart releases frequently."
  type        = string
}

variable "grafana_admin_password" {
  description = "Grafana admin password. Passed as a Terraform variable and marked sensitive rather than committed anywhere - same reasoning as OIDC-only GitHub Actions auth: no credential lives in a file that gets committed."
  type        = string
  sensitive   = true
}