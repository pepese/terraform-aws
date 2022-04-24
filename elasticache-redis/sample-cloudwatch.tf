#####################################
# CloudWatch Log Group
#####################################
resource "aws_cloudwatch_log_group" "sample_elasticache_slowlog" {
  name = "/aws/elasticache/${local.system}-${local.env}-sample/redis/slowlog"
  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-elasticach" }))
}