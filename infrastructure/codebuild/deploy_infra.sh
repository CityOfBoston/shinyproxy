#!/usr/bin/env bash

## This script is charged with running the appropriate Terraform Deploy depending on the environment specified in the
## Code Pipeline
set -e
export ROOT=$PWD
export SSH_KEYNAME="shinyproxy"
export SSH_KEY_LOCATION="~/.ssh/shinyproxy.pem"
export SHINY_PROXY_CONFIG_FILE="application.yml"
echo "config file is located here:"
echo "shiny_proxy_config_file=${ROOT}/${SHINY_PROXY_CONFIG_FILE}"
source /tmp/aws_cred_export.txt  && cd infrastructure/tf-stack/${DeploymentEnvironment} && \
terraform init && terraform get && \
terraform apply \
    -var "ssh_key=${SSH_KEY_LOCATION}" \
    -var "ssh_key_name=${SSH_KEYNAME}" \
    -var "shiny_proxy_config_file=${ROOT}/${SHINY_PROXY_CONFIG_FILE}"

echo "Successfully deployed application. I probably should start testing it"

echo -e BASTION_PUBLIC_IP=$(terraform output -json bastion_public_ip | jq '.value' | sed -e 's/^"//' | sed -e 's/"$//') > \
/tmp/shiny_proxy_ip
echo -e SHINY_PROXY_IP=$(terraform output -json shiny_proxy_private_ip | jq '.value' | sed -e 's/^"//' | sed -e 's/"$//') >> /tmp/shiny_proxy_ip
echo "whats in this file"
cat /tmp/shiny_proxy_ip
