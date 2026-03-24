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

### 2026-03-24: Team Assembly & PRD Complete → Pattern Module Strategy Update

Team hired: Morpheus (Lead), Trinity (Terraform), Tank (Bicep), Switch (DevOps), Niobe (Docs/QA).

**Morpheus completed comprehensive PRD** (docs/PRD.md v1.0):
- 3 workstreams: Terraform AVM (6 weeks), Bicep AVM (5 weeks), CI/CD Bootstrap (2 weeks)
- 16 Terraform + 24 Bicep module mappings
- 10 architectural decisions documented
- Risk assessment and phased execution plan

**PATTERN MODULE DISCOVERY (v2.0):** AVM pattern modules for App Service LZA discovered; strategy updated to pattern-module-first approach. This significantly impacts Niobe's documentation scope.

**Niobe's Updated Responsibilities:**
- Migration documentation: Refocus from "40+ module replacement guide" to "pattern module deployment + supplemental modules"
- Bootstrap runbooks: Unchanged (still needed for GitHub Actions + Azure DevOps OIDC)
- Troubleshooting guides: New focus on pattern module edge cases, state migration (pattern module addresses change)
- Updated README files: Emphasize pattern module approach
- Architecture docs: Reference pattern module as primary building block
- Testing/QA: Validate pattern module covers all LZA requirements; validate zero regression with new approach

**Updated Scope:**
- Timeline compressed: ~18 weeks → ~14 weeks (shorter Terraform/Bicep phases)
- Phase reduction: 7 → 5 per workstream (pattern module validates as unit)
- Documentation refocus: Fewer custom module docs needed; more pattern module configuration + troubleshooting

**Decisions Affecting Documentation/QA Work:**
- Decision 10: Documentation Over Code Comments — Unchanged (external docs prioritized)
- Decision 11 (NEW): Adopt AVM Pattern Modules — Major scope shift: migration guide focuses on pattern module + risk mitigation (new pattern module, state migration complexity)
- State Migration: Documentation must cover pattern module state migration (address changes differ from incremental module approach)
- See .squad/decisions.md for full decision log.

**Testing Strategy Remains:**
- Validate zero functionality regression
- Ensure all scenarios deploy successfully with pattern module
- Test state migration processes (now single-module migration vs. incremental)

