variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub deployment branch"
  type        = string
  default     = "main"
}

variable "ecr_repository_arn" {
  description = "ARN of the application ECR repository"
  type        = string
}

variable "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  type        = string
}

variable "ecs_service_arn" {
  description = "ARN of the ECS service"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ECS task role ARN"
  type        = string
}