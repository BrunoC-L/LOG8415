#!/bin/bash

echo $(pwd) >> /var/log/user-data.log
sudo apt update

echo "mysql cluster worker" >> /var/log/user-data.log



version=mysql-cluster-community-data-node_7.6.6-1ubuntu18.04_amd64.deb

wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.6/$version
sudo dpkg -i $version

echo "waiting on node ips" >> /var/log/user-data.log
sleep 100

sudo mkdir -p /usr/local/mysql
sudo mkdir -p /usr/local/mysql/data



echo "my.cnf" >> /var/log/user-data.log
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/project/worker-my.cnf > my.cnf

sudo cp my.cnf /etc/my.cnf

echo "install" >> /var/log/user-data.log
sudo apt -y install libtinfo5
sudo apt -y install libclass-methodmaker-perl
sudo apt -y install libncurses5

echo "ndbd" >> /var/log/user-data.log
sudo ndbd

echo "done" >> /var/log/user-data.log

