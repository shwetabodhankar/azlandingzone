# Squad Decisions

## Active Decisions

### Decision 1: AVM-First Strategy
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** Deciding how to handle custom modules vs. AVM modules

**Decision:** Adopt "AVM-First" strategy — replace all custom modules with AVM equivalents where available. Keep scenario-specific wrappers for composition logic.

**Rationale:**
- Microsoft maintains AVM modules, reducing our maintenance burden
- AVM modules are Well-Architected Framework aligned
- Consistent interfaces across modules improve developer experience
- Access to continuous updates for new Azure features

**Implications:**
- All 16 Terraform custom modules will be replaced
- All Bicep shared modules will be replaced
- Scenario-specific wrappers (`scenarios/secure-baseline-multitenant/bicep/modules/`) will be kept but refactored
- State migration required for existing deployments

---

### Decision 2: Terraform-First Migration Approach
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** Choosing whether to migrate Terraform or Bicep first

**Decision:** Migrate Terraform implementation first, then Bicep. Both can run in parallel with separate teams.

**Rationale:**
- Terraform has more complex module structure (16 modules with child modules)
- Terraform state migration is more intricate than Bicep Deployment Stacks
- Learning from Terraform migration can inform Bicep approach
- Parallelization possible with two-team setup

**Implications:**
- Terraform migration: Weeks 3-8 (6 weeks)
- Bicep migration: Weeks 9-13 (5 weeks)
- Can start in parallel with dedicated resources

---

### Decision 3: CI/CD Bootstrap Integration
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** How to integrate OIDC bootstrap into the repo

**Decision:** Add `bootstrap/` directory at root with GitHub Actions and Azure DevOps OIDC bootstrap solutions, adapted from Microsoft reference repos.

**Rationale:**
- OIDC is modern security standard (no secrets in repos)
- Reference implementations are proven and Microsoft-supported
- Both GitHub Actions and Azure DevOps users should be supported
- Bootstrap should be optional (not forced on existing users)

**Implications:**
- New directory: `bootstrap/github-actions/` and `bootstrap/azure-devops/`
- Existing workflows updated to use OIDC (but old method documented)
- State management moves to bootstrap-created storage account
- Multi-environment support (dev/test/prod) added

---

### Decision 4: Keep Scenario-Specific Wrappers
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** Should scenario-specific modules be kept or removed?

**Decision:** Keep scenario-specific wrapper modules (e.g., `app-service.module.bicep`, `keyvault.module.bicep`) but refactor them to use AVM modules internally.

**Rationale:**
- Wrappers provide solution-specific composition (private endpoint + DNS + RBAC)
- They encapsulate Landing Zone Accelerator patterns
- Removing them would increase complexity in main orchestration
- They add value beyond what AVM provides

**Implications:**
- Bicep modules in `scenarios/secure-baseline-multitenant/bicep/modules/` are refactored, not removed
- Wrappers become thin layers over AVM modules
- Reduces custom code while preserving solution patterns

---

### Decision 5: Pin AVM Module Versions
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** Should we use latest AVM versions or pin to specific versions?

**Decision:** Pin all AVM module versions in production code. Document version update process.

**Rationale:**
- Prevents unexpected breaking changes
- Allows controlled testing of new versions
- Aligns with infrastructure-as-code best practices
- Provides stability for users

**Implications:**
- All module references include version constraint (e.g., `version = "0.7.1"`)
- Version update process documented
- Testing required before version bumps
- Version matrix maintained in PRD appendix

---

### Decision 6: State Migration Strategy
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** How to handle Terraform state when module addresses change?

**Decision:** Provide state migration scripts using `terraform state mv`. Document manual migration steps. Offer "blue/green" approach for complex scenarios.

**Rationale:**
- Resource addresses change when switching from custom modules to AVM
- Users need clear migration path
- Automation reduces errors
- Blue/green approach provides safety net

**Implications:**
- Migration scripts created for each module replacement
- Documentation includes step-by-step manual process
- Testing required in non-production first
- Rollback plan documented

---

### Decision 7: Non-Goals — Sample App Unchanged
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** Should the ASP.NET Core sample app be updated?

**Decision:** No changes to sample application. It remains as-is.

**Rationale:**
- Sample app demonstrates workload deployment, not infrastructure
- Changes would expand scope unnecessarily
- App should work with new infrastructure (validation point)
- Focus should be on IaC refactoring

