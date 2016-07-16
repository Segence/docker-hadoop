#!/bin/bash

echo -e "\n"

$HADOOP_HOME/sbin/start-dfs.sh

echo -e "\n"

$HADOOP_HOME/sbin/start-yarn.sh

echo -e "\n"

$HADOOP_HOME/sbin/yarn-daemon.sh start nodemanager

echo -e "\n"

#$HADOOP_HOME/sbin/hadoop-daemon.sh start datanode
echo -e "\n"

