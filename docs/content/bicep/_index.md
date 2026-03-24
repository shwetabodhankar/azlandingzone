---
title: "Bicep"
weight: 30
geekdocCollapseSection: true
---

# Bicep Deployment

The Bicep implementation uses [Azure Verified Modules (AVM)](https://aka.ms/avm) to deploy the App Service Landing Zone spoke infrastructure. The AVM Bicep pattern module (`br/public:avm/ptn/app-service-lza/hosting-environment`) provides the core deployment, with supplemental AVM resource modules for additional services.

## How it works

The AVM pattern module deploys:

| Component | Description |
|-----------|-------------|
| **VNet + Subnets** | Spoke virtual network with App Service, private endpoint, and DevOps subnets |
| **App Service** | Multi-tenant App Service Plan or ASE v3 with VNet integration |
| **Front Door / App Gateway** | Azure Front Door or Application Gateway with WAF |
| **Key Vault** | Azure Key Vault with private endpoint |
| **Storage** | Azure Storage Account with private endpoint |
| **ACR** | Azure Container Registry with private endpoint |
| **Monitoring** | Log Analytics workspace + Application Insights |
| **DNS** | Private DNS Zones for all private endpoints |
| **RBAC** | Managed identities with least-privilege role assignments |

Supplemental resources not covered by the pattern module (SQL Database, Redis Cache, OpenAI, App Configuration, jump host VM) are deployed using individual AVM resource modules.

## Quick start

```bash
cd infra/bicep

az deployment sub create \
  --location <region> \
  --template-file main.bicep \
  --parameters main.parameters.jsonc
```

## Parameter reference

Configuration is done through Bicep parameter files. Key parameters include:

| Parameter | Description | Example |
|-----------|-------------|---------|
| `workloadName` | Name prefix for resources (up to 10 chars) | `app-svc-01` |
| `location` | Azure region for deployment | `northeurope` |
| `environment` | Environment name (dev/test/prod) | `dev` |
| `deployAseV3` | Deploy ASE v3 instead of multi-tenant | `false` |
| `vnetHubResourceId` | Resource ID of existing hub VNet for peering | — |
| `firewallInternalIp` | Internal IP of Azure Firewall for UDR | — |
| `deployRedis` | Feature flag: deploy Redis Cache | `false` |
| `deployAzureSql` | Feature flag: deploy Azure SQL | `false` |
| `deployAppConfig` | Feature flag: deploy App Configuration | `false` |
| `deployJumpHost` | Feature flag: deploy jump host VM | `false` |

See `infra/bicep/main.parameters.jsonc` for the complete parameter reference.

## Deployment Stacks

Bicep deployments use [Azure Deployment Stacks](https://learn.microsoft.com/azure/azure-resource-manager/bicep/deployment-stacks) at subscription level for lifecycle management, drift detection, and deny assignments.

## Examples

The `infra/bicep/` directory includes example parameter files for different scenarios. See the [Examples]({{< relref "examples" >}}) section for the full list.

## Resources

- [AVM Pattern Module — App Service LZA (Bicep)](https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/app-service-lza/hosting-environment)
- [Azure Verified Modules](https://aka.ms/avm)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
