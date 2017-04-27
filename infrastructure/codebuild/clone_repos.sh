#!/usr/bin/env bash
export ROOT=$PWD
mkdir shinyapps
cd shinyapps
source /tmp/shiny_proxy_ip

echo "attempting clone repos and build docker images from the following list"
cat $ROOT/repositories.conf
#while read repo; do
#    export REPO_NAME=$(echo $repo | grep -P -o "git@github.com:CityOfBoston\/\w+.git")
#    export IMAGE_TAG=$(echo $repo | grep -P -o "^\w+")
#    echo "cloning from ${REPO_NAME}"
#    git clone $REPO_NAME
#    echo "moving files to shiny server"
#    scp -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no -r $IMAGE_TAG ubuntu@$SHINY_PROXY_IP:~/shinyproxy/
#    echo "building docker images on shiny server"
#    ssh -T -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no  ubuntu@${SHINY_PROXY_IP} << EOF
#        cd ~/shinyproxy/$REPO_NAME
#        git checkout docker && docker build -t ${IMAGE_TAG} .
#EOF
#done < $ROOT/repositories.conf

export repo=$(cat $ROOT/repositories.conf)
export REPO_NAME=$(echo $repo | grep -P -o "git@github.com:CityOfBoston\/\w+.git")
export NAME=$(echo $repo | grep -P -o "^\w+")
git clone $REPO_NAME

ssh -T -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no  ubuntu@${SHINY_PROXY_IP} << EOF
 sudo rm -rf ~/shinyproxy/$NAME || echo "nothing here so nothing to delete"
EOF

scp -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no -r $NAME ubuntu@$SHINY_PROXY_IP:~/shinyproxy/
ssh -T -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no  ubuntu@${SHINY_PROXY_IP} << EOF
        cd ~/shinyproxy/$NAME
        git checkout docker
        git pull
        sudo docker build -t ${NAME} .
EOF
echo "done installing docker images for repos"



