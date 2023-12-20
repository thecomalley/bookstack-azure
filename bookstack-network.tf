locals {
  subnets = {
    ingress = "10.4.20.0/26"
    snet2 = "10.4.20.64/26"
    snet3 = "10.4.20.128/26"
    snet4 = "10.4.20.192/26"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "bookstack-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.4.20.0/24"]
}

resource "azurerm_subnet" "main" {
  for_each = local.subnets

  name                 = each.key
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value]
}