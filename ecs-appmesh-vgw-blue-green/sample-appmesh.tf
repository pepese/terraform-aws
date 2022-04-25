#####################################
# App Mesh
#####################################
resource "aws_appmesh_mesh" "sample" {
  name = "${local.base_name}-sample"
  spec {
    egress_filter {
      type = "ALLOW_ALL"
    }
  }
  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

#####################################
# App Mesh / Virtual Router
#####################################
resource "aws_appmesh_virtual_router" "sample" {
  name      = local.sample_param["app_name"]
  mesh_name = aws_appmesh_mesh.sample.id

  spec {
    listener {
      port_mapping {
        port     = local.sample_param["app_port"]
        protocol = "http"
      }
    }
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

// route for blue and green
resource "aws_appmesh_route" "sample" {
  count               = local.sample_param["blue_is_active"] == "true" && local.sample_param["green_is_active"] == "true" ? 1 : 0
  name                = local.sample_param["app_name"]
  mesh_name           = aws_appmesh_mesh.sample.id
  virtual_router_name = aws_appmesh_virtual_router.sample.name

  spec {
    http_route {
      match {
        prefix = "/"
      }

      retry_policy {
        tcp_retry_events = [
          "connection-error",
        ]
        max_retries = 1
        per_retry_timeout {
          unit  = "s"
          value = 1
        }
      }

      action {
        weighted_target {
          virtual_node = aws_appmesh_virtual_node.sample_blue[count.index].name
          weight       = local.sample_param["blue_weight"]
        }
        weighted_target {
          virtual_node = aws_appmesh_virtual_node.sample_green[count.index].name
          weight       = local.sample_param["green_weight"]
        }
      }
    }
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

// route for blue
resource "aws_appmesh_route" "sample_blue" {
  count               = local.sample_param["blue_is_active"] == "true" && local.sample_param["green_is_active"] == "false" ? 1 : 0
  name                = "${local.sample_param["app_name"]}-blue"
  mesh_name           = aws_appmesh_mesh.sample.id
  virtual_router_name = aws_appmesh_virtual_router.sample.name

  spec {
    http_route {
      match {
        prefix = "/"
      }

      retry_policy {
        tcp_retry_events = [
          "connection-error",
        ]
        max_retries = 1
        per_retry_timeout {
          unit  = "s"
          value = 1
        }
      }

      action {
        weighted_target {
          virtual_node = aws_appmesh_virtual_node.sample_blue[count.index].name
          weight       = local.sample_param["blue_weight"]
        }
      }
    }
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-blue" }))
}

// route for green
resource "aws_appmesh_route" "sample_green" {
  count               = local.sample_param["blue_is_active"] == "false" && local.sample_param["green_is_active"] == "true" ? 1 : 0
  name                = "${local.sample_param["app_name"]}-green"
  mesh_name           = aws_appmesh_mesh.sample.id
  virtual_router_name = aws_appmesh_virtual_router.sample.name

  spec {
    http_route {
      match {
        prefix = "/"
      }

      retry_policy {
        tcp_retry_events = [
          "connection-error",
        ]
        max_retries = 1
        per_retry_timeout {
          unit  = "s"
          value = 1
        }
      }

      action {
        weighted_target {
          virtual_node = aws_appmesh_virtual_node.sample_green[count.index].name
          weight       = local.sample_param["green_weight"]
        }
      }
    }
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-green" }))
}

#####################################
# App Mesh / Virtual Service
#####################################
resource "aws_appmesh_virtual_service" "sample" {
  name      = "${aws_service_discovery_service.sample.name}.${aws_service_discovery_private_dns_namespace.sample_private_dns.name}"
  mesh_name = aws_appmesh_mesh.sample.id

  spec {
    provider {
      virtual_router {
        virtual_router_name = aws_appmesh_virtual_router.sample.name
      }
    }
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}