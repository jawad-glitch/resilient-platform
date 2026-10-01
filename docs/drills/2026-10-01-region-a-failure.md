# Drill: kill region-a, measure failover (2026-10-01, about 22:41 UTC)

## What was tested
A probe hit HAProxy about every 0.2 s (curl, 1 s timeout) while `k3s-killall.sh` ran on region-a. That stops k3s and every container on it. HAProxy runs on the region-b VM.

## Result
| Metric | Value |
|---|---|
| Last good response from region-a | 22:41:36.09 UTC |
| First good response from region-b | 22:41:37.52 UTC |
| Client-observed outage | about 1.4 s |
| Failed requests | 1 (curl timeout, HTTP 000) |
| Version served by region-b | v2, identical to region-a |
| RPO | n/a: the app is stateless, no data is replicated |
| Failback | Not timed. After `systemctl start k3s`, region-a's ArgoCD apps returned to Synced/Healthy with no manual steps |

Raw probe lines around the failover:
1790894496.093752594 200 version=v2 region=region-a
1790894496.308222995 000
1790894497.523777450 200 version=v2 region=region-b
1790894497.737595697 200 version=v2 region=region-b

The 000 request hung for its full 1 s timeout, which is most of the outage.

## How the number was computed
Gap between the last response from region-a and the first from region-b. A first-fail-to-last-fail calculation reported 0.2 s, which undercounts: only one sample failed, and it hung for a full second.

## Limits of this result
- One run, not a distribution. The kill timestamp was not recorded.
- Both VMs share one Oracle region, availability domain and subnet: no cross-region latency, and HAProxy stands in for DNS failover, which would add TTL delay.
- HAProxy lives on region-b, so killing region-b would take the load balancer down too.
- The probe ran on the load balancer host, so there is no client network path.

## Next
Record the kill time, run at least 5 times, move HAProxy to its own VM, stop the whole VM from the OCI console, and add Postgres replication so RPO becomes measurable.
