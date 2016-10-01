#!/bin/bash

echo -e "\n\n====== STARTING HDFS ======\n\n"
$HADOOP_HOME/sbin/start-dfs.sh

echo -e "\n\n====== STARTING YARN ======\n\n"
$HADOOP_HOME/sbin/start-yarn.sh

echo -e "\n\n====== STARTING MAPREDUCE HISTORY SERVER ======\n\n"
$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver

echo -e "\n\n====== HDFS cluster overview ======\n\n"
$HADOOP_HOME/bin/hdfs dfsadmin -report
