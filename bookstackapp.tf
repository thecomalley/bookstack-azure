resource "azurerm_storage_share" "bookstackapp" {
  name                 = "bookstackapp"
  storage_account_name = azurerm_storage_account.main.name
  quota                = 5
}

resource "azurerm_container_app_environment_storage" "bookstackapp" {
  name                         = "bookstackapp"
  container_app_environment_id = azurerm_container_app_environment.main.id
  account_name                 = azurerm_storage_account.main.name
  share_name                   = azurerm_storage_share.bookstackapp.name
  access_key                   = azurerm_storage_account.main.primary_access_key
  access_mode                  = "ReadWrite"
}

locals {
  env_bookstackapp = {
    "PUID"        = "1000"
    "PGID"        = "1000"
    "APP_URL"     = "https://bookstack.example.com"
    "DB_HOST"     = "bookstackdb"
    "DB_PORT"     = "3306"
    "DB_DATABASE" = "bookstack"
    "DB_USER"     = "bookstack"
    "DB_PASS"     = "password"
  }
}

resource "azurerm_container_app" "bookstackapp" {
  name                         = "bookstackapp"
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
      name = "bookstackapp"
      storage_name = "bookstackapp"
      storage_type = "AzureFile"
    }

    container {
      name   = "bookstackapp"
      image  = "lscr.io/linuxserver/bookstack:latest"
      cpu    = 1
      memory = "2Gi"

      dynamic "env" {
        for_each = local.env_bookstackapp
        content {
          name  = env.key
          value = env.value
        }
      }

      volume_mounts {
        name      = "bookstackapp"
        path      = "/config"
      }

    }
  }
}