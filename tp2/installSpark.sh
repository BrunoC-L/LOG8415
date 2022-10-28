#!bin/bash

apt-get update -y

apt-get install default-jdf -y
apt-get install scala -y

wget https://dlcdn.apache.org/spark/spark-3.3.1/spark-3.3.1-bin-hadoop3.tgz

tar -xvzf spark-3.3.1-bin-hadoop3.tgz

mv spark-3.3.1-bin-hadoop3 /opt/spark

echo "SPARK_HOME=/opt/spark
PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
export SPARK_HOME
export PATH" >> ~/.bashrc
source ~/.bashrc

bash start-master.sh 
bash start-slave.sh spark://localhost:7077