# CHART_NAME 		?= stable/datadog
# CHART_VERSION	?= 2.0.7

# NAMESPACE			?= datadog
# RELEASE 			?= p4-datadog
#
# DEV_CLUSTER		:= p4-development
# PROD_CLUSTER	:= planet4-production

.DEFAULT_GOAL := all

all: rbac secret agent

# lint:
# 	@find . -type f -name '*.yml' | xargs yamllint
# 	@find . -type f -name '*.yaml' | xargs yamllint
#
# namespace:
# 	kubectl create ns $(NAMESPACE) || exit 0
#
# clean:
# 	helm delete $(RELEASE) --purge
#
# status:
# 	helm status $(RELEASE)
#
# dev: namespace

# 	@helm upgrade --install --force --wait $(RELEASE) $(CHART_NAME) \
# 		--namespace $(NAMESPACE) \
# 		--set datadog.apiKey=$(DATADOG_API_KEY)

secret:
ifeq ($(strip $(DATADOG_API_KEY)),)
	$(error DATADOG_API_KEY is not set)
endif
	kubectl -n $(NAMESPACE) create secret generic datadog-secret --from-literal api-key="$(DATADOG_API_KEY)" || true

rbac:
	kubectl -n $(NAMESPACE) create -f "https://raw.githubusercontent.com/DataDog/datadog-agent/master/Dockerfiles/manifests/rbac/clusterrole.yaml" || true
	kubectl -n $(NAMESPACE) create -f "https://raw.githubusercontent.com/DataDog/datadog-agent/master/Dockerfiles/manifests/rbac/serviceaccount.yaml" || true
	kubectl -n $(NAMESPACE) create -f "https://raw.githubusercontent.com/DataDog/datadog-agent/master/Dockerfiles/manifests/rbac/clusterrolebinding.yaml" || true

agent:
	kubectl -n $(NAMESPACE) create -f datadog-agent.yaml

clean:
	kubectl -n $(NAMESPACE) delete -f datadog-agent.yaml
	kubectl -n $(NAMESPACE) delete secret datadog-secret
	kubectl -n $(NAMESPACE) delete -f "https://raw.githubusercontent.com/DataDog/datadog-agent/master/Dockerfiles/manifests/rbac/clusterrole.yaml"
	kubectl -n $(NAMESPACE) delete -f "https://raw.githubusercontent.com/DataDog/datadog-agent/master/Dockerfiles/manifests/rbac/serviceaccount.yaml"
	kubectl -n $(NAMESPACE) delete -f "https://raw.githubusercontent.com/DataDog/datadog-agent/master/Dockerfiles/manifests/rbac/clusterrolebinding.yaml"
