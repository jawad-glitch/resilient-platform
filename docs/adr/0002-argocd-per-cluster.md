# ADR 0002: One ArgoCD per cluster, app-of-apps
## Status
Accepted
## Context
Each region must reconcile itself during an outage of the other.
## Decision
Each cluster runs its own ArgoCD with a root Application pointing at its overlay. Shared components live in gitops/platform.
## Alternatives rejected
- A central hub ArgoCD: a single point of failure for DR.
- Push-based CI deploys: no drift detection or self-heal.
## Consequences
Two ArgoCD instances to maintain. Changes need GitHub, but running clusters keep their last synced state if Git is down.
