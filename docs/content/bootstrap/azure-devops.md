---
title: "Azure DevOps"
weight: 20
---

> **Source:** [`Azure-Samples/azure-devops-terraform-oidc-ci-cd`](https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd)

## Prerequisites

- [Terraform CLI](https://www.terraform.io/downloads) and [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- [Azure subscription](https://azure.microsoft.com/pricing/purchase-options/azure-account) with Owner role
- [Azure DevOps Organization and Project](https://aex.dev.azure.com/signup/) (free tier with at least one pipeline)
- An Azure DevOps PAT ([PAT instructions](https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd#generate-a-pat-personal-access-token-in-azure-devops))

## Steps

### 1. Clone and configure

```bash
git clone https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd.git
cd azure-devops-terraform-oidc-ci-cd/bootstrap
```

Create `terraform.tfvars`:

```hcl
location          = "uksouth"
organization_name = "my-azdo-org"

approvers = {
  user1 = "approver@example.com"
}
```

### 2. Apply

```bash
az login -T "<tenant_id>"
az account set --subscription "<subscription_id>"

export TF_VAR_personal_access_token="<your_azdo_pat>"    # Linux/macOS
# $env:TF_VAR_personal_access_token = "<your_azdo_pat>"  # PowerShell

terraform init
terraform plan -out tfplan
terraform apply tfplan
```

### 3. Connect to this repo's infrastructure

Configure `infra/terraform/` to use the bootstrap-created state storage:

```hcl
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

Pipelines authenticate with the bootstrap-created service connections:

```yaml
- task: AzureCLI@2
  inputs:
    azureSubscription: 'OIDC-Dev-Plan'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      terraform init
      terraform plan -out tfplan
```

## Clean up

```bash
cd azure-devops-terraform-oidc-ci-cd/bootstrap
terraform destroy
```

> Destroy may fail on the first attempt due to dependency ordering. Run again if needed.
