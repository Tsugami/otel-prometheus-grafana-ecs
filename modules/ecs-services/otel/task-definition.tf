resource "aws_ecs_task_definition" "otel" {
  family                   = "aws-otel-EC2"
  # task_role_arn            = var.ecs_task_role.arn
  # execution_role_arn       = var.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 512
  memory                   = 512

  container_definitions = jsonencode([
    {
      name      = "aws-otel-collector"
      image     = "amazon/aws-otel-collector"
      essential = true
      command   = ["--config=/etc/ecs/ecs-default-config.yaml"]
      portMappings = [
        {
          hostPort      = 2000
          containerPort = 2000
          protocol      = "udp"
        },
        {
          hostPort      = 4317
          containerPort = 4317
          protocol      = "tcp"
        },
        {
          hostPort      = 8125
          containerPort = 8125
          protocol      = "udp"
        }
      ]
      healthCheck = {
        command      = ["/healthcheck"]
        interval     = 5
        timeout      = 6
        retries      = 5
        start_period = 1
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/aws-otel-EC2"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "True"
        }
      }
    },
  ])
}
