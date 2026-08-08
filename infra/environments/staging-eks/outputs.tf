output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded CA data for kubeconfig"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_version" {
  description = "Kubernetes version actually running"
  value       = module.eks.cluster_version
}

output "cluster_security_group_id" {
  description = "EKS-managed control-plane security group, needed by the M1.2 node group"
  value       = module.eks.cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN, required by IRSA trust policies in M1.3"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "OIDC issuer URL without the https:// prefix, for IRSA trust policy conditions"
  value       = module.eks.oidc_provider_url
}

output "node_group_status" {
  description = "Node group status - should read ACTIVE after apply."
  value       = module.eks.node_group_status
}

output "backend_irsa_role_arn" {
  description = "IAM role ARN for the backend pods' ServiceAccount - annotate it with eks.amazonaws.com/role-arn in the M2 manifests."
  value       = module.irsa_backend.role_arn
}