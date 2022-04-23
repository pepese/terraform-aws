#####################################
# ECS Cluster
#####################################
resource "aws_ecs_cluster" "cmn_ecs_cluster" {
  name = "${var.base_name}-cmn-ecs-cluster"
  tags = merge(tomap({ "Service" = "cmn" }), tomap({ "Name" = "${var.base_name}-cmn-ecs-cluster" }))
}