#!/bin/bash

echo $(pwd) >> /var/log/user-data.log
sudo apt update

echo "mysql cluster master" >> /var/log/user-data.log

version=mysql-cluster-community-management-server_7.6.6-1ubuntu18.04_amd64.deb

wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.6/$version
sudo dpkg -i $version

echo "waiting on node ips" >> /var/log/user-data.log
sleep 100

echo "config.ini" >> /var/log/user-data.log
sudo mkdir /var/lib/mysql-cluster
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/project/master-config.ini > config.ini
sudo cp config.ini /var/lib/mysql-cluster/config.ini

echo "install" >> /var/log/user-data.log
sudo apt -y install libtinfo5
sudo apt -y install libclass-methodmaker-perl
sudo apt -y install libncurses5

echo "ndb_mgmd" >> /var/log/user-data.log
sudo ndb_mgmd -f /var/lib/mysql-cluster/config.ini --ndb-nodeid=1 --reload >> /var/log/user-data.log

echo "custom cluster" >> /var/log/user-data.log
version=mysql-cluster_7.6.6-1ubuntu18.04_amd64.deb-bundle.tar
wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.6/$version
mkdir install
tar -xvf $version -C install/
cd install
sudo apt -y install libaio1 libmecab2
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/project/master-my.cnf > my.cnf
sudo mkdir /etc/mysql
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/project/master-mysqld.cnf > mysqld.cnf
echo "dependencies" >> /var/log/user-data.log
sudo dpkg -i mysql-common_7.6.6-1ubuntu18.04_amd64.deb
sudo dpkg -i mysql-cluster-community-client_7.6.6-1ubuntu18.04_amd64.deb
sudo dpkg -i mysql-client_7.6.6-1ubuntu18.04_amd64.deb
echo "done, waiting for interactive part 2" >> /var/log/user-data.log
