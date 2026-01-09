variable "databricks_cli_profile" {
  description = "Databricks CLI profile name to use for authentication"
  type        = string
  default     = "ONEENVAWS"
}

variable "databricks_account_id" {
  description = "Databricks account ID (found in Account Console)"
  type        = string
  sensitive   = true
}

variable "metastore_name" {
  description = "Name of the new Databricks metastore"
  type        = string
  sensitive   = true
}

variable "workspace_name" {
  description = "Name of the new Databricks workspace"
  type        = string
  
  validation {
    condition     = length(var.workspace_name) > 0 && length(var.workspace_name) <= 64
    error_message = "Workspace name must be between 1 and 64 characters."
  }
}

variable "aws_region" {
  description = "AWS region where the Databricks workspace will be deployed"
  type        = string
  default     = "us-east-1"
}
