#!/usr/bin/env bash

set -e
echo "Starting to set up github access via ssh"
export DEPLOY_KEYS_BUCKET=test-boston-deploy
export DEPLOY_KEYS_REGION=us-west-2
echo "Downloading ssh keys from s3://${DEPLOY_KEYS_BUCKET} to ~/.ssh"
aws s3 sync s3://${DEPLOY_KEYS_BUCKET} ~/.ssh/ --region ${DEPLOY_KEYS_REGION}

mv ~/.ssh/deploy_key ~/.ssh/id_rsa
chmod 700 ~/.ssh/id_rsa
chmod 700 ~/.ssh/shinyproxy.pem

echo "Adding www.github.com to known hosts"
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
ssh-keygen -f ~/.ssh/known_hosts -R [www.github.com]

echo "Done setting up ssh github access"

echo "Attempting to set up ssh keys"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
