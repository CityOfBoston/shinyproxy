#!/bin/bash

cat <<"EOF" > /tmp/docker_config
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network.target docker.socket firewalld.service
Requires=docker.socket

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H fd:// -D -H tcp://0.0.0.0:2375
LimitNOFILE=1048576
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process

[Install]
WantedBy=multi-user.target



EOF


cat <<"EOF" > /tmp/bootstrap_shiny.sh
#!/bin/bash
DOCKER_VERSION=17.06.0~ce-0~ubuntu
SHINY_PROXY_VERSION=0.9.2
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
apt-get update -y
apt-get install -y python3-pip
pip3 install awscli


echo -e  $$(aws ecr get-login --region=${AWS_REGION} --no-include-email) > /tmp/login_ecr.sh

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
curl -LO https://github.com/openanalytics/shinyproxy/releases/download/v${SHINY_PROXY_VERSION}/shinyproxy-${SHINY_PROXY_VERSION}.jar

mkdir -p /home/ubuntu/shinyproxy
mv shinyproxy-${SHINY_PROXY_VERSION}.jar /home/ubuntu/shinyproxy/
cd /home/ubuntu/shinyproxy

aws s3  cp  s3://${BUCKET_NAME}/${SHINY_APP_CONFIG_FILE}/ /home/ubuntu/shinyproxy/application.yml --region ${AWS_REGION}


mv /tmp/docker_config /lib/systemd/system/docker.service
systemctl daemon-reload
systemctl restart docker

docker pull openanalytics/shinyproxy-demo
chmod u+x /tmp/login_ecr.sh
/tmp/login_ecr.sh
for image in $(echo ${ecr_repositories} | sed "s/,/ /g")
do
    docker pull "$image"

done

echo "java -jar shinyproxy-${SHINY_PROXY_VERSION}.jar" > /tmp/start_proxy.sh
chmod u+x /tmp/start_proxy.sh
nohup /tmp/start_proxy.sh  >shinyproxy.out 2>&1 &
EOF
chmod u+x /tmp/bootstrap_shiny.sh
/tmp/bootstrap_shiny.sh