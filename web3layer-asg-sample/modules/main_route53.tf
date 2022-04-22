#####################################
# DNS Public Hosted Zone
#####################################
data "aws_route53_zone" "sample_com" {
  name = var.route53_settings["root_domain"]
}

resource "aws_route53_record" "hostname_record" {
  name    = "${var.route53_settings["hostname"]}.${var.route53_settings["root_domain"]}"
  zone_id = data.aws_route53_zone.sample_com.id
  type    = "A"

  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = true
  }
}

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
