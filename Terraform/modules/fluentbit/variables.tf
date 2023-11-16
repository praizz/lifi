# variable "region" {
#   description = "AWS region name"
#   type        = string
# }

# variable "cluster_id" {
#   description = "AWS EKS cluster id"
#   type        = string
# }

variable "fluentbit-namespace" {
  type    = string
  default = "fluentbit"
}

variable "fluentbit-sa" {
  type    = string
  default = "fluentbit-cloudwatch-sa"
}

variable "fluentbit-version" {
  type    = string
  default = "0.28.0"
}


# variable "fluentbit_configuration" {
#   description = "Fluentbit application configuration"
#   type = object({
#     kubernetes_namespace       = string
#     kubernetes_service_account = string
#     aws_iam_role_arn           = string
#     repository                 = string
#     repository_path            = string
#     repository_revision        = string
#     is_prune_enabled           = bool
#     is_selfheal_enabled        = bool
#   })
# }



#   fluentbit_configuration = {
#     enabled                    = true
#     kubernetes_namespace       = "fluentbit"
#     kubernetes_service_account = data.terraform_remote_state.sl1.outputs.fluentbit_kubernetes_service_account
#     aws_iam_role_arn           = data.terraform_remote_state.sl1.outputs.fluentbit_iam_role_arn
#     repository                 = "https://fluent.github.io/helm-charts"
#     repository_path            = "fluent-bit"
#     repository_revision        = "0.28.0"
#     is_prune_enabled           = true
#     is_selfheal_enabled        = true
#   }