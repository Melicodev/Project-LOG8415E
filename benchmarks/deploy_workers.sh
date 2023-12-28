#!/bin/bash

server_addr=$1
worker=$2

: <<'COMMENT'
This Bash script facilitates the deployment of the MySQL Cluster data node on a specified worker server. 
It connects to the remote server using SSH, updates system packages, installs necessary packages like libncurses5 and tar,
creates directories for MySQL Cluster, downloads and extracts MySQL Cluster, sets up environment variables,
and starts the MySQL Cluster data node (ndbd) on the specified worker server.
COMMENT

# SSH into the remote server and execute the following commands
ssh -oStrictHostKeyChecking=no -tt -i ./data/key.pem ubuntu@$server_addr << EOF
    # Update the system packages
    sudo apt-get update
    sudo apt-get -y install libncurses5 

    #install tar if it is not the case
    sudo apt-get install tar

    sudo mkdir -p /opt/mysqlcluster/home
    cd /opt/mysqlcluster/home

    #download mysql
    sudo wget http://dev.mysql.com/get/Downloads/MySQL-Cluster-7.2/mysql- cluster-gpl-7.2.1-linux2.6-x86_64.tar.gz
    sudo tar xvf mysql-cluster-gpl-7.2.1-linux2.6-x86_64.tar.gz
    sudo ln -s mysql-cluster-gpl-7.2.1-linux2.6-x86_64 mysqlc

    sudo -i
    echo 'export MYSQLC_HOME=/opt/mysqlcluster/home/mysqlc' > /etc/profile.d/mysqlc.sh
    echo 'export PATH=$MYSQLC_HOME/bin:$PATH' >> /etc/profile.d/mysqlc.sh
    source /etc/profile.d/mysqlc.sh step

    sudo mkdir -p /opt/mysqlcluster/deploy/ndb_data

    sudo /opt/mysqlcluster/home/mysqlc/bin/ndbd -c $worker:1186
exit
EOF
