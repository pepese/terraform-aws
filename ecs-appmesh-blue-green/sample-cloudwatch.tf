#####################################
# CloudWatch Log Group
#####################################
resource "aws_cloudwatch_log_group" "sample" {
  name = "/${local.system}/${local.env}/sample"
  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

resource "aws_cloudwatch_log_group" "sample_envoy" {
  name = "/${local.system}/${local.env}/sample/envoy"
  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-envoy" }))
}

resource "aws_cloudwatch_log_group" "sample_xray" {
  name = "/${local.system}/${local.env}/sample/xray"
  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-xray" }))
}