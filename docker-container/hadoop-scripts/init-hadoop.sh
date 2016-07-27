#!/bin/bash
#
# This task is to run on startup to set the Hadoop namenode
# host in configuration files and create the required Hadoop data directories
#
sed -i -e 's/HADOOP_NAMENODE_HOST/'"$HADOOP_NAMENODE_HOST"'/g' $HADOOP_HOME/etc/hadoop/core-site.xml
sed -i -e 's/HADOOP_NAMENODE_HOST/'"$HADOOP_NAMENODE_HOST"'/g' $HADOOP_HOME/etc/hadoop/yarn-site.xml

# Creating data directories
mkdir -p /data/hdfs/namenode
mkdir -p /data/hdfs/datanode
mkdir -p /data/logs/hadoop

# Change ownership
chown -R hadoop:hadoop /data
