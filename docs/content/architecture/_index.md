---
title: "Architecture"
weight: 50
geekdocCollapseSection: true
---

# Architecture

The App Service Landing Zone Accelerator deploys a **spoke-level** App Service environment aligned with the [Azure Cloud Adoption Framework](https://learn.microsoft.com/azure/cloud-adoption-framework/) and [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/).

## High-level architecture

![App Service Landing Zone Architecture](/img/AppServiceLandingZoneArchitecture-multitenant.png)

The spoke infrastructure includes:

- **Azure App Service** — Multi-tenant App Service Plan or ASE v3, with VNet integration for outbound traffic
- **Azure Front Door Premium** — Global load balancing, WAF policies, and private link origin to App Service
- **Azure Key Vault** — Secrets, certificates, and keys with private endpoint access
- **Azure SQL Database** — Managed relational database with private endpoint (optional)
- **Azure Cache for Redis** — In-memory caching with private endpoint (optional)
- **Azure Monitor** — Log Analytics workspace and Application Insights for observability
- **Private DNS Zones** — Name resolution for all private endpoints
- **Managed Identities** — System and user-assigned identities for zero-credential workloads

## Hub networking

Hub infrastructure (Azure Firewall, Bastion, hub VNet, VNet peering) is **not deployed by this accelerator**. Provision your hub using the [Azure Landing Zone IaC Accelerator](https://aka.ms/alz/acc), then connect the spoke by providing:

- `hub_virtual_network_id` — Resource ID of your hub VNet
- `route_table_id` / `firewallInternalIp` — For forced tunneling through Azure Firewall

## Design areas

### Identity and access management

- All services use **managed identities** — no passwords or service principal secrets
- **RBAC** assignments follow least-privilege principle
- SQL Server uses **Microsoft Entra ID** authentication
- CI/CD uses **OIDC federation** via Workload Identity Federation

### Networking

- Spoke VNet with dedicated subnets for App Service, private endpoints, and DevOps agents
- All PaaS services accessed exclusively via **private endpoints**
- Optional **forced tunneling** through hub Azure Firewall via UDR
- **Front Door Premium** provides global ingress with WAF and DDoS protection

### Security

- **Private endpoints** eliminate public internet exposure for all backend services
- **Key Vault** for all secrets and certificates
- **NSG rules** restrict traffic between subnets
- **TLS everywhere** — enforced on App Service and Front Door

### Monitoring and operations

- **Log Analytics workspace** collects diagnostics from all resources
- **Application Insights** provides application performance monitoring (APM)
- Diagnostic settings configured on all deployed resources

### Business continuity and disaster recovery

- **Zone-redundant** App Service Plans available (SKUs ending in `_AZ`)
- **Azure Front Door** provides automatic failover across regions
- **Deployment Stacks** (Bicep) provide drift detection and rollback

## Next steps

- [Getting Started]({{< relref "getting-started" >}}) — Deploy the accelerator
- [Terraform]({{< relref "terraform" >}}) — Terraform-specific details
- [Bicep]({{< relref "bicep" >}}) — Bicep-specific details
- [Examples]({{< relref "examples" >}}) — Deployment scenarios
