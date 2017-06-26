#!/usr/bin/env bash
export ROOT=$PWD
mkdir shinyapps
cd shinyapps
source /tmp/shiny_proxy_ip

# This script will clone the repos specified in the repositories.conf file.
# moves the source code to the AWS instance and builds the docker files contained in them

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/shinyproxy.pem

echo "attempting clone repos and build docker images from the following list"
cat $ROOT/repositories.conf
IFS=$'\n'
set -f
for repo in $(cat < $ROOT/repositories.conf); do
	export REPO_NAME=$(echo $repo | grep -P -o "git@github.com:CityOfBoston\/\w+.git")
	export NAME=$(echo $repo | grep -P -o "^\w+")
	echo cloning the following "${REPO_NAME}"
	git clone ${REPO_NAME}
	echo "copying over ${NAME} to the bastion server"
	sudo chown -R $USER:$USER ${NAME}
	sudo scp -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no -r ${NAME} ec2-user@${BASTION_PUBLIC_IP}:/tmp
	ssh -A -T -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no  ec2-user@${BASTION_PUBLIC_IP} << EOF
    eval "$(ssh-agent -s)"
    ssh-add -l
    echo "copying over files to shinyproxy server"
    sudo scp -o StrictHostKeyChecking=no  -r /tmp/${NAME} ubuntu@${SHINY_PROXY_IP}:~/shinyproxy
	echo "attempting to build docker image"
	ssh -T -A -v -o StrictHostKeyChecking=no ubuntu@${SHINY_PROXY_IP} <<- DOF
		cd ~/shinyproxy/${NAME} && sudo docker build -t bostonanalytics/${NAME} .
	DOF
EOF
done


echo "done building docker images for shiny apps"

