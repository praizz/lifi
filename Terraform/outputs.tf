output "ecr-repository" {
  value = module.lifi-ecr.repository_url
}
##### RDS
output "rds_master_db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.lifi-rds.db_instance_endpoint
}

output "rds_master_db_instance_name" {
  description = "The database name"
  value       = module.lifi-rds.db_instance_name
}
