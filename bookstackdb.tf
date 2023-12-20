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
    "TZ"                  = "Australia/Sydney"
    "MYSQL_DATABASE"      = "bookstackdb"
    "MYSQL_USER"          = "bookstack"
  }
}

resource "azurerm_container_app" "bookstackdb" {
  name                         = "bookstackdb"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Multiple"

  secret {
    name  = "mysql-root-password"
    value = random_password.mysql_root_password.result
  }

  secret {
    name  = "mysql-password"
    value = random_password.mysql_password.result
  }

  ingress {
    transport    = "tcp"
    exposed_port = 3306
    target_port  = 3306
    traffic_weight {
      latest_revision = true
      percentage = 100
    }
  }

  template {

    volume {
      name         = "bookstackdb"
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

      env {
        name = "MYSQL_ROOT_PASSWORD"
        secret_name = "mysql-root-password"
      }

      env {
        name = "MYSQL_PASSWORD"
        secret_name = "mysql-password"
      }

      volume_mounts {
        name = "bookstackdb"
        path = "/config"
      }

    }
  }
}