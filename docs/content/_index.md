---
title: "App Service Landing Zone Accelerator"
weight: 1
---

Welcome to the **App Service Landing Zone Accelerator** documentation.

This accelerator provides production-ready infrastructure-as-code for deploying Azure App Service aligned with the [Cloud Adoption Framework](https://learn.microsoft.com/azure/cloud-adoption-framework/), powered by [Azure Verified Modules (AVM)](https://aka.ms/avm).

## What is this?

The App Service Landing Zone Accelerator deploys a spoke-level App Service environment with:

- **Azure App Service** (multi-tenant or ASE v3) with private networking
- **Azure Front Door** for global load balancing and WAF
- **Azure Key Vault** for secrets management with private endpoints
- **Azure SQL Database** and **Redis Cache** for data services
- **Azure Monitor** with Log Analytics and Application Insights
- **Private endpoints** and **Private DNS Zones** for all PaaS services
- **Managed identities** and **RBAC** — no passwords or keys in code

Hub networking (Azure Firewall, Bastion, hub VNet, peering) is provisioned separately via the [Azure Landing Zone IaC Accelerator](https://aka.ms/alz/acc).

## Choose your tooling

| Tool | Description | Docs |
|------|-------------|------|
| **Terraform** | Uses the AVM pattern module for App Service Landing Zone | [Terraform →]({{< relref "terraform" >}}) |
| **Bicep** | Uses AVM resource modules composed for App Service | [Bicep →]({{< relref "bicep" >}}) |

## Getting started

New to this accelerator? Start with the [Getting Started]({{< relref "getting-started" >}}) guide.

Need CI/CD? See the [Bootstrap]({{< relref "bootstrap" >}}) guide for GitHub Actions or Azure DevOps with OIDC.

## Architecture

See the [Architecture]({{< relref "architecture" >}}) section for design guidance on networking, identity, security, monitoring, and disaster recovery.

## Examples

Browse the [Examples]({{< relref "examples" >}}) to see all available deployment scenarios.
