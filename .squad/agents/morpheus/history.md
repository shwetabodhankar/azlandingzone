# Project Context

- **Owner:** Jared Holgate
- **Project:** Refactoring the App Service Landing Zone Accelerator to leverage Azure Verified Modules (AVM) for Terraform and Bicep, plus CI/CD bootstrapping with OIDC
- **Stack:** Terraform, Bicep, Azure (App Service, Front Door, Firewall, VNet, Key Vault, SQL, Redis, and more), GitHub Actions, Azure DevOps
- **Repo:** appservice-landing-zone-accelerator
- **Key reference repos:** Azure-Samples/azure-devops-terraform-oidc-ci-cd, Azure-Samples/github-terraform-oidc-ci-cd
- **Created:** 2026-03-24

## Repo Structure

- `scenarios/secure-baseline-multitenant/terraform/` — Terraform implementation (hub/spoke)
- `scenarios/secure-baseline-multitenant/bicep/` — Bicep implementation with reusable modules
- `scenarios/shared/terraform-modules/` — Shared Terraform modules
- `scenarios/shared/bicep/` — Shared Bicep modules
- `sampleapp/` — ASP.NET Core sample workload
- `docs/` — Architecture docs covering identity, networking, monitoring, BCDR, security, DevOps

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2024-03-24: Repository Structure & Module Inventory

**Terraform Implementation:**
- Hub/spoke architecture in `scenarios/secure-baseline-multitenant/terraform/`
- 16 custom modules in `scenarios/shared/terraform-modules/`
- Key modules: network, firewall, bastion, app-service (with child modules), key-vault, sql-database, redis, frontdoor, openai, windows-vm
- Provider versions: AzureRM ~>4.5.0, AzureCAF >=1.2.23, Terraform >=1.3
- State managed via AzureRM backend with storage account
- CI/CD: Reusable workflow pattern with OIDC, tfsec scanning, artifact-based plan/apply

**Bicep Implementation:**
- Hub/spoke architecture in `scenarios/secure-baseline-multitenant/bicep/`
- Shared modules in `scenarios/shared/bicep/` covering networking, app services, databases, storage, cognitive services
- Scenario-specific wrappers in `scenarios/secure-baseline-multitenant/bicep/modules/`
- Deployment uses Azure Deployment Stacks at subscription level
- CI/CD: Reusable workflow pattern with OIDC, bicep build validation

**Key Architectural Patterns:**
- Hub provides: VNet, Firewall (with egress rules), Bastion, Log Analytics
- Spoke provides: VNet, App Service/ASEv3, Front Door, Key Vault, SQL, Redis, OpenAI (optional), App Config (optional), Jump Host (optional)
- Hub→Spoke peering with UDR for forced tunneling through firewall
- Private endpoints + private DNS zones for all PaaS services
- Managed identities + RBAC (no passwords/keys in code)

**Azure Services Inventory:**
- Compute: App Service, ASE v3, Virtual Machines
- Networking: VNet, Firewall, Front Door, Application Gateway (implicit), Bastion, Private Endpoint, Private DNS Zone, NSG, UDR
- Data: SQL Database, Redis Cache, Storage Account
- App Platform: App Configuration, Key Vault
- AI: OpenAI (Cognitive Services)
- Monitoring: Log Analytics, Application Insights, Monitor Diagnostics

**File Paths to Remember:**
- Terraform entry: `scenarios/secure-baseline-multitenant/terraform/main.tf`
- Terraform hub: `scenarios/secure-baseline-multitenant/terraform/hub/`
- Terraform spoke: `scenarios/secure-baseline-multitenant/terraform/spoke/`
- Bicep entry: `scenarios/secure-baseline-multitenant/bicep/main.bicep`
- Workflows: `.github/workflows/scenario1.terraform.yml`, `.github/workflows/scenario1.bicep.yml`
- Composite actions: `.github/actions/templates/tfValidatePlan/`, `.github/actions/templates/tfApply/`

### 2024-03-24: Azure Verified Modules (AVM) Research

**AVM Overview:**
- Microsoft-official IaC modules for Terraform and Bicep
- Well-Architected Framework aligned
- Published to Terraform Registry (`Azure/avm-res-*`) and Bicep Public Registry (`br/public:avm/*`)
- Three types: Resource (RES), Pattern (PNT), Utility (UTL)
- Maintained by Microsoft, continuously updated

**AVM Module Availability (2024):**
- **Terraform:** 100+ resource modules on registry.terraform.io/namespaces/Azure
- **Bicep:** 170+ resource modules, 40+ pattern modules on Bicep Public Registry
- Coverage for all services used in this repo: VNet, Firewall, Bastion, App Service, Key Vault, SQL, Redis, Front Door, OpenAI, VM, etc.

**Key AVM Modules for This Project:**
- Networking: `avm-res-network-virtualnetwork`, `avm-res-network-azurefirewall`, `avm-res-network-bastionhost`, `avm-res-network-privatednszone`, `avm-res-network-privateendpoint`
- App Platform: `avm-res-web-serverfarm`, `avm-res-web-site` (includes ASE), `avm-res-keyvault-vault`, `avm-res-appconfiguration-configurationstore`
- Data: `avm-res-sql-server`, `avm-res-cache-redis`, `avm-res-storage-storageaccount`
- AI: `avm-res-cognitiveservices-account`
- Front Door: `avm-res-cdn-profile`
- Compute: `avm-res-compute-virtualmachine`

**AVM Patterns:**
- Hub networking: `avm/ptn/network/hub-networking`
- App Service LZA: `avm/ptn/app-service-lza/hosting-environment`
- Pattern modules can accelerate migration

**User Preference:**
- Jared Holgate (owner) prefers comprehensive planning before execution
- Wants detailed PRD with specific module mappings, file paths, and phasing

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2026-03-24: Team Assembly & PRD Creation

**Team Hired:**
- Morpheus (Lead/Architect) — Overall vision, AVM strategy
- Trinity (Terraform Specialist) — Terraform AVM migration
- Tank (Bicep Specialist) — Bicep AVM migration
- Switch (DevOps/CI-CD) — Bootstrap and CI/CD automation
- Niobe (Documentation/QA) — Migration guides, testing, documentation

**PRD Created:** docs/PRD.md (49KB)
- 3 workstreams: Terraform AVM (6 weeks), Bicep AVM (5 weeks), CI/CD Bootstrap (2 weeks)
- 16 Terraform module mappings identified
- 24 Bicep module mappings identified
- 7-phase execution plan per workstream
- Risk assessment and mitigation strategies
- Success criteria: Zero functionality regression, all scenarios deploy successfully

**10 Key Decisions Documented:**
1. AVM-First Strategy (replace custom modules)
2. Terraform-First Migration (then Bicep in parallel)
3. CI/CD Bootstrap Integration (GitHub Actions + Azure DevOps)
4. Keep Scenario-Specific Wrappers (refactor, don't remove)
5. Pin AVM Module Versions (controlled updates)
6. State Migration Strategy (terraform state mv + blue/green)
7. Sample App Unchanged (no scope creep)
8. Phased Rollout (Foundation → Integration)
9. No Platform Lock-In (GitHub + Azure DevOps parity)
10. Documentation Over Code Comments (external docs prioritized)

**Orchestration Log:** .squad/orchestration-log/2026-03-24T11-13-morpheus.md
**Session Log:** .squad/log/2026-03-24-team-init-prd.md
**Decisions Merged:** .squad/decisions.md (all 10 decisions now canonical)

**Next Steps:** Stakeholder review, approval, create tracking project, begin Stage 1 execution.
