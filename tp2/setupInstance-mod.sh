#!/bin/bash

apt-get update
apt-get remove docker docker-engine docker.io containerd runc

# Setting up the repository to install docker
apt-get update
apt-get -y install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo 5 >> /var/log/user-data.log
# Install docker engine
sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "FROM ubuntu:focal

RUN apt-get update && apt-get install -y openjdk-11-jdk
RUN apt-get update && apt-get install -y python3
RUN apt-get install -y pip
RUN python3 -V

RUN \
    echo 'export PATH=/bin:/usr/bin' >> ~/.profile &&\
    echo 'JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> ~/.profile &&\
    echo 'PATH=$PATH:$HOME/bin:$JAVA_HOME/bin' >> ~/.profile &&\
    echo 'export JAVA_HOME' >> ~/.profile &&\
    echo 'export JRE_HOME' >> ~/.profile &&\
    echo 'export PATH' >> ~/.profile

RUN apt-get update && apt-get install -y wget
RUN \
    wget https://downloads.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz &&\
    tar -xf hadoop-3.3.4.tar.gz -C /usr/local/

RUN \
    echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /usr/local/hadoop-3.3.4/etc/hadoop/hadoop-env.sh &&\
    echo 'export HADOOP_HOME=/usr/local/hadoop-3.3.4' >> /usr/local/hadoop-3.3.4/etc/hadoop/hadoop-env.sh

# setting up the .profile file, would have to use source ~/.profile on login though
RUN \
    echo 'HADOOP_HOME=/usr/local/hadoop-3.3.4' >> ~/.profile &&\
    echo 'PATH=$HADOOP_HOME/bin:$PATH' >> ~/.profile &&\
    echo 'export HADOOP_HOME' >> ~/.profile &&\
    echo 'export PATH' >> ~/.profile

RUN python3 -m pip install pyspark
" > dockerfile
echo "Docker build starting" >> /var/log/user-data.log
sudo docker build - < dockerfile &>> /var/log/docker-build.log
echo "Docker build completed" >> /var/log/user-data.log

