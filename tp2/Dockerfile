# Using ubuntu focal distribution
FROM ubuntu:focal

# Installing python3, java and pyspark
RUN apt-get update
RUN apt-get install -y openjdk-11-jdk
RUN apt-get install -y python3
RUN apt-get install -y pip
RUN apt-get install -y curl
RUN python3 -m pip install pyspark

# Setting up the environment variables in the profile for running hadoop
RUN \
    echo 'export PATH=/bin:/usr/bin' >> ~/.profile &&\
    echo 'JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> ~/.profile &&\
    echo 'PATH=$PATH:$HOME/bin:$JAVA_HOME/bin' >> ~/.profile &&\
    echo 'export JAVA_HOME' >> ~/.profile &&\
    echo 'export JRE_HOME' >> ~/.profile &&\
    echo 'export PATH' >> ~/.profile

# Downloading hadoop distribution
RUN apt-get update && apt-get install -y wget
RUN \
    wget https://downloads.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz &&\
    tar -xf hadoop-3.3.4.tar.gz -C /usr/local/

# Setting up the environment variables in the hadoop environment
RUN \
    echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /usr/local/hadoop-3.3.4/etc/hadoop/hadoop-env.sh &&\
    echo 'export HADOOP_HOME=/usr/local/hadoop-3.3.4' >> /usr/local/hadoop-3.3.4/etc/hadoop/hadoop-env.sh

# Setting the hadoop environment variables to be able to use the hadoop command
# Precising that from now it is bash scripting (this is to be able to use source)

RUN \
    echo 'HADOOP_HOME=/usr/local/hadoop-3.3.4' >> ~/.profile &&\
    echo 'PATH=$HADOOP_HOME/bin:$PATH' >> ~/.profile &&\
    echo 'export HADOOP_HOME' >> ~/.profile &&\
    echo 'export PATH' >> ~/.profile

# SHELL ["/bin/bash", "-c"]
# RUN source ~/.profile

# Script to run on the docker container at initialisation
CMD curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/docker-run.sh > docker-run.sh && bash docker-run.sh
