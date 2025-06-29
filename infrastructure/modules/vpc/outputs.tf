output "vpc_id" {
  value = aws_vpc.coursework_vpc.id
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private_coursework_subnet : subnet.id]
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public_coursework_subnet : subnet.id]
}
  
output "db_subnet_group_name" {
  value = aws_db_subnet_group.db_subnet_group.name
}