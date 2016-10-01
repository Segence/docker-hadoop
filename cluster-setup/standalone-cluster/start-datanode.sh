#!/bin/bash

set -e

NEWLINE=$'\n'
HELP_DESCRIPTION=$"\nUsage: `basename "$0"` <NAMENODE HOST NAME> [HDFS REPLICATION FACTOR]
                   \nExample: `basename "$0"` hadoop-namenode.cluster.local
                   \n"

if (($# < 1)); then
  echo -e $HELP_DESCRIPTION
  exit 1
fi

HADOOP_NAMENODE_HOSTNAME=$1

HDFS_REPLICATION_FACTOR_PARAMETER=$2
HDFS_REPLICATION_FACTOR=${HDFS_REPLICATION_FACTOR_PARAMETER:-2}

DOCKER_CONTAINER_NAME=$(hostname --fqdn)

docker run -itd \
--privileged \
--name $DOCKER_CONTAINER_NAME \
--net=host \
-e HADOOP_NAMENODE_HOST=$HADOOP_NAMENODE_HOSTNAME \
-v /hadoop/data:/data \
-v /hadoop/slaves-config:/config:ro \
segence/hadoop
