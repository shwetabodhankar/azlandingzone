---
title: "Getting Started"
weight: 10
geekdocCollapseSection: true
---

# Getting Started

This guide walks you through deploying the App Service Landing Zone Accelerator infrastructure.

## Prerequisites

Before you begin, ensure you have:

- An [Azure Subscription](https://azure.microsoft.com/free/) with Owner or Contributor access
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed
- [Terraform](https://www.terraform.io/downloads) or [Bicep CLI](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install) installed (depending on your preference)
- Hub networking already provisioned via the [ALZ IaC Accelerator](https://aka.ms/alz/acc) (if connecting to a hub)

## Step 1: Choose your IaC tool

| Tool | Path | Guide |
|------|------|-------|
| Terraform | `infra/terraform/` | [Terraform docs]({{< relref "terraform" >}}) |
| Bicep | `infra/bicep/` | [Bicep docs]({{< relref "bicep" >}}) |

## Step 2: Bootstrap CI/CD (optional)

If you want automated deployments with OIDC (no secrets), follow the [Bootstrap guide]({{< relref "bootstrap" >}}) for your CI/CD platform:

- [GitHub Actions]({{< relref "bootstrap/github-actions" >}})
- [Azure DevOps]({{< relref "bootstrap/azure-devops" >}})

## Step 3: Configure and deploy

1. Clone the repository:

   ```bash
   git clone https://github.com/Azure/appservice-landing-zone-accelerator.git
   cd appservice-landing-zone-accelerator
   ```

2. Navigate to your IaC directory (`infra/terraform/` or `infra/bicep/`).

3. Review and customize the configuration variables for your environment.

4. Deploy:

   **Terraform:**
   ```bash
   cd infra/terraform
   terraform init
   terraform plan -out tfplan
   terraform apply tfplan
   ```

   **Bicep:**
   ```bash
   cd infra/bicep
   az deployment sub create \
     --location <region> \
     --template-file main.bicep \
     --parameters main.parameters.jsonc
   ```

## Step 4: Connect your hub (optional)

If you have an existing hub VNet with Azure Firewall, configure the spoke-to-hub integration by setting the hub VNet resource ID and firewall route table ID in your configuration variables. See the [Architecture]({{< relref "architecture" >}}) section for details.

## Next steps

- Browse [Examples]({{< relref "examples" >}}) for specific deployment scenarios
- Read the [Architecture]({{< relref "architecture" >}}) guidance for design decisions
