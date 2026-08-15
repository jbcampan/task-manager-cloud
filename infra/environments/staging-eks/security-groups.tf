# RDS's security group only ever allowed the ECS task security group -
# added when this environment was ECS-only, before the EKS migration.
# EKS worker nodes carry the cluster's own security group
# (module.eks.cluster_security_group_id), never granted ingress on RDS
# until now. Without this, Prisma fails with P1001 ("Can't reach database
# server")

resource "aws_vpc_security_group_ingress_rule" "rds_from_eks" {
  security_group_id            = data.terraform_remote_state.staging.outputs.rds_security_group_id
  description                  = "PostgreSQL from EKS worker nodes"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.eks.cluster_security_group_id
}