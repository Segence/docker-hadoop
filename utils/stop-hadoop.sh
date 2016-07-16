#!/bin/bash

echo -e "\n"

$HADOOP_HOME/sbin/yarn-daemon.sh stop nodemanager

echo -e "\n"

$HADOOP_HOME/sbin/stop-yarn.sh

echo -e "\n"

$HADOOP_HOME/sbin/stop-dfs.sh

echo -e "\n"
