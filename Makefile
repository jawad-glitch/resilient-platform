CLUSTERS := region-a region-b
LB       := global-lb
ARGOCD_CHART := 10.9.5

.PHONY: up down status lb-reload bootstrap apps

up:
	@for c in $(CLUSTERS); do \
	  kind get clusters | grep -qx $$c || kind create cluster --config infra/kind/$$c.yaml; \
	done
	@docker rm -f $(LB) >/dev/null 2>&1 || true
	@docker run -d --name $(LB) --network kind -p 8080:8080 -p 8404:8404 \
	  -v $(CURDIR)/infra/lb/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro haproxy:3.0
	@echo "Up. LB: http://localhost:8080  stats: http://localhost:8404"

down:
	@docker rm -f $(LB) >/dev/null 2>&1 || true
	@for c in $(CLUSTERS); do kind delete cluster --name $$c; done

status:
	@kind get clusters
	@for c in $(CLUSTERS); do echo "== $$c"; kubectl --context kind-$$c get nodes; done
	@docker ps --filter name=$(LB)

lb-reload:
	@docker kill -s HUP $(LB)

bootstrap:
	@helm repo add argo https://argoproj.github.io/argo-helm >/dev/null 2>&1 || true
	@for c in $(CLUSTERS); do \
	  helm upgrade --install argocd argo/argo-cd --version $(ARGOCD_CHART) \
	    --kube-context kind-$$c -n argocd --create-namespace \
	    -f gitops/bootstrap/argocd-values.yaml --wait; \
	  kubectl --context kind-$$c apply -f gitops/bootstrap/root-$$c.yaml; \
	done

apps:
	@for c in $(CLUSTERS); do echo "== $$c"; kubectl --context kind-$$c -n argocd get applications; done
