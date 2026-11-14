
variable "name" {
  description = "Infrastructure name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR range"
  type        = string
}

variable "subnet_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}


variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "production"], var.environment)
    error_message = "Environment must be dev or production."
  }
}