# Project Context

- **Owner:** Jared Holgate
- **Project:** Refactoring the App Service Landing Zone Accelerator to leverage Azure Verified Modules (AVM) for Terraform and Bicep, plus CI/CD bootstrapping with OIDC
- **Stack:** Terraform, Bicep, Azure (App Service, Front Door, Firewall, VNet, Key Vault, SQL, Redis, and more), GitHub Actions, Azure DevOps
- **Repo:** appservice-landing-zone-accelerator
- **Key reference repos:** Azure-Samples/azure-devops-terraform-oidc-ci-cd, Azure-Samples/github-terraform-oidc-ci-cd
- **Created:** 2026-03-24

## Repo Structure

- `scenarios/secure-baseline-multitenant/terraform/` — Terraform implementation (hub/spoke split)
- `scenarios/shared/terraform-modules/` — Shared Terraform modules (front-door, firewall, app-service, sql, redis, etc.)
- `.github/workflows/scenario1.terraform.yml` — Terraform deployment workflow
- `.github/actions/templates/` — Reusable Terraform CI/CD actions (validate/plan, apply)

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2026-03-24: Team Assembly & PRD Complete

Team hired: Morpheus (Lead), Trinity (Terraform), Tank (Bicep), Switch (DevOps), Niobe (Docs/QA).

**Morpheus completed comprehensive PRD** (docs/PRD.md):
- 3 workstreams: Terraform AVM (6 weeks), Bicep AVM (5 weeks), CI/CD Bootstrap (2 weeks)
- 16 Terraform + 24 Bicep module mappings
- 10 architectural decisions documented
- Risk assessment and phased execution plan

**Trinity's Responsibilities:** Migrate 16 Terraform modules to AVM equivalents across 6 weeks.
**Key AVM Modules:** avm-res-network-virtualnetwork, avm-res-network-azurefirewall, avm-res-web-site, avm-res-keyvault-vault, avm-res-sql-server, avm-res-cache-redis, avm-res-cdn-profile, avm-res-compute-virtualmachine.

**Decisions Affecting Terraform Work:**
- AVM-First Strategy: Replace all 16 custom modules
- Terraform-First Approach: Start before Bicep (learning cascade)
- Pin AVM Versions: Use specific version constraints
- State Migration: Use terraform state mv with blue/green safety net
- 7-Phase Rollout: Foundation → Security → App Platform → Data → AI → Compute → Integration

See .squad/decisions.md for full decision log.
