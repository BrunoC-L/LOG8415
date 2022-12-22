#!/bin/bash

echo $(pwd) >> /var/log/user-data.log
sudo apt update

echo "mysql standalone" >> /var/log/user-data.log
sudo apt install -y mysql-server >> /var/log/user-data.log

echo "download sample db" >> /var/log/user-data.log
sudo wget https://downloads.mysql.com/docs/sakila-db.tar.gz && sudo tar -xf sakila-db.tar.gz -C /tmp/>> /var/log/user-data.log

echo "mysql" >> /var/log/user-data.log

sudo mysql -u root -e "SOURCE /tmp/sakila-db/sakila-schema.sql;"
sudo mysql -u root -e "SOURCE /tmp/sakila-db/sakila-data.sql;"
sudo mysql -u root -e "create user 'bruno'@'%' identified by 'bruno';"
sudo mysql -u root -e "GRANT ALL ON *.* TO 'bruno'@'%';"

echo "allow external mysql requests" >> /var/log/user-data.log
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/project/mysqld.cnf > mysqld.cnf
sudo cp mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
sudo service mysql restart

echo "requesting" >> /var/log/user-data.log
sudo mysql -e "use sakila; select * from inventory limit 1;" >> /var/log/user-data.log

# echo "sysbench" >> /var/log/user-data.log
sudo apt -y install sysbench
# sudo mysql -e "create database dbtest;"

# echo "ready" >> /var/log/user-data.log
