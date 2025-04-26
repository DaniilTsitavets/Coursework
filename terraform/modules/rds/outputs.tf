output "db_endpoint" {
  value = aws_db_instance.OLTPdb.endpoint
}

output "db_name" {
  value = aws_db_instance.OLTPdb.db_name
}

output "db_username" {
  value = aws_db_instance.OLTPdb.username
}

output "db_password" {
  value = aws_db_instance.OLTPdb.password
  sensitive = true
}