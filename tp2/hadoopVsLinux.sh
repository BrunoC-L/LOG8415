#!/bin/bash
# With hadoop 
# Downloading wordcount java file
TIMEFORMAT=%R

curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/WordCount.java >/usr/local/hadoop-3.3.4/WordCount.java

# Creating wordcount jar file
hadoop com.sun.tools.javac.Main WordCount.java
jar cf wc.jar WordCount*.class
mkdir /usr/local/hadoop-3.3.4/input
# Downloading input data
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/pg4300.txt >/usr/local/hadoop-3.3.4/input/pg4300.txt

# Test files 
#echo 'Hello World Bye World'>> file01
#echo 'Hello Hadoop Goodbye Hadoop'>> file02

# Running the application on hadoop
echo "HADOOP " >> /usr/local/hadoop-3.3.4/linux_result.txt
time hadoop jar wc.jar WordCount input output  >> /usr/local/hadoop-3.3.4/linux_result.txt
# Results
# hadoop fs -cat ./output/part-r-00000

echo "LINUX " >> /usr/local/hadoop-3.3.4/linux_result.txt
#running on linux 
time cat input/pg4300.txt | tr ' ' '\n' | sort | uniq -c >> /usr/local/hadoop-3.3.4/linux_result.txt

# cat /usr/local/hadoop-3.3.4/linux_result.txt
