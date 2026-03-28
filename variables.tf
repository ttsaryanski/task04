variable "resource_group_name" {
  type        = string
  description = "Resource group name for Azure"
}

variable "resource_group_location" {
  type        = string
  description = "Name of the Azure region where the resource group will be created"
}

variable "app_service_plan_name" {
  type        = string
  description = "Name of the App Service Plan"
}

variable "app_service_name" {
  type        = string
  description = "Name of the App Service"
}

variable "sql_server_name" {
  type        = string
  description = "Name of the SQL Server"
}

variable "sql_database_name" {
  type        = string
  description = "Name of the SQL Database"
}

variable "firewall_rule_name" {
  type        = string
  description = "Firewall rule name"
}

variable "github_repo_url" {
  type        = string
  description = "URL of the GitHub repository to link with App Service"
}

variable "sql_admin_username" {
  type = string
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
}
