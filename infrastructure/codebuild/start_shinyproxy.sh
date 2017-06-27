#!/usr/bin/env bash
# This script will kill any running shiny proxy processes and start a new one
source /tmp/shiny_proxy_ip


eval "$(ssh-agent -s)"
ssh-add ~/.ssh/shinyproxy.pem
scp -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no application.yml ubuntu@${BASTION_PUBLIC_IP}:/tmp
scp -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no public_application.yml ubuntu@${BASTION_PUBLIC_IP}:/tmp
ssh -T -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ubuntu@${BASTION_PUBLIC_IP} << EOF
	sudo scp -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no /tmp/application.yml ubuntu@${SHINY_PROXY_IP}:~/shinyproxy
	sudo scp -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no /tmp/public_application.yml ubuntu@${SHINY_PROXY_IP}:/tmp/

	ssh -i ~/.ssh/shinyproxy.pem -A -T -v -o StrictHostKeyChecking=no ubuntu@${SHINY_PROXY_IP} <<- 'DOF'
		## Private Applications
		echo "going to kill any shinyproxy processes before starting up a new one"
		cd ~/shinyproxy
		echo "(jps -ml | grep shinyproxy | grep -P -o \"\\d+\\s\" | awk \"{print $1}\" | xargs kill) || echo \"nothing currently running\"; java -jar shinyproxy-0.8.7.jar" > /tmp/start_proxy.sh
		chmod u+x /tmp/start_proxy.sh
		nohup /tmp/start_proxy.sh  >shinyproxy.out 2>&1 &
		# Going to copy the contents of the main shiny proxy folder and
		# then replace the application.yml file with the public_application.yml
		rm -rf ~/public_shinyproxy
		cp -rf ~/shinyproxy ~/public_shinyproxy
		cp -T /tmp/public_application.yml ~/public_shinyproxy/application.yml
		cd ~/public_shinyproxy
		nohup /tmp/start_proxy.sh  >public_shinyproxy.out 2>&1 &
		DOF
EOF

