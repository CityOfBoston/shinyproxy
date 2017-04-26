#!/usr/bin/env bash

set -e
echo "Getting SSH Key to use for the deployed instance"
export DEPLOY_KEYS_BUCKET=test-boston-deploy
export DEPLOY_KEYS_REGION=us-west-2
export SHINYPROXYKEY=shinyproxy.pem
echo "Downloading ssh keys from s3://${DEPLOY_KEYS_BUCKET} to ~/.ssh"
aws s3 sync s3://${DEPLOY_KEYS_BUCKET}/${SHINYPROXYKEY} ~/.ssh/ --region ${DEPLOY_KEYS_REGION}
