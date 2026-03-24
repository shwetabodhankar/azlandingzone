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

### 2026-03-24: Team Assembly & PRD Complete

Team hired: Morpheus (Lead), Trinity (Terraform), Tank (Bicep), Switch (DevOps), Niobe (Docs/QA).

**Morpheus completed comprehensive PRD** (docs/PRD.md):
- 3 workstreams: Terraform AVM (6 weeks), Bicep AVM (5 weeks), CI/CD Bootstrap (2 weeks)
- 16 Terraform + 24 Bicep module mappings
- 10 architectural decisions documented
- Risk assessment and phased execution plan

**Switch's Responsibilities:** Integrate CI/CD bootstrap with OIDC for GitHub Actions and Azure DevOps.
**Bootstrap Scope:** New `bootstrap/` directory with both platforms, no secrets in repos, multi-environment support (dev/test/prod).
**Reference Implementations:** azure-devops-terraform-oidc-ci-cd, github-terraform-oidc-ci-cd (both Microsoft-official).

**Decisions Affecting CI/CD Work:**
- CI/CD Bootstrap Integration: Add bootstrap/ directory with both GitHub Actions and Azure DevOps solutions
- No Platform Lock-In: Support both platforms with parity (users choose)
- Bootstrap is optional: Don't force on existing users, document old method
- OIDC Federation: Modern security standard, separate managed identities for plan/apply per environment
- State management moves to bootstrap-created storage account

See .squad/decisions.md for full decision log.
