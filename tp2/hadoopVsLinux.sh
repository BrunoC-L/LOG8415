#!/bin/bash
# With hadoop 
# Downloading wordcount java file
TIMEFORMAT=%R

curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/WordCount.java > /usr/local/hadoop-3.3.4/WordCount.java

cd /usr/local/hadoop-3.3.4

# Creating wordcount jar file
hadoop com.sun.tools.javac.Main WordCount.java
jar cf wc.jar WordCount*.class
rm -R /usr/local/hadoop-3.3.4/input
rm -R /usr/local/hadoop-3.3.4/output
mkdir /usr/local/hadoop-3.3.4/input
# Downloading input data
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/pg4300.txt > /usr/local/hadoop-3.3.4/input/pg4300.txt

# Test files 
#echo 'Hello World Bye World'>> file01
#echo 'Hello Hadoop Goodbye Hadoop'>> file02

# Running the application on hadoop
echo "HADOOP " >> /linuxHadoopResult.txt
{ time /usr/local/hadoop-3.3.4/bin/hadoop jar wc.jar WordCount input output  2>> remove.stderr ;} 2>> /linuxHadoopResult.txt
# Results
# hadoop fs -cat ./output/part-r-00000

echo "LINUX " >> /linuxHadoopResult.txt
#running on linux 
{ time cat input/pg4300.txt | tr ' ' '\n' | sort | uniq -c 2>> remove.stderr ;} 2>> /linuxHadoopResult.txt

# cat /usr/local/hadoop-3.3.4/linuxHadoopResult.txt
