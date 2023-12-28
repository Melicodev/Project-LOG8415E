#!/bin/bash

server_addr=$1

: <<'COMMENT'
This Bash script automates the setup and benchmarking of the MySQL standalone server on a specified remote server.
It uses SSH to connect to the server, updates system packages, installs MySQL, configures MySQL to listen on all IP addresses,
downloads the Sakila sample database, sets up MySQL user authentication, creates and populates the Sakila database,
installs sysbench for benchmarking, prepares, runs, and cleans up a sysbench OLTP (Online Transaction Processing)
read-write benchmark on the Sakila database, and outputs the benchmark results to a file named "standalone_benchmark_results.txt".
COMMENT

chmod 600 ./data/key.pem

# SSH into the remote server and execute the following commands
# Update the system packages
ssh -oStrictHostKeyChecking=no -tt -i ./data/key.pem ubuntu@${server_addr} << EOF

    sudo apt-get update

    # Install MySQL
    sudo apt-get install mysql-server

    #Run the mysql_secure_installation script to address several security concerns in a default MySQL installation
    #sudo mysql_secure_installation

    #I do this because i want to change MySQL configuration so it can listen to my ip address
    sudo -i
    echo "[mysqld]
    bind-address=0.0.0.0" > /etc/mysql/mysql.conf.d/mysqld.cnf
    exit
    sudo systemctl restart mysql


    #Download sakila
    wget https://downloads.mysql.com/docs/sakila-db.zip

    #install zip because I'll need it later:
    sudo apt-get install zip
    unzip sakila-db.zip -d sakila


    #I change the password to be able to log in:
    sudo mysql
    ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';
    quit

    #To log in to MySQL as the root user
    mysql -u root -p
    root

    #Create the database structure and populate the database structure
    SOURCE ./sakila/sakila-db/sakila-schema.sql;
    SOURCE ./sakila/sakila-db/sakila-data.sql;

    #Confirm that the sample database is installed correctly
    USE sakila

    quit

    sudo apt-get install sysbench

    #MySQL benchmark :
    sudo sysbench oltp_read_write --table-size=100000 --db-driver=mysql --mysql-db=sakila --mysql-user=root --mysql-password=root --mysql-host=$server_addr prepare
    sudo sysbench oltp_read_write --table-size=100000 --db-driver=mysql --threads=6 --max-time=60 --max-requests=0 --mysql-db=sakila --mysql-user=root --mysql-password=root  --mysql-host=$server_addr run > \\wsl.localhost\Ubuntu\home\meli\standalone_benchmark_results.txt
    sudo sysbench oltp_read_write --mysql-db=sakila --mysql-user=root --mysql-password=root --mysql-host=$server_addr cleanup
    exit
EOF


