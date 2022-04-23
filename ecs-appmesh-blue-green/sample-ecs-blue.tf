#####################################
# App Mesh / Virtual Node
#####################################
resource "aws_appmesh_virtual_node" "sample_blue" {
  count     = local.sample_param["blue_is_active"] ? 1 : 0
  name      = "${local.sample_param["app_name"]}-blue" # タスク定義の「APPMESH_RESOURCE_ARN」の設定で紐づく
  mesh_name = aws_appmesh_mesh.sample.id

  spec {
    listener {
      port_mapping {
        port     = local.sample_param["app_port"]
        protocol = "http"
      }
      health_check {
        protocol            = "http"
        path                = local.sample_param["healthcheck_path"]
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout_millis      = 2000
        interval_millis     = 5000
      }
    }

    // Service Discovery で検索を行い、ヒットしたサービスを Virtural Node とする
    service_discovery {
      // 以下のクエリで ECS Service を検索しているのと同様
      // aws servicediscovery discover-instances --namespace-name system.svc --service-name system-sample --query-parameters ECS_SERVICE_NAME=system-[env]-sample-blue
      aws_cloud_map {
        attributes = {
          ECS_SERVICE_NAME = "${local.base_name}-sample-blue"
        }
        namespace_name = aws_service_discovery_private_dns_namespace.sample_private_dns.name
        service_name   = local.sample_param["app_name"]
      }
    }

    logging {
      access_log {
        file {
          path = "/dev/stdout"
        }
      }
    }
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-blue" }))
}

#####################################
# ECS / Virtual Service
#####################################
resource "aws_ecs_service" "sample_blue" {
  count            = local.sample_param["blue_is_active"] ? 1 : 0
  name             = "${local.base_name}-sample-blue"
  cluster          = aws_ecs_cluster.sample.arn
  task_definition  = aws_ecs_task_definition.sample_blue[count.index].arn
  desired_count    = local.sample_param["desired_count"]
  launch_type      = "FARGATE"
  platform_version = local.sample_param["platform_version"]

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.sample.id]
    subnets = [
      aws_subnet.sample_protected_1a.id,
      aws_subnet.sample_protected_1c.id,
    ]
  }

  # Service Discovery に登録
  service_registries {
    registry_arn = aws_service_discovery_service.sample.arn
  }

  ## デプロイ毎にタスク定義が更新されるため、リソース初回作成時を除き変更を無視
  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-blue" }))
}

#####################################
# ECS Task
#####################################
resource "aws_ecs_task_definition" "sample_blue" {
  count                    = local.sample_param["blue_is_active"] ? 1 : 0
  family                   = "${local.sample_param["app_name"]}-blue"
  cpu                      = local.sample_param["task_cpu"]
  memory                   = local.sample_param["task_memory"]
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.sample_exec.arn
  task_role_arn            = aws_iam_role.sample.arn
  container_definitions    = data.template_file.sample_blue[count.index].rendered

  proxy_configuration {
    type           = "APPMESH"
    container_name = "envoy"
    properties = {
      AppPorts         = "${local.sample_param["app_port"]}"
      EgressIgnoredIPs = "169.254.170.2,169.254.169.254"
      IgnoredUID       = "1337"
      ProxyEgressPort  = 15001
      ProxyIngressPort = 15000
    }
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-blue" }))
}

#####################################
# ECS Task Definition
#####################################
data "template_file" "sample_blue" {
  count    = local.sample_param["blue_is_active"] ? 1 : 0
  template = file("${path.module}/tpl/task-def-sample.tpl")
  vars = {
    // app container def
    name           = "${local.sample_param["app_name"]}-blue"
    image          = local.sample_param["app_image_blue"]
    memory         = local.sample_param["app_memory"]
    containerPort  = local.sample_param["app_port"]
    app_logs_group = aws_cloudwatch_log_group.sample.name
    // envoy container def
    envoy_image          = local.sample_param["envoy_image"]
    envoy_cpu            = local.sample_param["envoy_cpu"]
    envoy_memory_rsv     = local.sample_param["envoy_memory_rsv"]
    envoy_logs_group     = aws_cloudwatch_log_group.sample_envoy.name
    appmesh_resource_arn = "mesh/${aws_appmesh_mesh.sample.name}/virtualNode/${local.sample_param["app_name"]}-blue"
    // xray container def
    xray_image      = local.sample_param["xray_image"]
    xray_cpu        = local.sample_param["xray_cpu"]
    xray_memory_rsv = local.sample_param["xray_memory_rsv"]
    xray_logs_group = aws_cloudwatch_log_group.sample_xray.name
  }
}