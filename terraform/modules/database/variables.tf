
variable "name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "database_name" {
  type = string
}

variable "database_username" {
  type      = string
  sensitive = true

}


variable "security_group_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}
