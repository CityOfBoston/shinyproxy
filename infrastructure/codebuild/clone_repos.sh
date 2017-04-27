#!/usr/bin/env bash
export ROOT=$PWD
mkdir shinyapps
cd shinyapps
source /tmp/shiny_proxy_ip

echo "attempting clone repos and build docker images from the following list"
cat $ROOT/repositories.conf
while read repo; do
    echo "cloning from ${repo}"
    git clone $repo
    echo "moving files to shiny server"
    scp -T -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no -r $ROOT/$repo ubuntu@$SHINY_PROXY_IP:~/
    export IMAGE_TAG=$(echo $repo | grep -P -o "^\w+")
    echo "building docker images on shiny server"
    ssh -T -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no  ubuntu@${SHINY_PROXY_IP} << EOF
        cd $repo
        git checkout docker && docker build -t ${IMAGE_TAG} .
EOF
done < $ROOT/repositories.conf


