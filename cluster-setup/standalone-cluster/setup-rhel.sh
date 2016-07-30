#!/bin/bash

yum update -y
yum install bind-utils docker docker-registry -y
systemctl enable docker.service
/sbin/sysctl -w net.ipv4.ip_forward=1

mkdir -p /hadoop/data
mkdir -p /hadoop/deployments
mkdir -p /hadoop/slaves-config

useradd hadoop
chown -R hadoop:hadoop /hadoop

systemctl start docker.service
