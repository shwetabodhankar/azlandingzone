---
title: "CI/CD Bootstrap"
weight: 40
geekdocCollapseSection: true
---

# CI/CD Bootstrap

The bootstrap process automates the creation of everything you need for secure, production-ready CI/CD with **OIDC (OpenID Connect)** authentication — no secrets stored in your repos.

## What gets created

| Resource | Description |
|----------|-------------|
| **6 Managed Identities** | Separate plan and apply identities per environment (dev, test, prod) — least privilege by design |
| **OIDC Federation** | Workload Identity Federation credentials linking your CI/CD platform to Azure |
| **State Storage** | Azure Storage Account with per-environment containers for Terraform state files |
| **Environments** | CI/CD environments (dev/test/prod) with approval gates and concurrent deployment locks |
| **Pipelines** | Ready-to-run CI/CD workflows with Terraform plan, apply, and PR validation |

## Choose your CI/CD platform

Both options provide identical security posture and deployment capabilities. Choose based on your organization's platform:

| | GitHub Actions | Azure DevOps |
|---|---|---|
| **Guide** | [GitHub Actions →]({{< relref "bootstrap/github-actions" >}}) | [Azure DevOps →]({{< relref "bootstrap/azure-devops" >}}) |
| **Source Repo** | [Azure-Samples/github-terraform-oidc-ci-cd](https://github.com/Azure-Samples/github-terraform-oidc-ci-cd) | [Azure-Samples/azure-devops-terraform-oidc-ci-cd](https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd) |
| **Auth Method** | GitHub OIDC token exchange | Azure DevOps Workload Identity Federation |
| **Pipeline Governance** | `job_workflow_ref` claim on federated credentials | Required template check on service connections |
| **Concurrency Control** | `concurrency` setting (queue on lock) | `lockBehavior: sequential` on environments |
| **Approvals** | GitHub environment protection rules | Service connection approval gates |

## How bootstrap connects to infrastructure

```text
┌─────────────────────────────────────────────────────────┐
│  1. BOOTSTRAP (run once)                                │
│                                                         │
│  Clone bootstrap repo → configure tfvars → apply        │
│  Creates: identities, state storage, pipelines, envs    │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  2. DEPLOY INFRASTRUCTURE (via CI/CD)                   │
│                                                         │
│  infra/terraform/  or  infra/bicep/                     │
│  Uses bootstrap-created identities + state storage      │
│  Pipelines run: plan → approve → apply per environment  │
└─────────────────────────────────────────────────────────┘
```

### Integration points

- **State backend** — Configure your Terraform backend to use the bootstrap-created storage account and containers
- **OIDC authentication** — CI/CD workflows authenticate to Azure using the bootstrap-created managed identities (no secrets)
- **Environment promotion** — Deployments flow through dev → test → prod with approval gates at each stage

## Prerequisites

- [Terraform CLI](https://www.terraform.io/downloads) installed locally
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed locally
- An [Azure Subscription](https://azure.microsoft.com/pricing/purchase-options/azure-account) with permissions to create resources
- Owner or User Access Administrator role on the target subscription (to assign RBAC)

## Security model

The bootstrap implements a **zero-secrets** security model:

- **No passwords or service principal secrets** stored in CI/CD
- **OIDC federation** — short-lived tokens exchanged at runtime
- **Separate plan/apply identities** — plan has read-only access, apply has contributor access
- **Scoped credentials** — federated credentials are scoped to specific repos and branches
- **Environment gates** — production deployments require explicit approval
