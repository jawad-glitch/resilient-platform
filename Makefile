
ARGOCD_CHART := ARGOCD_CHART_VERSION

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
