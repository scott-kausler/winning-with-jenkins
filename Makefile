.PHONY: .EXPORT_ALL_VARIABLES all jenkins-operator jenkins

.EXPORT_ALL_VARIABLES:
TF_WORKSPACE=prod
TF_COMMAND=plan

KUBE_CONFIG_PATH=${HOME}/.kube/config
KUBECONFIG=$(KUBE_CONFIG_PATH)
KUBE_CTX=docker-desktop

all: jenkins

jenkins:
	scripts/terraform.sh $@
