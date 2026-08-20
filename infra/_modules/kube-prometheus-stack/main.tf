# Dedicated namespace for the whole stack (Prometheus Operator, Prometheus,
# Alertmanager, Grafana, kube-state-metrics, node-exporter) - kept separate
# from task-manager and amazon-cloudwatch (unused now), same isolation
# logic already applied to external-secrets and the ALB controller.
resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = var.namespace
    labels = {
      "kubernetes.io/metadata.name" = var.namespace
    }
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name

  # Large chart - Prometheus Operator's CRDs + 5 sub-charts. Default Helm
  # timeout (300s) has been observed to be tight on a first install while
  # the operator's admission webhook cert provisions and CRDs settle.
  timeout = 600

  values = [
    yamlencode({
      # ── Storage: no PVC anywhere in this stack for now ─────────────────
      # Staging is destroy/recreate by design (incidents.md #1/#3/#5/#6) -
      # same reasoning already applied to RDS backup retention and the JWT
      # secret's recovery window. Omitting storageSpec/persistence here
      # means Prometheus's TSDB and Grafana's state fall back to ephemeral
      # storage: gone on every pod reschedule or `helm uninstall`, and no
      # EBS CSI driver addon required as a prerequisite. Acceptable for a
      # demo cluster whose metrics history nobody needs to survive a
      # destroy. Revisit with a PVC (adds the EBS CSI driver as a new
      # addon) if this stack is ever pointed at a longer-lived cluster.
      prometheus = {
        prometheusSpec = {
          # Bounds Prometheus's own memory/local-disk footprint during the
          # pod's lifetime - not a retention guarantee, since there's no
          # persistent volume behind it regardless of this value.
          retention = "6h"
          resources = {
            requests = { cpu = "100m", memory = "256Mi" }
            limits   = { cpu = "500m", memory = "512Mi" }
          }
        }
      }

      alertmanager = {
        alertmanagerSpec = {
          resources = {
            requests = { cpu = "25m", memory = "64Mi" }
            limits   = { cpu = "100m", memory = "128Mi" }
          }
        }
      }

      grafana = {
        persistence = {
          enabled = false
        }
        adminPassword = var.grafana_admin_password
        resources = {
          requests = { cpu = "50m", memory = "128Mi" }
          limits   = { cpu = "200m", memory = "256Mi" }
        }
      }

      # DaemonSet - one node-exporter pod per node, scraping host-level
      # metrics (CPU, memory, disk, network). Only schedulable because we
      # chose an EC2 SPOT node group over Fargate - the same prerequisite
      # that was going to justify the CloudWatch agent DaemonSets before
      # this stack replaced that approach.
      prometheus-node-exporter = {
        enabled = true
      }

      # Deployment, not a DaemonSet - watches the Kubernetes API and
      # exposes cluster object state (deployment replica counts, pod
      # restart counts, resource requests/limits) as Prometheus metrics.
      # Complements node-exporter's host-level view with a
      # Kubernetes-object-level one.
      kube-state-metrics = {
        enabled = true
      }
    })
  ]
}