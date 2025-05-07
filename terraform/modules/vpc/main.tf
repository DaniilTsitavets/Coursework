resource "aws_vpc" "coursework_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "public_coursework_subnet" {
  count = length(var.public_subnet_cidr)
  vpc_id            = aws_vpc.coursework_vpc.id
  availability_zone = var.subnet_az[count.index]
  cidr_block        = var.public_subnet_cidr[count.index]

  tags = {
    Name = "${var.project_name}-public-subnet-${var.subnet_az[count.index]}"
  }
}

resource "aws_subnet" "private_coursework_subnet" {
  count = length(var.subnet_az)
  vpc_id            = aws_vpc.coursework_vpc.id
  availability_zone = var.subnet_az[count.index]
  cidr_block        = var.private_subnet_cidr[count.index]
  tags = {
    Name = "${var.project_name}-private-subnet-${var.subnet_az[count.index]}"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private_coursework_subnet : subnet.id]

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.coursework_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.coursework_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public_coursework_subnet)
  subnet_id      = aws_subnet.public_coursework_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.coursework_vpc.id

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private_coursework_subnet)
  subnet_id      = aws_subnet.private_coursework_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = aws_vpc.coursework_vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.private.id]

  tags = {
    Name = "${var.project_name}-s3-endpoint"
  }
}
