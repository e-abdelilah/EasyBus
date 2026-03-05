
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "  "
}

data "azurerm_resource_group" "grp01" {
  name = "group01"

}


data "azurerm_network_interface" "nic_srv1" {
  name = "nic-srv1"

  resource_group_name = "group01"


}

data "azurerm_network_interface" "nic_srv2" {
  name = "nic-srv2"

  resource_group_name = "group01"


}



resource "azurerm_linux_virtual_machine" "srv1" {
  name                = "SRV1"
  computer_name       = "SRV1"
  location            = "spaincentral"
  resource_group_name = data.azurerm_resource_group.grp01.name
  size                = "Standard_B2ms"

  admin_username                  = "serverK8s"
  admin_password                  = "test@@test00testA"
  disable_password_authentication = false

  network_interface_ids = [
    data.azurerm_network_interface.nic_srv1.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "srv2" {
  name                = "SRV2"
  computer_name       = "SRV2"
  location            = "spaincentral"
  resource_group_name = data.azurerm_resource_group.grp01.name
  size                = "Standard_B2ms"

  admin_username                  = "azureuser"
  admin_password                  = "MotDePasseTresSecurise123!"
  disable_password_authentication = false

  network_interface_ids = [
    data.azurerm_network_interface.nic_srv2.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}









