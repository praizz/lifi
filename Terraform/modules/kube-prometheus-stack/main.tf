resource "kubernetes_namespace" "this" {
  metadata {
    name = var.prometheus-namespace
  }
}

resource "helm_release" "kube-prometheus-stack" {
  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.this.metadata[0].name
  version    = var.prometheus-version
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
}