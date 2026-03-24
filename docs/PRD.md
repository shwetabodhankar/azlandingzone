# Product Requirements Document: AVM Migration & CI/CD Bootstrapping

## Executive Summary

### What We're Doing

Refactoring the App Service Landing Zone Accelerator repository to:

1. **Migrate to Azure Verified Modules (AVM)** — Replace custom Terraform and Bicep modules with official Microsoft-supported AVM modules from the Terraform Registry and Bicep Public Registry
2. **Add CI/CD Bootstrapping** — Integrate OIDC-based CI/CD bootstrap solutions for both GitHub Actions and Azure DevOps, based on proven reference implementations
3. **Maintain Solution Value** — Preserve the Landing Zone Accelerator's architectural guidance, secure baseline patterns, and sample application while improving maintainability and alignment with Microsoft best practices

### Why We're Doing It

**Business Drivers:**
- **Reduce maintenance burden** — Shift module maintenance to Microsoft's AVM team
- **Improve reliability** — Leverage Microsoft-tested, Well-Architected Framework-aligned modules
- **Accelerate adoption** — Provide turnkey CI/CD bootstrap to reduce time-to-production
- **Stay current** — Align with Microsoft's strategic direction for IaC standardization

**Technical Drivers:**
- Custom modules duplicate work that AVM already provides
- OIDC authentication is the modern, secure standard (vs. service principals with secrets)
- AVM modules receive continuous updates for new Azure features
- Consistent module interface patterns improve developer experience

### Success Metrics

- ✅ All custom modules replaced with AVM equivalents (or justified as solution-specific)
- ✅ Zero functionality regression — all scenarios deploy successfully
- ✅ CI/CD bootstrap modules integrated and documented
- ✅ Documentation updated to reflect AVM usage patterns
- ✅ GitHub Actions workflows updated for OIDC bootstrap
- ✅ State migration path documented for existing deployments

---

## Current State

### Repository Structure

```
appservice-landing-zone-accelerator/
├── scenarios/
│   ├── secure-baseline-multitenant/
│   │   ├── terraform/           # Hub/spoke orchestration
│   │   │   ├── hub/             # Hub network with Firewall, Bastion
│   │   │   ├── spoke/           # Spoke network with App Service, SQL, Redis, OpenAI
│   │   │   ├── main.tf          # Entry point, provider config
│   │   │   └── backend.hcl.template
│   │   └── bicep/               # Bicep orchestration
│   │       ├── main.bicep       # Subscription-level deployment
│   │       ├── deploy.hub.bicep
│   │       ├── deploy.spoke.bicep
│   │       └── modules/         # Scenario-specific wrappers
│   └── shared/
│       ├── terraform-modules/   # 16 custom modules
│       └── bicep/               # Reusable Bicep modules
├── .github/
│   ├── workflows/               # CI/CD pipelines
│   │   ├── scenario1.terraform.yml
│   │   ├── scenario1.bicep.yml
│   │   ├── .template.terraform.yml (reusable)
│   │   └── .template.bicep.yml (reusable)
│   └── actions/templates/       # Composite actions
│       ├── tfValidatePlan/
│       └── tfApply/
├── sampleapp/                   # ASP.NET Core sample workload
└── docs/                        # Architecture guidance (6 design areas)
```

### Terraform Implementation

**Custom Modules (`scenarios/shared/terraform-modules/`):**

| Module Path | Primary Resources | Purpose |
|-------------|------------------|---------|
| `network` | `azurerm_virtual_network`, `azurerm_subnet`, `azurerm_virtual_network_peering` | VNet with subnets and optional peering |
| `firewall` | `azurerm_firewall`, `azurerm_firewall_*_rule_collection`, `azurerm_log_analytics_workspace` | Azure Firewall with rules and diagnostics |
| `bastion` | `azurerm_bastion_host`, `azurerm_public_ip` | Azure Bastion |
| `user-defined-routes` | `azurerm_route_table`, `azurerm_route`, `azurerm_subnet_route_table_association` | Route tables with forced tunneling |
| `private-dns-zone` | `azurerm_private_dns_zone`, `azurerm_private_dns_zone_virtual_network_link`, `azurerm_private_dns_a_record` | Private DNS zones with VNet links and A records |
| `private-endpoint` | `azurerm_private_endpoint`, `azurerm_private_dns_a_record` | Generic private endpoint with DNS integration |
| `app-service` | `azurerm_service_plan`, `azurerm_application_insights`, child modules for Windows/Linux web apps | App Service Plan + App Insights + Web App + VNet integration |
| `app-service/windows-web-app` | `azurerm_windows_web_app`, `azurerm_windows_web_app_slot`, `azurerm_monitor_diagnostic_setting` | Windows Web App with slots and diagnostics |
| `app-service/linux-web-app` | `azurerm_linux_web_app`, `azurerm_linux_web_app_slot`, `azurerm_monitor_diagnostic_setting` | Linux Web App with slots and diagnostics |
| `app-configuration` | `azurerm_app_configuration`, `azurerm_private_endpoint`, `azurerm_role_assignment` | App Configuration with private endpoint and RBAC |
| `key-vault` | `azurerm_key_vault`, `azurerm_role_assignment`, `azurerm_private_endpoint` | Key Vault with RBAC and private endpoint |
| `sql-database` | `azurerm_mssql_server`, `azurerm_mssql_database`, `azurerm_key_vault_secret`, `azurerm_private_endpoint` | SQL Database with password in Key Vault and private endpoint |
| `redis` | `azurerm_redis_cache`, `azurerm_private_endpoint` | Redis Cache with private endpoint |
| `cognitive-services/openai` | `azurerm_cognitive_account`, `azurerm_cognitive_deployment` | Azure OpenAI with model deployments |
| `openai` | `azurerm_cognitive_account`, `azurerm_cognitive_deployment` | Duplicate/legacy OpenAI module |
| `frontdoor` | `azurerm_cdn_frontdoor_profile`, `azurerm_cdn_frontdoor_firewall_policy`, child endpoint module | Front Door with WAF policy |
| `frontdoor/endpoint` | `azurerm_cdn_frontdoor_endpoint`, `azurerm_cdn_frontdoor_origin_group`, `azurerm_cdn_frontdoor_origin`, `azurerm_cdn_frontdoor_route` | Front Door endpoint with private link to App Service |
| `windows-vm` | `azurerm_windows_virtual_machine`, `azurerm_network_interface`, `random_password`, `azurerm_role_assignment` | Windows VM with Entra login and secrets in Key Vault |
| `windows-vm-ext` | `azurerm_virtual_machine_extension` | VM extensions for Entra login and SSMS |

