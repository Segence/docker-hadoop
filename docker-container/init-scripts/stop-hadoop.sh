#!/bin/bash

echo -e "\n\n====== STOPPING MAPREDUCE HISTORY SERVER ======\n\n"
$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh stop historyserver

echo -e "\n\n====== STOPPING YARN ======\n\n"
$HADOOP_HOME/sbin/stop-yarn.sh

echo -e "\n\n====== STOPPING HDFS ======\n\n"
$HADOOP_HOME/sbin/stop-dfs.sh
