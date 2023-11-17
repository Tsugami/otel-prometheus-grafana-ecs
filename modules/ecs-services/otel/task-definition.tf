resource "aws_ecs_task_definition" "otel" {
  family                   = "aws-otel-EC2"
  task_role_arn            = var.ecs_task_role.arn
  execution_role_arn       = var.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  
  requires_compatibilities = ["EC2"]
  cpu                      = "1024"
  memory                   = "970"

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
          protocol       = "udp"
        },
        {
          hostPort      = 4317
          containerPort = 4317
          protocol       = "tcp"
        },
        {
          hostPort      = 8125
          containerPort = 8125
          protocol       = "udp"
        }
      ]
      health_check = {
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
    {
      name      = "aws-otel-emitter"
      image     = "public.ecr.aws/aws-otel-test/aws-otel-goxray-sample-app:latest"
      essential = false
      depends_on = [
        {
          container_name = "aws-otel-collector"
          condition      = "START"
        }
      ]
      portMappings = [
        {
          hostPort      = 8000
          containerPort = 8000
          protocol       = "tcp"
        }
      ]
      environment = [
        {
          name  = "AWS_XRAY_DAEMON_ADDRESS"
          value = "aws-otel-collector:2000"
        }
      ]
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
    {
      name      = "nginx"
      image     = "public.ecr.aws/nginx/nginx:latest"
      essential = false
      depends_on = [
        {
          container_name = "aws-otel-collector"
          condition      = "START"
        }
      ]
    },
    {
      name      = "aoc-statsd-emitter"
      image     = "alpine/socat:latest"
      essential = false
      depends_on = [
        {
          container_name = "aws-otel-collector"
          condition      = "START"
        }
      ]
      entry_point = ["/bin/sh", "-c", "while true; do echo 'statsdTestMetric:1|c' | socat -v -t 0 - UDP:127.0.0.1:8125; sleep 1; done"]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/statsd-emitter"
          "awslogs-region"        = "us-west-2"
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "True"
        }
      }
    },
  ])
}
