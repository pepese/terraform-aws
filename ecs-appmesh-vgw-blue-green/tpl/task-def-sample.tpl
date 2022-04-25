[
  {
    "name": "${name}",
    "image": "${image}",
    "essential": true,
    "memory": ${memory},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "ecs",
        "awslogs-group": "${app_logs_group}"
      }
    },
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": ${containerPort},
        "hostPort": ${containerPort}
      }
    ],
    "environment": [
      {
        "name": "TZ",
        "value": "Asia/Tokyo"
      }
    ],
    "dependsOn": [
      {
        "containerName": "envoy",
        "condition": "HEALTHY"
      }
    ]
  },
  {
    "name": "envoy",
    "image": "${envoy_image}",
    "user": "1337",
    "essential": true,
    "cpu": ${envoy_cpu},
    "memoryReservation": ${envoy_memory_rsv},
    "environment": [
      {
        "name": "AWS_REGION",
        "value": "ap-northeast-1"
      },
      {
        "name": "APPMESH_RESOURCE_ARN",
        "value": "${appmesh_resource_arn}"
      },
      {
        "name": "ENVOY_LOG_LEVEL",
        "value": "info"
      },
      {
        "name": "ENABLE_ENVOY_XRAY_TRACING",
        "value": "1"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${envoy_logs_group}",
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "envoy"
      }
    },
    "healthCheck": {
      "command": [
        "CMD-SHELL",
        "curl -s http://localhost:9901/server_info | grep state | grep -q LIVE"
      ],
      "startPeriod": 10,
      "interval": 5,
      "timeout": 2,
      "retries": 3
    }
  },
  {
    "name": "xray-daemon",
    "image": "${xray_image}",
    "user": "1337",
    "essential": true,
    "cpu": ${xray_cpu},
    "memoryReservation": ${xray_memory_rsv},
    "portMappings": [
      {
        "containerPort": 2000,
        "protocol": "udp"
      }
    ],
    "environment": [
      {
        "name": "AWS_REGION",
        "value": "ap-northeast-1"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${xray_logs_group}",
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "xray"
      }
    },
    "entryPoint": [
      "/xray",
      "-t",
      "0.0.0.0:2000",
      "-b",
      "0.0.0.0:2000",
      "-o"
    ]
  }
]