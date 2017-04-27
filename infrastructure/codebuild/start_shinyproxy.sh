#!/usr/bin/env bash
source /tmp/shiny_proxy_ip

#echo "going to kill any shinyproxy processes before starting up a new one"
# (ssh -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ubuntu@$SHINY_PROXY_IP '(jps -ml | grep shinyproxy | grep -P -o "\d+\s" | awk '{print $1}' | xargs kill)') && \
# (nohup ssh -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ubuntu@$SHINY_PROXY_IP  'nohup cd ~/shinyproxy/ && (java -jar shinyproxy-0.8.7.jar ) &' &) || \
#echo "starting up a new shinyproxy process"
#(nohup ssh -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ubuntu@$SHINY_PROXY_IP  'nohup cd ~/shinyproxy/ && (java -jar shinyproxy-0.8.7.jar ) &' &)
#echo "done starting shinyproxy"

nohup ssh -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ubuntu@$SHINY_PROXY_IP << EOF
echo "going to kill any shinyproxy processes before starting up a new one"
(jps -ml | grep shinyproxy | grep -P -o "\d+\s" | awk '{print $1}' | xargs kill) && \
 (cd ~/shinyproxy/ &&  nohup java -jar shinyproxy-0.8.7.jar &) || (cd ~/shinyproxy/ && nohup java -jar shinyproxy-0.8.7.jar &)
EOF &