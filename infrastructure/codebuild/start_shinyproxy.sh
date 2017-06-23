#!/usr/bin/env bash
# This script will kill any running shiny proxy processes and start a new one
source /tmp/shiny_proxy_ip

#scp -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no application.yml ubuntu@$SHINY_PROXY_IP:~/shinyproxy/application.yml
#ssh -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ubuntu@$SHINY_PROXY_IP << 'EOF'
#echo "going to kill any shinyproxy processes before starting up a new one"
#cd ~/shinyproxy
#echo "(jps -ml | grep shinyproxy | grep -P -o \"\\d+\\s\" | awk \"{print $1}\" | xargs kill) || echo \"nothing currently running\"; java -jar shinyproxy-0.8.7.jar" > /tmp/start_proxy.sh
# chmod u+x /tmp/start_proxy.sh
# nohup /tmp/start_proxy.sh  >/dev/null 2>&1 &
#EOF

scp -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no application.yml ec2-user@BASTION_PUBLIC_IP:/tmp/shinyproxy/application.yml
ssh -T -A -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ec2-user@$BASTION_PUBLIC_IP << 'EOF'
ssh -T -o StrictHostKeyChecking=no ubuntu@$SHINY_PROXY_IP << 'DOF'
scp -o StrictHostKeyChecking=no /tmp/shinyproxy/application.yml ubuntu@SHINY_PROXY_IP:/tmp/shinyproxy/application.yml
echo "going to kill any shinyproxy processes before starting up a new one"
cd ~/shinyproxy
echo "(jps -ml | grep shinyproxy | grep -P -o \"\\d+\\s\" | awk \"{print $1}\" | xargs kill) || echo \"nothing currently running\"; java -jar shinyproxy-0.8.7.jar" > /tmp/start_proxy.sh
chmod u+x /tmp/start_proxy.sh
nohup /tmp/start_proxy.sh  >/dev/null 2>&1 &
DOF
EOF

