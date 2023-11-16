variable "prometheus-namespace" {
  type    = string
  default = "kube-prometheus-stack"
}

variable "prometheus-version" {
  type    = string
  default = "53.0.0"
}