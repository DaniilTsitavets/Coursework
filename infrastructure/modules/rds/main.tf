resource "aws_db_instance" "db" {
  allocated_storage    = var.allocated_storage
  db_name              = var.db_name
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = var.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]

  publicly_accessible = false
  skip_final_snapshot = true
  storage_encrypted   = true
  apply_immediately   = true

  tags = {
    Name = "${var.project_name}-rds-instance"
  }
}

resource "aws_security_group" "rds_security_group" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow database access"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_bastion_connection" {
  security_group_id            = aws_security_group.rds_security_group.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
  referenced_security_group_id = var.bastion_sg
}

resource "aws_vpc_security_group_ingress_rule" "allow_lambda_traffic" {
  for_each = toset(var.lambda_sg_ids)

  security_group_id            = aws_security_group.rds_security_group.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
  referenced_security_group_id = each.value
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.rds_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
