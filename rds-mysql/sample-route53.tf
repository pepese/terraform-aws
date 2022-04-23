#####################################
# DNS Private Hosted Zone
#####################################
resource "aws_route53_zone" "sample_private_hosted_zone" {
  name = local.route53_settings["private_hosted_zone_name"]

  vpc {
    vpc_id = aws_vpc.sample.id
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-private-hosted-zone" }))
}

resource "aws_route53_record" "sample_rds_local_record" {
  name    = "rds.${local.route53_settings["private_hosted_zone_name"]}"
  zone_id = aws_route53_zone.sample_private_hosted_zone.zone_id
  type    = "CNAME"
  records = [aws_db_instance.sample.address]
  ttl     = 60
}
