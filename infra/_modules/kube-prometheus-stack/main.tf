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

          # backend/frontend ServiceMonitors live in task-manager,
          # not monitoring. Without these three lines Prometheus Operator
          # only watches ServiceMonitors matching its own Helm release
          # label, in its own namespace - the chart's secure-by-default
          # posture, deliberately loosened here since this is a
          # single-team staging cluster, not a multi-tenant one where
          # namespace isolation between teams' metrics would matter.
          serviceMonitorSelectorNilUsesHelmValues = false
          serviceMonitorSelector                  = {}
          serviceMonitorNamespaceSelector         = {}

          # Same reasoning, for PrometheusRule this time - our
          # alerting rules live in task-manager, alongside the app
          # manifests they alert on, not in monitoring. Loosened for the
          # same single-team-cluster reason as the ServiceMonitor
          # selector above.
          ruleSelectorNilUsesHelmValues = false
          ruleSelector                  = {}
          ruleNamespaceSelector         = {}
        }
      }

      alertmanager = {
        alertmanagerSpec = {
          resources = {
            requests = { cpu = "25m", memory = "64Mi" }
            limits   = { cpu = "100m", memory = "128Mi" }
          }
        }

        # Routing skeleton, no real notification channel wired up
        # yet. "critical-receiver" has no notifiers configured - alerts
        # matching it are grouped and visible in the Alertmanager UI, but
        # nothing is sent externally. Swapping in a real channel (Slack/
        # Discord/PagerDuty webhook_configs) later would follow the same
        # pattern already used for JWT/RDS credentials: the
        # webhook URL stored in Secrets Manager, synced in via an
        # ExternalSecret, never committed here in plaintext.
        config = {
          global = {
            resolve_timeout = "5m"
          }
          route = {
            receiver        = "null-receiver"
            group_by        = ["alertname", "namespace"]
            group_wait      = "30s"
            group_interval  = "5m"
            repeat_interval = "4h"
            routes = [
              {
                receiver = "critical-receiver"
                matchers = ["severity = \"critical\""]
                continue = false
              }
            ]
          }
          receivers = [
            { name = "null-receiver" },
            { name = "critical-receiver" },
          ]
          # A firing critical alert suppresses the matching warning-level
          # one for the same alertname/namespace - avoids two alerts for
          # what's really one underlying problem (e.g. BackendHighErrorRate
          # at both warning and critical thresholds simultaneously).
          inhibit_rules = [
            {
              source_matchers = ["severity = \"critical\""]
              target_matchers = ["severity = \"warning\""]
              equal           = ["alertname", "namespace"]
            }
          ]
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

        # The default (chart-bundled) dashboards - Kubernetes
        # compute resources, node metrics, etc. - already ship enabled.
        # This sidecar watches for additional ConfigMaps labeled
        # grafana_dashboard: "1" and loads them automatically - no manual
        # dashboard import through the Grafana UI. searchNamespace: "ALL"
        # is the same secure-by-default loosening already applied to
        # serviceMonitorSelector/ruleSelector above - our dashboard
        # ConfigMap lives in task-manager, not monitoring.
        sidecar = {
          dashboards = {
            enabled         = true
            label           = "grafana_dashboard"
            searchNamespace = "ALL"
          }
        }

        # The chart's own Ingress creation stays disabled - our own
        # Ingress template (28-ingress-grafana.yaml) follows the same
        # hand-written pattern already used for backend/frontend
        # (12/13-ingress-*.yaml), sharing their ALB group rather than
        # letting the chart provision an independent one.
        ingress = {
          enabled = false
        }

        # Required because Grafana is reached at /grafana on the shared
        # ALB (path-based routing, no separate hostname configured) -
        # without serve_from_sub_path, Grafana's own generated links,
        # redirects, and static asset URLs would point at "/" and 404
        # once actually hit through the Ingress.
        "grafana.ini" = {
          server = {
            domain              = var.alb_hostname
            root_url            = "%(protocol)s://%(domain)s/grafana/"
            serve_from_sub_path = true
          }
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