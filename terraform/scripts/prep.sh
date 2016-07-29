#!/bin/bash

ec2Host="ec2-54-86-112-244.compute-1.amazonaws.com"

sh terraform/scripts/gen-build.sh
sh terraform/scripts/gen-deploy.sh

ssh aws_terra bash /home/ec2-user/workspace/drew/scripts/lock.sh --acquire || exit 1

rsync -avzrh --delete --exclude=".*/" -e ssh terraform/* aws_terra:~/workspace/drew

ssh aws_terra bash /home/ec2-user/workspace/drew/scripts/lock.sh --release
