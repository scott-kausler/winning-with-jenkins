.PHONY: jenkins all .EXPORT_ALL_VARIABLES

.EXPORT_ALL_VARIABLES:
TF_WORKSPACE=prod
TF_COMMAND=plan

KUBE_CONFIG_PATH=${HOME}/.kube/config
KUBECONFIG=$(KUBE_CONFIG_PATH)
KUBE_CTX=docker-desktop

jenkins:
	scripts/terraform.sh $(COMMAND)