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