**Hub/Spoke Architecture:**

- **Hub** (`scenarios/secure-baseline-multitenant/terraform/hub/`):
  - `network.tf` — Hub VNet, Firewall, Bastion
  - `main.tf` — Hub resource group
  - Uses: `network`, `firewall`, `bastion` modules

- **Spoke** (`scenarios/secure-baseline-multitenant/terraform/spoke/`):
  - `network.tf` — Spoke VNet, subnets, peering, private DNS zones, Front Door, UDRs
  - `app.tf` — App Service, Key Vault, SQL, App Configuration, Redis
  - `ai.tf` — OpenAI
  - `devops.tf` — Jump host VM
  - `identity.tf` — User-assigned identities
  - `monitoring.tf` — Log Analytics
  - `asev3.tf` — ASE v3 (inline resource, not module)
  - Uses: `network`, `app-service`, `key-vault`, `sql-database`, `redis`, `openai`, `app-configuration`, `frontdoor`, `private-dns-zone`, `private-endpoint`, `user-defined-routes`, `windows-vm`, `windows-vm-ext` modules

**Terraform Provider Versions:**
- AzureRM: `~>4.5.0` (root), `>=4.0` (modules)
- AzureCAF: `>=1.2.23`
- Terraform: `>=1.3`

**Current CI/CD Pattern (Terraform):**

- **Workflows:** `.github/workflows/scenario1.terraform.yml` calls `.github/workflows/.template.terraform.yml`
- **Actions:** Composite actions in `.github/actions/templates/tfValidatePlan/` and `tfApply/`
- **Pattern:**
  - OIDC login to Azure (`azure/login@v2`, `ARM_USE_OIDC=true`)
  - `terraform init` with backend config (RG, storage account, container, key)
  - `terraform validate`
  - `tfsec` PR comments
  - `terraform plan` → artifact
  - PR comment with plan output
  - `terraform apply` from artifact
- **State Bootstrap:** `.github/workflows/platform.terraform-dependencies.yml` creates storage account for state

---

### Bicep Implementation

**Shared Modules (`scenarios/shared/bicep/`):**

| Module Path | Primary Resources | Purpose |
|-------------|------------------|---------|
| `naming.module.bicep` | None (helper) | Naming convention generator |
| `managed-identity.bicep` | `Microsoft.ManagedIdentity/userAssignedIdentities` | User-assigned managed identity |
| `role-assignments/role-assignment.bicep` | `Microsoft.Resources/deployments` | Generic RBAC wrapper |
| `private-dns-zone.bicep` | `Microsoft.Network/privateDnsZones`, `virtualNetworkLinks`, `A` records | Private DNS zone with VNet links |
| `private-endpoint.bicep` | `Microsoft.Network/privateEndpoints`, `privateDnsZoneGroups` | Private endpoint with DNS zone group |
| `network/vnet.bicep` | `Microsoft.Network/virtualNetworks` | VNet with subnets |
| `network/udr.bicep` | `Microsoft.Network/routeTables` | Route table |
| `network/nsg.bicep` | `Microsoft.Network/networkSecurityGroups`, diagnostics | NSG with diagnostics |
| `network/peering.bicep` | `Microsoft.Network/virtualNetworks/virtualNetworkPeerings` | VNet peering |
| `network/nic.private.dynamic.bicep` | `Microsoft.Network/networkInterfaces` | Network interface |
| `network/bastion.bicep` | `Microsoft.Network/bastionHosts`, `publicIPAddresses` | Bastion host |
| `network/front-door.bicep` | `Microsoft.Cdn/profiles`, `afdEndpoints`, `originGroups`, `origins`, `routes`, `securitypolicies`, WAF policy | Front Door with WAF |
| `network/publicIPAddresses/main.bicep` | `Microsoft.Network/publicIPAddresses`, locks, diagnostics, RBAC | Public IP with full features |
| `network/azureFirewalls/main.bicep` | `Microsoft.Network/azureFirewalls`, locks, diagnostics, RBAC | Azure Firewall |
| `app-services/app-service-plan.bicep` | `Microsoft.Web/serverfarms`, diagnostics | App Service Plan |
| `app-services/web-app.bicep` | `Microsoft.Web/sites`, `hostNameBindings`, diagnostics, calls appsettings/slots | Web App with slots |
| `app-services/web-app.appsettings.bicep` | `Microsoft.Web/sites/config` | App settings merge |
| `app-services/web-app.slots.bicep` | `Microsoft.Web/sites/slots`, diagnostics, calls slot appsettings | Deployment slots |
| `app-services/web-app.slots.appsettings.bicep` | `Microsoft.Web/sites/slots/config` | Slot app settings |
| `app-services/ase/ase.bicep` | `Microsoft.Web/hostingEnvironments`, locks, diagnostics | ASE v3 |
| `app-services/ase/ase.networking-configuration.bicep` | `Microsoft.Web/hostingEnvironments/configurations` | ASE networking config |
| `app-services/ase/ase.custom-dns-configuration.bicep` | `Microsoft.Web/hostingEnvironments/configurations` | ASE custom DNS |
| `compute/jumphost-win11.bicep` | `Microsoft.Compute/virtualMachines`, extensions | Windows 11 jump host |
| `log-analytics-ws.bicep` | `Microsoft.OperationalInsights/workspaces` | Log Analytics workspace |
| `app-insights.bicep` | `Microsoft.Insights/components` | Application Insights |
| `keyvault.bicep` | `Microsoft.KeyVault/vaults` | Key Vault |
| `app-configuration.bicep` | `Microsoft.AppConfiguration/configurationStores` | App Configuration |
| `databases/sql.bicep` | `Microsoft.Sql/servers`, `databases`, `transparentDataEncryption` | SQL Database |
| `databases/redis.bicep` | `Microsoft.Cache/redis`, diagnostics, Key Vault secret | Redis Cache |
| `storage/storage.bicep` | `Microsoft.Storage/storageAccounts` | Storage account |
| `storage/storage.blobsvc.bicep` | `Microsoft.Storage/storageAccounts`, `blobServices`, containers | Blob storage with containers |
| `storage/storage.queuesvc.bicep` | `Microsoft.Storage/storageAccounts`, `queueServices`, queues | Queue storage |
| `storage/storage.tablesvc.bicep` | `Microsoft.Storage/storageAccounts`, `tableServices`, tables | Table storage |
| `cognitive-services/open-ai.bicep` | `Microsoft.CognitiveServices/accounts`, locks, diagnostics, RBAC, CMK | OpenAI/Cognitive Services with full features |
| `cognitive-services/open-ai.Gpt.deployment.bicep` | `Microsoft.CognitiveServices/accounts/deployments` | GPT model deployment |

