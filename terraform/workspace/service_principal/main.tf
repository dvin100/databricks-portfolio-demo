terraform {
  required_version = ">= 1.0"
  
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.30"
    }
  }
}

# Databricks provider configuration for account-level resources
# Authentication via Databricks CLI profile
provider "databricks" {
  alias   = "workspace"
  profile = var.databricks_cli_profile
}

data "databricks_group" "admins" {
  display_name = var.group_name
}

resource "databricks_service_principal" "sp" {
  display_name = var.sp_name 
}

resource "databricks_group_member" "i-am-admin" {
  group_id     = data.databricks_group.admins.id
  member_id    = databricks_service_principal.sp.id
}

resource "databricks_catalog" "demo" {
  name    = "demo"
  comment = "this catalog is managed by terraform"
}