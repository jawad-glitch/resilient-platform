#!/usr/bin/env bash
set -u
for t in docker kubectl helm kind k9s terraform tflint argocd cosign trivy gh go pre-commit jq git; do
  if command -v "$t" >/dev/null; then printf "OK   %s\n" "$t"; else printf "MISS %s\n" "$t"; fi
done
docker info >/dev/null 2>&1 && echo "OK   docker daemon" || echo "MISS docker daemon"
echo "RAM: $(free -h | awk '/Mem:/ {print $2}')  CPUs: $(nproc)"
