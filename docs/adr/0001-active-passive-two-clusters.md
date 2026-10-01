# ADR 0001: Active-passive across two clusters
## Status
Accepted (the kind layout was later replaced, see ADR 0003)
## Context
The goal is a measurable failover story. Multi-writer data would obscure it.
## Decision
Region-a serves traffic; region-b is a warm standby. The load balancer fails over when region-a's health checks fail.
## Alternatives rejected
- Active-active: needs conflict handling or a globally consistent database.
- Cold standby: recovery time would be dominated by provisioning.
## Consequences
Standby capacity is paid for while idle.
