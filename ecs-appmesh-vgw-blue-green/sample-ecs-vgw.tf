#####################################
# App Mesh / Virtual Gateway
#####################################
resource "aws_appmesh_virtual_gateway" "sample_vgw" {
  name      = local.sample_vgw_param["app_name"]
  mesh_name = aws_appmesh_mesh.sample.id

  spec {
    listener {
      port_mapping {
        port     = local.sample_param["app_port"]
        protocol = "http"
      }

      health_check {
        port                = local.sample_param["app_port"]
        protocol            = "http"
        path                = local.sample_param["healthcheck_path"]
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout_millis      = 2000
        interval_millis     = 5000
      }
    }
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-vgw" }))
}

resource "aws_appmesh_gateway_route" "sample_vgw_sample" {
  name                 = "system-sample-vgw-to-sample"
  virtual_gateway_name = aws_appmesh_virtual_gateway.sample_vgw.name
  mesh_name            = aws_appmesh_mesh.sample.id
  spec {
    http_route {
      action {
        target {
          virtual_service {
            virtual_service_name = aws_appmesh_virtual_service.sample.name
          }
        }
      }

      match {
        prefix = "/"
      }
    }
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-vgw" }))
}

#####################################
# ECS Service
#####################################
resource "aws_ecs_service" "sample_vgw" {
  name                  = "${local.base_name}-sample-vgw"
  cluster               = aws_ecs_cluster.sample.arn
  task_definition       = aws_ecs_task_definition.sample_vgw.arn
  desired_count         = local.sample_vgw_param["desired_count"]
  launch_type           = "FARGATE"
  platform_version      = local.sample_vgw_param["platform_version"]
  force_new_deployment  = true
  wait_for_steady_state = true

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.sample_vgw.id]
    subnets = [
      aws_subnet.sample_protected_1a.id,
      aws_subnet.sample_protected_1c.id,
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.sample_80_to_vgw.arn
    container_name   = "envoy"
    container_port   = local.sample_param["app_port"]
  }

  # load_balancer {
  #   target_group_arn = aws_lb_target_group.sample_9901_to_vgw.arn
  #   container_name   = "envoy"
  #   container_port   = 9901
  # }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-vgw" }))
}

#####################################
# ECS Task
#####################################
resource "aws_ecs_task_definition" "sample_vgw" {
  family                   = local.sample_vgw_param["app_name"]
  cpu                      = local.sample_vgw_param["task_cpu"]
  memory                   = local.sample_vgw_param["task_memory"]
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.sample_vgw_exec.arn
  task_role_arn            = aws_iam_role.sample_vgw.arn
  container_definitions    = data.template_file.sample_vgw.rendered

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-vgw" }))
}

#####################################
# ECS Task Definition
#####################################
data "template_file" "sample_vgw" {
  template = file("${path.module}/tpl/task-def-sample-vgw.tpl")
  vars = {
    // app container def
    app_image            = local.sample_vgw_param["app_image"]
    app_cpu              = local.sample_vgw_param["app_cpu"]
    port                 = local.sample_param["app_port"]
    appmesh_resource_arn = "mesh/${aws_appmesh_mesh.sample.name}/virtualGateway/${local.sample_vgw_param["app_name"]}"
    envoy_logs_group     = "${aws_cloudwatch_log_group.sample_vgw.name}"
  }
}