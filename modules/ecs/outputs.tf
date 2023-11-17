
output "ecs_task_role" {
  value = aws_iam_role.ECSTaskRole
}

output "ecs_task_execution_role" {
  value = aws_iam_role.TaskExecutionRole
}

output "ecs_cluster" {
  value = aws_ecs_cluster.main
}

output "security_group" {
  value = aws_security_group.autoescaling_sg
}