locals {
  name           = "sample-app"
  image          = "ghcr.io/tsugami/otel-prometheus-grafana-ecs:master"
  port           = 80
  container_port = 3000
}


resource "aws_ecs_task_definition" "app" {
  family                   = local.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 512
  memory                   = 512

  container_definitions = jsonencode([
    {
      name      = local.name
      image     = local.image
      essential = true
      portMappings = [
        {
          hostPort      = local.container_port
          containerPort = local.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${local.name}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "True"
        }
      }
    },
  ])
}
