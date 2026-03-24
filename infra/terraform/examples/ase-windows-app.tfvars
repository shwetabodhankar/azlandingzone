# =============================================================================
# ASE v3 — Windows Code-Based Web App
#
# Deploys an App Service Environment v3 with a Windows App Service Plan
# running a .NET code-based application (no containers).
#
# Usage: cp examples/ase-windows-app.tfvars terraform.tfvars
# =============================================================================

# --- Required ---
location            = "uksouth"
resource_group_name = "rg-contoso-ase-win-prod"

# --- App Service Plan ---
app_service_plan_os_type  = "Windows"
app_service_plan_sku_name = "I1v2"

# --- Web Apps ---
web_apps = {
  contoso-ase-win-app = {
    site_config = {
      always_on = true
      application_stack = {
        dotnet = {
          dotnet_version = "v8.0"
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
              dotnet_version = "v8.0"
              current_stack  = "dotnet"
            }
          }
        }
      }
    }
  }
}

# --- Networking ---
virtual_network_address_space                 = ["10.2.0.0/16"]
app_service_subnet_address_prefix             = "10.2.0.0/24"
private_endpoint_subnet_address_prefix        = "10.2.1.0/24"
app_service_environment_subnet_address_prefix = "10.2.2.0/24"

# --- Feature Toggles ---
front_door_enabled           = true
key_vault_enabled            = true
application_insights_enabled = true
private_dns_zones_enabled    = true

# --- ASE v3 ---
app_service_environment_enabled = true

# --- Container (not used) ---
container_registry_enabled = false

# --- ALZ Hub Integration ---
hub_virtual_network_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-connectivity/providers/Microsoft.Network/virtualNetworks/vnet-hub-uksouth"
hub_firewall_private_ip        = "10.0.0.4"
hub_route_table_address_spaces = ["10.0.0.0/16"]

# --- Metadata ---
environment = "prod"
tags = {
  workload    = "contoso-ase-windows-app"
  environment = "prod"
  deployed_by = "terraform"
  owner       = "platform-team"
}
