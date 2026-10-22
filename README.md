# Azure Governance Lab

Identity, RBAC and Policy on Azure, built with the Azure CLI at zero cost.

## What it does
- **01-identity-rbac.sh**: creates a tagged resource group, 2 Entra ID users, 2 groups, and assigns roles to the **groups** (Reader, Contributor) at resource group scope.
- **02-policy.sh**: assigns two built-in policies with a Deny effect: *Allowed locations* (UK South only) and *Require a tag on resources* (`env`).

## Proof
| Test | Result |
|---|---|
| Storage account in `eastus` | Denied by "Allowed locations" |
| Storage account without `env` tag | Denied by "Require a tag on resources" |
| Storage account in `uksouth` with `env=lab` | Succeeded |

See `/evidence`.

## Key concepts demonstrated
- Least privilege: roles assigned to groups, not individual users
- Scope: assignments at resource group level
- Policy as guardrails: Deny effect blocks non-compliant resources at creation
- Everything scripted and repeatable

## AWS equivalent
| Azure | AWS |
|---|---|
| Entra ID groups + RBAC | IAM groups + policies |
| Azure Policy (Deny) | SCPs / IAM permission boundaries / AWS Config |
| Resource group tags | Resource tags + tag policies |

## Cleanup
`az group delete -n rg-governance-lab --yes`
