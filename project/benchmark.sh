standaloneIP=44.201.115.10

sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$standaloneIP prepare
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$standaloneIP --time=60 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$standaloneIP --time=60 --threads=4 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$standaloneIP --time=60 --threads=16 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$standaloneIP --time=60 --threads=64 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$standaloneIP --time=60 --threads=256 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$standaloneIP cleanup


masterIP=3.87.207.202

sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP prepare
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP --time=60 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP --time=60 --threads=4 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP --time=60 --threads=16 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP --time=60 --threads=64 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP --time=60 --threads=256 run
sudo sysbench oltp_read_write --mysql-user=bruno --mysql-password=bruno --mysql-db=sakila --mysql-host=$masterIP cleanup