

#####################################
# DNS Private Hosted Zone
#####################################
resource "aws_route53_zone" "private_hosted_zone" {
  name = var.route53_settings["private_hosted_zone_name"]

  vpc {
    vpc_id = aws_vpc.vpc.id
  }

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-private-hosted-zone" }))
}

resource "aws_route53_record" "rds_local_record" {
  name    = "rds.${var.route53_settings["private_hosted_zone_name"]}"
  zone_id = aws_route53_zone.private_hosted_zone.zone_id
  type    = "CNAME"
  records = [aws_db_instance.rds.address]
  ttl     = 60
}
