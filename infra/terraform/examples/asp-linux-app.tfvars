# =============================================================================
# App Service Plan — Linux Code-Based Web App (no ASE)
#
# Deploys a Premium v3 Linux App Service Plan with a .NET code-based
# application. No App Service Environment — cost-effective for workloads
# that don't require network isolation.
#
# Usage: cp examples/asp-linux-app.tfvars terraform.tfvars
# =============================================================================

# --- Required ---
location            = "uksouth"
resource_group_name = "rg-contoso-asp-linux-prod"

# --- App Service Plan ---
app_service_plan_os_type  = "Linux"
app_service_plan_sku_name = "P1v3"

# --- Web Apps ---
web_apps = {
  contoso-asp-linux-app = {
    site_config = {
      always_on = true
      application_stack = {
        dotnet = {
          dotnet_version = "8.0"
          current_stack  = "dotnet"
        }
      }
    }
    app_settings = {
      SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
    }
    deployment_slots = {
      staging = {
        name = "staging"
        site_config = {
          application_stack = {
            dotnet = {
              dotnet_version = "8.0"
              current_stack  = "dotnet"
            }
          }
        }
      }
    }
  }
}

# --- Networking ---
virtual_network_address_space          = ["10.8.0.0/16"]
app_service_subnet_address_prefix      = "10.8.0.0/24"
private_endpoint_subnet_address_prefix = "10.8.1.0/24"

# --- Feature Toggles ---
front_door_enabled           = true
key_vault_enabled            = true
application_insights_enabled = true
private_dns_zones_enabled    = true

# --- ASE / Container (not used) ---
app_service_environment_enabled = false
container_registry_enabled      = false

# --- ALZ Hub Integration ---
hub_virtual_network_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-connectivity/providers/Microsoft.Network/virtualNetworks/vnet-hub-uksouth"
hub_firewall_private_ip        = "10.0.0.4"
hub_route_table_address_spaces = ["10.0.0.0/16"]

# --- Metadata ---
environment = "prod"
tags = {
  workload    = "contoso-asp-linux-app"
  environment = "prod"
  deployed_by = "terraform"
  owner       = "platform-team"
}
