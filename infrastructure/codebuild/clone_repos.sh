#!/usr/bin/env bash
export ROOT=$PWD
mkdir shinyapps
cd shinyapps
source /tmp/shiny_proxy_ip && \
while read repo; do
    echo "cloning from ${repo}"
    git clone $repo &&  \
    scp -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no -r $repo ubuntu@$SHINY_PROXY_IP && \
    export IMAGE_TAG=$(echo $repo | grep -P -o "^\w+") && \
    ssh -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no $repo ubuntu@$SHINY_PROXY_IP /bin/bash -c  "cd $repo && git checkout docker && docker build -t ${IMAGE_TAG} ."
done < $ROOT/repositories.conf


