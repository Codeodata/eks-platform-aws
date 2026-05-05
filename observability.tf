
resource "kubernetes_namespace" "observability" {
  count = var.deploy_observability ? 1 : 0

  metadata {
    name = "observability"
    labels = {
      name = "observability"
    }
  }
}

resource "helm_release" "prometheus" {
  count = var.deploy_observability ? 1 : 0

  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.observability[0].metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  values = [
    file("${path.module}/observability/prometheus/values.yaml")
  ]

  depends_on = [kubernetes_namespace.observability]
}

resource "helm_release" "grafana" {
  count = var.deploy_observability ? 1 : 0

  name       = "grafana"
  namespace  = kubernetes_namespace.observability[0].metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"

  values = [
    file("${path.module}/observability/grafana/helm-values.yaml")
  ]

  set_sensitive {
    name  = "adminPassword"
    value = var.grafana_admin_password
  }

  depends_on = [
    kubernetes_namespace.observability,
    helm_release.prometheus,
  ]
}

resource "kubernetes_ingress_v1" "grafana" {
  count = var.deploy_observability ? 1 : 0

  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.observability[0].metadata[0].name
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "grafana.example.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.grafana]
}
