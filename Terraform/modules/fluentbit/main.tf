resource "kubernetes_namespace" "this" {
  metadata {
    name = var.fluentbit-namespace
  }
}

resource "kubernetes_service_account" "this" {
  metadata {
    name        = var.fluentbit-sa
    namespace   = kubernetes_namespace.this.metadata[0].name
    # annotations = { "eks.amazonaws.com/role-arn" : var.fluentbit_configuration["aws_iam_role_arn"] }
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


# resource "aws_iam_policy" "this" {
#   name        = "${var.cluster_id}-${var.kubernetes_service_account}-policy"
#   description = "AWS IAM policy for Fluentbit"
#   policy      = data.aws_iam_policy_document.this.json

#   tags = var.tags
# }
# data "aws_iam_policy_document" "this" {
#   statement {
#     sid    = "FluentbitCloudwatchPolicy"
#     effect = "Allow"

#     actions = [
#       "logs:CreateLogStream",
# 			"logs:CreateLogGroup",
# 			"logs:PutLogEvents"
#     ]

#     resources = ["*"]
#   }
# }