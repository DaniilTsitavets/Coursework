output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "bucket_name" {
  value = module.s3.bucket_name
}

output "bastion_public_ip" {
  value = module.ec2-bastion.instance_public_ip
}