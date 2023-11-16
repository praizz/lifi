resource "kubernetes_namespace" "this" {
  metadata {
    name = var.fluentbit-namespace
  }
}

resource "kubernetes_service_account" "this" {
  metadata {
    name      = var.fluentbit-sa
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  automount_service_account_token = true

  depends_on = [
    kubernetes_namespace.this,
  ]
}


resource "helm_release" "this" {
  name       = "fluent-bit"
  namespace  = kubernetes_namespace.this.metadata[0].name
  version    = var.fluentbit-version
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"

  values = [
    "${file("${path.module}/values.yaml")}"
  ]
}