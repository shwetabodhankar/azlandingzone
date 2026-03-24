# Project Context

- **Owner:** Jared Holgate
- **Project:** Refactoring the App Service Landing Zone Accelerator to leverage Azure Verified Modules (AVM) for Terraform and Bicep, plus CI/CD bootstrapping with OIDC
- **Stack:** Terraform, Bicep, Azure (App Service, Front Door, Firewall, VNet, Key Vault, SQL, Redis, and more), GitHub Actions, Azure DevOps
- **Repo:** appservice-landing-zone-accelerator
- **Key reference repos:** Azure-Samples/azure-devops-terraform-oidc-ci-cd, Azure-Samples/github-terraform-oidc-ci-cd
- **Created:** 2026-03-24

## Repo Structure

- `scenarios/secure-baseline-multitenant/bicep/` — Bicep implementation with reusable modules
- `scenarios/shared/bicep/` — Shared Bicep modules (network, app-service, databases, etc.)
- `.github/workflows/scenario1.bicep.yml` — Bicep deployment workflow

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2026-03-24: Team Assembly & PRD Complete

Team hired: Morpheus (Lead), Trinity (Terraform), Tank (Bicep), Switch (DevOps), Niobe (Docs/QA).

**Morpheus completed comprehensive PRD** (docs/PRD.md):
- 3 workstreams: Terraform AVM (6 weeks), Bicep AVM (5 weeks), CI/CD Bootstrap (2 weeks)
- 16 Terraform + 24 Bicep module mappings
- 10 architectural decisions documented
- Risk assessment and phased execution plan

**Tank's Responsibilities:** Migrate 24 Bicep modules to AVM equivalents across 5 weeks.
**Key AVM Modules:** avm-res-network-virtualnetwork, avm-res-network-azurefirewall, avm-res-web-site, avm-res-keyvault-vault, avm-res-sql-server, avm-res-cache-redis, avm-res-cdn-profile.
**Pattern Modules:** avm/ptn/network/hub-networking, avm/ptn/app-service-lza/hosting-environment.

**Decisions Affecting Bicep Work:**
- AVM-First Strategy: Replace shared modules, keep scenario-specific wrappers
- Keep Scenario-Specific Wrappers: Refactor to use AVM internally
- Bicep Second: Start after Terraform foundations (learning from Terraform phase)
- Pin AVM Versions: Use specific version constraints
- 7-Phase Rollout: Foundation → Security → App Platform → Data → AI → Compute → Integration

See .squad/decisions.md for full decision log.
