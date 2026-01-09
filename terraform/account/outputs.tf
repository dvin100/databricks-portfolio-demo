output "workspace_id" {
  description = "Databricks workspace ID"
  value       = databricks_mws_workspaces.this.workspace_id
}

output "workspace_name" {
  description = "Databricks workspace name"
  value       = databricks_mws_workspaces.this.workspace_name
}

output "workspace_url" {
  description = "URL to access the Databricks workspace"
  value       = databricks_mws_workspaces.this.workspace_url
}

output "workspace_status" {
  description = "Current status of the workspace"
  value       = databricks_mws_workspaces.this.workspace_status
}

output "deployment_name" {
  description = "Deployment name for the workspace"
  value       = databricks_mws_workspaces.this.deployment_name
}

output "aws_region" {
  description = "AWS region where the workspace is deployed"
  value       = databricks_mws_workspaces.this.aws_region
}

output "login_new_workspace" {
  description = "Execute this command for the next step"
  value       = "databricks auth login --host ${databricks_mws_workspaces.this.workspace_url} --profile DEMO"
}

output "set_env_variable_config_profile" {
  description = "Execute this command for the next step"
  value       = "export DATABRICKS_CONFIG_PROFILE='DEMO'"
}

output "set_env_variable_host" {
  description = "Execute this command for the next step"
  value       = "export DATABRICKS_HOST='${databricks_mws_workspaces.this.workspace_url}'"
}