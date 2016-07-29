#!/bin/bash

SUFFIX_DEFAULT=
COMMAND_DEFAULT=apply
REMOTE_STATE_BUCKET_DEFAULT=show-n-tell-state

read -p "remote state bucket ($REMOTE_STATE_BUCKET_DEFAULT): " remoteState
remoteState=${universeSuffix:-$REMOTE_STATE_BUCKET_DEFAULT}

read -p "universe suffix ($SUFFIX_DEFAULT): " universeSuffix
universeSuffix=${universeSuffix:-$SUFFIX_DEFAULT}

read -p "command ($COMMAND_DEFAULT): " command
command=${command:-$COMMAND_DEFAULT}

key=u$universeSuffix

sh ../scripts/terraform_wrapper.sh --key $key --command $command --bucket $remoteState --var "suffix=${universeSuffix}"
