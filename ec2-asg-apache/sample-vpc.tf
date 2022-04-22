#####################################
# VPC Settings
#####################################
resource "aws_vpc" "sample" {
  cidr_block           = local.vpc_settings["vpc_cidr_block"]
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

#####################################
# Subnet Settings
#####################################
resource "aws_subnet" "sample_public_1a" {
  vpc_id                          = aws_vpc.sample.id
  availability_zone               = "ap-northeast-1a"
  cidr_block                      = local.vpc_settings["public_1a_cidr_block"]
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-public-1a" }))
}

resource "aws_subnet" "sample_public_1c" {
  vpc_id                          = aws_vpc.sample.id
  availability_zone               = "ap-northeast-1c"
  cidr_block                      = local.vpc_settings["public_1c_cidr_block"]
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-public-1c" }))
}

resource "aws_subnet" "sample_protected_1a" {
  vpc_id                          = aws_vpc.sample.id
  availability_zone               = "ap-northeast-1a"
  cidr_block                      = local.vpc_settings["protected_1a_cidr_block"]
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-protected-1a" }))
}

resource "aws_subnet" "sample_protected_1c" {
  vpc_id                          = aws_vpc.sample.id
  availability_zone               = "ap-northeast-1c"
  cidr_block                      = local.vpc_settings["protected_1c_cidr_block"]
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-protected-1c" }))
}

resource "aws_subnet" "sample_private_1a" {
  vpc_id                          = aws_vpc.sample.id
  availability_zone               = "ap-northeast-1a"
  cidr_block                      = local.vpc_settings["private_1a_cidr_block"]
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-private-1a" }))
}

resource "aws_subnet" "sample_private_1c" {
  vpc_id                          = aws_vpc.sample.id
  availability_zone               = "ap-northeast-1c"
  cidr_block                      = local.vpc_settings["private_1c_cidr_block"]
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-private-1c" }))
}

resource "aws_subnet" "sample_management_1a" {
  vpc_id                          = aws_vpc.sample.id
  availability_zone               = "ap-northeast-1a"
  cidr_block                      = local.vpc_settings["management_1a_cidr_block"]
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-management-1a" }))
}

resource "aws_subnet" "sample_management_1c" {
  vpc_id                          = aws_vpc.sample.id
  availability_zone               = "ap-northeast-1c"
  cidr_block                      = local.vpc_settings["management_1c_cidr_block"]
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-management-1c" }))
}

#####################################
# Internet Gateway Settings
#####################################
resource "aws_internet_gateway" "sample" {
  vpc_id = aws_vpc.sample.id
  tags   = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

#####################################
# NAT Gateway Settings
#####################################
resource "aws_eip" "sample_1a" {
  vpc  = true
  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-1a" }))
}

resource "aws_eip" "sample_1c" {
  vpc  = true
  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-1c" }))
}

resource "aws_nat_gateway" "sample_1a" {
  allocation_id = aws_eip.sample_1a.id
  subnet_id     = aws_subnet.sample_public_1a.id
  depends_on    = [aws_internet_gateway.sample]
  tags          = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-1a" }))
}

resource "aws_nat_gateway" "sample_1c" {
  allocation_id = aws_eip.sample_1c.id
  subnet_id     = aws_subnet.sample_public_1c.id
  depends_on    = [aws_internet_gateway.sample]
  tags          = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-1c" }))
}

#####################################
# Route Table Settings
#####################################
resource "aws_route_table" "sample_igw" {
  vpc_id = aws_vpc.sample.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sample.id
  }
  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-igw" }))
}

resource "aws_route_table" "sample_ngw_1a" {
  vpc_id = aws_vpc.sample.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.sample_1a.id
  }
  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-ngw-1a" }))
}

resource "aws_route_table" "sample_ngw_1c" {
  vpc_id = aws_vpc.sample.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.sample_1c.id
  }
  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-ngw-1c" }))
}

#####################################
# Route Table Association Settings
#####################################
resource "aws_route_table_association" "sample_igw_public_1a" {
  subnet_id      = aws_subnet.sample_public_1a.id
  route_table_id = aws_route_table.sample_igw.id
}

resource "aws_route_table_association" "sample_igw_public_1c" {
  subnet_id      = aws_subnet.sample_public_1c.id
  route_table_id = aws_route_table.sample_igw.id
}

resource "aws_route_table_association" "sample_ngw_protected_1a" {
  subnet_id      = aws_subnet.sample_protected_1a.id
  route_table_id = aws_route_table.sample_ngw_1a.id
}

resource "aws_route_table_association" "sample_ngw_protected_1c" {
  subnet_id      = aws_subnet.sample_protected_1c.id
  route_table_id = aws_route_table.sample_ngw_1c.id
}

resource "aws_route_table_association" "sample_igw_management_1a" {
  subnet_id      = aws_subnet.sample_management_1a.id
  route_table_id = aws_route_table.sample_ngw_1a.id
}

resource "aws_route_table_association" "sample_igw_management_1c" {
  subnet_id      = aws_subnet.sample_management_1c.id
  route_table_id = aws_route_table.sample_ngw_1c.id
}