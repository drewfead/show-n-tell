#!/bin/bash

while [ $# -ge 2 ]; do
	if [ "$1" == "--key" ]; then
		key="$2"
		shift 2
	elif [ "$1" == "--command" ]; then
		command="$2"
		shift 2
	elif [ "$1" == "--bucket" ]; then
		bucket="$2"
		shift 2
	elif [ "$1" == "--var" ]; then
		vars_string="${vars_string}-var ${2} "
		shift 2
	elif [ "$1" == "--target" ]; then
		vars_string="${vars_string}-target=${2} "
		shift 2
	fi
done

#echo key=$key
#echo command=$command
#echo bucket=$bucket
#echo vars=$vars

set -e

bash lock.sh --acquire

set +e

rm -rf .terraform

/home/ec2-user/terraform/terraform remote config \
    -backend=s3 \
    -backend-config="bucket=$bucket" \
    -backend-config="key=$key" \
    -backend-config="region=us-east-1"

# Sync the remote storage to the local storage (download).
/home/ec2-user/terraform/terraform remote pull

command_string="/home/ec2-user/terraform/terraform $command ${vars_string}"
eval ${command_string}

bash lock.sh --release
