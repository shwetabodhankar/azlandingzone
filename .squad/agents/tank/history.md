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

### 2026-03-24: Team Assembly & PRD Complete → Pattern Module Strategy Update

Team hired: Morpheus (Lead), Trinity (Terraform), Tank (Bicep), Switch (DevOps), Niobe (Docs/QA).

**Morpheus completed comprehensive PRD** (docs/PRD.md v1.0):
- 3 workstreams: Terraform AVM (6 weeks), Bicep AVM (5 weeks), CI/CD Bootstrap (2 weeks)
- 16 Terraform + 24 Bicep module mappings
- 10 architectural decisions documented
- Risk assessment and phased execution plan

**PATTERN MODULE DISCOVERY (v2.0):** AVM now offers `br/public:avm/ptn/app-service-lza/hosting-environment` (v0.2) pattern module on Bicep Public Registry that consolidates 22 Bicep custom modules into a single module call. This fundamentally changes Tank's work:

**Tank's Updated Responsibilities:**
- Primary: Deploy AVM pattern module (`br/public:avm/ptn/app-service-lza/hosting-environment`) in place of 24 custom modules
- Supplemental: Individual AVM resource modules for: Firewall, SQL, Redis, OpenAI, App Config
- Full module mapping retained as reference/fallback
- Pattern module maturity consideration (v0.2 is relatively new)

**Updated Timeline & Phases:**
- 5 weeks reduced to ~4 weeks (pattern module reduces module-by-module work)
- 7-phase rollout reduced to 5 phases (pattern module validates as complete unit)

**Decisions Affecting Bicep Work:**
- Decision 1 (AVM-First) — Updated: Now pattern-module-first strategy
- Decision 4 (Keep Scenario Wrappers) — Updated: Most wrappers become unnecessary; pattern module handles composition
- Decision 11 (NEW): Adopt AVM Pattern Modules as Primary Strategy
- State Migration: Deployment Stack addresses change; pattern module scope includes entire LZA
- See .squad/decisions.md for full decision log.

