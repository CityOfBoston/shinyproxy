#!/usr/bin/env bash
export ROOT=$PWD
mkdir shinyapps
cd shinyapps
source /tmp/shiny_proxy_ip

# This script will clone the repos specified in the repositories.conf file.
# moves the source code to the AWS instance and builds the docker files contained in them

echo "attempting clone repos and build docker images from the following list"
cat $ROOT/repositories.conf
while read repo; do
    export REPO_NAME=$(echo $repo | grep -P -o "git@github.com:CityOfBoston\/\w+.git")
    export NAME=$(echo $repo | grep -P -o "^\w+")
    git clone $REPO_NAME
    ssh -T -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no  ubuntu@${SHINY_PROXY_IP} << EOF
        sudo rm -rf ~/shinyproxy/$NAME && echo "Deleted old $NAME repo contents" || echo "nothing here so nothing to delete"
EOF
    echo "copying over $NAME to the shinyproxy server"
    scp -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no -r $NAME ubuntu@$SHINY_PROXY_IP:~/shinyproxy/
    ssh -T -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no  ubuntu@${SHINY_PROXY_IP} << EOF
            cd ~/shinyproxy/$NAME
            echo "Building the $NAME docker image"
            sudo docker build -t bostonanalytics/${NAME} .
EOF
done < $ROOT/repositories.conf

echo "done building docker images for shiny apps"



