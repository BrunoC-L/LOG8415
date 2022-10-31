FROM ubuntu:focal

RUN apt-get update && apt-get install -y openjdk-11-jdk
RUN apt-get update && apt-get install -y python3
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