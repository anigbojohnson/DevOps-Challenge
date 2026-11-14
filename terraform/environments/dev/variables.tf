
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

variable "database_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
}

variable "container_port" {
  description = "Node.js application port"
  type        = number
  default     = 3000
}
