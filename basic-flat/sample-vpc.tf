#####################################
# VPC
#####################################
resource "aws_vpc" "sample" {
  cidr_block = local.vpc_cidr_block
  tags       = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}