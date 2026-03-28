terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.66.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "5e30cc49-5685-41ff-a372-127e3ef1c10f"
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "arg" {
  name     = "${var.resource_group_name}-${random_integer.ri.result}"
  location = var.resource_group_location
}

resource "azurerm_service_plan" "asp" {
  name                = "${var.app_service_plan_name}-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_resource_group.arg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "alwa" {
  name                = "${var.app_service_name}-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_resource_group.arg.location
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.amssqls.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.amssqldb.name};User ID=${azurerm_mssql_server.amssqls.administrator_login};Password=${azurerm_mssql_server.amssqls.administrator_login_password};Trusted_Connection=False;MultipleActiveResultSets=True;"
  }
}

resource "azurerm_mssql_server" "amssqls" {
  name                         = "${var.sql_server_name}-${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.arg.name
  location                     = azurerm_resource_group.arg.location
  version                      = "12.0"
  administrator_login          = TF_VAR_sql_admin_username
  administrator_login_password = TF_VAR_sql_admin_password
}

resource "azurerm_mssql_database" "amssqldb" {
  name                 = "${var.sql_database_name}-${random_integer.ri.result}"
  server_id            = azurerm_mssql_server.amssqls.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  license_type         = "LicenseIncluded"
  sku_name             = "S0"
  zone_redundant       = false
  storage_account_type = "Local"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true #false
  }
}

resource "azurerm_mssql_firewall_rule" "amssqlsfr" {
  name             = "${var.firewall_rule_name}-${random_integer.ri.result}"
  server_id        = azurerm_mssql_server.amssqls.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_app_service_source_control" "aassc" {
  app_id                 = azurerm_linux_web_app.alwa.id
  repo_url               = var.github_repo_url
  branch                 = "main"
  use_manual_integration = true
}
