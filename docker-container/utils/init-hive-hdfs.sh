#!/bin/bash

hdfs dfs -mkdir -p /tmp
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -chmod g+w /tmp
hdfs dfs -chmod 0777 /tmp
hdfs dfs -chmod g+w /user/hive/warehouse