**Scenario-Specific Modules (`scenarios/secure-baseline-multitenant/bicep/modules/`):**

These are composition layers that wire shared modules together for the secure baseline scenario:

| Module | Purpose |
|--------|---------|
| `app-service.module.bicep` | Composes App Service Plan + Web App + App Insights + optional ASE + private endpoint/DNS + managed identity + RBAC |
| `keyvault.module.bicep` | Wraps Key Vault + private DNS zone + private endpoint |
| `redis.module.bicep` | Wraps Redis + private DNS zone + private endpoint |
| `sql-database.module.bicep` | Wraps SQL Database + private DNS zone + private endpoint |
| `open-ai.module.bicep` | Wraps OpenAI + optional GPT deployment + private DNS zone + private endpoint |
| `vmJumphost.module.bicep` | Wraps jump host VM + managed identity + Key Vault/App Config RBAC |
| `firewall-basic.module.bicep` | Wraps Azure Firewall Basic |
| `peerings.deployment.bicep` | Creates bidirectional VNet peering |
| `approve-afd-pe.module.bicep` | Deployment script to auto-approve AFD private endpoint connections |

**Top-Level Orchestration (`scenarios/secure-baseline-multitenant/bicep/`):**

- `main.bicep` — Subscription-level deployment, creates RGs, calls hub/spoke deployments
- `deploy.hub.bicep` — Hub VNet, Bastion, Log Analytics, Firewall
- `deploy.spoke.bicep` — Spoke VNet, NSGs, UDR, Key Vault, App Service, AFD, optional Redis/SQL/OpenAI/App Config/VM

**Current CI/CD Pattern (Bicep):**

- **Workflows:** `.github/workflows/scenario1.bicep.yml` calls `.github/workflows/.template.bicep.yml`
- **Pattern:**
  - OIDC login to Azure (`azure/login@v2`)
  - `az bicep build` for validation
  - `az stack sub create` for deployment (uses Azure Deployment Stacks)
  - `az stack delete --delete-all` for cleanup
  - Deploy only on `main` branch or manual dispatch
  - PSRule integration planned but commented out

---

## Target State

### Vision

The refactored repository will:

1. **Use AVM modules as building blocks** — Replace custom modules with AVM equivalents from official registries
2. **Preserve Landing Zone Accelerator value** — Keep hub/spoke architecture, secure baseline patterns, scenario orchestration, and documentation
3. **Provide CI/CD bootstrap** — Integrate OIDC-based bootstrap for GitHub Actions and Azure DevOps
4. **Maintain backward compatibility where possible** — Document migration paths for existing deployments

### Repository Structure (Post-Refactoring)

```
appservice-landing-zone-accelerator/
├── scenarios/
│   ├── secure-baseline-multitenant/
│   │   ├── terraform/
│   │   │   ├── hub/             # Uses AVM modules
│   │   │   ├── spoke/           # Uses AVM modules
│   │   │   ├── main.tf
│   │   │   └── bootstrap/       # NEW: OIDC bootstrap (optional)
│   │   └── bicep/
│   │       ├── main.bicep       # Uses AVM modules
│   │       ├── deploy.hub.bicep
│   │       ├── deploy.spoke.bicep
│   │       ├── modules/         # Scenario-specific wrappers (kept)
│   │       └── bootstrap/       # NEW: OIDC bootstrap (optional)
│   └── shared/
│       ├── terraform-modules/   # REMOVED or minimal solution-specific helpers
│       └── bicep/               # REMOVED or minimal solution-specific helpers
├── .github/
│   ├── workflows/               # Updated for OIDC bootstrap usage
│   └── actions/templates/       # Updated or replaced
├── bootstrap/                   # NEW: Root-level bootstrap documentation
│   ├── github-actions/          # GitHub OIDC bootstrap
│   ├── azure-devops/            # Azure DevOps OIDC bootstrap
│   └── README.md
├── sampleapp/                   # UNCHANGED
└── docs/                        # UPDATED with AVM guidance
    ├── PRD.md                   # This document
    └── migration-guide.md       # NEW: Migration guide for existing deployments
```

### AVM Module Strategy

**Principles:**
- **AVM First** — Use AVM modules wherever available
- **Thin Wrappers** — Keep scenario-specific modules as thin composition layers
- **Document Gaps** — Clearly document where custom logic is needed
- **Version Pinning** — Pin AVM module versions for stability

**AVM Module Sources:**
- **Terraform:** `registry.terraform.io/modules/Azure/` (e.g., `Azure/avm-res-network-virtualnetwork/azurerm`)
- **Bicep:** `br/public:avm/res.*` (e.g., `br/public:avm/res/network/virtual-network`)

---

## Workstream 1: Terraform AVM Migration

### Objective

Replace custom Terraform modules in `scenarios/shared/terraform-modules/` with AVM equivalents, update hub/spoke to use AVM, and document migration paths.

### AVM Module Mapping

