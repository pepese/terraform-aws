[
  {
    "command": [],
    "cpu": ${app_cpu},
    "dockerLabels": {
    },
    "entrypoint": [],
    "environment": [
      {
        "name": "APPMESH_RESOURCE_ARN",
        "value": "${appmesh_resource_arn}"
      }
    ],
    "essential": true,
    "healthCheck": {
      "COMMENT": "https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_HealthCheck.html",
      "command": ["CMD-SHELL", "curl -f http://localhost:9901/ready || exit 1"],
      "interval": 30,
      "retries": 3,
      "timeout": 5
    },
    "image": "${app_image}",
    "securityContext": {
        "runAsUser": 1337
    },
    "memory": 64,
    "mountPoints": [],
    "name": "envoy",
    "portMappings": [
      {
        "containerPort": ${port},
        "hostPort": ${port},
        "protocol": "tcp"
      },
      {
        "containerPort": 9901,
        "hostPort": 9901,
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${envoy_logs_group}",
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "vgw"
      }
    },
    "volumesFrom": []
  }
]