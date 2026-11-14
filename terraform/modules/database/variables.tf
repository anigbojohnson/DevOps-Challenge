
variable "name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "database_name" {
  type = string
}

variable "database_password" {
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
