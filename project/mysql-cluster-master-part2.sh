cd install

# this line requires a password, we pick "abcd" everytime for simplicity
sudo dpkg -i mysql-cluster-community-server_7.6.6-1ubuntu18.04_amd64.deb

# automatic


sudo dpkg -i mysql-server_7.6.6-1ubuntu18.04_amd64.deb

sudo cp my.cnf /etc/mysql/my.cnf
sudo cp mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

sudo systemctl restart mysql

sudo wget https://downloads.mysql.com/docs/sakila-db.tar.gz
sudo tar -xf sakila-db.tar.gz -C /tmp/

sudo mysql -u root -pabcd -e "SOURCE /tmp/sakila-db/sakila-schema.sql;"
sudo mysql -u root -pabcd -e "SOURCE /tmp/sakila-db/sakila-data.sql;"
sudo mysql -u root -pabcd -e "create user 'bruno'@'%' identified by 'bruno';"
sudo mysql -u root -pabcd -e "GRANT ALL ON *.* TO 'bruno'@'%';"





# to verify if it works


sudo apt install net-tools
sudo netstat
ps aux | grep mysql
sudo mysql -ubruno -pbruno -e "use sakila; select * from inventory limit 1;"
sudo mysql -ubruno -pbruno -e "show engine ndb status \g;"
sudo ndb_mgm -e show
