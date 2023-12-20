resource "azurerm_storage_share" "bookstackdb" {
  name                 = "bookstackdb"
  storage_account_name = azurerm_storage_account.main.name
  quota                = 5
}

resource "azurerm_container_app_environment_storage" "bookstackdb" {
  name                         = "bookstackdb"
  container_app_environment_id = azurerm_container_app_environment.main.id
  account_name                 = azurerm_storage_account.main.name
  share_name                   = azurerm_storage_share.bookstackdb.name
  access_key                   = azurerm_storage_account.main.primary_access_key
  access_mode                  = "ReadWrite"
}

locals {
  env_bookstackdb = {
    "PUID"                = "1000"
    "PGID"                = "1000"
    "MYSQL_ROOT_PASSWORD" = "https://bookstack.example.com"
    "TZ"                  = "Australia/Sydney"
    "MYSQL_DATABASE"      = "bookstackapp"
    "MYSQL_USER"          = "bookstack"
    "MYSQL_PASSWORD"      = "bookstack"
  }
}

resource "azurerm_container_app" "bookstackdb" {
  name                         = "bookstackdb"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Multiple"

  ingress {
    target_port      = 6875
    external_enabled = true
    traffic_weight {
      percentage = 100
    }
  }

  template {
    
    volume {
      name = "bookstackdb"
      storage_name = "bookstackdb"
      storage_type = "AzureFile"
    }

    container {
      name   = "bookstackdb"
      image  = "lscr.io/linuxserver/mariadb:latest"
      cpu    = 1
      memory = "2Gi"

      dynamic "env" {
        for_each = local.env_bookstackdb
        content {
          name  = env.key
          value = env.value
        }
      }

      volume_mounts {
        name      = "bookstackdb"
        path      = "/config"
      }

    }
  }
}