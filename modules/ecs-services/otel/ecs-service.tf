resource "aws_ecs_service" "otel" {
  name            = "otel"
  desired_count   = 1
  cluster         = var.ecs_cluster.id
  task_definition = aws_ecs_task_definition.otel.arn
  
  network_configuration {
    subnets         = var.private_subnets
    security_groups = var.security_groups
  }
}
