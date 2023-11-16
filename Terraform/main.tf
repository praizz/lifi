locals {
  project_name = "lifi"
  region       = var.aws-region
  tags = {
    managed-by  = "terraform"
    environment = "lifi"
    version     = "1.0"
  }
}

#--------------------------------
# VPC
#--------------------------------
module "lifi-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "${local.project_name}-vpc"
  cidr = var.vpc-subnet-cidr

  azs              = data.aws_availability_zones.available.names
  private_subnets  = var.private-subnet-cidr
  public_subnets   = var.public-subnet-cidr
  database_subnets = var.db-subnet-cidr

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true

  tags = local.tags
}

#--------------------------------
# EKS
#--------------------------------
module "lifi-eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "${local.project_name}-eks"
  cluster_version = "1.27"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = module.lifi-vpc.vpc_id
  subnet_ids = module.lifi-vpc.private_subnets

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  manage_aws_auth_configmap = true

  #manage user praise
  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::487437956131:user/praise"
      username = "praise"
      groups   = ["system:masters"]
    },
  ]

  tags = local.tags
}

# run 'aws eks update-kubeconfig ...' locally and update local kube config
resource "null_resource" "update_kubeconfig" {
  depends_on = [module.lifi-eks]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${local.project_name}-eks --region ${var.aws-region}"
  }
}

#--------------------------------
# RDS
#--------------------------------
locals {
  password = length(var.rds_password) > 0 ? var.rds_password : random_string.password.result
  username = length(var.rds_username) > 0 ? var.rds_username : random_string.username.result
}

resource "random_string" "username" {
  length  = 10
  special = false
  numeric = false
}

resource "random_string" "password" {
  length  = 20
  special = false
}

# allow all inbound on 3306 and all outbound
resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Security group for RDS"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "lifi-rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.3.0"

  identifier = "${local.project_name}-rds"

  engine            = var.rds_engine
  engine_version    = var.rds_engine_version
  instance_class    = var.rds_instance_class
  allocated_storage = var.rds_allocated_storage

  db_name  = "${local.project_name}rds"
  username = local.username
  password = local.password
  port     = var.rds_port

  manage_master_user_password = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring created automatically to cloudwatch
  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole"
  create_monitoring_role = true

  # DB subnet group
  create_db_subnet_group = false #created in vpc already
  subnet_ids             = module.lifi-vpc.database_subnets
  publicly_accessible    = true #TD

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Database Deletion Protection
  deletion_protection = false #true

  tags = local.tags
}

#--------------------------------
# ECR
#--------------------------------
module "lifi-ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "${local.project_name}-ecr"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = local.tags
}

#--------------------------------
# REMOTE STATE #one-off
#--------------------------------
module "remote-state" {
  source = "./modules/remote-state"
  region = "eu-west-1"
}

#--------------------------------
# PROMETHEUS
#--------------------------------
module "kube-prometheus-stack" {
  source               = "./modules/kube-prometheus-stack"
  prometheus-version   = "53.0.0"
  prometheus-namespace = "kube-prometheus-stack"
}

#--------------------------------
# FLUENTBIT - CLOUDWATCH
#--------------------------------
module "lifi-fluentbit-cloudwatch" {
  source              = "./modules/fluentbit"
  fluentbit-version   = "0.28.0"
  fluentbit-namespace = "fluentbit"
}
