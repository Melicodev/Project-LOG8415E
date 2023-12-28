#!/bin/bash

server_addr=$1
manager=$2
worker1=$3
worker2=$4
worker3=$5

# SSH into the remote server and execute the following commands
ssh -oStrictHostKeyChecking=no -tt -i ./data/key.pem ec2-user@$server_addr << EOF
    # Update the system packages
    sudo apt-get update

    #install tar is not the case
    sudo apt-get install tar

    sudo mkdir -p /opt/mysqlcluster/home
    cd /opt/mysqlcluster/home

    #download
    wget http://dev.mysql.com/get/Downloads/MySQL-Cluster-7.2/mysql- cluster-gpl-7.2.1-linux2.6-x86_64.tar.gz
    tar xvf mysql-cluster-gpl-7.2.1-linux2.6-x86_64.tar.gz
    ln -s mysql-cluster-gpl-7.2.1-linux2.6-x86_64 mysqlc

    echo 'export MYSQLC_HOME=/opt/mysqlcluster/home/mysqlc' > /etc/profile.d/mysqlc.sh
    echo 'export PATH=$MYSQLC_HOME/bin:$PATH' >> /etc/profile.d/mysqlc.sh
    source /etc/profile.d/mysqlc.sh step

    sudo apt-get update && sudo apt-get -y install libncurses5 

    sudo mkdir -p /opt/mysqlcluster/deploy
    cd /opt/mysqlcluster/deploy
    sudo mkdir conf
    sudo mkdir mysqld_data
    sudo mkdir ndb_data
    cd conf

    sudo -i
    echo "[mysqld]
    ndbcluster
    datadir=/opt/mysqlcluster/deploy/mysqld_data
    basedir=/opt/mysqlcluster/home/mysqlc
    port=3306" > /opt/mysqlcluster/deploy/conf/my.cnf

    #gedit config.ini
    echo "[ndb_mgmd]
    hostname=$manager
    datadir=/opt/mysqlcluster/deploy/ndb_data
    nodeid=1"

    echo "[ndbd default]
    noofreplicas=2
    datadir=/opt/mysqlcluster/deploy/ndb_data"

    echo "[ndbd]
    hostname=$worker1
    nodeid=3"

    echo "[ndbd]
    hostname=$worker2
    nodeid=4"

    echo "[ndbd]
    hostname=$worker3
    nodeid=5"

    echo "[mysqld]
    nodeid=50" > /opt/mysqlcluster/deploy/conf/config.ini
    exit

    sudo /opt/mysqlcluster/home/mysqlc/bin/ndb_mgmd -f/opt/mysqlcluster/deploy/conf/config.ini --initial --configdir=/opt/mysqlcluster/deploy/conf/

    # Exit the SSH session
exit
EOF
