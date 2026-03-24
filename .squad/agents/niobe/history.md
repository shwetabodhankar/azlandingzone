# Project Context

- **Owner:** Jared Holgate
- **Project:** Refactoring the App Service Landing Zone Accelerator to leverage Azure Verified Modules (AVM) for Terraform and Bicep, plus CI/CD bootstrapping with OIDC
- **Stack:** Terraform, Bicep, Azure (App Service, Front Door, Firewall, VNet, Key Vault, SQL, Redis, and more), GitHub Actions, Azure DevOps
- **Repo:** appservice-landing-zone-accelerator
- **Key reference repos:** Azure-Samples/azure-devops-terraform-oidc-ci-cd, Azure-Samples/github-terraform-oidc-ci-cd
- **Created:** 2026-03-24

## Repo Structure

- `.psrule/` — PSRule configuration for Azure best practices
- `.tfsec/` — tfsec security scanning configuration
- `.pre-commit-config.yaml` — Pre-commit hook configuration
- `scenarios/secure-baseline-multitenant/terraform/` — Terraform to validate
- `scenarios/secure-baseline-multitenant/bicep/` — Bicep to validate

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2026-03-24: Team Assembly & PRD Complete

Team hired: Morpheus (Lead), Trinity (Terraform), Tank (Bicep), Switch (DevOps), Niobe (Docs/QA).

**Morpheus completed comprehensive PRD** (docs/PRD.md):
- 3 workstreams: Terraform AVM (6 weeks), Bicep AVM (5 weeks), CI/CD Bootstrap (2 weeks)
- 16 Terraform + 24 Bicep module mappings
- 10 architectural decisions documented
- Risk assessment and phased execution plan

**Niobe's Responsibilities:** Migration documentation, testing, QA.
**Key Deliverables:** Migration guide, bootstrap runbooks, troubleshooting guides, updated README files, architecture docs.
**Documentation Strategy:** Comprehensive external docs prioritized over code comments (AVM modules are self-documenting).
**Testing Focus:** Validate zero functionality regression, ensure all scenarios deploy successfully with new AVM modules, test state migration processes.

**Decisions Affecting Documentation/QA Work:**
- Documentation Over Code Comments: Create comprehensive external docs, minimal inline comments
- Non-Goals — Sample App Unchanged: App deployment is validation point (if it breaks, infrastructure migration failed)
- State Migration Strategy: Document manual steps, automation via terraform state mv, blue/green approach
- 7-Phase Rollout: Each phase must pass validation before next starts, integration testing only after all phases
- Success Criteria: Zero regression, all scenarios deploy, CI/CD bootstrap integrated, documentation complete

See .squad/decisions.md for full decision log.
