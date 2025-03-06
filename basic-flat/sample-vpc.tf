#####################################
# VPC
#####################################
resource "aws_vpc" "sample" {
  cidr_block = local.vpc_cidr_block
  tags = {
    Service = "sample"
    Name    = "${local.base_name}-sample"
  }
}