---
title: "Terraform"
weight: 20
geekdocCollapseSection: true
---

# Terraform Deployment

The Terraform implementation uses the [AVM Pattern Module for App Service Landing Zone](https://registry.terraform.io/modules/Azure/avm-ptn-app-service-landing-zone/azure/latest) to deploy the entire spoke infrastructure in a single module call.

## How it works

The AVM pattern module deploys:

| Component | Description |
|-----------|-------------|
| **VNet + Subnets** | Spoke virtual network with App Service, private endpoint, and DevOps subnets |
| **App Service** | Multi-tenant App Service Plan or ASE v3 with VNet integration |
| **Front Door** | Azure Front Door Premium with WAF and private link to App Service |
| **Key Vault** | Azure Key Vault with private endpoint |
| **Storage** | Azure Storage Account with private endpoint |
| **ACR** | Azure Container Registry with private endpoint |
| **Monitoring** | Log Analytics workspace + Application Insights |
| **DNS** | Private DNS Zones for all private endpoints |
| **RBAC** | Managed identities with least-privilege role assignments |

Supplemental resources not covered by the pattern module (SQL Database, Redis Cache, OpenAI, App Configuration, jump host VM) are deployed using individual AVM resource modules.

## Quick start

```bash
cd infra/terraform
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

## Variable reference

Configuration is done through Terraform variables. Key variables include:

| Variable | Description | Default |
|----------|-------------|---------|
| `location` | Azure region for deployment | — |
| `workload_name` | Name prefix for resources | — |
| `environment` | Environment name (dev/test/prod) | `"dev"` |
| `deploy_asev3` | Deploy ASE v3 instead of multi-tenant | `false` |
| `hub_virtual_network_id` | Resource ID of existing hub VNet for peering | `""` |
| `route_table_id` | Route table ID for forced tunneling through hub firewall | `""` |
| `deploy_redis` | Feature flag: deploy Redis Cache | `false` |
| `deploy_sql` | Feature flag: deploy Azure SQL | `false` |
| `deploy_app_config` | Feature flag: deploy App Configuration | `false` |
| `deploy_jump_host` | Feature flag: deploy jump host VM | `false` |

See `infra/terraform/variables.tf` for the complete variable reference.

## State management

Configure the Terraform backend to use Azure Storage:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "<state-rg>"
    storage_account_name = "<state-sa>"
    container_name       = "dev"
    key                  = "appservice-lza.tfstate"
    use_oidc             = true
  }
}
```

If you used the [CI/CD Bootstrap]({{< relref "bootstrap" >}}), the state storage is already created for you.

## Examples

The `infra/terraform/` directory includes example `.tfvars` files for different scenarios. See the [Examples]({{< relref "examples" >}}) section for the full list.

## Resources

- [AVM Pattern Module — App Service Landing Zone](https://registry.terraform.io/modules/Azure/avm-ptn-app-service-landing-zone/azure/latest)
- [Azure Verified Modules](https://aka.ms/avm)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
