#####################################
# ECS Cluster
#####################################
resource "aws_ecs_cluster" "sample" {
  name = "${local.base_name}-sample"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}