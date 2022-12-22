#!/bin/bash

echo $(pwd) >> /var/log/user-data.log
sudo apt update

echo "mysql cluster worker" >> /var/log/user-data.log

# wget https://downloads.mysql.com/archives/get/p/14/file/mysql-cluster_8.0.30-1ubuntu22.04_amd64.deb-bundle.tar
# tar -xvf mysql-cluster_8.0.30-1ubuntu22.04_amd64.deb-bundle.tar

# sudo apt -y install libclass-methodmaker-perl
# sudo apt -y install libncurses5

# sudo dpkg -i mysql-cluster-community-data-node_8.0.30-1ubuntu22.04_amd64.deb

# sudo ndb_mgmd -f /var/lib/mysql-cluster/config.ini
