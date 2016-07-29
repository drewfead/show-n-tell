#!/bin/bash
PAYLOAD_FILE_NAME='terraform/lambda/create-deploy-readyfile.zip'

if [ -f $PAYLOAD_FILE_NAME ]; then
    rm $PAYLOAD_FILE_NAME
fi
echo "Zipping up code.."
zip -rjq $PAYLOAD_FILE_NAME terraform/lambda/create-deploy-readyfile.py || echo "Zip failed"; exit 1

echo "Generated $PAYLOAD_FILE_NAME"