# ADR 0005: HAProxy on the region-b VM as the global load balancer
## Status
Accepted (known weakness)
## Context
Failover needs something that health-checks region-a and redirects traffic. Cloud DNS failover is not available in this lab.
## Decision
HAProxy on the region-b VM, region-a as primary, region-b as backup, checking /healthz every 1 s (fall 2, rise 2).
## Alternatives rejected
- Dedicated load balancer VM: the right design, skipped to finish the project.
- DNS failover: closest to production, but TTLs dominate recovery time.
## Consequences
The load balancer shares a failure domain with the standby, so losing region-b is a total outage. Measured failover on region-a loss: about 1.4 s (see docs/drills).
