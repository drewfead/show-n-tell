#!/bin/bash

BRANCH_DEFAULT=master
COMMAND_DEFAULT=apply
REMOTE_STATE_BUCKET_DEFAULT=show-n-tell-state

read -p "remote state bucket ($REMOTE_STATE_BUCKET_DEFAULT): " remoteState
remoteState=${universeSuffix:-$REMOTE_STATE_BUCKET_DEFAULT}

read -p "git branch ($BRANCH_DEFAULT): " branch
branch=${branch:-$BRANCH_DEFAULT}

read -p "command ($COMMAND_DEFAULT): " command
command=${command:-$COMMAND_DEFAULT}

key=b-$branch

sh ../scripts/terraform_wrapper.sh --key $key --command $command --bucket $remoteState --var "branch=${branch}"