| Custom Module | AVM Module | Notes |
|---------------|------------|-------|
| `network` | `Azure/avm-res-network-virtualnetwork/azurerm` | Includes VNet, subnets, NSG associations, route table associations, peering |
| `firewall` | `Azure/avm-res-network-azurefirewall/azurerm` | Includes firewall, public IP, diagnostics, application/network rules |
| `bastion` | `Azure/avm-res-network-bastionhost/azurerm` | Includes bastion host and public IP |
| `user-defined-routes` | `Azure/avm-res-network-routetable/azurerm` | Route table with routes and subnet associations |
| `private-dns-zone` | `Azure/avm-res-network-privatednszone/azurerm` | Private DNS zones with VNet links and A records |
| `private-endpoint` | `Azure/avm-res-network-privateendpoint/azurerm` | Private endpoint with DNS zone group integration |
| `app-service` (plan) | `Azure/avm-res-web-serverfarm/azurerm` | App Service Plan |
| `app-service` (web app) | `Azure/avm-res-web-site/azurerm` | Web App (Windows/Linux) with slots, diagnostics, VNet integration |
| `app-configuration` | `Azure/avm-res-appconfiguration-configurationstore/azurerm` | App Configuration with private endpoint and RBAC |
| `key-vault` | `Azure/avm-res-keyvault-vault/azurerm` | Key Vault with RBAC, private endpoint, diagnostics |
| `sql-database` | `Azure/avm-res-sql-server/azurerm` + `Azure/avm-res-sql-database/azurerm` | SQL Server and Database with private endpoint |
| `redis` | `Azure/avm-res-cache-redis/azurerm` | Redis Cache with private endpoint |
| `cognitive-services/openai` | `Azure/avm-res-cognitiveservices-account/azurerm` | Cognitive Services (OpenAI) with deployments |
| `frontdoor` | `Azure/avm-res-cdn-profile/azurerm` | Front Door (CDN) profile with WAF, endpoints, origins, routes |
| `windows-vm` | `Azure/avm-res-compute-virtualmachine/azurerm` | Virtual Machine with managed identity, diagnostics, extensions |
| `windows-vm-ext` | Included in VM module | VM extensions (Entra login, custom scripts) |

**Note:** Module names are based on AVM naming conventions (as of 2024). Verify exact names in registry before implementation.

### Breaking Changes & Migration Considerations

| Area | Breaking Change | Migration Strategy |
|------|----------------|-------------------|
| **Module Inputs** | AVM modules use different parameter names and structures | Create input variable mapping layer; update caller code |
| **Module Outputs** | AVM output structure differs from custom modules | Update output references in hub/spoke orchestration |
| **State Migration** | Resource addresses change when switching modules | Document `terraform state mv` commands; provide migration script |
| **Provider Requirements** | AVM modules may require newer provider versions | Update `required_providers` block; test compatibility |
| **Feature Parity** | AVM modules may lack custom features (e.g., specific rule sets) | Document workarounds or inline resources for gaps |
| **Child Modules** | App Service currently uses child modules for Windows/Linux | Use AVM's `os_type` parameter instead |
| **Diagnostics** | AVM modules use consistent diagnostics interface | Update diagnostics configuration to match AVM patterns |
| **RBAC** | AVM modules use `role_assignments` variable pattern | Refactor RBAC assignments to AVM structure |

### Implementation Phases

**Phase 1: Foundation (Networking & Observability)**
- [ ] Replace `network` module with `avm-res-network-virtualnetwork`
- [ ] Replace `user-defined-routes` with `avm-res-network-routetable`
- [ ] Replace `private-dns-zone` with `avm-res-network-privatednszone`
- [ ] Replace `private-endpoint` with `avm-res-network-privateendpoint`
- [ ] Test hub VNet and spoke VNet creation
- [ ] Verify peering and DNS integration

**Phase 2: Security & Connectivity**
- [ ] Replace `firewall` with `avm-res-network-azurefirewall`
- [ ] Replace `bastion` with `avm-res-network-bastionhost`
- [ ] Test hub network with firewall rules
- [ ] Verify UDR forced tunneling

**Phase 3: App Platform**
- [ ] Replace `app-service` with `avm-res-web-serverfarm` and `avm-res-web-site`
- [ ] Test App Service deployment with VNet integration
- [ ] Verify slots and diagnostics
- [ ] Test ASE v3 scenario (inline resource or AVM module if available)

**Phase 4: Data & State**
- [ ] Replace `key-vault` with `avm-res-keyvault-vault`
- [ ] Replace `sql-database` with `avm-res-sql-server` and `avm-res-sql-database`
- [ ] Replace `redis` with `avm-res-cache-redis`
- [ ] Replace `app-configuration` with `avm-res-appconfiguration-configurationstore`
- [ ] Test private endpoints for all data services

**Phase 5: AI & Front Door**
- [ ] Replace `cognitive-services/openai` with `avm-res-cognitiveservices-account`
- [ ] Remove duplicate `openai` module
- [ ] Replace `frontdoor` with `avm-res-cdn-profile`
- [ ] Test Front Door private link to App Service

**Phase 6: Compute & DevOps**
- [ ] Replace `windows-vm` and `windows-vm-ext` with `avm-res-compute-virtualmachine`
- [ ] Test VM deployment with Entra login and SSMS
- [ ] Verify Key Vault secret integration

**Phase 7: Integration & Testing**
- [ ] Update hub/spoke orchestration to use all AVM modules
- [ ] End-to-end deployment test (multitenant + ASE v3)
- [ ] Performance and drift detection testing
- [ ] Document state migration scripts

### Validation Criteria

- ✅ All custom modules replaced or justified
- ✅ Hub/spoke deployment succeeds with AVM modules
- ✅ ASE v3 scenario works
- ✅ Private endpoints and DNS function correctly
- ✅ Diagnostics and monitoring work
- ✅ RBAC assignments function correctly
- ✅ Sample app deploys and runs
- ✅ State migration documented and tested

---

## Workstream 2: Bicep AVM Migration

### Objective

Replace custom Bicep modules in `scenarios/shared/bicep/` with AVM equivalents, update main deployment to use AVM, and maintain scenario-specific composition modules.

### AVM Module Mapping

