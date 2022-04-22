#####################################
# DNS Public Hosted Zone
#####################################
# data "aws_route53_zone" "sample_com" {
#   name = local.route53_settings["root_domain"]
# }

# resource "aws_route53_record" "hostname_record" {
#   name    = "${local.route53_settings["hostname"]}.${local.route53_settings["root_domain"]}"
#   zone_id = data.aws_route53_zone.sample_com.id
#   type    = "A"

#   alias {
#     name                   = aws_lb.sample.dns_name
#     zone_id                = aws_lb.sample.zone_id
#     evaluate_target_health = true
#   }
# }