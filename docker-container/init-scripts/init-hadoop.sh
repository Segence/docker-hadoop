#!/bin/bash
#
# This task is to run on startup to set the Hadoop namenode
# host in configuration files and create the required Hadoop data directories
#

HDFS_REPLICATION_FACTOR=${HDFS_REPLICATION_FACTOR:-3}
HADOOP_CURRENT_HOST=$(hostname --fqdn)

sed -i -e 's/HDFS_REPLICATION_FACTOR/'"$HDFS_REPLICATION_FACTOR"'/g' $HADOOP_CONF_DIR/hdfs-site.xml
sed -i -e 's/HADOOP_NAMENODE_HOST/'"$HADOOP_NAMENODE_HOST"'/g' $HADOOP_CONF_DIR/core-site.xml
sed -i -e 's/HADOOP_NAMENODE_HOST/'"$HADOOP_NAMENODE_HOST"'/g' $HADOOP_CONF_DIR/yarn-site.xml
sed -i -e 's/HADOOP_CURRENT_HOST/'"$HADOOP_CURRENT_HOST"'/g' $HADOOP_CONF_DIR/yarn-site.xml

# Creating data directories
mkdir -p /data/hdfs/namenode
mkdir -p /data/hdfs/datanode
mkdir -p /data/logs/hadoop

# Change ownership
chown -R hadoop:hadoop /data
