#!/usr/bin/env bash

source /tmp/shiny_proxy_ip && \
nohup ssh -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no  $repo ubuntu@$SHINY_PROXY_IP  'java -jar ~/shinyproxy/shinyproxy-0.8.7.jar' &