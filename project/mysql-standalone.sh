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

echo "server set up" >> /var/log/user-data.log

# sudo vi /etc/mysql/mysql.conf.d/mysqld.cnf  # Set IP allowed 0.0.0.0
# sudo service mysql restart

# sudo mysql -e "use sakila; select * from inventory"
