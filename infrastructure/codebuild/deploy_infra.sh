#!/usr/bin/env bash

## This script is charged with running the appropriate Terraform Deploy depending on the environment specified in the
## Code Pipeline
set -e
export ROOT=$PWD
export SSH_KEYNAME="shinyproxy"
export SSH_KEY_LOCATION="~/.ssh/shinyproxy.pem"
export PRIVATE_SHINY_PROXY_CONFIG_FILE="application.yml"
export PUBLIC_SHINY_PROXY_CONFIG_FILE="public_application.yml"
echo "config file is located here:"
echo "shiny_proxy_config_file=${ROOT}/${SHINY_PROXY_CONFIG_FILE}"
source /tmp/docker_images.txt
source /tmp/aws_cred_export.txt  && cd infrastructure/tf-stack/${DeploymentEnvironment} && \
terraform init && terraform get && \
terraform apply \
    -var "ssh_key_name=${SSH_KEYNAME}" \
    -var "public_application_file=${ROOT}/${PUBLIC_SHINY_PROXY_CONFIG_FILE}" \
    -var "private_application_file=${ROOT}/${PRIVATE_SHINY_PROXY_CONFIG_FILE}" \
    -var "shiny_app_docker_images=${PUBLIC_IMAGES},${PRIVATE_IMAGES}"

echo "Successfully deployed application. I probably should start testing it"
