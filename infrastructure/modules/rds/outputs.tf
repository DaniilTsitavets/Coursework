output "db_endpoint" {
  value = aws_db_instance.db.endpoint
}

output "db_name" {
  value = aws_db_instance.db.db_name
}

output "db_username" {
  value = aws_db_instance.db.username
}

output "db_password" {
  value = aws_db_instance.db.password
  # sensitive = true
}
output "db_address" {
  value = aws_db_instance.db.address
}