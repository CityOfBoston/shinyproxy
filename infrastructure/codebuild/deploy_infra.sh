#!/usr/bin/env bash
set -e

export SSH_KEYNAME="shinyproxy"
export SSH_KEY_LOCATION="~/.ssh/shinyproxy.pem"

source /tmp/aws_cred_export.txt  && cd infrastructure/tf-stack/${DeploymentEnvironment} && \
terraform init && terraform get && \
terraform apply \
    -var "ssh_key=${SSH_KEY_LOCATION}" \
    -var "ssh_key_name${SSH_KEYNAME}"


echo "Successfully deployed application. I probably should start testing it"
echo -e SHINY_PROXY_IP=$(terraform output -json shiny_proxy_public_ip | jq '.value' | sed -e 's/^"//' | sed -e 's/"$//') > \
/tmp/shiny_proxy_ip