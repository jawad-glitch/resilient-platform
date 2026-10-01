# ADR 0004: Canary releases judged by a Job-based error-rate check
## Status
Accepted
## Context
A plain Deployment only checks that pods start. The sample app's /healthz always returns 200, so a release that errors on real requests looks healthy.
## Decision
Argo Rollouts canary (20% then 60% by pod count) with an AnalysisTemplate that runs a Job sending 50 requests to the canary Service and failing above 10% errors, 3 measurements, failureLimit 0. A failure aborts the rollout.
## Evidence
A release with ERROR_RATE=0.5 was aborted: the analysis run ended Failed, the canary ReplicaSet was scaled to 0, and requests during the window were still served by the stable version.
## Alternatives rejected
- Plain rolling update: cannot see request errors.
- Prometheus-metric analysis: the better design, deferred (no Prometheus yet).
- Exact traffic splitting via ingress or mesh: Traefik was disabled to save RAM.
## Consequences
The check uses synthetic traffic, not real users. The 20% split is approximate because it depends on replica count. The image tag is duplicated in the AnalysisTemplate, so a version bump needs two edits.