| Custom Module | AVM Module | Notes |
|---------------|------------|-------|
| `network/vnet.bicep` | `br/public:avm/res/network/virtual-network` | VNet with subnets, NSGs, route tables |
| `network/nsg.bicep` | Included in VNet module | NSG with diagnostics |
| `network/udr.bicep` | `br/public:avm/res/network/route-table` | Route table with routes |
| `network/peering.bicep` | Included in VNet module | VNet peering |
| `network/bastion.bicep` | `br/public:avm/res/network/bastion-host` | Bastion host with public IP |
| `network/publicIPAddresses/main.bicep` | `br/public:avm/res/network/public-ip-address` | Public IP with locks, diagnostics, RBAC |
| `network/azureFirewalls/main.bicep` | `br/public:avm/res/network/azure-firewall` | Azure Firewall with rules, diagnostics |
| `network/front-door.bicep` | `br/public:avm/res/cdn/profile` | Front Door with endpoints, origins, WAF |
| `private-dns-zone.bicep` | `br/public:avm/res/network/private-dns-zone` | Private DNS zone with VNet links |
| `private-endpoint.bicep` | `br/public:avm/res/network/private-endpoint` | Private endpoint with DNS zone groups |
| `app-services/app-service-plan.bicep` | `br/public:avm/res/web/serverfarm` | App Service Plan |
| `app-services/web-app.bicep` | `br/public:avm/res/web/site` | Web App with slots, diagnostics |
| `app-services/ase/ase.bicep` | `br/public:avm/res/web/hosting-environment` | App Service Environment v3 |
| `keyvault.bicep` | `br/public:avm/res/key-vault/vault` | Key Vault with RBAC, private endpoint |
| `app-configuration.bicep` | `br/public:avm/res/app-configuration/configuration-store` | App Configuration with RBAC |
| `databases/sql.bicep` | `br/public:avm/res/sql/server` | SQL Server and databases |
| `databases/redis.bicep` | `br/public:avm/res/cache/redis` | Redis Cache |
| `storage/storage.*.bicep` | `br/public:avm/res/storage/storage-account` | Storage account with blob/queue/table services |
| `cognitive-services/open-ai.bicep` | `br/public:avm/res/cognitive-services/account` | Cognitive Services (OpenAI) with deployments |
| `log-analytics-ws.bicep` | `br/public:avm/res/operational-insights/workspace` | Log Analytics workspace |
| `app-insights.bicep` | `br/public:avm/res/insights/component` | Application Insights |
| `managed-identity.bicep` | `br/public:avm/res/managed-identity/user-assigned-identity` | User-assigned managed identity |
| `compute/jumphost-win11.bicep` | `br/public:avm/res/compute/virtual-machine` | Virtual Machine with extensions |

**Scenario-Specific Modules (`modules/`) — Keep and Refactor:**
- These modules provide solution-specific composition and wiring
- Update them to consume AVM modules instead of custom modules
- Keep the scenario-specific logic (e.g., AFD auto-approval, multi-service composition)

**Pattern Modules:**
- Consider leveraging AVM pattern modules for common combinations:
  - `br/public:avm/ptn/network/hub-networking` for hub architecture
  - `br/public:avm/ptn/app-service-lza/hosting-environment` for App Service patterns

### Breaking Changes & Migration Considerations

| Area | Breaking Change | Migration Strategy |
|------|----------------|-------------------|
| **Parameter Names** | AVM uses camelCase consistently | Update parameter references in main.bicep and deploy.*.bicep |
| **Output Structure** | AVM outputs are standardized | Update output references in orchestration |
| **Diagnostics** | AVM uses `diagnosticSettings` parameter object | Refactor diagnostics configuration |
| **RBAC** | AVM uses `roleAssignments` parameter array | Refactor role assignments to AVM pattern |
| **Locks** | AVM uses `lock` parameter object | Update lock configuration where needed |
| **Tags** | AVM uses `tags` parameter consistently | Ensure tag propagation works correctly |
| **Module Registry** | Switching to `br/public:avm/*` references | Update all module references; version pinning recommended |

### Implementation Phases

**Phase 1: Foundation (Networking)**
- [ ] Replace VNet module with AVM
- [ ] Replace route table module with AVM
- [ ] Replace private DNS zone module with AVM
- [ ] Replace private endpoint module with AVM
- [ ] Test hub and spoke networking

**Phase 2: Security & Observability**
- [ ] Replace Azure Firewall module with AVM
- [ ] Replace Bastion module with AVM
- [ ] Replace Log Analytics module with AVM
- [ ] Replace Application Insights module with AVM
- [ ] Test hub security resources

**Phase 3: App Platform**
- [ ] Replace App Service Plan module with AVM
- [ ] Replace Web App module with AVM
- [ ] Replace ASE module with AVM (or pattern module)
- [ ] Update `app-service.module.bicep` to use AVM
- [ ] Test App Service deployment

**Phase 4: Data Services**
- [ ] Replace Key Vault module with AVM
- [ ] Replace SQL Database module with AVM
- [ ] Replace Redis module with AVM
- [ ] Replace App Configuration module with AVM
- [ ] Replace Storage modules with AVM
- [ ] Update scenario wrappers
- [ ] Test data services with private endpoints

**Phase 5: AI & Front Door**
- [ ] Replace Cognitive Services module with AVM
- [ ] Replace Front Door module with AVM
- [ ] Update `open-ai.module.bicep` wrapper
- [ ] Test OpenAI and Front Door integration

**Phase 6: Compute & Identity**
- [ ] Replace VM module with AVM
- [ ] Replace Managed Identity module with AVM
- [ ] Update `vmJumphost.module.bicep` wrapper
- [ ] Test jump host deployment

**Phase 7: Integration & Testing**
- [ ] Update `main.bicep`, `deploy.hub.bicep`, `deploy.spoke.bicep` for AVM
- [ ] End-to-end deployment test
- [ ] Test Azure Deployment Stack compatibility
- [ ] Verify all feature flags work

### Validation Criteria

- ✅ All shared modules replaced with AVM or removed
- ✅ Scenario-specific wrappers updated and validated
- ✅ Hub/spoke deployment succeeds
- ✅ ASE v3 scenario works
- ✅ Deployment Stacks work correctly
- ✅ All feature flags function
- ✅ Sample app deploys and runs
- ✅ Documentation updated

---

## Workstream 3: CI/CD Bootstrapping with OIDC

### Objective

Integrate OIDC-based CI/CD bootstrap solutions for GitHub Actions and Azure DevOps, based on proven reference implementations from Microsoft.

