#!/usr/bin/env bash

# Ugh weird grub based errors started showing up on 4/24/17
#https://askubuntu.com/questions/146921/how-do-i-apt-get-y-dist-upgrade-without-a-grub-config-prompt
#sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold"  install grub-pc

DOCKER_VERSION=17.06.0~ce-0~ubuntu

DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
sudo apt-get update -y
sudo apt-get install -y python3-pip
sudo pip3 install awscli

eval $(aws ecr get-login --no-include-email)

## Installing Perquisites

# JAVA 8
sudo apt-get install -y default-jre
sudo apt-get install -y default-jdk
#sudo apt-get install oracle-java8-installer

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
echo "List all available versions"
sudo apt-cache madison docker-ce
sudo apt-get install -y docker-ce=${DOCKER_VERSION}

sudo docker run hello-world

# Install Shiny Proxy
sudo su -c 'echo  #Use DOCKER_OPTS to modify the daemon startup options. >> /etc/default/docker'
sudo su -c 'echo DOCKER_OPTS="-H tcp://0.0.0.0:2375 -H unix://" >> /etc/default/docker'


sudo service docker restart

#Downloading Shiny Proxy
curl -LO https://github.com/openanalytics/shinyproxy/releases/download/v0.9.2/shinyproxy-0.9.2.jar

mv shinyproxy-0.9.2.jar ~/shinyproxy
cd ~/shinyproxy


sudo mv /tmp/docker_config /lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl restart docker

sudo docker pull openanalytics/shinyproxy-demo