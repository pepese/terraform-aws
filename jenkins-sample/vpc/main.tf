#####################################
# VPC Settings
#####################################

resource "aws_vpc" "vpc" {
  cidr_block                       = "10.0.0.0/16"
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  enable_classiclink               = false
  enable_classiclink_dns_support   = false
  assign_generated_ipv6_cidr_block = false
  tags                             = merge(local.base_tags, map("Name", "${local.base_name}-vpc"))
}

#####################################
# VPC DHCP Option Settings
#####################################

resource "aws_vpc_dhcp_options" "vpc" {
  domain_name_servers = ["10.0.0.2", "169.254.169.253"]
  ntp_servers         = ["169.254.169.123"]
  tags                = merge(local.base_tags, map("Name", "${local.base_name}-vpc"))
}

resource "aws_vpc_dhcp_options_association" "vpc" {
  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.vpc.id
}

#####################################
# Subnet Settings
#####################################

resource "aws_subnet" "public_1a" {
  vpc_id                          = aws_vpc.vpc.id
  availability_zone               = "ap-northeast-1a"
  cidr_block                      = "10.0.0.0/24"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(local.base_tags, map("Name", "${local.base_name}-subnet-public-1a"))
}

resource "aws_subnet" "public_1c" {
  vpc_id                          = aws_vpc.vpc.id
  availability_zone               = "ap-northeast-1c"
  cidr_block                      = "10.0.1.0/24"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(local.base_tags, map("Name", "${local.base_name}-subnet-public-1c"))
}

resource "aws_subnet" "public_1d" {
  vpc_id                          = aws_vpc.vpc.id
  availability_zone               = "ap-northeast-1d"
  cidr_block                      = "10.0.2.0/24"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(local.base_tags, map("Name", "${local.base_name}-subnet-public-1d"))
}

resource "aws_subnet" "protected_1a" {
  vpc_id                          = aws_vpc.vpc.id
  availability_zone               = "ap-northeast-1a"
  cidr_block                      = "10.0.64.0/24"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(local.base_tags, map("Name", "${local.base_name}-subnet-protected-1a"))
}

resource "aws_subnet" "protected_1c" {
  vpc_id                          = aws_vpc.vpc.id
  availability_zone               = "ap-northeast-1c"
  cidr_block                      = "10.0.65.0/24"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(local.base_tags, map("Name", "${local.base_name}-subnet-protected-1c"))
}

resource "aws_subnet" "protected_1d" {
  vpc_id                          = aws_vpc.vpc.id
  availability_zone               = "ap-northeast-1d"
  cidr_block                      = "10.0.66.0/24"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(local.base_tags, map("Name", "${local.base_name}-subnet-protected-1d"))
}

resource "aws_subnet" "private_1a" {
  vpc_id                          = aws_vpc.vpc.id
  availability_zone               = "ap-northeast-1a"
  cidr_block                      = "10.0.128.0/24"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(local.base_tags, map("Name", "${local.base_name}-subnet-private-1a"))
}

resource "aws_subnet" "private_1c" {
  vpc_id                          = aws_vpc.vpc.id
  availability_zone               = "ap-northeast-1c"
  cidr_block                      = "10.0.129.0/24"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(local.base_tags, map("Name", "${local.base_name}-subnet-private-1c"))
}

resource "aws_subnet" "private_1d" {
  vpc_id                          = aws_vpc.vpc.id
  availability_zone               = "ap-northeast-1d"
  cidr_block                      = "10.0.130.0/24"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(local.base_tags, map("Name", "${local.base_name}-subnet-private-1d"))
}

#####################################
# Internet Gateway Settings
#####################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(local.base_tags, map("Name", "${local.base_name}-igw"))
}

#####################################
# NAT Gateway Settings
#####################################

resource "aws_eip" "ngw_ip_1a" {
  vpc  = true
  tags = merge(local.base_tags, map("Name", "${local.base_name}-ngw-ip-1a"))
}

resource "aws_eip" "ngw_ip_1c" {
  vpc  = true
  tags = merge(local.base_tags, map("Name", "${local.base_name}-ngw-ip-1c"))
}

resource "aws_eip" "ngw_ip_1d" {
  vpc  = true
  tags = merge(local.base_tags, map("Name", "${local.base_name}-ngw-ip-1d"))
}

resource "aws_nat_gateway" "ngw_1a" {
  allocation_id = aws_eip.ngw_ip_1a.id
  subnet_id     = aws_subnet.public_1a.id
  depends_on    = [aws_internet_gateway.igw]
  tags          = merge(local.base_tags, map("Name", "${local.base_name}-ngw-1a"))
}

resource "aws_nat_gateway" "ngw_1c" {
  allocation_id = aws_eip.ngw_ip_1c.id
  subnet_id     = aws_subnet.public_1c.id
  depends_on    = [aws_internet_gateway.igw]
  tags          = merge(local.base_tags, map("Name", "${local.base_name}-ngw-1c"))
}

resource "aws_nat_gateway" "ngw_1d" {
  allocation_id = aws_eip.ngw_ip_1d.id
  subnet_id     = aws_subnet.public_1d.id
  depends_on    = [aws_internet_gateway.igw]
  tags          = merge(local.base_tags, map("Name", "${local.base_name}-ngw-1d"))
}

#####################################
# Route Table Settings
#####################################

resource "aws_route_table" "igw_rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(local.base_tags, map("Name", "${local.base_name}-igw-rtb"))
}

resource "aws_route_table" "ngw_rtb_1a" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw_1a.id
  }
  tags = merge(local.base_tags, map("Name", "${local.base_name}-ngw-rtb-1a"))
}

resource "aws_route_table" "ngw_rtb_1c" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw_1c.id
  }
  tags = merge(local.base_tags, map("Name", "${local.base_name}-ngw-rtb-1c"))
}

resource "aws_route_table" "ngw_rtb_1d" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw_1d.id
  }
  tags = merge(local.base_tags, map("Name", "${local.base_name}-ngw-rtb-1d"))
}

#####################################
# Route Table Association Settings
#####################################

resource "aws_route_table_association" "igw_rtba_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.igw_rtb.id
}

resource "aws_route_table_association" "igw_rtba_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.igw_rtb.id
}

resource "aws_route_table_association" "igw_rtba_1d" {
  subnet_id      = aws_subnet.public_1d.id
  route_table_id = aws_route_table.igw_rtb.id
}

resource "aws_route_table_association" "ngw_rtba_1a" {
  subnet_id      = aws_subnet.protected_1a.id
  route_table_id = aws_route_table.ngw_rtb_1a.id
}

resource "aws_route_table_association" "ngw_rtba_1c" {
  subnet_id      = aws_subnet.protected_1c.id
  route_table_id = aws_route_table.ngw_rtb_1c.id
}

resource "aws_route_table_association" "ngw_rtba_1d" {
  subnet_id      = aws_subnet.protected_1d.id
  route_table_id = aws_route_table.ngw_rtb_1d.id
}
