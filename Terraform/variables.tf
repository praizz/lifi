# variable "eks_cluster_name" {
#   type        = string
#   description = "the EKS cluster name"
#   default     = "lifi-eks"
# }

variable "aws-region" {
  type        = string
  description = "the AWS region to create all the resources"
  default     = "eu-west-1"
}

# variable "public-subnets" {
#   description = "the public subnets to provision on the vpc"
#   default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
# }




######VPC

variable "vpc-subnet-cidr" {
  default     = "10.0.0.0/16"
  type        = string
  description = "The VPC Subnet CIDR"
}

variable "private-subnet-cidr" {
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  type        = list
  description = "Private Subnet CIDR"
}

variable "public-subnet-cidr" {
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  type        = list
  description = "Public Subnet CIDR"
}

variable "db-subnet-cidr" {
  default     = ["10.0.192.0/21", "10.0.200.0/21", "10.0.208.0/21"]
  type        = list
  description = "DB/Spare Subnet CIDR"
}

####### RDS

variable "rds_engine" {
  description = "The database engine to use"
  type        = string
  default     = "mysql"
}

variable "rds_engine_version" {
  description = "The engine version to use"
  type        = string
  default     = "5.7"
}

variable "rds_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 5
}

variable "rds_port" {
  description = "The port on which the DB accepts connections"
  type        = string
  default     = "3306"
}

variable "rds_username" {
  description = "Username for the master DB user"
  type        = string
  default     = ""
}

variable "rds_password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file"
  type        = string
  default     = ""
}
