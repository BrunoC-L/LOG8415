sudo dpkg -i mysql-cluster-community-server_7.6.6-1ubuntu18.04_amd64.deb
sudo dpkg -i mysql-server_7.6.6-1ubuntu18.04_amd64.deb

echo "my.cnf" >> /var/log/user-data.log
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/project/master-my.cnf > my.cnf
sudo mkdir /etc/mysql
sudo cp my.cnf /etc/mysql/my.cnf
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/project/master-mysqld.cnf > mysqld.cnf
sudo cp mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

echo "restart mysql" >> /var/log/user-data.log
sudo systemctl restart mysql

echo "download sample db" >> /var/log/user-data.log
sudo wget https://downloads.mysql.com/docs/sakila-db.tar.gz && sudo tar -xf sakila-db.tar.gz -C /tmp/

sudo mysql -u root -e "SOURCE /tmp/sakila-db/sakila-schema.sql;"
sudo mysql -u root -e "SOURCE /tmp/sakila-db/sakila-data.sql;"
sudo mysql -u root -e "create user 'bruno'@'%' identified by 'bruno';"
sudo mysql -u root -e "GRANT ALL ON *.* TO 'bruno'@'%';"