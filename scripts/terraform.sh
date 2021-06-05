#!/usr/bin/env bash
set -eou pipefail

DIRECTORY=$1

export TF_CLI_ARGS_apply=${TF_CLI_ARGS_apply:-"-auto-approve"}
export TF_CLI_ARGS_destroy=${TF_CLI_ARGS_destroy:-"-auto-approve"}

pushd terraform/$DIRECTORY
terraform init -backend-config="secret_suffix=$DIRECTORY"
terraform workspace new $TF_WORKSPACE || true
terraform "$TF_COMMAND"
popd > /dev/null