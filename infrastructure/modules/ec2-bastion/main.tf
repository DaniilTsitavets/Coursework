resource "aws_instance" "ec2-bastion-host" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-bastion"
  }
}

resource "aws_security_group" "bastion-sg" {
  name   = "${var.project_name}-bastion-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-bastion-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-22" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4         = var.cidr_ipv4_ingress
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4         = var.cidr_ipv4_egress
  ip_protocol       = "-1"
}
