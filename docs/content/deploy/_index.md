---
title: "Deploy"
weight: 30
geekdocCollapseSection: true
---

## Interactive deployment

The repo includes a PowerShell helper that guides you through configuration and deployment:

```powershell
./deploy.ps1
```

It prompts for your Azure region, IaC tool, scenario, and hub connectivity — then runs the deployment.

## Manual deployment

### Terraform

```bash
cd infra/terraform
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

**Key variables** (full reference in `infra/terraform/variables.tf`):

| Variable | Description | Default |
|----------|-------------|---------|
| `location` | Azure region | — |
| `workload_name` | Name prefix for resources | — |
| `environment` | `dev`, `test`, or `prod` | `"dev"` |
| `deploy_asev3` | Use ASE v3 instead of multi-tenant | `false` |
| `deploy_sql` | Deploy Azure SQL | `false` |
| `deploy_redis` | Deploy Redis Cache | `false` |
| `deploy_app_config` | Deploy App Configuration | `false` |
| `deploy_jump_host` | Deploy jump host VM | `false` |
| `hub_virtual_network_id` | Hub VNet resource ID for peering | `""` |
| `route_table_id` | Route table for forced tunneling | `""` |

**State backend** — use Azure Storage:

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

If you used the [CI/CD Bootstrap]({{< relref "bootstrap" >}}), state storage is already provisioned.

### Bicep

```bash
cd infra/bicep
az deployment sub create \
  --location <region> \
  --template-file main.bicep \
  --parameters main.parameters.jsonc
```

**Key parameters** (full reference in `infra/bicep/main.parameters.jsonc`):

| Parameter | Description | Default |
|-----------|-------------|---------|
| `location` | Azure region | — |
| `workloadName` | Name prefix (up to 10 chars) | — |
| `environment` | `dev`, `test`, or `prod` | `"dev"` |
| `deployAseV3` | Use ASE v3 instead of multi-tenant | `false` |
| `deployAzureSql` | Deploy Azure SQL | `false` |
| `deployRedis` | Deploy Redis Cache | `false` |
| `deployAppConfig` | Deploy App Configuration | `false` |
| `deployJumpHost` | Deploy jump host VM | `false` |
| `vnetHubResourceId` | Hub VNet resource ID for peering | — |
| `firewallInternalIp` | Firewall IP for UDR | — |

Bicep uses [Deployment Stacks](https://learn.microsoft.com/azure/azure-resource-manager/bicep/deployment-stacks) at subscription level for lifecycle management and drift detection.

## Via CI/CD pipeline

If you bootstrapped CI/CD (see [Bootstrap]({{< relref "bootstrap" >}})):

1. Push changes to a feature branch
2. Open a PR — the pipeline runs `terraform plan` / `bicep build` and posts the result
3. Merge to `main` — deploys to dev, then promotes through test → prod with approval gates
