output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "db_subnet_group_name" {
  value = module.vpc.db_subnet_group
}

output "bucket_name" {
  value = module.s3.bucket_name
}