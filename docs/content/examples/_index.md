---
title: "Examples"
weight: 50
geekdocCollapseSection: true
---

All scenarios use the same codebase — toggle feature flags in your variable/parameter file. No code changes needed.

## Scenarios

| # | Scenario | Description |
|---|----------|-------------|
| 1 | **Multi-tenant baseline** | App Service Plan + Front Door + Key Vault + private networking |
| 2 | **ASE v3 baseline** | App Service Environment v3 (isolated, single-tenant) with secure baseline |
| 3 | **With Azure SQL** | Baseline + SQL Database with private endpoint and Entra ID auth |
| 4 | **With Redis Cache** | Baseline + Azure Cache for Redis with private endpoint |
| 5 | **With App Configuration** | Baseline + App Configuration with private endpoint |
| 6 | **With jump host** | Baseline + Windows VM in DevOps subnet for private access |
| 7 | **Full stack** | All features: SQL, Redis, App Config, jump host |
| 8 | **Hub-connected** | Baseline + peering to hub VNet with forced tunneling through Firewall |
| 9 | **Zone-redundant** | Baseline with zone-redundant App Service Plan |

## Feature flags

**Terraform** (`terraform.tfvars`):

```hcl
deploy_asev3      = false
deploy_sql        = true
deploy_redis      = true
deploy_app_config = true
deploy_jump_host  = true
```

**Bicep** (`main.parameters.jsonc`):

```json
{
  "deployAseV3":     { "value": false },
  "deployAzureSql":  { "value": true },
  "deployRedis":     { "value": true },
  "deployAppConfig": { "value": true },
  "deployJumpHost":  { "value": true }
}
```

## Sample application

A sample ASP.NET Core app is in [`sampleapp/`](https://github.com/Azure/appservice-landing-zone-accelerator/tree/main/sampleapp) for testing.
