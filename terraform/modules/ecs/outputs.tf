
output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "service_name" {
  value = aws_ecs_service.app.name
}

output "execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.app.arn
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.app.name
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.app.id
}