**Implications:**
- `sampleapp/` directory untouched
- Deployment of sample app is validation step
- If sample app breaks, infrastructure migration has failed

---

### Decision 8: Phased Rollout (7 Phases per Workstream)
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** How to structure the migration work?

**Decision:** Use 7-phase approach for both Terraform and Bicep:
1. Foundation (Networking & Observability)
2. Security & Connectivity
3. App Platform
4. Data & State
5. AI & Front Door
6. Compute & DevOps
7. Integration & Testing

**Rationale:**
- Builds from foundation up (networking first)
- Each phase is independently testable
- Reduces risk of "big bang" migration
- Allows incremental progress tracking

**Implications:**
- Migration takes 6-8 weeks per language
- Each phase must pass validation before next starts
- Integration testing only after all phases complete
- Git branch strategy needed for work-in-progress

---

### Decision 9: No Platform Lock-In (GitHub + Azure DevOps)
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** Should we standardize on one CI/CD platform?

**Decision:** Support both GitHub Actions and Azure DevOps with parity. Users choose their platform.

**Rationale:**
- Enterprise customers use both platforms
- Microsoft supports both (reference implementations exist)
- Platform choice is organizational, not technical
- Flexibility increases adoption

**Implications:**
- Bootstrap solutions for both platforms
- Workflows/pipelines updated for both
- Documentation covers both approaches
- No platform is "second-class"

---

### Decision 10: Documentation Over Code Comments
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** How to document the migration and new patterns?

**Decision:** Create comprehensive external documentation (migration guide, bootstrap runbooks, troubleshooting) rather than relying on inline comments.

**Rationale:**
- AVM modules are self-documenting via registry
- Inline comments create maintenance burden
- External docs are more discoverable
- Aligns with Landing Zone Accelerator's existing doc structure

**Implications:**
- New files: `docs/migration-guide.md`, `bootstrap/README.md`, troubleshooting guides
- Code comments minimal (only for complex logic)
- README files updated
- Architecture docs updated to reference AVM

---

### Decision 11: Adopt AVM Pattern Modules as Primary Migration Strategy
**Date:** 2026-03-24  
**Made by:** Morpheus  
**Status:** Active (approved by team)
**Context:** Discovery that AVM pattern modules exist for the App Service Landing Zone, fundamentally changing migration approach from "replace 40+ custom modules one-by-one" to "one pattern module call + supplemental resource modules."

**Decision:** Use AVM pattern modules as the primary building block for App Service Landing Zone migration, supplemented by individual resource modules only where pattern module coverage is insufficient.

**Rationale:**
- **Massive simplification:** One pattern module call replaces 12 Terraform and 22 Bicep custom modules
- **Reduced maintenance:** Microsoft maintains the pattern module, eliminating custom composition burden
- **Faster delivery:** Single module to configure, test, and validate vs. 40+ individual modules
- **Better alignment:** Pattern module IS the App Service LZA reference architecture (packaged as AVM)
- **Continuous updates:** Pattern module receives architectural improvements from Microsoft
- **Repo focus shift:** Project becomes configuration + supplements + documentation (not IaC authoring)

**Implications:**
- **Updates Decision 1 (AVM-First):** Strategy evolves from "replace with resource modules" to "replace with pattern module + supplementals"
- **Updates Decision 4 (Keep Scenario Wrappers):** Most wrappers become unnecessary; pattern module handles composition
- **Updates Decision 8 (Phased Rollout):** Phases reduced from 7 to 5; pattern module validates as complete unit
- **Timeline:** Reduced from ~18 weeks to ~14 weeks
- **Scope:** Terraform modules 16→1 primary; Bicep modules 24→1 primary; supplemental resource modules (Firewall, SQL, Redis, OpenAI, App Config, VM) still needed
- **Module references:**
  - **Terraform:** `Azure/avm-ptn-app-service-landing-zone/azure` (registry.terraform.io)
  - **Bicep:** `br/public:avm/ptn/app-service-lza/hosting-environment` (v0.2)

**New Risks:**
- Pattern module maturity (v0.2 for Bicep is relatively new)
- State migration complexity (all resource addresses change at once vs. incrementally)
- Must validate pattern module covers all LZA-specific requirements

**Affected Files:**
- `docs/PRD.md` — Updated to v2.0 with pattern module strategy
- `scenarios/shared/terraform-modules/` — Will be removed (replaced by pattern module + supplements)
- `scenarios/shared/bicep/` — Will be removed (replaced by pattern module + supplements)

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction
