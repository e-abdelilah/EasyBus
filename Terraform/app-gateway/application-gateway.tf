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

data "azurerm_web_application_firewall_policy" "waf" {
  name = "wafpolicy-app-gateway"
  resource_group_name = "group01"

}


data "azurerm_public_ip" "public_ip-app-gateway" {
  name                = "public-ip-application-gateway"
  resource_group_name = "group01"
}


data "azurerm_resource_group" "grp01" {
  name = "group01"
}

data "azurerm_subnet" "sub02" {
  name = "sub02"
  virtual_network_name = "vnet-100"
  resource_group_name = "group01"
}


resource "azurerm_application_gateway" "app_gateway" {
  name                = "app-gateway-01"
  resource_group_name = data.azurerm_resource_group.grp01.name
  location            = "spaincentral"
  firewall_policy_id = data.azurerm_web_application_firewall_policy.waf.id

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
    
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = data.azurerm_subnet.sub02.id
  }

  frontend_port {
    name = "frontend-port-80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = data.azurerm_public_ip.public_ip-app-gateway.id
  }

  backend_address_pool {
    name         = "backend-pool"
    ip_addresses = ["192.168.1.10", "192.168.1.20"]
  }



  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "frontend-port-80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule-1"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
    priority                   = 100
  }

}