provider "aws" {
  region = var.aws-region
  profile = "ogunnowo"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.lifi-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.lifi-cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.lifi-cluster.token
  # load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.lifi-cluster.endpoint
    token                  = data.aws_eks_cluster_auth.lifi-cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.lifi-cluster.certificate_authority.0.data)
  }
}

# provider "kubectl" {
#   host                   = data.aws_eks_cluster.lifi-cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.lifi-cluster.certificate_authority.0.data)
#   token                  = data.aws_eks_cluster_auth.lifi-cluster.token
#   load_config_file       = false
# }

# provider "random" {
#   version = ">= 3.0.0"
# }