#!/usr/bin/env bash

echo "going to kill any shinyproxy processes before starting up a new one"
source /tmp/shiny_proxy_ip && (nohup ssh -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ubuntu@$SHINY_PROXY_IP '(jps -ml | grep shinyproxy | grep -P -o "\d+\s" | awk '{print $1}' | xargs kill)' &)
echo "starting up a new shinyproxy process"
source /tmp/shiny_proxy_ip && (nohup ssh -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ubuntu@$SHINY_PROXY_IP  'nohup cd ~/shinyproxy/ && (java -jar shinyproxy-0.8.7.jar ) &' &)
echo "done starting shinyproxy" 