### Reference Implementations

**1. GitHub Actions Bootstrap**
- **Source:** `Azure-Samples/github-terraform-oidc-ci-cd`
- **Features:**
  - 6 Azure User Assigned Managed Identities with OIDC federation
  - Azure Storage Account for Terraform state
  - GitHub repository + environments setup (dev/test/prod)
  - Continuous Delivery Action with OIDC auth
  - Pull Request workflow with static analysis
  - Separate plan/apply identities for least privilege
  - Environment approvals and concurrent locks

**2. Azure DevOps Bootstrap**
- **Source:** `Azure-Samples/azure-devops-terraform-oidc-ci-cd`
- **Features:**
  - 6 Azure User Assigned Managed Identities with OIDC federation
  - Azure Storage Account for Terraform state
  - Azure DevOps repository + environments setup (dev/test/prod)
  - Governed pipelines (template repository pattern)
  - Continuous Delivery pipeline with OIDC auth
  - Pull Request workflow with static analysis
  - Separate plan/apply identities
  - Environment approvals and locks

### Integration Strategy

**Repository Structure:**

```
bootstrap/
├── README.md                      # Bootstrap overview and decision guide
├── github-actions/
│   ├── terraform/                 # Terraform for GitHub OIDC bootstrap
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md             # GitHub-specific instructions
│   └── workflows/                 # Example workflows using OIDC
│       ├── continuous-delivery.yml
│       └── pull-request.yml
└── azure-devops/
    ├── terraform/                 # Terraform for Azure DevOps OIDC bootstrap
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md             # Azure DevOps-specific instructions
    └── pipelines/                 # Example pipelines using OIDC
        ├── continuous-delivery.yml
        └── pull-request.yml
```

**Integration Points:**

1. **State Management:**
   - Bootstrap creates storage account for Terraform state
   - Update `backend.hcl.template` to reference bootstrap-created storage
   - Document how to migrate existing state

2. **Workflow Updates:**
   - Update `.github/workflows/*.yml` to use OIDC identities
   - Replace service principal login with OIDC login
   - Add environment gates (dev → test → prod)
   - Separate plan identity (read) from apply identity (write)

3. **Environment Strategy:**
   - **Dev:** Auto-deploy on PR merge to `main`
   - **Test:** Manual approval gate
   - **Prod:** Manual approval gate + additional reviewers

4. **Security Posture:**
   - No secrets or service principal credentials in GitHub/Azure DevOps
   - OIDC federated credentials scoped to specific repos/branches
   - Managed identities with least-privilege RBAC

### GitHub Actions Integration

**Managed Identities:**
1. `github-plan-dev` — Terraform plan for dev
2. `github-apply-dev` — Terraform apply for dev
3. `github-plan-test` — Terraform plan for test
4. `github-apply-test` — Terraform apply for test
5. `github-plan-prod` — Terraform plan for prod
6. `github-apply-prod` — Terraform apply for prod

**Workflow Changes:**

**Before (Current):**
```yaml
- name: Azure Login
  uses: azure/login@v2
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

**After (OIDC):**
```yaml
- name: Azure Login (OIDC)
  uses: azure/login@v2
  with:
    client-id: ${{ vars.AZURE_CLIENT_ID_PLAN_DEV }}  # From bootstrap outputs
    tenant-id: ${{ vars.AZURE_TENANT_ID }}
    subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}
    enable-oidc: true
```

**Environment Configuration:**
- Create `dev`, `test`, `prod` environments in GitHub repo settings
- Add protection rules (approvals, reviewers)
- Store bootstrap outputs as environment variables

### Azure DevOps Integration

**Managed Identities:**
1. `azdo-plan-dev` — Terraform plan for dev
2. `azdo-apply-dev` — Terraform apply for dev
3. `azdo-plan-test` — Terraform plan for test
4. `azdo-apply-test` — Terraform apply for test
5. `azdo-plan-prod` — Terraform plan for prod
6. `azdo-apply-prod` — Terraform apply for prod

**Service Connection:**
- Create Azure Resource Manager service connection with Workload Identity Federation
- Use managed identity client ID from bootstrap outputs
- Scope to subscription

**Pipeline Changes:**

**Before (Current):**
```yaml
- task: AzureCLI@2
  inputs:
    azureSubscription: 'Service-Connection-Name'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: 'terraform init'
```

**After (OIDC):**
```yaml
- task: AzureCLI@2
  inputs:
    azureSubscription: 'OIDC-Dev-Plan'  # Workload Identity Federation
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: 'terraform init'
    addSpnToEnvironment: true
    useGlobalConfig: true
