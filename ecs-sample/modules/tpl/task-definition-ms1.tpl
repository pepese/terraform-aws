[
  {
    "name": "httpd-container",
    "image": "httpd:latest",
    "essential": true,
    "memory": ${memory},
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": ${containerPort}
      }
    ]
  }
]