---
title: "Azure DevOps"
weight: 20
---

# Azure DevOps — OIDC CI/CD Bootstrap

Bootstrap CI/CD for deploying the App Service Landing Zone Accelerator using **Azure DevOps Pipelines with Workload Identity Federation (OIDC)**.

> **Source:** [`Azure-Samples/azure-devops-terraform-oidc-ci-cd`](https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd)

## What gets created

| Resource | Details |
|----------|---------|
| **6 Managed Identities** | `plan-dev`, `apply-dev`, `plan-test`, `apply-test`, `plan-prod`, `apply-prod` |
| **OIDC Federation** | Federated credentials linking Azure DevOps service connections to each managed identity |
| **Storage Account** | Terraform state with `dev`, `test`, `prod` containers |
| **Azure DevOps Repository** | Code repo with variable groups and environments configured |
| **Service Connections** | Workload Identity Federation connections per environment |
| **Environments** | `dev`, `test`, `prod` with exclusive locks |
| **CI/CD Pipelines** | Continuous Delivery and Pull Request validation pipelines |

## Key features

- **OIDC Authentication** — No secrets stored in Azure DevOps; Workload Identity Federation on service connections
- **Separate Plan/Apply Identities** — Plan identity has read-only access; apply identity has contributor access (least privilege)
- **Multi-Environment** — Dev, test, and prod with sequential promotion
- **Governed Pipelines** — Pipelines stored in a separate template repository; required template check on service connections ensures only approved templates can authenticate
- **Approval Gates** — Production apply requires explicit approval on the service connection (not the environment, preventing bypass)
- **Environment Locks** — `lockBehavior: sequential` queues deployments instead of failing on parallel runs
- **PR Validation** — Branch policy triggers static analysis and plan output on pull requests

## Prerequisites

- [Terraform CLI](https://www.terraform.io/downloads)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- [Azure Subscription](https://azure.microsoft.com/pricing/purchase-options/azure-account)
- [Azure DevOps Organization and Project](https://aex.dev.azure.com/signup/) (free tier with at least one pipeline)
- An Azure DevOps PAT with appropriate scopes (see [detailed PAT instructions](https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd#generate-a-pat-personal-access-token-in-azure-devops))

## Quickstart

### 1. Clone the bootstrap repo

```bash
git clone https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd.git
cd azure-devops-terraform-oidc-ci-cd/bootstrap
```

### 2. Create your configuration

Create a `terraform.tfvars` file in the `bootstrap/` folder:

```hcl
location          = "uksouth"                # Your preferred Azure region
organization_name = "my-azdo-org"            # Your Azure DevOps organization name

# Optional: configure production approvals
approvers = {
  user1 = "approver@example.com"
}

# Optional: use Microsoft-hosted agents instead of self-hosted
# use_self_hosted_agents = false
```

### 3. Authenticate and apply

```bash
# Login to Azure
az login -T "<tenant_id>"
az account set --subscription "<subscription_id>"

# Set your Azure DevOps PAT
export TF_VAR_personal_access_token="<your_azdo_pat>"    # Linux/macOS
# $env:TF_VAR_personal_access_token = "<your_azdo_pat>"  # PowerShell

# Run Terraform
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

### 4. Save the outputs

After apply completes, save the output values. These contain the managed identity client IDs and service connection names needed for OIDC authentication.

### 5. Connect to App Service Landing Zone infrastructure

Once bootstrap is complete, configure your `infra/terraform/` backend to use the bootstrap-created state storage:

```hcl
# infra/terraform/backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "<bootstrap-state-rg>"      # From bootstrap outputs
    storage_account_name = "<bootstrap-state-sa>"       # From bootstrap outputs
    container_name       = "dev"                        # Or test/prod
    key                  = "appservice-lza.tfstate"
    use_oidc             = true
  }
}
```

Your Azure DevOps pipelines authenticate using the bootstrap-created service connections:

```yaml
- task: AzureCLI@2
  inputs:
    azureSubscription: 'OIDC-Dev-Plan'       # Workload Identity Federation service connection
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      terraform init
      terraform plan -out tfplan
```

## Environment strategy

| Environment | Trigger | Approval |
|-------------|---------|----------|
| **Dev** | Auto-deploy on merge to `main` | None |
| **Test** | After dev succeeds | Manual approval gate |
| **Prod** | After test succeeds | Service connection approval + additional reviewers |

## Azure DevOps vs GitHub Actions — key differences

| Aspect | Azure DevOps | GitHub Actions |
|--------|-------------|---------------|
| **Governance** | Required template check on service connections | `job_workflow_ref` claim on federated credentials |
| **Approvals** | On service connection (cannot be bypassed) | On environment protection rules |
| **Concurrency** | `lockBehavior: sequential` on environments | `concurrency` setting on workflows |
| **Agent Pools** | Self-hosted or Microsoft-hosted agents | Self-hosted or GitHub-hosted runners |

## Clean up

To remove all bootstrap-created resources:

```bash
cd azure-devops-terraform-oidc-ci-cd/bootstrap
terraform destroy
```

> **Note:** The destroy may fail on the first attempt due to dependency ordering between service connections and federated credentials. Run `terraform destroy` again if this occurs.

## Resources

- [Source Repository — Azure-Samples/azure-devops-terraform-oidc-ci-cd](https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd)
- [Azure DevOps Workload Identity Federation](https://learn.microsoft.com/azure/devops/pipelines/library/connect-to-azure?view=azure-devops#create-an-azure-resource-manager-service-connection-that-uses-workload-identity-federation)
- [Terraform AzureRM OIDC Configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_oidc)
- [Azure Workload Identity Federation](https://learn.microsoft.com/azure/active-directory/develop/workload-identity-federation-create-trust?pivots=identity-wif-apps-methods-azp)
