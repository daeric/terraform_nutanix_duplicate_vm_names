variable "pc_endpoint" {}
variable "pc_username" {}
variable "pc_password" { sensitive = true }
variable "foundation_endpoint" {}
variable "foundation_port" {}
variable "ndb_endpoint" {}
variable "ndb_username" {}
variable "ndb_password" {}

variable "vm_name" {
  description = "The name of the VM"
  type        = string

}