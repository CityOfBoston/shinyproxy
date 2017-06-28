#!/usr/bin/env bash
# This script will kill any running shiny proxy processes and start a new one
source /tmp/shiny_proxy_ip


eval "$(ssh-agent -s)"
ssh-add ~/.ssh/shinyproxy.pem
scp -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no application.yml ubuntu@${BASTION_PUBLIC_IP}:/tmp
ssh -T -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ubuntu@${BASTION_PUBLIC_IP} << EOF
	sudo scp -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no /tmp/application.yml ubuntu@${SHINY_PROXY_IP}:~/shinyproxy
	ssh -i ~/.ssh/shinyproxy.pem -A -T -v -o StrictHostKeyChecking=no ubuntu@${SHINY_PROXY_IP} <<- 'DOF'
		## Private Applications
		echo "going to kill any shinyproxy processes before starting up a new one"
		cd ~/shinyproxy
		echo "(jps -ml | grep shinyproxy | grep -P -o \"\\d+\\s\" | awk \"{print $1}\" | xargs kill) || echo \"nothing currently running\"; java -jar shinyproxy-0.8.7.jar" > /tmp/start_proxy.sh
		chmod u+x /tmp/start_proxy.sh
		nohup /tmp/start_proxy.sh  >shinyproxy.out 2>&1 &
		DOF
EOF

