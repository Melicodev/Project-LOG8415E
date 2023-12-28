#!/bin/bash

PUBLIC_ADDRESSES=$(python3 -m public_dns)
PRIVATE_ADDRESSES=$(python3 -m private_dns)

standalone=${PUBLIC_ADDRESSES[0]}
manager=${PUBLIC_ADDRESSES[1]}
worker1=${PUBLIC_ADDRESSES[2]}
worker2=${PUBLIC_ADDRESSES[3]}
worker3=${PUBLIC_ADDRESSES[4]}
manager_private=${PRIVATE_ADDRESSES[1]}

build() {
    docker build -t tp3-image .
    docker run -d --name my_container tp3-image
}

setup() {
   echo "Executing environment setup..."
   docker run -v $(pwd):/app -it --rm tp3-image bash -c "\
       pip install boto3 && \
       python3 /app/setup.py && \
       bash /app/deploy_standalone_benchmark.sh $standalone && \
       bash /app/deploy_manager.sh $manager $manager_private $worker1 $worker2 $worker3 && \
       bash /app/deploy_node.sh $worker1 $manager_private && \
       bash /app/deploy_node.sh $worker2 $manager_private && \
       bash /app/deploy_node.sh $worker3 $manager_private
       "
}


run_benchmark_cluster() {
    echo "Running benchmark for cluster..."
    dockerexec my_container ./benchmark_cluster.sh
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
    "benchmark")
        run_benchmark_cluster
        ;;
    "teardown")
        teardown
        ;;
esac