#!/usr/bin/env bash


source /tmp/shiny_proxy_ip && ssh -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ubuntu@$SHINY_PROXY_IP '(jps -ml | grep shinyproxy | grep -P -o "\d+\s" | awk '{print $1}' | xargs kill)'
nohup source /tmp/shiny_proxy_ip && ssh -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ubuntu@$SHINY_PROXY_IP  'nohup cd ~/shinyproxy/ && (java -jar shinyproxy-0.8.7.jar ) &' &
