#!/bin/bash

manager=$1

: <<'COMMENT'
This Bash script installs sysbench, then performs a sysbench OLTP read-write benchmark on a MySQL cluster managed by a specified manager node. The benchmark involves preparing the Sakila database, running the benchmark with six threads for a maximum of 60 seconds, and finally cleaning up the benchmark. The results of the benchmark are redirected to a file named "cluster_benchmark_results.txt" in the specified directory.
The benchmark is conducted using the NDB storage engine for MySQL cluster-specific configuration.
COMMENT

sudo apt-get install sysbench


sudo sysbench oltp_read_write --table-size=100000 --db-driver=mysql --mysql-db=sakila --mysql-user=root --mysql-password=root --mysql-host=$manager --mysql_storage_engine=ndbcluster prepare
sudo sysbench oltp_read_write --table-size=100000 --db-driver=mysql --threads=6 --max-time=60 --max-requests=0 --mysql-db=sakila --mysql-db=sakila --mysql-user=root --mysql-password=root --mysql-host=$manager --mysql_storage_engine=ndbcluster run > \\wsl.localhost\Ubuntu\home\meli\cluster_benchmark_results.txt
sudo sysbench oltp_read_write --table-size=100000 --db-driver=mysql --mysql-db=sakila --mysql-user=root --mysql-password=root --mysql-host=$manager --mysql_storage_engine=ndbcluster cleanup