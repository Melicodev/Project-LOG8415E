#!/bin/bash

server_addr=$1

scp -oStrictHostKeyChecking=no -i ./data/key.pem proxy.py ubuntu@$server_addr:proxy.py
scp -oStrictHostKeyChecking=no -i ./data/key.pem ./data/mysqlcluster.json ubuntu@$server_addr:mysqlcluster.json

ssh -oStrictHostKeyChecking=no -tt -i ./data/key.pem ubuntu@$server_addr << EOF
    sudo apt-get update

    sudo apt-get -y install python3-pip

    sudo pip3 install flask

    sudo pip3 install pymysql

    sudo nohup python3 proxy.py &

    curl -X POST http://localhost/direct_hit -d "SELECT * FROM film_actor" 
    exit
EOF



