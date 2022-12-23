singleIP=52.23.204.143
sudo mysql --host=$singleIP -ubruno -pbruno -e "use sakila; select * from inventory limit 1;"


sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$singleIP prepare
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$singleIP --time=10 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$singleIP --time=10 --threads=4 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$singleIP --time=10 --threads=16 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$singleIP --time=10 --threads=64 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$singleIP cleanup




masterIP=54.197.191.35
sudo mysql --host=$masterIP -ubruno -pbruno -e "use sakila; select * from inventory limit 1;"
sudo mysql --host=$masterIP -ubruno -pbruno -e "show engine ndb status \g;"


sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP prepare
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP --time=10 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP --time=10 --threads=4 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP --time=10 --threads=16 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP --time=10 --threads=64 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP cleanup
