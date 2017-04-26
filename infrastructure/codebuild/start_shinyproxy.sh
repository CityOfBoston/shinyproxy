#!/usr/bin/env bash


source /tmp/shiny_proxy_ip && \
ssh -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ubuntu@$SHINY_PROXY_IP 'kill $(jps -ml | grep /home/ubuntu/shinyproxy/shinyproxy-0.8.7.jar | grep -P -o "\d+\s" | awk "{print $1}")'  && \
nohup ssh -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ubuntu@$SHINY_PROXY_IP  'java -jar ~/shinyproxy/shinyproxy-0.8.7.jar' &