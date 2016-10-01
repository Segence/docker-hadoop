#!/bin/bash

set -e

HDFS_REPLICATION_FACTOR_PARAMETER=$1
HDFS_REPLICATION_FACTOR=${HDFS_REPLICATION_FACTOR_PARAMETER:-2}
DOCKER_CONTAINER_NAME=$(hostname --fqdn)

docker run -itd \
--privileged \
--name $DOCKER_CONTAINER_NAME \
--net=host \
-e HDFS_REPLICATION_FACTOR=$HDFS_REPLICATION_FACTOR \
-e HADOOP_NAMENODE_HOST=$DOCKER_CONTAINER_NAME \
-v /hadoop/data:/data \
-v /hadoop/slaves-config:/config:ro \
-v /hadoop/deployments:/deployments:ro \
segence/hadoop
