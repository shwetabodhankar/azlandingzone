---
title: "Examples"
weight: 60
geekdocCollapseSection: true
---

# Examples

The App Service Landing Zone Accelerator supports multiple deployment scenarios via feature flags in the configuration. Below are the available scenarios.

## Deployment scenarios

| # | Scenario | Description | Terraform | Bicep |
|---|----------|-------------|-----------|-------|
| 1 | **Multi-tenant baseline** | Standard App Service Plan with Front Door, Key Vault, and private networking | ✅ | ✅ |
| 2 | **ASE v3 baseline** | App Service Environment v3 (isolated, single-tenant) with the same secure baseline | ✅ | ✅ |
| 3 | **With Azure SQL** | Baseline + Azure SQL Database with private endpoint and Entra ID auth | ✅ | ✅ |
| 4 | **With Redis Cache** | Baseline + Azure Cache for Redis with private endpoint | ✅ | ✅ |
| 5 | **With App Configuration** | Baseline + Azure App Configuration with private endpoint | ✅ | ✅ |
| 6 | **With jump host** | Baseline + Windows VM as jump host in the DevOps subnet for private access | ✅ | ✅ |
| 7 | **Full stack** | All features enabled: SQL, Redis, App Config, jump host | ✅ | ✅ |
| 8 | **Hub-connected** | Baseline with peering to existing hub VNet and forced tunneling through Azure Firewall | ✅ | ✅ |
| 9 | **Zone-redundant** | Baseline with zone-redundant App Service Plan and zone-aware configuration | ✅ | ✅ |

## How to use

Each scenario is configured by setting feature flags in your variable/parameter file:

### Terraform

```hcl
# Example: Full stack (scenario 7)
deploy_asev3      = false
deploy_sql        = true
deploy_redis      = true
deploy_app_config = true
deploy_jump_host  = true
```

### Bicep

```json
// Example: Full stack (scenario 7)
{
  "deployAseV3":     { "value": false },
  "deployAzureSql":  { "value": true },
  "deployRedis":     { "value": true },
  "deployAppConfig": { "value": true },
  "deployJumpHost":  { "value": true }
}
```

## Sample application

A sample ASP.NET Core application is provided in the [`sampleapp/`](https://github.com/Azure/appservice-landing-zone-accelerator/tree/main/sampleapp) directory for testing and validation.

## Related patterns

Looking for developer-focused reference implementations? Check out:

- [Reliable web app pattern for .NET](https://github.com/Azure/reliable-web-app-pattern-dotnet)
