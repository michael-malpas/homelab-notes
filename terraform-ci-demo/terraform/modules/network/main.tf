resource "aws_vpc" "vpc" {
  #checkov:skip=CKV2_AWS_11:VPC Flow Logs will be implemented in a later security monitoring lesson

  #  description = "environment vpc resource"

  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-vpc"
    }
  )
}

resource "aws_subnet" "public" {
  #checkov:skip=CKV_AWS_130:Public subnet intentionally assigns public IPs

  #  description = "environment public subnet"

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-public-subnet"
    }
  )
}

resource "aws_subnet" "private" {

  #  description = "environment private subnet"

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-private-subnet"
    }
  )
}

resource "aws_internet_gateway" "main" {

  #  description = "environment internet gateway"

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-gateway"
    }
  )
}

resource "aws_route_table" "public" {

  #  description = "Public route table"

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-public-route-table"
    }
  )
}

resource "aws_route" "public_internet" {

  #  description = "Public Internet Route"

  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {

  #  description = "Private route table"

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-private-route-table"
    }
  )
}

resource "aws_route" "private_internet" {

  #  description = "Private Internet Route"

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gw.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "nat" {

  domain = "vpc"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-nat-eip"
    }
  )
}

resource "aws_nat_gateway" "nat-gw" {
  subnet_id     = aws_subnet.public.id
  allocation_id = aws_eip.nat.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-nat"
    }
  )
  depends_on = [aws_internet_gateway.main]
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  ingress = []

  egress = []
}
