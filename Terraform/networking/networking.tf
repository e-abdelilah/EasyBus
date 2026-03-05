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



resource "azurerm_resource_group" "grp01" {
  name = "group01"

  location = "spaincentral"
}

resource "azurerm_virtual_network" "vnet-100" {
  name                = "vnet-100"
  location            = "spaincentral"
  resource_group_name = azurerm_resource_group.grp01.name
  depends_on          = [azurerm_resource_group.grp01]
  address_space       = ["192.168.0.0/16"]

}

resource "azurerm_subnet" "sub01" {
  name                 = "sub01"
  virtual_network_name = azurerm_virtual_network.vnet-100.name
  resource_group_name  = azurerm_resource_group.grp01.name
  address_prefixes     = ["192.168.1.0/24"]

}


resource "azurerm_subnet" "sub02" {
  name                 = "sub02"
  virtual_network_name = azurerm_virtual_network.vnet-100.name
  resource_group_name  = azurerm_resource_group.grp01.name
  address_prefixes     = ["192.168.2.0/28"]


}

resource "azurerm_public_ip" "public_ipnat-gateway" {


  name                = "public-ip-nat-gateway"
  resource_group_name = azurerm_resource_group.grp01.name
  allocation_method   = "Static"
  location            = "spaincentral"
}


resource "azurerm_public_ip" "public_ip-app-gateway" {


  name                = "public-ip-application-gateway"
  resource_group_name = azurerm_resource_group.grp01.name
  allocation_method   = "Static"
  location            = "spaincentral"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat-gateway" {
  name                = "nat-gateway"
  location            = "spaincentral"
  resource_group_name = azurerm_resource_group.grp01.name
  sku_name            = "Standard"


}


resource "azurerm_nat_gateway_public_ip_association" "nat-gateway-ip" {
  nat_gateway_id       = azurerm_nat_gateway.nat-gateway.id
  public_ip_address_id = azurerm_public_ip.public_ipnat-gateway.id
}

resource "azurerm_subnet_nat_gateway_association" "nat_subnet_assoc" {
  subnet_id      = azurerm_subnet.sub01.id
  nat_gateway_id = azurerm_nat_gateway.nat-gateway.id
}


#resource "azurerm_subnet_nat_gateway_association" "nat_subnet_assoc-2" {
# subnet_id      = azurerm_subnet.sub02.id
#nat_gateway_id = azurerm_nat_gateway.nat-gateway.id
#}










resource "azurerm_network_security_group" "nsg_private_srv" {
  name                = "nsg-private-srv"
  location            = azurerm_resource_group.grp01.location
  resource_group_name = azurerm_resource_group.grp01.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}






resource "azurerm_network_interface" "nic_srv1" {
  name                = "nic-srv1"
  location            = azurerm_resource_group.grp01.location
  resource_group_name = azurerm_resource_group.grp01.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.sub01.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "192.168.1.10" #  SRV1
  }

}



resource "azurerm_network_interface" "nic_srv2" {
  name                = "nic-srv2"
  location            = azurerm_resource_group.grp01.location
  resource_group_name = azurerm_resource_group.grp01.name

  ip_configuration {
    name                          = "ipconfig2"
    subnet_id                     = azurerm_subnet.sub01.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "192.168.1.20" #  SRV2
  }

}

resource "azurerm_network_interface_security_group_association" "nic1-nsg" {
  network_interface_id      = azurerm_network_interface.nic_srv1.id
  network_security_group_id = azurerm_network_security_group.nsg_private_srv.id
}

resource "azurerm_network_interface_security_group_association" "nic2-nsg" {
  network_interface_id      = azurerm_network_interface.nic_srv2.id
  network_security_group_id = azurerm_network_security_group.nsg_private_srv.id
}