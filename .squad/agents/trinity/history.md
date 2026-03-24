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

### 2026-03-24: Team Assembly & PRD Complete → Pattern Module Strategy Update

Team hired: Morpheus (Lead), Trinity (Terraform), Tank (Bicep), Switch (DevOps), Niobe (Docs/QA).

**Morpheus completed comprehensive PRD** (docs/PRD.md v1.0):
- 3 workstreams: Terraform AVM (6 weeks), Bicep AVM (5 weeks), CI/CD Bootstrap (2 weeks)
- 16 Terraform + 24 Bicep module mappings
- 10 architectural decisions documented
- Risk assessment and phased execution plan

**PATTERN MODULE DISCOVERY (v2.0):** AVM now offers `Azure/avm-ptn-app-service-landing-zone/azure` pattern module (registry.terraform.io) that consolidates 12 Terraform custom modules into a single module call. This fundamentally changes Trinity's work:

**Trinity's Updated Responsibilities:**
- Primary: Deploy AVM pattern module (`Azure/avm-ptn-app-service-landing-zone/azure`) in place of 16 custom modules
- Supplemental: Individual AVM resource modules for: Firewall, SQL, Redis, OpenAI, App Config, VM (jump host)
- Full module mapping retained as reference/fallback

**Updated Timeline & Phases:**
- 6 weeks reduced to ~5 weeks (pattern module reduces module-by-module work)
- 7-phase rollout reduced to 5 phases (pattern module validates as complete unit)

**Decisions Affecting Terraform Work:**
- Decision 1 (AVM-First) — Updated: Now pattern-module-first strategy
- Decision 11 (NEW): Adopt AVM Pattern Modules as Primary Strategy
- State Migration: `terraform state mv` scripts needed for address changes (pattern module state structure different)
- See .squad/decisions.md for full decision log.

