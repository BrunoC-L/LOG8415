#!/bin/bash

curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/soc-LiveJournal1Adj.txt > soc-LiveJournal1Adj.txt
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/network_problem.py > network_problem.py
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/hadoopVsLinux.sh > hadoopVsLinux.sh
curl https://raw.githubusercontent.com/BrunoC-L/LOG8415/main/tp2/hadoopVsSpark.sh > hadoopVsSpark.sh

bash hadoopVsLinux.sh
bash hadoopVsSpark.sh
python3 network_problem.py
