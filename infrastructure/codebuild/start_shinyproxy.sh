#!/usr/bin/env bash


source /tmp/shiny_proxy_ip && \
ssh -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ubuntu@$SHINY_PROXY_IP '(jps -ml | grep shinyproxy | grep -P -o "\d+\s" | awk '{print $1}' | xargs kill) && java -jar ~/shinyproxy/shinyproxy-0.8.7.jar'  || \
nohup ssh -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ubuntu@$SHINY_PROXY_IP  'java -jar ~/shinyproxy/shinyproxy-0.8.7.jar' &