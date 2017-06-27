#!/usr/bin/env bash

set -e
source /tmp/shiny_proxy_ip
eval "$(ssh-agent -s)"
sudo scp -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ~/.ssh/shinyproxy.pem ubuntu@${BASTION_PUBLIC_IP}:/.ssh/shinyproxy.pem