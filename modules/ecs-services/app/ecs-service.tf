resource "aws_ecs_service" "app" {
  name                               = local.name
  desired_count                      = 1
  cluster                            = var.ecs_cluster.id
  task_definition                    = aws_ecs_task_definition.app.arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  force_new_deployment               = true

  network_configuration {
    subnets         = var.private_subnets
    security_groups = concat(var.security_groups, [aws_security_group.app_inbound_sg.id])
  }

  load_balancer {
    container_name   = local.name
    container_port   = local.container_port
    target_group_arn = aws_lb_target_group.app.arn
  }
}
