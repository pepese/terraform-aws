#####################################
# VPC Settings
#####################################
resource "aws_vpc" "cmn_vpc" {
  cidr_block = var.vpc_settings["vpc_cidr_block"]
  tags = {
    Service = "cmn"
    Name    = "${var.base_name}-cmn-vpc"
  }
}

#####################################
# Subnet Settings
#####################################
resource "aws_subnet" "cmn_subnet_public_1a" {
  vpc_id                          = aws_vpc.cmn_vpc.id
  availability_zone               = "ap-northeast-1a"
  cidr_block                      = var.vpc_settings["public_1a_cidr_block"]
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(tomap({ "Service" = "cmn" }), tomap({ "Name" = "${var.base_name}-cmn-subnet-public-1a" }))
}

resource "aws_subnet" "cmn_subnet_public_1c" {
  vpc_id                          = aws_vpc.cmn_vpc.id
  availability_zone               = "ap-northeast-1c"
  cidr_block                      = var.vpc_settings["public_1c_cidr_block"]
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(tomap({ "Service" = "cmn" }), tomap({ "Name" = "${var.base_name}-cmn-subnet-public-1c" }))
}

resource "aws_subnet" "cmn_subnet_protected_1a" {
  vpc_id                          = aws_vpc.cmn_vpc.id
  availability_zone               = "ap-northeast-1a"
  cidr_block                      = var.vpc_settings["protected_1a_cidr_block"]
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(tomap({ "Service" = "cmn" }), tomap({ "Name" = "${var.base_name}-cmn-subnet-protected-1a" }))
}

resource "aws_subnet" "cmn_subnet_protected_1c" {
  vpc_id                          = aws_vpc.cmn_vpc.id
  availability_zone               = "ap-northeast-1c"
  cidr_block                      = var.vpc_settings["protected_1c_cidr_block"]
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(tomap({ "Service" = "cmn" }), tomap({ "Name" = "${var.base_name}-cmn-subnet-protected-1c" }))
}

resource "aws_subnet" "cmn_subnet_private_1a" {
  vpc_id                          = aws_vpc.cmn_vpc.id
  availability_zone               = "ap-northeast-1a"
  cidr_block                      = var.vpc_settings["private_1a_cidr_block"]
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(tomap({ "Service" = "cmn" }), tomap({ "Name" = "${var.base_name}-cmn-subnet-private-1a" }))
}

resource "aws_subnet" "cmn_subnet_private_1c" {
  vpc_id                          = aws_vpc.cmn_vpc.id
  availability_zone               = "ap-northeast-1c"
  cidr_block                      = var.vpc_settings["private_1c_cidr_block"]
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(tomap({ "Service" = "cmn" }), tomap({ "Name" = "${var.base_name}-cmn-subnet-private-1c" }))
}

resource "aws_subnet" "cmn_subnet_management_1a" {
  vpc_id                          = aws_vpc.cmn_vpc.id
  availability_zone               = "ap-northeast-1a"
  cidr_block                      = var.vpc_settings["management_1a_cidr_block"]
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(tomap({ "Service" = "cmn" }), tomap({ "Name" = "${var.base_name}-cmn-subnet-management-1a" }))
}

resource "aws_subnet" "cmn_subnet_management_1c" {
  vpc_id                          = aws_vpc.cmn_vpc.id
  availability_zone               = "ap-northeast-1c"
  cidr_block                      = var.vpc_settings["management_1c_cidr_block"]
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(tomap({ "Service" = "cmn" }), tomap({ "Name" = "${var.base_name}-cmn-subnet-management-1c" }))
}

#####################################
# Internet Gateway Settings
#####################################
resource "aws_internet_gateway" "cmn_igw" {
  vpc_id = aws_vpc.cmn_vpc.id
  tags   = merge(tomap({ "Service" = "cmn" }), tomap({ "Name" = "${var.base_name}-cmn-igw" }))
}

#####################################
# NAT Gateway Settings
#####################################
resource "aws_eip" "cmn_ngw_ip_1a" {
  vpc  = true
  tags = merge(tomap({ "Service" = "cmn" }), tomap({ "Name" = "${var.base_name}-cmn-ngw-ip-1a" }))
}

resource "aws_eip" "cmn_ngw_ip_1c" {
  vpc  = true
  tags = merge(tomap({ "Service" = "cmn" }), tomap({ "Name" = "${var.base_name}-cmn-ngw-ip-1c" }))
}

resource "aws_nat_gateway" "cmn_ngw_1a" {
  allocation_id = aws_eip.cmn_ngw_ip_1a.id
  subnet_id     = aws_subnet.cmn_subnet_public_1a.id
  depends_on    = [aws_internet_gateway.cmn_igw]
  tags          = merge(tomap({ "Service" = "cmn" }), tomap({ "Name" = "${var.base_name}-cmn-ngw-1a" }))
}

resource "aws_nat_gateway" "cmn_ngw_1c" {
  allocation_id = aws_eip.cmn_ngw_ip_1c.id
  subnet_id     = aws_subnet.cmn_subnet_public_1c.id
  depends_on    = [aws_internet_gateway.cmn_igw]
  tags          = merge(tomap({ "Service" = "cmn" }), tomap({ "Name" = "${var.base_name}-cmn-ngw-1c" }))
}

#####################################
# Route Table Settings
#####################################
resource "aws_route_table" "cmn_rtb_igw" {
  vpc_id = aws_vpc.cmn_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cmn_igw.id
  }
  tags = merge(tomap({ "Service" = "cmn" }), tomap({ "Name" = "${var.base_name}-cmn-rtb-igw" }))
}

resource "aws_route_table" "cmn_rtb_ngw_1a" {
  vpc_id = aws_vpc.cmn_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.cmn_ngw_1a.id
  }
  tags = merge(tomap({ "Service" = "cmn" }), tomap({ "Name" = "${var.base_name}-cmn-ngw-rtb-1a" }))
}

resource "aws_route_table" "cmn_rtb_ngw_1c" {
  vpc_id = aws_vpc.cmn_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.cmn_ngw_1c.id
  }
  tags = merge(tomap({ "Service" = "cmn" }), tomap({ "Name" = "${var.base_name}-cmn-ngw-rtb-1c" }))
}

#####################################
# Route Table Association Settings
#####################################
resource "aws_route_table_association" "igw_rtba_public_1a" {
  subnet_id      = aws_subnet.cmn_subnet_public_1a.id
  route_table_id = aws_route_table.cmn_rtb_igw.id
}

resource "aws_route_table_association" "igw_rtba_public_1c" {
  subnet_id      = aws_subnet.cmn_subnet_public_1c.id
  route_table_id = aws_route_table.cmn_rtb_igw.id
}

resource "aws_route_table_association" "ngw_rtba_protected_1a" {
  subnet_id      = aws_subnet.cmn_subnet_protected_1a.id
  route_table_id = aws_route_table.cmn_rtb_ngw_1a.id
}

resource "aws_route_table_association" "ngw_rtba_protected_1c" {
  subnet_id      = aws_subnet.cmn_subnet_protected_1c.id
  route_table_id = aws_route_table.cmn_rtb_ngw_1c.id
}

resource "aws_route_table_association" "igw_rtba_management_1a" {
  subnet_id      = aws_subnet.cmn_subnet_management_1a.id
  route_table_id = aws_route_table.cmn_rtb_igw.id
}

resource "aws_route_table_association" "igw_rtba_management_1c" {
  subnet_id      = aws_subnet.cmn_subnet_management_1c.id
  route_table_id = aws_route_table.cmn_rtb_igw.id
}