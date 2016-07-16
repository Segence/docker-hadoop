#!/bin/bash

#
# This utility cleans all data from the HDFS directories.
# Useful when want to rebuild a cluster so we can clean out the old content.
#

rm -rf data-master/hdfs
rm -rf data-master/logs
rm -rf data-slave1/hdfs
rm -rf data-slave1/logs
