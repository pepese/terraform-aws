#####################################
# VPC
#####################################
resource "aws_vpc" "sample" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Service = "sample"
    Name    = "${var.base_name}-sample"
  }
}