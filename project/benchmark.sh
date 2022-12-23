singleIP=44.202.228.30
sudo mysql --host=$singleIP -ubruno -pbruno -e "use sakila; select * from inventory limit 1;"

sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$singleIP prepare
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$singleIP --time=10 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$singleIP --time=10 --threads=4 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$singleIP --time=10 --threads=16 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$singleIP --time=10 --threads=64 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$singleIP --time=10 --threads=256 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$singleIP cleanup


masterIP=3.92.205.148
sudo mysql --host=$masterIP -ubruno -pbruno -e "use sakila; select * from inventory limit 1;"

sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP prepare
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP --time=10 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP --time=10 --threads=4 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP --time=10 --threads=16 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP --time=10 --threads=64 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP --time=10 --threads=256 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP cleanup
