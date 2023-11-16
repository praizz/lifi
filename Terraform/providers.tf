provider "aws" {
  region = var.aws-region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.lifi-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.lifi-cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.lifi-cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.lifi-cluster.endpoint
    token                  = data.aws_eks_cluster_auth.lifi-cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.lifi-cluster.certificate_authority.0.data)
  }
}