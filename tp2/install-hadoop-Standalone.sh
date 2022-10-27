#installing java
echo "sudo apt update " 
sudo apt update 
echo "sudo apt install openjdk-11-jdk -y " 
sudo apt install openjdk-11-jdk -y 
echo "java -version; javac -version " 
java -version

#adding java environement variables
echo 'export PATH=/bin:/usr/bin' >> ~/.profile
echo 'JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
PATH=$PATH:$HOME/bin:$JAVA_HOME/bin
export JAVA_HOME
export JRE_HOME
export PATH' >> ~/.profile

downloading hadoop
wget https://downloads.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz
sudo tar -xf hadoop-3.3.4.tar.gz -C /usr/local/
cd /usr/local
# changing permissions to write in hadoop-env.sh file
sudo chmod a+rw hadoop-3.3.4 hadoop-3.3.4/etc hadoop-3.3.4/etc/hadoop hadoop-3.3.4/etc/hadoop/hadoop-env.sh

cd /usr/local/hadoop-3.3.4

#adding hadoop environement variables
echo 'HADOOP_PREFIX=/usr/local/hadoop-3.3.4
PATH=$HADOOP_PREFIX/bin:$PATH
export HADOOP_PREFIX
export PATH' >> ~/.profile
source ~/.profile

# defining parameters in hadoop-env.sh
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_PREFIX=/usr/local/hadoop-3.3.4' >> ./etc/hadoop/hadoop-env.sh

#downloading wordcount java file
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/WordCount.java >./WordCount.java

# create wordcount jar file
hadoop com.sun.tools.javac.Main WordCount.java
jar cf wc.jar WordCount*.class

cd input

# downloading input data
#does not work yet
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/pg4300.txt >./pg4300.txt

#test files 
#echo 'Hello World Bye World'>> file01
#echo 'Hello Hadoop Goodbye Hadoop'>> file02

cd ..

# running the application
hadoop jar wc.jar WordCount input output
hadoop fs -cat ./output/part-r-00000

