output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate authority data, used to configure kubectl/kubeconfig."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_version" {
  description = "Kubernetes version actually running (echoes the input, useful for CI logs)."
  value       = aws_eks_cluster.this.version
}

output "cluster_security_group_id" {
  description = "Security group automatically created and managed by EKS for control-plane-to-node communication. Needed by the node group and by any security group rule allowing node <-> control plane traffic."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_arn" {
  description = "ARN of the EKS cluster - needed to scope IAM policies (e.g. eks:DescribeCluster for the GitHub Actions deploy role)."
  value       = aws_eks_cluster.this.arn
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider registered for this cluster. Required by IRSA role trust policies."
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "OIDC issuer URL without the \"https://\" prefix, as required in IRSA trust policy Federated principals and StringEquals conditions."
  value       = replace(aws_iam_openid_connect_provider.eks.url, "https://", "")
}

output "node_group_arn" {
  description = "ARN of the managed node group."
  value       = aws_eks_node_group.this.arn
}

output "node_group_status" {
  description = "Node group status - check for ACTIVE before running kubectl validation."
  value       = aws_eks_node_group.this.status
}

output "node_role_arn" {
  description = "IAM role ARN used by worker nodes."
  value       = aws_iam_role.node.arn
}