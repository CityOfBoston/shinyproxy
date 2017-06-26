#!/usr/bin/env bash
# This script will kill any running shiny proxy processes and start a new one
source /tmp/shiny_proxy_ip


eval "$(ssh-agent -s)"
ssh-add ~/.ssh/shinyproxy.pem
echo "why cant it find the applicaiton file"
ls ~/
scp -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ~/application.yml ec2-user@${BASTION_PUBLIC_IP}:/tmp/application.yml
ssh -T -A -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ec2-user@${BASTION_PUBLIC_IP} << EOF
scp -o StrictHostKeyChecking=no /tmp/application.yml ubuntu@${SHINY_PROXY_IP}:/tmp/shinyproxy/application.yml
ssh -T -o StrictHostKeyChecking=no ubuntu@${SHINY_PROXY_IP} << 'DOF'
echo "going to kill any shinyproxy processes before starting up a new one"
cd ~/shinyproxy
echo "(jps -ml | grep shinyproxy | grep -P -o \"\\d+\\s\" | awk \"{print $1}\" | xargs kill) || echo \"nothing currently running\"; java -jar shinyproxy-0.8.7.jar" > /tmp/start_proxy.sh
chmod u+x /tmp/start_proxy.sh
nohup /tmp/start_proxy.sh  >/dev/null 2>&1 &
DOF
EOF

