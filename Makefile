.PHONY: .EXPORT_ALL_VARIABLES all jenkins-operator jenkins

.EXPORT_ALL_VARIABLES:
TF_WORKSPACE=prod
TF_COMMAND=plan

all: jenkins

jenkins:
	scripts/terraform.sh $@
