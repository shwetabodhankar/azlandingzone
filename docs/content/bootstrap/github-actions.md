---
title: "GitHub Actions"
weight: 10
---

# GitHub Actions — OIDC CI/CD Bootstrap

Bootstrap CI/CD for deploying the App Service Landing Zone Accelerator using **GitHub Actions with Workload Identity Federation (OIDC)**.

> **Source:** [`Azure-Samples/github-terraform-oidc-ci-cd`](https://github.com/Azure-Samples/github-terraform-oidc-ci-cd)

## What gets created

| Resource | Details |
|----------|---------|
| **6 Managed Identities** | `plan-dev`, `apply-dev`, `plan-test`, `apply-test`, `plan-prod`, `apply-prod` |
| **OIDC Federation** | Federated credentials linking GitHub to each managed identity |
| **Storage Account** | Terraform state with `dev`, `test`, `prod` containers |
| **GitHub Repository** | Code repo with environments and variables configured |
| **GitHub Environments** | `dev-plan`, `dev-apply`, `test-plan`, `test-apply`, `prod-plan`, `prod-apply` |
| **CI/CD Workflows** | Continuous Delivery and Pull Request validation workflows |

## Key features

- **OIDC Authentication** — No secrets stored in GitHub; short-lived tokens via Workload Identity Federation
- **Separate Plan/Apply Identities** — Plan identity has read-only access; apply identity has contributor access (least privilege)
- **Multi-Environment** — Dev, test, and prod with sequential promotion
- **Governed Pipelines** — `job_workflow_ref` claim on federated credentials ensures only approved workflow templates can authenticate
- **Approval Gates** — Production environment requires explicit reviewer approval
- **Concurrent Locks** — `concurrency` setting queues deployments instead of failing on parallel runs
- **PR Validation** — Static analysis and plan output on pull requests

## Prerequisites

- [Terraform CLI](https://www.terraform.io/downloads)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- [Azure Subscription](https://azure.microsoft.com/pricing/purchase-options/azure-account)
- [GitHub Organization](https://github.com/organizations/plan) (free tier works; personal orgs are **not** supported)
- A GitHub Fine-Grained PAT with repository and organization permissions (see [detailed PAT instructions](https://github.com/Azure-Samples/github-terraform-oidc-ci-cd#generate-a-pat-personal-access-token-in-github))

## Quickstart

### 1. Clone the bootstrap repo

```bash
git clone https://github.com/Azure-Samples/github-terraform-oidc-ci-cd.git
cd github-terraform-oidc-ci-cd/bootstrap
```

### 2. Create your configuration

Create a `terraform.tfvars` file in the `bootstrap/` folder:

```hcl
location          = "uksouth"                # Your preferred Azure region
organization_name = "my-github-org"          # Your GitHub organization name

# Optional: configure production approvals
approvers = {
  user1 = "approver@example.com"
}

# Optional: use Microsoft-hosted runners instead of self-hosted
# use_self_hosted_agents = false
```

### 3. Authenticate and apply

```bash
# Login to Azure
az login -T "<tenant_id>"
az account set --subscription "<subscription_id>"

# Set your GitHub PAT
export TF_VAR_personal_access_token="<your_github_pat>"    # Linux/macOS
# $env:TF_VAR_personal_access_token = "<your_github_pat>"  # PowerShell

# Run Terraform
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

### 4. Save the outputs

After apply completes, save the output values. These contain the managed identity client IDs needed for OIDC authentication.

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

Your CI/CD workflows authenticate using the bootstrap-created managed identities:

```yaml
- name: Azure Login (OIDC)
  uses: azure/login@v2
  with:
    client-id: ${{ vars.AZURE_CLIENT_ID_PLAN_DEV }}    # Set by bootstrap
    tenant-id: ${{ vars.AZURE_TENANT_ID }}
    subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}
    enable-oidc: true
```

## Environment strategy

| Environment | Trigger | Approval |
|-------------|---------|----------|
| **Dev** | Auto-deploy on merge to `main` | None |
| **Test** | After dev succeeds | Manual approval gate |
| **Prod** | After test succeeds | Manual approval + additional reviewers |

## Clean up

To remove all bootstrap-created resources:

```bash
cd github-terraform-oidc-ci-cd/bootstrap
terraform destroy
```

> **Note:** The destroy may fail on the first attempt due to dependency ordering. Run `terraform destroy` again if this occurs.

## Resources

- [Source Repository — Azure-Samples/github-terraform-oidc-ci-cd](https://github.com/Azure-Samples/github-terraform-oidc-ci-cd)
- [GitHub OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-cloud-providers)
- [Terraform AzureRM OIDC Configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_oidc)
- [Azure Workload Identity Federation](https://learn.microsoft.com/azure/active-directory/develop/workload-identity-federation-create-trust?pivots=identity-wif-apps-methods-azp)
