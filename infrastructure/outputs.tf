output "bucket_name" {
  value = module.s3.bucket_name
}

output "connect_to_db" {
  description = "Shows ssh command to db"
  value = "ssh -i ./Downloads/pem/coursework-bastion-kp.pem -L 5432:${module.rds_oltp.db_endpoint} ubuntu@${module.ec2-bastion.ssh_connect_ip}"
}