```

**Environment Configuration:**
- Create `dev`, `test`, `prod` environments in Azure DevOps
- Add approval gates
- Configure checks and validations

### Implementation Phases

**Phase 1: Bootstrap Setup**
- [ ] Create `bootstrap/` directory structure
- [ ] Adapt GitHub Actions bootstrap from reference repo
- [ ] Adapt Azure DevOps bootstrap from reference repo
- [ ] Document bootstrap prerequisites and steps
- [ ] Test bootstrap in clean environment

**Phase 2: GitHub Actions Migration**
- [ ] Create dev/test/prod environments in GitHub
- [ ] Run GitHub bootstrap to create identities and storage
- [ ] Update `.github/workflows/.template.terraform.yml` for OIDC
- [ ] Update `.github/workflows/scenario1.terraform.yml` for multi-environment
- [ ] Test OIDC authentication
- [ ] Test plan/apply separation
- [ ] Test environment approvals

**Phase 3: Azure DevOps Setup**
- [ ] Create dev/test/prod environments in Azure DevOps
- [ ] Run Azure DevOps bootstrap to create identities and storage
- [ ] Create example pipelines (not replacing GitHub Actions, just documenting)
- [ ] Document Azure DevOps setup process
- [ ] Test OIDC authentication in Azure DevOps

**Phase 4: Documentation & Examples**
- [ ] Create decision guide (GitHub Actions vs Azure DevOps)
- [ ] Document state migration from existing storage to bootstrap storage
- [ ] Create runbook for bootstrap execution
- [ ] Document RBAC requirements
- [ ] Create troubleshooting guide

**Phase 5: Legacy Support**
- [ ] Document how to continue using service principals (if needed)
- [ ] Provide migration path for existing deployments
- [ ] Create rollback procedure

### Validation Criteria

- ✅ Bootstrap terraform deploys successfully for both platforms
- ✅ OIDC authentication works for plan operations
- ✅ OIDC authentication works for apply operations
- ✅ Environment approvals function correctly
- ✅ Plan/apply identity separation enforced
- ✅ State storage in bootstrap-created account works
- ✅ No secrets or credentials in repo
- ✅ Documentation complete and tested

---

## Non-Goals

### Explicitly Out of Scope

**Sample Application:**
- ❌ No changes to `sampleapp/` ASP.NET Core application
- ❌ No changes to application architecture or code
- ✅ Sample app must continue to work with new infrastructure

**Documentation Structure:**
- ❌ No changes to `docs/Design-Areas/` architecture guidance
- ✅ Documentation will be updated to reference AVM modules instead of custom modules
- ✅ New migration guide will be added

**Scenario Structure:**
- ❌ No new scenarios or reference implementations
- ❌ No changes to hub/spoke architecture pattern
- ✅ Existing secure-baseline-multitenant scenario remains the focus

**Azure Services:**
- ❌ No new Azure services added
- ❌ No architecture pattern changes (e.g., hub/spoke remains hub/spoke)
- ✅ All existing services supported with AVM modules

**Breaking Changes (Where Avoidable):**
- ❌ Do not force immediate migration for existing deployments
- ✅ Document migration paths and provide upgrade scripts
- ✅ Maintain backward compatibility through documentation

**CI/CD Platform Choice:**
- ❌ Not deprecating GitHub Actions
- ❌ Not mandating Azure DevOps
- ✅ Provide both options; users choose based on their platform

---

## Dependencies & Risks

### Dependencies

**External:**
- **AVM Module Availability:** All required AVM modules must be published and stable
- **AVM Module Maturity:** Modules must support features needed for Landing Zone Accelerator
- **Terraform Registry:** Modules must be available on `registry.terraform.io`
- **Bicep Public Registry:** Modules must be available on `br/public:avm/*`
- **Azure API Stability:** Azure Resource Manager APIs must remain stable

**Internal:**
- **Testing Infrastructure:** Need Azure subscriptions for testing
- **CI/CD Setup:** GitHub Actions must continue to work during migration
- **Team Bandwidth:** Need dedicated time for migration and testing

### Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| **AVM module not available** | Medium | High | Document workaround; keep custom module as fallback; engage AVM team |
| **AVM module missing features** | Medium | Medium | Use inline resources for gaps; submit feature request to AVM |
| **Breaking changes in AVM** | Low | High | Pin module versions; test before upgrading |
| **State migration issues** | Medium | High | Extensive testing; provide rollback plan; document `terraform state mv` |
| **Performance degradation** | Low | Medium | Benchmark before/after; optimize module usage |
| **User adoption resistance** | Medium | Medium | Clear documentation; migration guides; support channels |
| **Bootstrap complexity** | Medium | Low | Detailed runbooks; automated scripts; example repositories |
| **OIDC federation issues** | Low | Medium | Test in multiple tenants; document troubleshooting; fallback to SPN if needed |
| **Hub/spoke peering breaks** | Low | High | Extensive integration testing; validation scripts |
| **Private endpoint DNS fails** | Low | High | Test all services; validate DNS resolution |

### Mitigations

**AVM Module Gaps:**
- Maintain list of required features vs. available AVM features
- Engage with AVM team early to prioritize needed modules
- Document custom implementations for gaps
- Plan fallback to custom modules if critical features missing

**State Migration:**
- Create comprehensive state migration scripts
- Test migration in non-production environments first
- Document manual migration steps for edge cases
- Provide "blue/green" approach: deploy new alongside old, then switch

**Version Management:**
- Pin all AVM module versions in production
- Test new versions in dev environment before promoting
- Document version compatibility matrix
- Subscribe to AVM release notifications

**User Support:**
- Create detailed migration guides with examples
- Provide comparison tables (old vs. new)
- Set up office hours or Q&A sessions
- Create troubleshooting FAQ

---

## Success Criteria

### Functional

- ✅ All custom Terraform modules replaced with AVM or documented exceptions
- ✅ All custom Bicep modules replaced with AVM or documented exceptions
- ✅ Hub/spoke deployment succeeds with AVM modules
- ✅ Multitenant App Service scenario deploys successfully
- ✅ ASE v3 scenario deploys successfully
- ✅ Sample application deploys and runs
- ✅ Private endpoints function correctly
- ✅ DNS resolution works for all private endpoints
- ✅ Front Door routes traffic to App Service
- ✅ Monitoring and diagnostics operational
- ✅ RBAC assignments function correctly
- ✅ GitHub Actions OIDC bootstrap works
- ✅ Azure DevOps OIDC bootstrap works (documented)

### Quality

- ✅ No functionality regressions
- ✅ Deployment time within 10% of baseline
- ✅ Resource costs unchanged or lower
- ✅ Code passes tfsec security scanning
- ✅ Code passes Bicep linting
- ✅ Documentation complete and accurate
- ✅ Migration guide tested and validated

### Non-Functional

- ✅ Repository structure is cleaner (fewer custom modules)
- ✅ Maintenance burden reduced (fewer custom modules to maintain)
- ✅ Alignment with Microsoft best practices (AVM usage)
- ✅ Security improved (OIDC vs. service principals)
- ✅ Developer experience improved (consistent AVM interfaces)
- ✅ Discoverability improved (AVM modules are searchable)

### Documentation

- ✅ PRD completed (this document)
- ✅ Migration guide for existing deployments
- ✅ Bootstrap runbooks for GitHub Actions and Azure DevOps
- ✅ AVM module reference guide
- ✅ Breaking changes documented
- ✅ Troubleshooting guide created
- ✅ Architecture docs updated to reference AVM
- ✅ README updated with AVM and bootstrap info

---

## Phasing & Execution

### Recommended Order of Work

**Stage 1: Planning & Setup (Week 1-2)**
1. ✅ PRD approval (this document)
2. Team decision: Terraform-first or Bicep-first? (Recommend: Terraform-first due to complexity)
3. Set up testing environment (Azure subscriptions, GitHub Actions, Azure DevOps)
4. Verify AVM module availability (compare mapping tables to actual registry)
5. Create migration tracking (GitHub Projects or Azure Boards)
6. Set up branching strategy (e.g., `feature/avm-migration` branch)

**Stage 2: Terraform AVM Migration (Week 3-8)**
1. Phase 1: Foundation (Networking & Observability) — Week 3-4
2. Phase 2: Security & Connectivity — Week 4-5
3. Phase 3: App Platform — Week 5-6
4. Phase 4: Data & State — Week 6-7
5. Phase 5: AI & Front Door — Week 7
6. Phase 6: Compute & DevOps — Week 7-8
7. Phase 7: Integration & Testing — Week 8

**Stage 3: Bicep AVM Migration (Week 9-13)**
1. Phase 1: Foundation (Networking) — Week 9
2. Phase 2: Security & Observability — Week 9-10
3. Phase 3: App Platform — Week 10-11
4. Phase 4: Data Services — Week 11-12
5. Phase 5: AI & Front Door — Week 12
6. Phase 6: Compute & Identity — Week 12-13
7. Phase 7: Integration & Testing — Week 13

**Stage 4: CI/CD Bootstrap (Week 14-16)**
1. Phase 1: Bootstrap Setup — Week 14
2. Phase 2: GitHub Actions Migration — Week 15
3. Phase 3: Azure DevOps Setup — Week 15-16
4. Phase 4: Documentation & Examples — Week 16
5. Phase 5: Legacy Support — Week 16

**Stage 5: Documentation & Launch (Week 17-18)**
1. Complete migration guide
2. Update architecture documentation
3. Update README and getting started
4. Create announcement and blog post
5. Release PR and announce

### Parallelization Opportunities

**Can Run in Parallel:**
- Terraform and Bicep migrations can run in parallel with separate teams
- Bootstrap development can start during Stage 2 or 3
- Documentation can be written alongside implementation

**Must Be Sequential:**
- Testing must follow implementation for each phase
- Integration testing must follow all module replacements
- Bootstrap integration requires AVM migration to be complete (for realistic testing)

### Team Assignments (If Squad-Based)

**Morpheus (Lead/Architect):**
- Overall strategy and coordination
- Code reviews for all PRs
- Architecture decisions and trade-offs
- Issue triage and priority setting

**Terraform Specialist:**
- Terraform AVM migration
- State migration scripts
- Terraform testing

**Bicep Specialist:**
- Bicep AVM migration
- Deployment Stacks validation
- Bicep testing

**DevOps Specialist:**
- CI/CD bootstrap implementation
- Workflow updates
- Pipeline testing

**Documentation Specialist:**
- Migration guides
- Bootstrap runbooks
- Architecture doc updates

---

## Appendix

### AVM Resources

**Official Sites:**
- AVM Portal: https://aka.ms/avm
- AVM GitHub: https://github.com/Azure/Azure-Verified-Modules
- Terraform Modules: https://registry.terraform.io/namespaces/Azure
- Bicep Modules: https://azure.github.io/Azure-Verified-Modules/indexes/bicep/

**Key Documentation:**
- AVM Terraform Quickstart: https://azure.github.io/Azure-Verified-Modules/usage/quickstart/terraform/
- AVM Bicep Quickstart: https://azure.github.io/Azure-Verified-Modules/usage/quickstart/bicep/
- Module Lifecycle: https://azure.github.io/Azure-Verified-Modules/specs/shared/module-lifecycle/

### Bootstrap Reference Repositories

**GitHub Actions + Terraform OIDC:**
- Repo: https://github.com/Azure-Samples/github-terraform-oidc-ci-cd
- Documentation: README in repository

**Azure DevOps + Terraform OIDC:**
- Repo: https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd
- Documentation: README in repository

### Module Version Matrix (Example)

| Service | Terraform AVM Module | Version | Bicep AVM Module | Version |
|---------|---------------------|---------|------------------|---------|
| Virtual Network | `Azure/avm-res-network-virtualnetwork/azurerm` | 0.7.x | `avm/res/network/virtual-network` | 0.6.x |
| Azure Firewall | `Azure/avm-res-network-azurefirewall/azurerm` | 0.4.x | `avm/res/network/azure-firewall` | 0.5.x |
| App Service Plan | `Azure/avm-res-web-serverfarm/azurerm` | 0.3.x | `avm/res/web/serverfarm` | 0.4.x |
| Key Vault | `Azure/avm-res-keyvault-vault/azurerm` | 0.12.x | `avm/res/key-vault/vault` | 0.11.x |
| SQL Database | `Azure/avm-res-sql-server/azurerm` | 0.8.x | `avm/res/sql/server` | 0.9.x |

**Note:** Versions are examples. Verify actual versions at migration time.

### Testing Checklist

**Terraform:**
- [ ] `terraform fmt -check` passes
- [ ] `terraform validate` passes
- [ ] `tfsec` passes with no high/critical issues
- [ ] `terraform plan` succeeds
- [ ] `terraform apply` succeeds
- [ ] All outputs populated correctly
- [ ] Resources created in correct resource groups
- [ ] Tags applied correctly
- [ ] Diagnostics sending logs
- [ ] Private endpoints resolvable
- [ ] Sample app deployed and accessible

**Bicep:**
- [ ] `az bicep build` succeeds
- [ ] Bicep linter passes
- [ ] `az deployment sub create --what-if` shows expected changes
- [ ] `az stack sub create` succeeds
- [ ] All outputs populated correctly
- [ ] Resources created in correct resource groups
- [ ] Tags applied correctly
- [ ] Diagnostics sending logs
- [ ] Private endpoints resolvable
- [ ] Sample app deployed and accessible

---

## Changelog

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2024-XX-XX | 1.0 | Initial PRD | Morpheus |

---

## Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Lead/Architect | Morpheus | | |
| Product Owner | Jared Holgate | | |
| Tech Lead (Terraform) | TBD | | |
| Tech Lead (Bicep) | TBD | | |
| DevOps Lead | TBD | | |

---

*End of PRD*
