#!/usr/bin/env bash
set -e
export ROOT=$PWD
export SSH_KEYNAME="shinyproxy"
export SSH_KEY_LOCATION="~/.ssh/shinyproxy.pem"
export SHINY_PROXY_CONFIG_FILE="shinyproxy_application.yml"
echo "config file is located here:"
echo "shiny_proxy_config_file=${ROOT}/${SHINY_PROXY_CONFIG_FILE}"
source /tmp/aws_cred_export.txt  && cd infrastructure/tf-stack/${DeploymentEnvironment} && \
terraform init && terraform get && \
terraform apply \
    -var "ssh_key=${SSH_KEY_LOCATION}" \
    -var "ssh_key_name=${SSH_KEYNAME}" \
    -var "shiny_proxy_config_file=${ROOT}/${SHINY_PROXY_CONFIG_FILE}"

echo "Successfully deployed application. I probably should start testing it"
echo -e SHINY_PROXY_IP=$(terraform output -json shiny_proxy_ip | jq '.value' | sed -e 's/^"//' | sed -e 's/"$//') > \
/tmp/shiny_proxy_ip
