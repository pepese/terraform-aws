#####################################
# Service Discovery
#####################################
resource "aws_service_discovery_private_dns_namespace" "sample_private_dns" {
  name = "${local.system}.svc"
  vpc  = aws_vpc.sample.id
  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-private-dns" }))
}

#####################################
# Service Discovery
#####################################
resource "aws_service_discovery_service" "sample" {
  name = local.sample_param["app_name"]

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.sample_private_dns.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}