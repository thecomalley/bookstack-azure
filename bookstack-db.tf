resource "azurerm_mysql_flexible_server" "main" {
  name                   = "bookstack-mysql${random_integer.storage_account.result}"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  administrator_login    = "bookstack"
  administrator_password = random_password.mysql_password.result
  sku_name               = "B_Standard_B1s"
}

resource "azurerm_mysql_flexible_database" "bookstackdb" {
  name                = "bookstackdb"
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "main" {
  name                = "allow-access-to-azure-services"
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.main.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}