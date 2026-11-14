
variable "name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "repository_url" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "container_port" {
  type    = number
  default = 3000
}

variable "database_endpoint" {
  type = string
}

variable "database_name" {
  type = string
}

variable "database_secret_arn" {
  description = "ARN of the database credentials secret in AWS Secrets Manager"
  type        = string
}

variable "database_username"{
    type = string
}
variable "database_password" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "desired_count" {
  type    = number
  default = 1
}