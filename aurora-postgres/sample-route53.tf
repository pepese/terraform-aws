#####################################
# DNS Private Hosted Zone
#####################################
resource "aws_route53_zone" "sample_private" {
  name = local.route53_settings["private_hosted_zone_name"]

  vpc {
    vpc_id = aws_vpc.sample.id
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-private" }))
}