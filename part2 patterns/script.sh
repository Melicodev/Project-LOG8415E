#!/bin/bash

PUBLIC_CLUSTER_ADDRESSES=$(python3 -m public_dns)
PRIVATE_ADDRESSES=$(python3 -m private_dns)
PUBLIC_PROXY=$(python3 -m proxy_public_dns)
PRIVATE_PROXY=$(python3 -m proxy_private_dns)
GATEKEEPER=$(python3 -m gatekeeper_dns)

manager=${PUBLIC_CLUSTER_ADDRESSES[0]}
worker1=${PUBLIC_CLUSTER_ADDRESSES[1]}
worker2=${PUBLIC_CLUSTER_ADDRESSES[2]}
worker3=${PUBLIC_CLUSTER_ADDRESSES[3]}
manager_private=${PRIVATE_ADDRESSES[0]}

build() {
    docker build -t tp3-image .
    docker run -d --name my_container tp3-image
}

setup() {
   echo "Executing environment setup..."
   docker run -v $(pwd):/app -it --rm tp3-image bash -c "\
       pip install boto3 && \
       python3 /app/setup.py && \
       bash /app/deploy_manager.sh $manager $manager_private $worker1 $worker2 $worker3 && \
       bash /app/deploy_node.sh $worker1 $manager_private && \
       bash /app/deploy_node.sh $worker2 $manager_private && \
       bash /app/deploy_node.sh $worker3 $manager_private && \
       bash /app/deploy_proxy.sh $PUBLIC_PROXY && \
       bash /app/deploy_gatekeeper.sh $GATEKEEPER $PRIVATE_PROXY
       "
}


teardown() {
    echo "Terminating environment..."

    docker exec my_container python3 teardown.py
}


case "$1" in
    "build")
        build
        ;;
    "setup")
        setup
        ;;
    "teardown")
        teardown
        ;;
esac