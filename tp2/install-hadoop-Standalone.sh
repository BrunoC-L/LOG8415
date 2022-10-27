# Installing java
echo "sudo apt update " 
sudo apt update 
echo "sudo apt install openjdk-11-jdk -y " 
sudo apt install openjdk-11-jdk -y 
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
sudo tar -xf hadoop-3.3.4.tar.gz -C /usr/local/
cd /usr/local
# Changing permissions to write in hadoop-env.sh file
sudo chmod a+rw hadoop-3.3.4 hadoop-3.3.4/etc hadoop-3.3.4/etc/hadoop hadoop-3.3.4/etc/hadoop/hadoop-env.sh

cd /usr/local/hadoop-3.3.4

# Adding hadoop environement variables
echo 'HADOOP_PREFIX=/usr/local/hadoop-3.3.4
PATH=$HADOOP_PREFIX/bin:$PATH
export HADOOP_PREFIX
export PATH' >> ~/.profile
source ~/.profile

# Defining parameters in hadoop-env.sh
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_PREFIX=/usr/local/hadoop-3.3.4' >> ./etc/hadoop/hadoop-env.sh

# Downloading wordcount java file
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/WordCount.java >./WordCount.java

# Create wordcount jar file
hadoop com.sun.tools.javac.Main WordCount.java
jar cf wc.jar WordCount*.class

cd input

# Downloading input data
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/pg4300.txt >./pg4300.txt

# Test files 
#echo 'Hello World Bye World'>> file01
#echo 'Hello Hadoop Goodbye Hadoop'>> file02

cd ..

# Running the application
hadoop jar wc.jar WordCount input output
# Results
hadoop fs -cat ./output/part-r-00000

