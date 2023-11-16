data "aws_availability_zones" "available" {}

# data "aws_security_group" "rds_sg" {
#   name = "rds_sg"
# }

data "aws_eks_cluster" "lifi-cluster" {
  name = module.lifi-eks.cluster_name
}

data "aws_eks_cluster_auth" "lifi-cluster" {
  name = module.lifi-eks.cluster_name
}