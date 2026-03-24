---
title: "GitHub Actions"
weight: 10
---

> **Source:** [`Azure-Samples/github-terraform-oidc-ci-cd`](https://github.com/Azure-Samples/github-terraform-oidc-ci-cd)

## Prerequisites

- [Terraform CLI](https://www.terraform.io/downloads) and [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- [Azure subscription](https://azure.microsoft.com/pricing/purchase-options/azure-account) with Owner role
- [GitHub Organization](https://github.com/organizations/plan) (free tier works; personal orgs **not** supported)
- A GitHub Fine-Grained PAT ([PAT instructions](https://github.com/Azure-Samples/github-terraform-oidc-ci-cd#generate-a-pat-personal-access-token-in-github))

## Steps

### 1. Clone and configure

```bash
git clone https://github.com/Azure-Samples/github-terraform-oidc-ci-cd.git
cd github-terraform-oidc-ci-cd/bootstrap
```

Create `terraform.tfvars`:

```hcl
location          = "uksouth"
organization_name = "my-github-org"

approvers = {
  user1 = "approver@example.com"
}
```

### 2. Apply

```bash
az login -T "<tenant_id>"
az account set --subscription "<subscription_id>"

export TF_VAR_personal_access_token="<your_github_pat>"    # Linux/macOS
# $env:TF_VAR_personal_access_token = "<your_github_pat>"  # PowerShell

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

CI/CD workflows authenticate with the bootstrap-created managed identities:

```yaml
- name: Azure Login (OIDC)
  uses: azure/login@v2
  with:
    client-id: ${{ vars.AZURE_CLIENT_ID_PLAN_DEV }}
    tenant-id: ${{ vars.AZURE_TENANT_ID }}
    subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}
    enable-oidc: true
```

## Clean up

```bash
cd github-terraform-oidc-ci-cd/bootstrap
terraform destroy
```

> Destroy may fail on the first attempt due to dependency ordering. Run again if needed.
