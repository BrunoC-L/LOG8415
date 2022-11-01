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
curl http://www.gutenberg.ca/ebooks/buchanj-midwinter/buchanj-midwinter-00-t.txt > ~/input2/4vxdw3pa
curl http://www.gutenberg.ca/ebooks/carman-farhorizons/carman-farhorizons-00-t.txt > ~/input2/kh9excea
curl http://www.gutenberg.ca/ebooks/colby-champlain/colby-champlain-00-t.txt > ~/input2/dybs9bnk
curl http://www.gutenberg.ca/ebooks/cheyneyp-darkbahama/cheyneyp-darkbahama-00-t.txt > ~/input2/datumz6m
curl http://www.gutenberg.ca/ebooks/delamare-bumps/delamare-bumps-00-t.txt > ~/input2/j4j4xdw6
curl http://www.gutenberg.ca/ebooks/charlesworth-scene/charlesworth-scene-00-t.txt > ~/input2/ym8s5fm4
curl http://www.gutenberg.ca/ebooks/delamare-lucy/delamare-lucy-00-t.txt > ~/input2/2h6a75nk
curl http://www.gutenberg.ca/ebooks/delamare-myfanwy/delamare-myfanwy-00-t.txt > ~/input2/vwvram8
curl http://www.gutenberg.ca/ebooks/delamare-penny/delamare-penny-00-t.txt > ~/input2/weh83uyn
# Test files 
#echo 'Hello World Bye World'>> file01
#echo 'Hello Hadoop Goodbye Hadoop'>> file02
mkdir ~/hadoop
mkdir ~/spark

for i in 1 2 3 
do
    #remove old output directories if exist
    mkdir /usr/local/hadoop-3.3.4/run$i
    mkdir ~/hadoop/run$i
    mkdir ~/spark/run$i
    rm -r /usr/local/hadoop-3.3.4/run$i/output1 
    rm -r /usr/local/hadoop-3.3.4/run$i/output2 
    rm -r /usr/local/hadoop-3.3.4/run$i/output3 
    rm -r /usr/local/hadoop-3.3.4/run$i/output4 
    rm -r /usr/local/hadoop-3.3.4/run$i/output5 
    rm -r /usr/local/hadoop-3.3.4/run$i/output6 
    rm -r /usr/local/hadoop-3.3.4/run$i/output7 
    rm -r /usr/local/hadoop-3.3.4/run$i/output8 
    rm -r /usr/local/hadoop-3.3.4/run$i/output9 
    # Running the application on hadoop
    time hadoop jar /usr/local/hadoop-3.3.4/wc.jar WordCount ~/input2/4vxdw3pa /usr/local/hadoop-3.3.4/run$i/output1 2> ~/hadoop/run$i/output1.txt
    time hadoop jar /usr/local/hadoop-3.3.4/wc.jar WordCount ~/input2/kh9excea /usr/local/hadoop-3.3.4/run$i/output2 2> ~/hadoop/run$i/output2.txt
    time hadoop jar /usr/local/hadoop-3.3.4/wc.jar WordCount ~/input2/dybs9bnk /usr/local/hadoop-3.3.4/run$i/output3 2> ~/hadoop/run$i/output3.txt
    time hadoop jar /usr/local/hadoop-3.3.4/wc.jar WordCount ~/input2/datumz6m /usr/local/hadoop-3.3.4/run$i/output4 2> ~/hadoop/run$i/output4.txt
    time hadoop jar /usr/local/hadoop-3.3.4/wc.jar WordCount ~/input2/j4j4xdw6 /usr/local/hadoop-3.3.4/run$i/output5 2> ~/hadoop/run$i/output5.txt
    time hadoop jar /usr/local/hadoop-3.3.4/wc.jar WordCount ~/input2/ym8s5fm4 /usr/local/hadoop-3.3.4/run$i/output6 2> ~/hadoop/run$i/output6.txt
    time hadoop jar /usr/local/hadoop-3.3.4/wc.jar WordCount ~/input2/2h6a75nk /usr/local/hadoop-3.3.4/run$i/output7 2> ~/hadoop/run$i/output7.txt
    time hadoop jar /usr/local/hadoop-3.3.4/wc.jar WordCount ~/input2/vwvram8 /usr/local/hadoop-3.3.4/run$i/output8 2> ~/hadoop/run$i/output8.txt
    time hadoop jar /usr/local/hadoop-3.3.4/wc.jar WordCount ~/input2/weh83uyn /usr/local/hadoop-3.3.4/run$i/output9 2> ~/hadoop/run$i/output9.txt

    # Results
    # hadoop fs -cat ./output/part-r-00000

    # spark
    time spark-submit /opt/spark/examples/src/main/python.py ~/input2/4vxdw3pa 2> ~/spark/run$i/output1.txt
    time spark-submit /opt/spark/examples/src/main/python.py ~/input2/kh9excea  2> ~/spark/run$i/output2.txt
    time spark-submit /opt/spark/examples/src/main/python.py ~/input2/dybs9bnk  2> ~/spark/run$i/output3.txt
    time spark-submit /opt/spark/examples/src/main/python.py ~/input2/datumz6m  2> ~/spark/run$i/output4.txt
    time spark-submit /opt/spark/examples/src/main/python.py ~/input2/j4j4xdw6  2> ~/spark/run$i/output5.txt
    time spark-submit /opt/spark/examples/src/main/python.py ~/input2/ym8s5fm4  2> ~/spark/run$i/output6.txt
    time spark-submit /opt/spark/examples/src/main/python.py ~/input2/2h6a75nk  2> ~/spark/run$i/output7.txt
    time spark-submit /opt/spark/examples/src/main/python.py ~/input2/vwvram8  2> ~/spark/run$i/output8.txt
    time spark-submit /opt/spark/examples/src/main/python.py ~/input2/weh83uyn  2> ~/spark/run$i/output9.txt
done