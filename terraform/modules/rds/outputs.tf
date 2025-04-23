output "db_endpoint" {
  value = aws_db_instance.oltp-db.endpoint
}

output "db_name" {
  value = aws_db_instance.oltp-db.db_name
}

output "db_username" {
  value = aws_db_instance.oltp-db.username
}

output "db_password" {
  value = aws_db_instance.oltp-db.password
  sensitive = true
}