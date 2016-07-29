#!/bin/bash

RUNTIME_DEFAULT=dev
BRANCH_DEFAULT=master
COLOR_DEFAULT=blue
COMMAND_DEFAULT=apply
REMOTE_STATE_BUCKET_DEFAULT=show-n-tell-state

read -p "remote state bucket ($REMOTE_STATE_BUCKET_DEFAULT): " remoteState
remoteState=${universeSuffix:-$REMOTE_STATE_BUCKET_DEFAULT}

read -p "runtime ($RUNTIME_DEFAULT): " runtime
runtime=${runtime:-$RUNTIME_DEFAULT}

read -p "git branch ($BRANCH_DEFAULT): " branch
branch=${branch:-$BRANCH_DEFAULT}

read -p "deployment color ($COLOR_DEFAULT): " color
color=${color:-$COLOR_DEFAULT}

read -p "command ($COMMAND_DEFAULT): " command
command=${command:-$COMMAND_DEFAULT}

key=d-$runtime-$branch-$color

sh ../scripts/terraform_wrapper.sh --key $key --command $command --bucket $remoteState --var "runtime=${runtime}" --var "branch=${branch}" --var "deploymentColor=${color}"

