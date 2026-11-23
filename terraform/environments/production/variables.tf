
variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "af-south-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "todo-app"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "database_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "tododb"
}

variable "database_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "todoadmin"
  sensitive   = true
}


variable "container_port" {
  description = "Node.js application port"
  type        = number
  default     = 3000
}

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

variable "github_owner_id" {
  description = "GitHub account owner ID"
  type        = string
}

variable "github_repository_id" {
  description = "GitHub repository ID"
  type        = string
}

variable "domain_name" {
  description = "Domain name of the website"
  type        = string
}

variable "alarm_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
}
