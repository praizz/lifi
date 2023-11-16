output "ecr-repository" {
  value = module.lifi-ecr.repository_url
}
##### RDS
output "rds_master_db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.lifi-rds.db_instance_address
}

output "rds_master_db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = module.lifi-rds.db_instance_arn
}

output "rds_master_db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.lifi-rds.db_instance_endpoint
}

output "rds_master_db_instance_name" {
  description = "The database name"
  value       = module.lifi-rds.db_instance_name
}

# output "rds_master_db_instance_password" {
#   description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
#   value       = module.lifi-rds.db_instance_password
# }