#!/bin/bash

echo $(pwd) >> /var/log/user-data.log
sudo apt update

echo "mysql cluster master" >> /var/log/user-data.log

mysql_ubuntu=7.6.6-1ubuntu18.04_amd64.deb

version=mysql-cluster-community-management-server_$mysql_ubuntu

wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.6/$version
sudo dpkg -i $version

echo "waiting on node ips" >> /var/log/user-data.log
sleep 60

echo "config.ini" >> /var/log/user-data.log
sudo mkdir /var/lib/mysql-cluster
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/project/master-config.ini > config.ini
sudo cp config.ini /var/lib/mysql-cluster/config.ini

echo "my.cnf" >> /var/log/user-data.log
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/project/master-my.cnf > my.cnf
sudo mkdir /etc/mysql
sudo cp my.cnf /etc/mysql/my.cnf

echo "install" >> /var/log/user-data.log
sudo apt -y install libtinfo5
sudo apt -y install libclass-methodmaker-perl
sudo apt -y install libncurses5

echo "ndb_mgmd" >> /var/log/user-data.log
sudo ndb_mgmd -f /var/lib/mysql-cluster/config.ini --ndb-nodeid=1 >> /var/log/user-data.log

echo "custom cluster" >> /var/log/user-data.log
version=mysql-cluster_$mysql_ubuntu-bundle.tar
wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.6/$version
mkdir install
tar -xvf $version -C install/
cd install
sudo apt install libaio1 libmecab2
echo "dependencies" >> /var/log/user-data.log
sudo dpkg -i mysql-common_$mysql_ubuntu
echo "1" >> /var/log/user-data.log
sudo dpkg -i mysql-cluster-community-client_$mysql_ubuntu
echo "2" >> /var/log/user-data.log
sudo dpkg -i mysql-client_$mysql_ubuntu
echo "3" >> /var/log/user-data.log
sudo dpkg -i mysql-cluster-community-server_$mysql_ubuntu
echo "4" >> /var/log/user-data.log
sudo dpkg -i mysql-server_$mysql_ubuntu

echo "restart mysql" >> /var/log/user-data.log
sudo systemctl restart mysql

echo "download sample db" >> /var/log/user-data.log
sudo wget https://downloads.mysql.com/docs/sakila-db.tar.gz && sudo tar -xf sakila-db.tar.gz -C /tmp/>> /var/log/user-data.log

sudo mysql -u root -pabcd -e "SOURCE /tmp/sakila-db/sakila-schema.sql;"
sudo mysql -u root -pabcd -e "SOURCE /tmp/sakila-db/sakila-data.sql;"
sudo mysql -u root -pabcd -e "create user 'bruno'@'%' identified by 'bruno';"
sudo mysql -u root -pabcd -e "GRANT ALL ON *.* TO 'bruno'@'%';"
