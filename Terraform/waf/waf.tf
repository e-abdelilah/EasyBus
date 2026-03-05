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
  subscription_id = "   "
}

# Resource Group
data "azurerm_resource_group" "grp01" {
  name = "group01"
}


# WAF Policy
resource "azurerm_web_application_firewall_policy" "appgw-waf-policy" {
  name                = "wafpolicy-app-gateway"
  resource_group_name = data.azurerm_resource_group.grp01.name
  location            = "spaincentral"

  # Policy Settings
  policy_settings {
    file_upload_limit_in_mb                   = 100
    max_request_body_size_in_kb               = 128
    mode                                      = "Prevention"
    request_body_check                        = true
    enabled                                   = true
    request_body_inspect_limit_in_kb          = 128
    request_body_enforcement                  = true
    file_upload_enforcement                   = true
    js_challenge_cookie_expiration_in_minutes = 30
  }

  # Managed Rules
  managed_rules {
    # Microsoft Default Rule Set
    managed_rule_set {
      type    = "Microsoft_DefaultRuleSet"
      version = "2.1"
    }



  }
}