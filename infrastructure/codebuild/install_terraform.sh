#!/usr/bin/env bash
set -e
echo "Installing Terraform on Build Server"

cd /tmp &&
 curl -o terraform.zip https://releases.hashicorp.com/terraform/${TerraformVersion}/terraform_${TerraformVersion}_linux_amd64.zip && \
 echo "${TerraformSha256} terraform.zip" | sha256sum -c --quiet && \
 unzip terraform.zip && mv terraform /usr/bin

echo "Finished Installing Terraform on Build Server"