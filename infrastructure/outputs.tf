output "bucket_name" {
  value = module.s3.bucket_name
}

output "connect_to_dbs" {
  description = "Shows ssh command to db"
  value = <<EOT
ssh -i ./Downloads/pem/coursework-bastion-kp.pem \
  -L 5432:${module.rds_oltp.db_endpoint} \
  -L 5433:${module.rds_olap.db_endpoint} \
  ubuntu@${module.ec2-bastion.ssh_connect_ip}
EOT
}