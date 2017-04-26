#!/usr/bin/env bash
ROOT = $PWD
mkdir shinyapps
cd shinyapps
source /tmp/shiny_proxy_ip
while read repo; do
    git clone $repo &&  \
    scp -o StrictHostKeyChecking=no -r $repo ubuntu@$SHINY_PROXY_IP && \
    ssh -o StrictHostKeyChecking=no -r $repo ubuntu@$SHINY_PROXY_IP /bin/bash -c  "cd $repo && docker build"
done < repositories.conf


