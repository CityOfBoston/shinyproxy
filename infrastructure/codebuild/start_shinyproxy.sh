#!/usr/bin/env bash

source /tmp/shiny_proxy_ip && \
ssh -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no -r $repo ubuntu@$SHINY_PROXY_IP /bin/bash -c  "java -jar ~/shinyproxy/shinyproxy-0.8.7.jar"