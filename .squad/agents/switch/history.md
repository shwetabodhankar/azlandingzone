# Project Context

- **Owner:** Jared Holgate
- **Project:** Refactoring the App Service Landing Zone Accelerator to leverage Azure Verified Modules (AVM) for Terraform and Bicep, plus CI/CD bootstrapping with OIDC
- **Stack:** Terraform, Bicep, Azure (App Service, Front Door, Firewall, VNet, Key Vault, SQL, Redis, and more), GitHub Actions, Azure DevOps
- **Repo:** appservice-landing-zone-accelerator
- **Key reference repos:** Azure-Samples/azure-devops-terraform-oidc-ci-cd, Azure-Samples/github-terraform-oidc-ci-cd
- **Created:** 2026-03-24

## Repo Structure

- `.github/workflows/` — GitHub Actions deployment workflows (Terraform + Bicep)
- `.github/actions/templates/` — Reusable composite actions (tfValidatePlan, tfApply)
- `.github/workflows/platform.terraform-dependencies.yml` — Terraform state prerequisites

## Key Reference Repos

- **azure-devops-terraform-oidc-ci-cd:** Bootstrap Terraform CI/CD with OIDC for Azure DevOps
- **github-terraform-oidc-ci-cd:** Bootstrap Terraform CI/CD with OIDC for GitHub Actions

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2026-03-24: Team Assembly & PRD Complete → Pattern Module Strategy Update

Team hired: Morpheus (Lead), Trinity (Terraform), Tank (Bicep), Switch (DevOps), Niobe (Docs/QA).

**Morpheus completed comprehensive PRD** (docs/PRD.md v1.0):
- 3 workstreams: Terraform AVM (6 weeks), Bicep AVM (5 weeks), CI/CD Bootstrap (2 weeks)
- 16 Terraform + 24 Bicep module mappings
- 10 architectural decisions documented
- Risk assessment and phased execution plan

**PATTERN MODULE DISCOVERY (v2.0):** AVM pattern modules for App Service LZA discovered; strategy updated. **Impact on Switch's work:** Timeline compressed (~18 weeks → ~14 weeks); Trinity/Tank phase times reduced. CI/CD bootstrap work unchanged.

**Switch's Responsibilities (UNCHANGED):**
- Integrate CI/CD bootstrap with OIDC for GitHub Actions and Azure DevOps
- New `bootstrap/` directory with both platforms, no secrets in repos, multi-environment support (dev/test/prod)
- Reference implementations: azure-devops-terraform-oidc-ci-cd, github-terraform-oidc-ci-cd (Microsoft-official)

**Decisions Affecting CI/CD Work:**
- Decision 3: CI/CD Bootstrap Integration — Core responsibility (GitHub Actions + Azure DevOps OIDC)
- Decision 9: No Platform Lock-In — Unchanged (parity across GitHub Actions and Azure DevOps)
- Decision 11 (NEW): Adopt AVM Pattern Modules — No impact on bootstrap scope; Terraform/Bicep phases reduce but bootstrap integration timeline stable
- Decision 15 (NEW): CI/CD Consolidation (OIDC-Only) — **Primary impact:** Remove all legacy CI/CD workflows; OIDC is ONLY auth method; no password-based examples; no PAT/SPN credentials
- See .squad/decisions.md for full decision log.

**Updated Switch Responsibilities:**
- Primary: OIDC bootstrap for GitHub Actions and Azure DevOps (unchanged scope, cleaner requirements)
- Remove: All legacy/password-based workflow examples
- Add: Clear OIDC-only guidance; no credential alternatives documented
- Simplify: Single auth method (OIDC) reduces bootstrap complexity; Decision 14 (no Portal/ARM) means CI/CD is ONLY deployment method

**Note:** Trinity/Tank will update state migration scripts and module configuration for pattern module approach; Switch coordinates bootstrap integration across shortened timeline with simplified auth model (OIDC-only).

