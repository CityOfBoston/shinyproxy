#!/bin/bash

DOCKER_VERSION=17.06.0~ce-0~ubuntu

DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
apt-get update -y
apt-get install -y python3-pip
pip3 install awscli

eval $(aws ecr get-login --no-include-email)

## Installing Perquisites

# JAVA 8
apt-get install -y default-jre
apt-get install -y default-jdk


# Docker
apt-get install -y \
 apt-transport-https \
 ca-certificates \
 curl \
 software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -


add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update
echo "List all available versions"
apt-cache madison docker-ce
apt-get install -y docker-ce=${DOCKER_VERSION}

docker run hello-world

# Install Shiny Proxy
echo  '#Use DOCKER_OPTS to modify the daemon startup options. >> /etc/default/docker'
echo 'DOCKER_OPTS="-H tcp://0.0.0.0:2375 -H unix://" >> /etc/default/docker'


service docker restart

#Downloading Shiny Proxy
curl -LO https://github.com/openanalytics/shinyproxy/releases/download/v0.9.2/shinyproxy-0.9.2.jar

mv shinyproxy-0.9.2.jar ~/shinyproxy
cd ~/shinyproxy


mv /tmp/docker_config /lib/systemd/system/docker.service
systemctl daemon-reload
systemctl restart docker

docker pull openanalytics/shinyproxy-demo


for image in $(echo ${ecr_repositories} | sed "s/,/ /g")
do
    docker pull "$image"

done
