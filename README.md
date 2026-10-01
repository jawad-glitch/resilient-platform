# resilient-platform

A small two-region platform that ships releases safely and survives losing a region, with measured evidence. The app is deliberately boring; the point is how it is deployed and what happens when things break.

            client
              |
      HAProxy :8080 (on region-b VM)
  health check /healthz every 1 s
     | primary            | backup
+----v--------+    +------v---------+
| region-a VM |    | region-b VM |
| k3s + ArgoCD |   | k3s + ArgoCD |
| Rollouts + app | | Rollouts + app |
+-------^--------+ +------^---------+
+----- GitHub repo ---+ (single source of truth)

## What was demonstrated
| Claim | Evidence |
|---|---|
| A bad release is stopped automatically | v3 with 50% errors: analysis Failed, canary scaled to 0, users stayed on stable (ADR 0004) |
| Losing a region costs about 1.4 s | Drill: 1 failed request, region-b served v2 (docs/drills/) |
| Both regions deploy from Git | Independent ArgoCD per cluster, app-of-apps, same version served by both |

RPO is n/a because the app is stateless.

## Failure modes
| Failure | Behaviour | Tested? |
|---|---|---|
| region-a down | HAProxy fails over to region-b | Yes |
| Bad release | Analysis aborts, stable keeps serving | Yes |
| region-b (LB host) down | Total outage, known weakness (ADR 0005) | No |
| GitHub unreachable | Clusters keep their last synced state; no new deploys | Reasoned, not tested |
| Manual drift | ArgoCD selfHeal is enabled | Configured, not drill-tested |

## Decisions
See docs/adr/: active-passive (0001), ArgoCD per cluster (0002), k3s on separate VMs (0003), canary analysis (0004), HAProxy placement (0005).

## Honest limits
- Two VMs in one Oracle region and subnet, not two cloud regions.
- One drill run; the kill timestamp was not recorded.
- Synthetic-traffic analysis, not real-user metrics.

## Cut for time (next steps)
Postgres replication (to make RPO real), Prometheus and SLO burn-rate analysis, Kyverno and cosign image signing, a dedicated load balancer VM, Terraform for the VMs, repeated drills.

## Reproduce
Cost: $0 on Oracle Always Free (two A1 VMs, 1 OCPU / 6 GB each).
1. Create two Ubuntu 24.04 Arm VMs in one VCN; allow 10.0.0.0/16 (all protocols) in the security list and in each VM's iptables.
2. On each VM install k3s with `--disable traefik --disable servicelb` and distinct CIDRs (10.10/10.11 and 10.20/10.21).
3. Install ArgoCD 10.9.5 with Helm using gitops/bootstrap/argocd-values.yaml, then apply gitops/bootstrap/root-<region>.yaml.
4. Install HAProxy on one VM with infra/lb/haproxy.cfg.
These steps were done by hand to build this lab; they have not been scripted or re-run from scratch.
