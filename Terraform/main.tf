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
  source = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "${local.project_name}-vpc"
  cidr = var.vpc-subnet-cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = var.private-subnet-cidr
  public_subnets  = var.public-subnet-cidr
  database_subnets = var.db-subnet-cidr

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway = true
  # enable_vpn_gateway = true

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

  cluster_endpoint_public_access  = true

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

  vpc_id                   = module.lifi-vpc.vpc_id
  subnet_ids               = module.lifi-vpc.private_subnets

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

  # aws-auth configmap
  manage_aws_auth_configmap = true

  # aws_auth_roles = [
  #   {
  #     rolearn  = "arn:aws:iam::66666666666:role/role1"
  #     username = "role1"
  #     groups   = ["system:masters"]
  #   },
  # ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::487437956131:user/praise"
      username = "praise"
      groups   = ["system:masters"]
    },
    # {
    #   userarn  = "arn:aws:iam::66666666666:user/user2"
    #   username = "user2"
    #   groups   = ["system:masters"]
    # },
  ]

  # aws_auth_accounts = [
  #   "777777777777",
  #   "888888888888",
  # ]

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
  password   = length(var.rds_password) > 0 ? var.rds_password : random_string.password.result
  username   = length(var.rds_username) > 0 ? var.rds_username : random_string.username.result
}

resource "random_string" "username" {
  length  = 10
  special = false
  numeric  = false
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
  source = "terraform-aws-modules/rds/aws"
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
  # iam_database_authentication_enabled = true

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
 publicly_accessible = true
  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Database Deletion Protection
  deletion_protection = false #true

  tags = local.tags

  # parameters = [
  #   {
  #     name  = "character_set_client"
  #     value = "utf8mb4"
  #   },
  #   {
  #     name  = "character_set_server"
  #     value = "utf8mb4"
  #   }
  # ]

  # options = [
  #   {
  #     option_name = "MARIADB_AUDIT_PLUGIN"

  #     option_settings = [
  #       {
  #         name  = "SERVER_AUDIT_EVENTS"
  #         value = "CONNECT"
  #       },
  #       {
  #         name  = "SERVER_AUDIT_FILE_ROTATIONS"
  #         value = "37"
  #       },
  #     ]
  #   },
  # ]
}

#--------------------------------
# ECR
#--------------------------------
module "lifi-ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "${local.project_name}-ecr"

  # repository_read_write_access_arns = ["arn:aws:iam::012345678901:role/terraform"]
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
  region = "eu-west-1" #local.region
}

#--------------------------------
# PROMETHEUS
#--------------------------------
module "kube-prometheus-stack" {
  source = "./modules/kube-prometheus-stack"
  prometheus-version = "53.0.0"
  prometheus-namespace = "kube-prometheus-stack"
}

#--------------------------------
# FLUENTBIT - CLOUDWATCH
#--------------------------------
module "lifi-fluentbit-cloudwatch" {
  source = "./modules/fluentbit"
  fluentbit-version = "0.28.0"
  fluentbit-namespace = "fluentbit"
}























# locals {
#   name = "notejam"
#   tags = {
#     Terraform = "true"
#     Environment = "dev"
#   }
# }

# module "notejam_vpc" {
#   source          = "terraform-aws-modules/vpc/aws"
#   name            = "notejam-vpc"
#   cidr            = "10.0.0.0/16"
#   azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
#   public_subnets  = var.public-subnets

#   enable_nat_gateway = false #read
#   enable_vpn_gateway = false

#   tags = local.tags
# }

# module "notejam_eks" {
#   source          = "terraform-aws-modules/eks/aws"
#   cluster_name    = var.cluster_name
#   cluster_version = "1.21"
#   subnet_ids      = module.notejam_vpc.public_subnets
#   vpc_id          = module.notejam_vpc.vpc_id


#   # EKS Managed Node Group(s)
#   eks_managed_node_group_defaults = {
#     ami_type               = "AL2_x86_64"
#     disk_size              = 20
#   }

#   eks_managed_node_groups = {
#     blue = {}
#     green = {
#       min_size     = 1
#       max_size     = 3
#       desired_size = 1

#       instance_types = ["t3.medium"]
#       capacity_type  = "ON_DEMAND"
#     }
#   }
#   tags = local.tags
# }

# # run 'aws eks update-kubeconfig ...' locally and update local kube config
# resource "null_resource" "update_kubeconfig" {
#   depends_on = [module.notejam_eks]

#   provisioner "local-exec" {
#     command = "aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.aws_region}"
#   }
# }

# module "ecr" {
#   source = "cloudposse/ecr/aws"
#   name   = "notejam-ecr"
#   tags   = local.tags
# }




################# AUTOMATING REMOTE STATE LOCKING
# data "template_file" "remote-state" {
#   template = "${file("./scripts/remote-state.tpl")}"
#   vars = {
#     s3-bucket      = module.remote-state-locking.bucket_name
#     dynamodb_table = module.remote-state-locking.dynamodb_table
#   }
# }
# resource "null_resource" "remote-state-locks" {
#   depends_on = [module.remote-state-locking, data.template_file.remote-state]
#   provisioner "local-exec" {
#     command = "sleep 20;cat > backend.tf <<EOL\n${data.template_file.remote-state.rendered}"
#   }
# }


# module "remote-state-locking" {
#   source = "./modules/remote-state-locking"
#   region = var.region
# }