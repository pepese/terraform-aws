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
  tags                             = merge(local.eks_nw_tags, map("Name", "${local.base_name}-vpc"))
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
  vpc_id          = "${aws_vpc.vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.vpc.id}"
}

#####################################
# Subnet Settings
#####################################

resource "aws_subnet" "public_subnet_a" {
  vpc_id                          = "${aws_vpc.vpc.id}"
  availability_zone               = "ap-northeast-1a"
  cidr_block                      = "10.0.0.0/24"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(local.eks_nw_tags, map("Name", "${local.base_name}-public-subnet-a"))
}

resource "aws_subnet" "public_subnet_c" {
  vpc_id                          = "${aws_vpc.vpc.id}"
  availability_zone               = "ap-northeast-1c"
  cidr_block                      = "10.0.1.0/24"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(local.eks_nw_tags, map("Name", "${local.base_name}-public-subnet-c"))
}

resource "aws_subnet" "public_subnet_d" {
  vpc_id                          = "${aws_vpc.vpc.id}"
  availability_zone               = "ap-northeast-1d"
  cidr_block                      = "10.0.2.0/24"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(local.eks_nw_tags, map("Name", "${local.base_name}-public-subnet-d"))
}

resource "aws_subnet" "cluster_subnet_a" {
  vpc_id                          = "${aws_vpc.vpc.id}"
  availability_zone               = "ap-northeast-1a"
  cidr_block                      = "10.0.64.0/24"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(local.eks_nw_tags, map("kubernetes.io/role/internal-elb", "1"), map("Name", "${local.base_name}-private-subnet-a"))
}

resource "aws_subnet" "cluster_subnet_c" {
  vpc_id                          = "${aws_vpc.vpc.id}"
  availability_zone               = "ap-northeast-1c"
  cidr_block                      = "10.0.65.0/24"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(local.eks_nw_tags, map("kubernetes.io/role/internal-elb", "1"), map("Name", "${local.base_name}-cluster-subnet-c"))
}

resource "aws_subnet" "cluster_subnet_d" {
  vpc_id                          = "${aws_vpc.vpc.id}"
  availability_zone               = "ap-northeast-1d"
  cidr_block                      = "10.0.66.0/24"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(local.eks_nw_tags, map("kubernetes.io/role/internal-elb", "1"), map("Name", "${local.base_name}-cluster-subnet-d"))
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                          = "${aws_vpc.vpc.id}"
  availability_zone               = "ap-northeast-1a"
  cidr_block                      = "10.0.128.0/24"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(local.base_tags, map("kubernetes.io/role/internal-elb", "1"), map("Name", "${local.base_name}-cluster-subnet-a"))
}

resource "aws_subnet" "private_subnet_c" {
  vpc_id                          = "${aws_vpc.vpc.id}"
  availability_zone               = "ap-northeast-1c"
  cidr_block                      = "10.0.129.0/24"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(local.base_tags, map("Name", "${local.base_name}-private-subnet-c"))
}

resource "aws_subnet" "private_subnet_d" {
  vpc_id                          = "${aws_vpc.vpc.id}"
  availability_zone               = "ap-northeast-1d"
  cidr_block                      = "10.0.130.0/24"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags                            = merge(local.base_tags, map("Name", "${local.base_name}-private-subnet-d"))
}

#####################################
# Internet Gateway Settings
#####################################

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags   = merge(local.base_tags, map("Name", "${local.base_name}-igw"))
}

#####################################
# NAT Gateway Settings
#####################################

resource "aws_eip" "ngw_ip_a" {
  vpc  = true
  tags = merge(local.base_tags, map("Name", "${local.base_name}-ngw-ip-a"))
}

resource "aws_eip" "ngw_ip_c" {
  vpc  = true
  tags = merge(local.base_tags, map("Name", "${local.base_name}-ngw-ip-c"))
}

resource "aws_eip" "ngw_ip_d" {
  vpc  = true
  tags = merge(local.base_tags, map("Name", "${local.base_name}-ngw-ip-d"))
}

resource "aws_nat_gateway" "ngw_a" {
  allocation_id = "${aws_eip.ngw_ip_a.id}"
  subnet_id     = "${aws_subnet.public_subnet_a.id}"
  depends_on    = ["aws_internet_gateway.igw"]
  tags          = merge(local.base_tags, map("Name", "${local.base_name}-ngw-a"))
}

