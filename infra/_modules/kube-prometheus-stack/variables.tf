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

variable "alb_hostname" {
  description = "Public ALB hostname, shared across the backend/frontend/Grafana Ingresses (task-manager group). Same placeholder-until-known pattern already used for CORS_ORIGIN in 04-configmap-backend.yaml.tftpl - update this default (or override at the module call site) if the ALB is ever recreated (e.g. after the incident #7 destroy/recreate sequence) or once a custom domain is attached."
  type        = string
  default     = "k8s-taskmanager-3c184ca188-606630983.eu-west-3.elb.amazonaws.com"
}