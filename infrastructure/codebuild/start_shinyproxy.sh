#!/usr/bin/env bash
source /tmp/shiny_proxy_ip

scp -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no application.yml ubuntu@$SHINY_PROXY_IP:~/shinyproxy/application.yml
ssh -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ubuntu@$SHINY_PROXY_IP << EOF
echo "going to kill any shinyproxy processes before starting up a new one"
cd ~/shinyproxy
echo "(jps -ml | grep shinyproxy | grep -P -o "\d+\s" | awk '{print $1}' | xargs kill) && java -jar shinyproxy-0.8.7.jar || (java -jar shinyproxy-0.8.7.jar )" > /tmp/start_proxy.sh
 chmod u+x /tmp/start_proxy.sh
 nohup ./tmp/start_proxy.sh &
EOF
