
variable "name" {
  type = string
}

variable "vpc_id" {
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

variable "domain_name" {
  description = "Domain name for the application SSL certificate"
  type        = string
}