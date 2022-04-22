/*
#####################################
# ACM
#####################################

resource "aws_acm_certificate" "cert" {
  domain_name       = "sample.com"
  validation_method = "DNS"
  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-sample-route53-cert" }))
}

#####################################
# DNS
#####################################

resource "aws_route53_zone" "public_zone" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone
  name = "sample.com"
  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-sample-route53-public-zone" }))
}

resource "aws_route53_zone" "dev_subdomain" {
  name = "dev.example.com"
  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-sample-route53-subdomain-zone" }))
}

resource "aws_route53_record" "dev_subdomain_record" {
  zone_id = aws_route53_zone.public_zone.zone_id
  name    = "dev.example.com"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.dev_subdomain.name_servers
}

resource "aws_route53_record" "validation" {
  zone_id = aws_route53_zone.public_zone.zone_id
  name    = "_xxxx.example.com."
  type    = "CNAME"
  ttl     = "300"
  records = ["_xxxx.acm-validations.aws."]
}
*/