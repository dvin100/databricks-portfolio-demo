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
  alias   = "account"
  profile = var.databricks_cli_profile
}

resource "databricks_metastore" "this" {
  provider       = databricks.account
  name          = var.metastore_name
  region        = var.aws_region
  force_destroy = true
}

# Create a new Databricks workspace
resource "databricks_mws_workspaces" "this" {
  provider       = databricks.account
  account_id     = var.databricks_account_id
  workspace_name = var.workspace_name
  aws_region     = var.aws_region
  compute_mode   = "SERVERLESS"
  depends_on     = [databricks_metastore.this]
}

resource "databricks_metastore_assignment" "this" {
  provider       = databricks.account
  metastore_id   = databricks_metastore.this.id
  workspace_id   = databricks_mws_workspaces.this.workspace_id
  depends_on     = [databricks_mws_workspaces.this]
}
