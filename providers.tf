terraform {
  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = "= 2.2.3"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "nutanix" {
  username            = var.pc_username
  password            = var.pc_password
  endpoint            = var.pc_endpoint
  insecure            = true
  foundation_endpoint = var.foundation_endpoint
  foundation_port     = var.foundation_port
  ndb_endpoint        = var.ndb_endpoint
  ndb_username        = var.ndb_username
  ndb_password        = var.ndb_password
}
