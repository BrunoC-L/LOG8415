#!/bin/bash
echo "sudo apt update " >> /var/log/user-data.log
sudo apt update >> /var/log/user-data.log
echo "sudo apt install openjdk-11-jdk -y " >> /var/log/user-data.log
sudo apt install openjdk-11-jdk -y >> /var/log/user-data.log
echo "java -version; javac -version " >> /var/log/user-data.log
java -version; javac -version >> /var/log/user-data.log
# this has an interactive window bc of some version already installed and requires input idk wtf so i commented it to see if it works without
# echo "sudo apt install openssh-server openssh-client -y " >> /var/log/user-data.log
# sudo apt install openssh-server openssh-client -y >> /var/log/user-data.log
echo "sudo service ssh start " >> /var/log/user-data.log
sudo service ssh start >> /var/log/user-data.log

echo "sudo adduser hdoop " >> /var/log/user-data.log
sudo adduser hdoop >> /var/log/user-data.log
echo "su - hdoop " >> /var/log/user-data.log
su - hdoop >> /var/log/user-data.log

echo "ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa " >> /var/log/user-data.log
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa >> /var/log/user-data.log
echo "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys " >> /var/log/user-data.log
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys >> /var/log/user-data.log
echo "chmod 0600 ~/.ssh/authorized_keys " >> /var/log/user-data.log
chmod 0600 ~/.ssh/authorized_keys >> /var/log/user-data.log

echo "wget https://downloads.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz " >> /var/log/user-data.log
wget https://downloads.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz >> /var/log/user-data.log
echo "tar xzf hadoop-3.3.4.tar.gz " >> /var/log/user-data.log
tar xzf hadoop-3.3.4.tar.gz >> /var/log/user-data.log
echo "cat .bashrc BEFORE" >> /var/log/user-data.log
cat .bashrc >> /var/log/user-data.log
echo '
#Hadoop Related Options
export HADOOP_HOME=/home/hdoop/hadoop-3.3.4
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
export HADOOP_OPTS"-Djava.library.path=$HADOOP_HOME/lib/nativ"
' >> .bashrc
source ~/.bashrc
echo "cat .bashrc AFTER" >> /var/log/user-data.log
cat .bashrc >> /var/log/user-data.log

echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
mkdir /home/hdoop/tmpdata
mkdir /home/hdoop/dfsdata
mkdir /home/hdoop/dfsdata/namenode
mkdir /home/hdoop/dfsdata/datanode

for file in core hdfs mapred yarn
do
    cat hadoop_file_overwrites/$file-site.xml > $HADOOP_HOME/etc/hadoop/$file-site.xml
done

# FILE_$file replaced in {}-mod.sh, see run.sh
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/hadoop_file_overwrites/core-site.xml > $HADOOP_HOME/etc/hadoop/core-site.xml
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/hadoop_file_overwrites/hdfs-site.xml > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/hadoop_file_overwrites/mapred-site.xml > $HADOOP_HOME/etc/hadoop/mapred-site.xml
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/hadoop_file_overwrites/yarn-site.xml > $HADOOP_HOME/etc/hadoop/yarn-site.xml

hdfs namenode -format
./start-dfs.sh
./start-yarn.sh
jps
curl http://localhost:9870
curl http://localhost:9864
curl http://localhost:8088
