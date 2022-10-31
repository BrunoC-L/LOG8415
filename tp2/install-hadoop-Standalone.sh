# Installing java
echo "sudo apt update " 
pt update 
echo "sudo apt install openjdk-11-jdk -y " 
apt install openjdk-11-jdk -y 
echo "java -version; javac -version " 
java -version

# Adding java environement variables
echo 'export PATH=/bin:/usr/bin' >> ~/.profile
echo 'JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
PATH=$PATH:$HOME/bin:$JAVA_HOME/bin
export JAVA_HOME
export JRE_HOME
export PATH' >> ~/.profile

# Downloading hadoop
wget https://downloads.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz
tar -xf hadoop-3.3.4.tar.gz -C /usr/local/
cd /usr/local
# Changing permissions to write in hadoop-env.sh file
chmod a+rw hadoop-3.3.4 hadoop-3.3.4/etc hadoop-3.3.4/etc/hadoop hadoop-3.3.4/etc/hadoop/hadoop-env.sh

cd /usr/local/hadoop-3.3.4

# Adding hadoop environement variables
echo 'HADOOP_HOME=/usr/local/hadoop-3.3.4
PATH=$HADOOP_HOME/bin:$PATH
export HADOOP_HOME
export PATH' >> ~/.profile
source ~/.profile

# Defining parameters in hadoop-env.sh
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=/usr/local/hadoop-3.3.4' >> ./etc/hadoop/hadoop-env.sh
