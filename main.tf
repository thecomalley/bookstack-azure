resource "azurerm_resource_group" "main" {
  name     = "bookstack-rg"
  location = "Australia East"
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "bookstack-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "main" {
  name                       = "bookstack-aca-env"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
}

resource "random_integer" "storage_account" {
  min = 1
  max = 999
}

resource "azurerm_storage_account" "main" {
  name                     = "bookstackst${random_integer.storage_account.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "random_password" "mysql_root_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "mysql_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}