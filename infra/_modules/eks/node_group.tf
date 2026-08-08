# ── IAM role assumed by worker node instances ─────────────────────────────────

data "aws_iam_policy_document" "node_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  name               = "${local.cluster_name}-eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "node_worker" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  # Attached directly to the node role for simplicity in M1.2. A stricter
  # setup would scope this to the aws-node ServiceAccount via IRSA instead
  # of the whole node role - worth revisiting once IRSA is wired up in M1.3.
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_readonly" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ── Managed node group ─────────────────────────────────────────────────────────

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.node.arn

  # Private subnets only - worker nodes are never internet-facing directly,
  # outbound traffic goes through the NAT Gateway already provisioned for ECS.
  subnet_ids = var.private_subnet_ids

  ami_type       = var.node_ami_type
  capacity_type  = var.node_capacity_type
  instance_types = var.node_instance_types
  disk_size      = var.node_disk_size

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    "node-group" = "default"
  }

  tags = var.tags

  # IAM permissions must exist before nodes try to join the cluster, or they
  # come up NotReady in a way that looks like a networking problem and is
  # actually a missing policy - same failure-mode class as incident #1
  # (a rejection surfaced only at apply/runtime, not by `plan`).
  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr_readonly,
  ]

  lifecycle {
    # Once nodes exist, desired_size may drift (manual scaling, or the
    # Cluster Autoscaler later on) - Terraform shouldn't fight that on
    # every apply.
    ignore_changes = [scaling_config[0].desired_size]
  }
}