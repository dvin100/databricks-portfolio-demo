variable "databricks_cli_profile" {
  description = "Databricks CLI profile name to use for authentication"
  type        = string
  default     = "DEMO"
}

variable "group_name" {
  description = "Service principal group"
  type        = string
  default     = "admins"
}

variable "sp_name" {
  description = "Service principal name"
  type        = string
  sensitive   = true
  default     = "demo_sp"
}