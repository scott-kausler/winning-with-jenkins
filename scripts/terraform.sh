#!/usr/bin/env bash
set -eou pipefail

export TF_CLI_ARGS_apply=${TF_CLI_ARGS_apply:-"-auto-approve"}
export TF_CLI_ARGS_destroy=${TF_CLI_ARGS_destroy:-"-auto-approve"}

pushd terraform
terraform workspace new $TF_WORKSPACE || true
terraform init
terraform "$TF_COMMAND"
popd