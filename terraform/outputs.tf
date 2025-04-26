output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "db_subnet_group_name" {
  value = module.vpc.db_subnet_group_name
}

output "bucket_name" {
  value = module.s3.bucket_name
}

output "db_endpoint" {
  value = module.rds.db_endpoint
}

output "db_name" {
  value = module.rds.db_name
}

output "db_username" {
  value = module.rds.db_username
}

output "db_password" {
  value = module.rds.db_password
  sensitive = true
}