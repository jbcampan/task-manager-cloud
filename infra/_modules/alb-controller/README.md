# AWS Load Balancer Controller module

## 1. Choose the controller version

Latest as of writing: `v3.4.1` (2026-07-07). Check https://github.com/aws/eks-charts/releases for
anything newer, and https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases for
release notes / known issues before picking.

## 2. Find the matching Helm chart version

​`bash helm repo add eks https://aws.github.io/eks-charts helm repo update helm search repo eks/aws-load-balancer-controller --versions | head -20 ​`

Match the `APP VERSION` column to the controller version chosen in step 1, then set `chart_version`
in `staging-eks/variables.tf` (or wherever this module is instantiated) to the corresponding
`CHART VERSION`.

## 3. Download the matching IAM policy

​`bash curl -o infra/_modules/alb-controller/iam-policy.json \   https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v3.4.1/docs/install/iam_policy.json ​`

The tag in the URL must match the controller **appVersion** from step 1 - not the chart version, and
not the eks-charts repo release tag.
