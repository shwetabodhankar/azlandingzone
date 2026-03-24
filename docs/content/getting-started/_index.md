---
title: "Getting Started"
weight: 10
geekdocCollapseSection: true
---

## Prerequisites

- An [Azure subscription](https://azure.microsoft.com/free/) with **Owner** or **Contributor + User Access Administrator** access
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- [Terraform CLI](https://www.terraform.io/downloads) (for Terraform) or [Bicep CLI](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install) (for Bicep)

## 1. Clone the repo

```bash
git clone https://github.com/Azure/appservice-landing-zone-accelerator.git
cd appservice-landing-zone-accelerator
```

## 2. Choose your IaC tool

| Tool | Code path | Module |
|------|-----------|--------|
| **Terraform** | `infra/terraform/` | [AVM pattern module](https://registry.terraform.io/modules/Azure/avm-ptn-app-service-landing-zone/azure/latest) |
| **Bicep** | `infra/bicep/` | [AVM pattern module](https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/app-service-lza/hosting-environment) |

## 3. Choose your scenario

Pick a deployment scenario from the [Examples]({{< relref "examples" >}}) table. Scenarios are toggled via feature flags in your variable/parameter file — no code changes needed.

## 4. Deploy

Run the interactive deployment helper:

```powershell
./deploy.ps1
```

It prompts for your Azure region, IaC tool, scenario, and hub connectivity — then runs the deployment. For manual deployment commands, see [Deploy]({{< relref "deploy" >}}).

## 5. Set up CI/CD (optional)

For automated deployments with OIDC (zero secrets), see [Bootstrap CI/CD]({{< relref "bootstrap" >}}).
