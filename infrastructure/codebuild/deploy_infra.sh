#!/usr/bin/env bash
set -e


source /tmp/aws_cred_export.txt  && cd infrastructure/tf-stack/${DeploymentEnvironment} && \
terraform init && terraform get && \
terraform apply
echo "Successfully deployed application. I probably should start testing it"
echo -e SHINY_PROXY_IP=$(terraform output -json shiny_proxy_public_ip | jq '.value' | sed -e 's/^"//' | sed -e 's/"$//') > \
/tmp/shiny_proxy_ip
