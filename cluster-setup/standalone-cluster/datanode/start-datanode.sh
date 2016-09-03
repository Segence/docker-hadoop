#!/bin/bash

set -e

NEWLINE=$'\n'
HELP_DESCRIPTION=$"\nUsage: `basename "$0"` <HOST NAME> <NAMENODE HOST NAME> [DNS SEARCH DOMAIN] [DNS SERVER HOST]
                   \nExample: `basename "$0"` hadoop-slave1.cluster.local hadoop-master.cluster.local cluster.local dns.cluster.local
                   \n"

if (($# < 2)); then
  echo -e $HELP_DESCRIPTION
  exit 1
fi

HOSTNAME=$1
HADOOP_NAMENODE_HOSTNAME=$2
DNS_SEARCH=$3
DNS_SERVER=$4

if [ -z ${HOSTNAME} ]; then
    echo "Please provide the host name as the first argument"
    exit 1
else
    DOCKER_HOST_NAME="--hostname $HOSTNAME"
    DOCKER_CONTAINER_NAME="--name $HOSTNAME"
fi

if [ -z ${DNS_SEARCH} ]; then
    DOCKER_DNS_SEARCH=""
else
    DOCKER_DNS_SEARCH="--dns-search=$DNS_SEARCH"
fi

if [ -z ${DNS_SERVER} ]; then
    DOCKER_DNS_SERVER=""
else
    DOCKER_DNS_SERVER="--dns=$DNS_SERVER"
fi

docker run -itd \
--privileged \
$DOCKER_HOST_NAME \
$DOCKER_CONTAINER_NAME \
$DOCKER_DNS_SERVER \
$DOCKER_DNS_SEARCH \
-e HADOOP_NAMENODE_HOST=$HADOOP_NAMENODE_HOSTNAME \
-p 2222:2222 \
-p 50010:50010 \
-v /hadoop/data:/data \
-v /hadoop/slaves-config:/config:ro \
segence/hadoop:0.3.1
