#####################################
# ECS Service
#####################################
resource "aws_ecs_service" "ms1_ecs_service" {
  name             = "${var.base_name}-ms1-ecs-service"
  cluster          = aws_ecs_cluster.cmn_ecs_cluster.arn
  task_definition  = aws_ecs_task_definition.ms1_ecs_task.arn
  desired_count    = var.ms1_ecs_service_settings["desired_count"]
  launch_type      = "FARGATE"
  platform_version = var.ms1_ecs_service_settings["platform_version"]

  load_balancer {
    target_group_arn = aws_lb_target_group.ms1_lb_tg.arn
    container_name   = "httpd-container"
    container_port   = var.ms1_ecs_service_settings["container_port"]
  }

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.ms1_ecs_service_sg.id]
    subnets          = [aws_subnet.cmn_subnet_public_1a.id, aws_subnet.cmn_subnet_public_1c.id]
  }

  ## デプロイ毎にタスク定義が更新されるため、リソース初回作成時を除き変更を無視
  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = merge(tomap({ "Service" = "ms1" }), tomap({ "Name" = "${var.base_name}-ms1-ecs-service" }))
}

#####################################
# ECS Service Security Group
#####################################
resource "aws_security_group" "ms1_ecs_service_sg" {
  name        = "httpd-sg"
  description = "httpd-sg"
  vpc_id      = aws_vpc.cmn_vpc.id

  tags = merge(tomap({ "Service" = "ms1" }), tomap({ "Name" = "${var.base_name}-ms1-ecs-service-sg" }))
}

resource "aws_security_group_rule" "ms1_sg_egress_rule" {
  security_group_id = aws_security_group.ms1_ecs_service_sg.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ms1_sg_self_ingress_rule" {
  security_group_id = aws_security_group.ms1_ecs_service_sg.id

  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  self      = true
}

resource "aws_security_group_rule" "ms1_sg_ingress_rule" {
  security_group_id = aws_security_group.ms1_ecs_service_sg.id

  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ms1_lb_sg.id
}

#####################################
# LB Target Group Settings
#####################################
resource "aws_lb_target_group" "ms1_lb_tg" {
  name        = "${var.base_name}-ms1-lb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.cmn_vpc.id

  tags = merge(tomap({ "Service" = "ms1" }), tomap({ "Name" = "${var.base_name}-ms1-lb-tg" }))
}

resource "aws_lb_listener_rule" "listener_rule_forward" {
  listener_arn = aws_lb_listener.ms1_lb_listener_http.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ms1_lb_tg.arn
  }
  condition {
    path_pattern {
      values = ["/?*"]
    }
  }
}

#####################################
# ECS Task
#####################################
# タスク定義
resource "aws_ecs_task_definition" "ms1_ecs_task" {
  family                   = "httpd-task"
  cpu                      = var.ms1_ecs_service_settings["task_cpu"]
  memory                   = var.ms1_ecs_service_settings["task_memory"]
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.ms1_ecs_task_definition.rendered

  tags = merge(tomap({ "Service" = "ms1" }), tomap({ "Name" = "${var.base_name}-ms1-ecs-task" }))
}

#####################################
# ECS Task Definition
#####################################

data "template_file" "ms1_ecs_task_definition" {
  template = file("${path.module}/tpl/task-definition-ms1.tpl")
  vars = {
    memory        = "${var.ms1_ecs_service_settings["task_definition_memory"]}"
    containerPort = "${var.ms1_ecs_service_settings["task_definition_containerPort"]}"
  }
}