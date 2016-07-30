#!/bin/bash

yum update -y
yum install bind-utils telnet nmap ntp docker docker-registry -y
systemctl enable ntpd.service
systemctl enable docker.service
/sbin/sysctl -w net.ipv4.ip_forward=1

# Set system timezone to UTC
/bin/cp /usr/share/zoneinfo/UTC /etc/localtime

mkdir -p /hadoop/data
mkdir -p /hadoop/deployments
mkdir -p /hadoop/slaves-config

# Creating hadoop user and adding it to the wheel group to automatically
# be able to run sudo commands
useradd -G wheel hadoop
chown -R hadoop:hadoop /hadoop

systemctl start ntpd.service
systemctl start docker.service