resource "aws_nat_gateway" "ngw_c" {
  allocation_id = "${aws_eip.ngw_ip_c.id}"
  subnet_id     = "${aws_subnet.public_subnet_c.id}"
  depends_on    = ["aws_internet_gateway.igw"]
  tags          = merge(local.base_tags, map("Name", "${local.base_name}-ngw-c"))
}

resource "aws_nat_gateway" "ngw_d" {
  allocation_id = "${aws_eip.ngw_ip_d.id}"
  subnet_id     = "${aws_subnet.public_subnet_d.id}"
  depends_on    = ["aws_internet_gateway.igw"]
  tags          = merge(local.base_tags, map("Name", "${local.base_name}-ngw-d"))
}

#####################################
# Route Table Settings
#####################################

resource "aws_route_table" "igw_rtb" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags = merge(local.base_tags, map("Name", "${local.base_name}-igw-rtb"))
}

resource "aws_route_table" "ngw_rtb_a" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ngw_a.id}"
  }
  tags = merge(local.base_tags, map("Name", "${local.base_name}-ngw-rtb-a"))
}

resource "aws_route_table" "ngw_rtb_c" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ngw_c.id}"
  }
  tags = merge(local.base_tags, map("Name", "${local.base_name}-ngw-rtb-c"))
}

resource "aws_route_table" "ngw_rtb_d" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ngw_d.id}"
  }
  tags = merge(local.base_tags, map("Name", "${local.base_name}-ngw-rtb-d"))
}

#####################################
# Route Table Association Settings
#####################################

resource "aws_route_table_association" "igw_rtba_a" {
  subnet_id      = "${aws_subnet.public_subnet_a.id}"
  route_table_id = "${aws_route_table.igw_rtb.id}"
}

resource "aws_route_table_association" "igw_rtba_c" {
  subnet_id      = "${aws_subnet.public_subnet_c.id}"
  route_table_id = "${aws_route_table.igw_rtb.id}"
}

resource "aws_route_table_association" "igw_rtba_d" {
  subnet_id      = "${aws_subnet.public_subnet_d.id}"
  route_table_id = "${aws_route_table.igw_rtb.id}"
}

resource "aws_route_table_association" "ngw_rtba_a" {
  subnet_id      = "${aws_subnet.cluster_subnet_a.id}"
  route_table_id = "${aws_route_table.ngw_rtb_a.id}"
}

resource "aws_route_table_association" "ngw_rtba_c" {
  subnet_id      = "${aws_subnet.cluster_subnet_c.id}"
  route_table_id = "${aws_route_table.ngw_rtb_c.id}"
}

resource "aws_route_table_association" "ngw_rtba_d" {
  subnet_id      = "${aws_subnet.cluster_subnet_d.id}"
  route_table_id = "${aws_route_table.ngw_rtb_d.id}"
}

#####################################
# Security Group Settings
#####################################

resource "aws_security_group" "eks_master_sg" {
  name   = "${local.base_name}-eks-master-sg"
  vpc_id = "${aws_vpc.vpc.id}"
  tags   = merge(local.base_tags, map("Name", "${local.base_name}-eks-master-sg"))
}

resource "aws_security_group_rule" "eks_master_sg_allow_ingress_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.eks_master_sg.id}"
}

resource "aws_security_group_rule" "eks_master_sg_allow_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.eks_master_sg.id}"
}

resource "aws_security_group" "eks_worker_sg" {
  name   = "${local.base_name}-eks-worker-sg"
  vpc_id = "${aws_vpc.vpc.id}"
  tags   = merge(local.base_tags, map("Name", "${local.base_name}-eks-worker-sg"))
}

resource "aws_security_group_rule" "eks_worker_sg_allow_ingress_443" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.eks_master_sg.id}"
  security_group_id        = "${aws_security_group.eks_worker_sg.id}"
}

resource "aws_security_group_rule" "eks_worker_sg_allow_ingress_k8s" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.eks_master_sg.id}"
  security_group_id        = "${aws_security_group.eks_worker_sg.id}"
}

resource "aws_security_group_rule" "eks_worker_sg_allow_ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = "${aws_security_group.eks_worker_sg.id}"
}

resource "aws_security_group_rule" "eks_worker_sg_allow_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.eks_worker_sg.id}"
}