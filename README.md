Segence Hadoop Docker container
===============================

Overview
--------

This Docker container contains a full Hadoop distribution with the following components:

- Hadoop 2.7.2 (including YARN)
- Oracle JDK 8
- Scala 2.11.8
- Spark 1.6.2

Starting the cluster
--------------------

1. Log in to the master node, e.g. `docker exec -it [CONTAINER ID] bash`
2. Become the *hadoop* user: `su hadoop`
3. Format the HDFS namenode: `~/utils/format-namenode.sh`
4. Start Hadoop: `~/utils/start-hadoop.sh`

Running the word count example
------------------------------

The script will create a directory called *input* with some sample files.
It'll upload them into the HDFS cluster and run a simple MapReduce job.
It'll print the results to the console.

1. Log in to the master node, e.g. `docker exec -it [CONTAINER ID] bash`
2. Become the *hadoop* user: `su hadoop`
3. Run `~/utils/run-wordcount.sh`

Web UI
------

Namenode UI: http://[MASTER NODE]:50070
where [MASTER NODE] is the IP address or host name of the Hadoop master.
