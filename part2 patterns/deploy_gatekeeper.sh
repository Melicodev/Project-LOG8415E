#!/bin/bash

server_addr=$1
proxy_addr=$1

#SCP to copy gatekeeper.py
scp -oStrictHostKeyChecking=no -i ./data/key.pem gatekeeper.py ubuntu@$server_addr:gatekeeper.py

ssh -oStrictHostKeyChecking=no -tt -i ./data/key.pem ubuntu@$server_addr << EOF
    sudo apt-get update
    
    sudo apt-get -y install python3-pip

    sudo pip3 install flask

    echo "$proxy_addr" > proxy_addr

    sudo nohup python3 gatekeeper.py &

    curl -X POST http://localhost/process_request -d "SELECT * FROM film_actor;"

    exit
EOF