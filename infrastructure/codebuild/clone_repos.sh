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
export IMAGE_TAG=$(echo $repo | grep -P -o "^\w+")
git clone $REPO_NAME
scp -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no -r $IMAGE_TAG ubuntu@$SHINY_PROXY_IP:~/shinyproxy/
ssh -T -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no  ubuntu@${SHINY_PROXY_IP} << EOF
        cd ~/shinyproxy/$REPO_NAME
        git checkout docker && docker build -t ${IMAGE_TAG} .
EOF
echo "done installing docker images for repos"



