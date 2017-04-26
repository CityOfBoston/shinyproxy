#!/usr/bin/env bash
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y awscli


eval $(aws ecr get-login)

## Installing Perquisites

# JAVA 8
sudo apt-get install -y default-jre
sudo apt-get install -y default-jdk

# Docker
sudo apt-get install -y \
 apt-transport-https \
 ca-certificates \
 curl \
 software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -


sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
sudo apt-get install -y docker-ce

sudo docker run hello-world
# Install Shiny Proxy
#sudo su -
sudo su -c 'echo  #Use DOCKER_OPTS to modify the daemon startup options. >> /etc/default/docker'
sudo su -c 'echo DOCKER_OPTS="-H tcp://0.0.0.0:2375 -H unix://" >> /etc/default/docker'


sudo service docker restart

#Downloading Shiny Proxy
curl -LO https://github.com/openanalytics/shinyproxy/releases/download/v0.8.7/shinyproxy-0.8.7.jar

mv shinyproxy-0.8.7.jar ~/shinyproxy
cd ~/shinyproxy


sudo mv /tmp/docker_config /lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl restart docker

sudo docker pull openanalytics/shinyproxy-demo