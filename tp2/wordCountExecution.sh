# With hadoop 
cd /usr/local/hadoop-3.3.4
# Downloading wordcount java file
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/WordCount.java >./WordCount.java

# Creating wordcount jar file
hadoop com.sun.tools.javac.Main WordCount.java
jar cf wc.jar WordCount*.class

mkdir input
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