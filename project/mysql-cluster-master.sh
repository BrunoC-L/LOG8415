#!/bin/bash

echo $(pwd) >> /var/log/user-data.log
sudo apt update

echo "mysql cluster master" >> /var/log/user-data.log

wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.0/mysql-cluster-community-management-server_8.0.31-1ubuntu20.04_amd64.deb
sudo dpkg -i mysql-cluster-community-management-server_8.0.31-1ubuntu20.04_amd64.deb

echo "config.ini" >> /var/log/user-data.log
sudo mkdir /var/lib/mysql-cluster



# sudo apt -y install libclass-methodmaker-perl
# sudo apt -y install libncurses5

# version=mysql-cluster-gpl-7.2.1-linux2.6-x86_64

# wget http://dev.mysql.com/get/Downloads/MySQL-Cluster-7.2/$version.tar.gz
# tar -xf  $version.tar.gz

# sudo mkdir mysql-cluster
# sudo mkdir /usr/local/mysql
# sudo mkdir /usr/local/mysql/data
# sudo mkdir /usr/local/mysql/mysql-cluster

# sudo echo "
# [ndbd default]
# [ndb_mgmd]
# # Management process options:
# hostname=
# datadir=/mysql-cluster

# [ndbd]
# hostname=
# NodeId=2
# datadir=/usr/local/mysql/data

# [ndbd]
# hostname=
# NodeId=3
# datadir=/usr/local/mysql/data

# [ndbd]
# hostname=
# NodeId=4
# datadir=/usr/local/mysql/data

# [mysqld]
# hostname=
# " > ./mysql-cluster/config.ini

# sudo $version/bin/ndb_mgmd -f ./mysql-cluster/config.ini
