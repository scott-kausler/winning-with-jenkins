#!/usr/bin/env bash
set -eou pipefail

. .env
. .${TF_WORKSPACE}.env || true; 

DIRECTORY=$1

export TF_CLI_ARGS_apply=${TF_CLI_ARGS_apply:-"-auto-approve"}
export TF_CLI_ARGS_destroy=${TF_CLI_ARGS_destroy:-"-auto-approve"}

pushd terraform/$DIRECTORY
terraform workspace new $TF_WORKSPACE || true
terraform init -backend-config="secret_suffix=$DIRECTORY"
terraform "$TF_COMMAND"
popd > /dev/null