resource "aws_instance" "ec2-bastion-host" {
  ami                     = var.ami
  instance_type           = var.instance_type
  vpc_security_group_ids  = aws_security_group.bastion-sg.id
  disable_api_termination = true
  subnet_id = "" //public subnet
}

resource "aws_security_group" "bastion-sg" {
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow-22" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}