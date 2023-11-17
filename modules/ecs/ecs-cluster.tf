resource "aws_ecs_cluster" "main" {
  name = format("%s-ecs-cluster", var.project_name)
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = [aws_ecs_capacity_provider.main.name]
}
