# ADR 0003: k3s on two separate VMs instead of kind on one host
## Status
Accepted (supersedes the kind layout in ADR 0001)
## Context
Local kind clusters shared one machine, disk and network, so "killing a region" was only simulated. The laptop also ran out of disk.
## Decision
Each region is a separate Oracle Cloud VM (1 OCPU / 6 GB, Arm) running single-node k3s with distinct pod and service CIDRs, in one shared VCN.
## Alternatives rejected
- kind on one host: shared failure domain, so the drill proves less.
- Managed Kubernetes: more realistic, but not free at this scale.
- One bigger VM with two clusters: the free Arm capacity was not available.
## Consequences
Stopping a VM is a real outage. Each control plane is single-node, so there is no HA inside a region; the region is the unit of failure being tested.
