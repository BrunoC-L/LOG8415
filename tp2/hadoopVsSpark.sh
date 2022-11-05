#!/bin/bash
# With hadoop 
# Downloading wordcount java file
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/WordCount.java >/usr/local/hadoop-3.3.4/WordCount.java
cd /usr/local/hadoop-3.3.4
# Creating wordcount jar file
hadoop com.sun.tools.javac.Main WordCount.java
jar cf wc.jar WordCount*.class
mkdir ~/input2
# Downloading input data
curl http://www.gutenberg.ca/ebooks/buchanj-midwinter/buchanj-midwinter-00-t.txt > ~/input2/data1
curl http://www.gutenberg.ca/ebooks/carman-farhorizons/carman-farhorizons-00-t.txt > ~/input2/data2
curl http://www.gutenberg.ca/ebooks/colby-champlain/colby-champlain-00-t.txt > ~/input2/data3
curl http://www.gutenberg.ca/ebooks/cheyneyp-darkbahama/cheyneyp-darkbahama-00-t.txt > ~/input2/data4
curl http://www.gutenberg.ca/ebooks/delamare-bumps/delamare-bumps-00-t.txt > ~/input2/data5
curl http://www.gutenberg.ca/ebooks/charlesworth-scene/charlesworth-scene-00-t.txt > ~/input2/data6
curl http://www.gutenberg.ca/ebooks/delamare-lucy/delamare-lucy-00-t.txt > ~/input2/data7
curl http://www.gutenberg.ca/ebooks/delamare-myfanwy/delamare-myfanwy-00-t.txt > ~/input2/data8
curl http://www.gutenberg.ca/ebooks/delamare-penny/delamare-penny-00-t.txt > ~/input2/data9

TIMEFORMAT=%R

for i in 1 2 3
do
    rm -R /usr/local/hadoop-3.3.4/run$i
    mkdir /usr/local/hadoop-3.3.4/run$i

    # Running the application on hadoop
    for j in {1..9}
    do
        echo "Run $i Hadoop $j" >> /hadoopSparkResult.txt
        { time ./usr/local/hadoop-3.3.4/hadoop jar /usr/local/hadoop-3.3.4/wc.jar WordCount ~/input2/data$j /usr/local/hadoop-3.3.4/run$i/output$j 2>> remove.stderr;} 2>> /hadoopSparkResult.txt
        echo "Run $i Spark $j" >> /hadoopSparkResult.txt
        { time python3 /wordCount.py ~/input2/data$j 2>> remove.stderr ;} 2>> /hadoopSparkResult.txt
    done
done