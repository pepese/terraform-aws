#####################################
# VPC
#####################################
resource "aws_vpc" "sample" {
  cidr_block = var.vpc_cidr_block
  tags       = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${var.base_name}-sample" }))
}