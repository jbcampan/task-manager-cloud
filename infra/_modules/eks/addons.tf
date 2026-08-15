# The vpc-cni addon already exists on this cluster - EKS auto-installs it
# at cluster creation regardless of whether Terraform declares it. This
# resource brings it under Terraform management rather than creating it from scratch.

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "vpc-cni"

  # Every fresh cluster installs vpc-cni as a self-managed component by
  # default (not registered via the Addon API) - a plain "create" collides
  # with that install (ResourceInUseException), and re-importing by hand on
  # every destroy/recreate cycle isn't sustainable for an environment meant
  # to be torn down and rebuilt often. OVERWRITE lets this resource adopt
  # whatever's already running on cluster creation, every time, with no
  # manual import step.
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  # No addon_version pinned on purpose - AWS resolves the default version
  # compatible with the cluster's Kubernetes version automatically. Same
  # reasoning as incident #2 (RDS engine_version, major only): pinning an
  # exact addon version risks the same silent breakage once AWS retires it
  # from the compatible list for this cluster version.

  # Enables the AWS Network Policy agent as part of this addon - required
  # for Kubernetes NetworkPolicy resources to actually be enforced. Without
  # this, NetworkPolicy manifests apply without error but have zero effect,
  # which is worse than not writing them at all (false sense of security).
  configuration_values = jsonencode({
    enableNetworkPolicy = "true"
  })

  tags = var.tags
}
