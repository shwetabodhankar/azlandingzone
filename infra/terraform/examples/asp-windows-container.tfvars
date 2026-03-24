# =============================================================================
# App Service Plan — Windows Container Web App (no ASE)
#
# Deploys a Premium v3 WindowsContainer App Service Plan running a Docker
# container from Azure Container Registry. No ASE required.
#
# Usage: cp examples/asp-windows-container.tfvars terraform.tfvars
# =============================================================================

# --- Required ---
location            = "uksouth"
resource_group_name = "rg-contoso-asp-winc-prod"

# --- App Service Plan ---
app_service_plan_os_type  = "WindowsContainer"
app_service_plan_sku_name = "P1v3"

# --- Web Apps ---
web_apps = {
  contoso-asp-winc-app = {
    site_config = {
      always_on = true
      application_stack = {
        docker = {
          docker_image_name   = "contoso/webapp:latest"
          docker_registry_url = "https://contosoaspwincacr.azurecr.io"
        }
      }
    }
    deployment_slots = {
      staging = {
        name = "staging"
        site_config = {
          application_stack = {
            docker = {
              docker_image_name   = "contoso/webapp:staging"
              docker_registry_url = "https://contosoaspwincacr.azurecr.io"
            }
          }
        }
      }
    }
  }
}

# --- Networking ---
virtual_network_address_space          = ["10.7.0.0/16"]
app_service_subnet_address_prefix      = "10.7.0.0/24"
private_endpoint_subnet_address_prefix = "10.7.1.0/24"

# --- Feature Toggles ---
front_door_enabled           = true
key_vault_enabled            = true
application_insights_enabled = true
private_dns_zones_enabled    = true

# --- ASE (not used) ---
app_service_environment_enabled = false

# --- Container Registry ---
container_registry_enabled = true

# --- ALZ Hub Integration ---
hub_virtual_network_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-connectivity/providers/Microsoft.Network/virtualNetworks/vnet-hub-uksouth"
hub_firewall_private_ip        = "10.0.0.4"
hub_route_table_address_spaces = ["10.0.0.0/16"]

# --- Metadata ---
environment = "prod"
tags = {
  workload    = "contoso-asp-windows-container"
  environment = "prod"
  deployed_by = "terraform"
  owner       = "platform-team"
}
