Segence Hadoop Docker container
===============================

Overview
--------

This Docker container contains a full Hadoop distribution with the following components:

- Hadoop 2.7.2 (including YARN)
- Oracle JDK 8
- Scala 2.11.8
- Spark 1.6.2

Setting up a new Hadoop cluster
-------------------------------

For all below steps the Docker image `segence/hadoop:0.1.0` has to be built or
pulled from DockerHub.

### Setting up a local Hadoop cluster

This will set up a local Hadoop cluster using bridged networking with one master
and one slave node.

1. Go into the *cluster-setup/local-cluster* directory: `cd cluster-setup/local-cluster`
2. Edit the `slaves-config/slaves` file if you want to add more slaves other than the default one slave node. If you add more slaves then also edit the `docker-compose.yml`
by adding more slave node configuration.
3. Launch the new cluster: `docker-compose up -d`

### Setting up a standalone Hadoop cluster

#### Namenode setup

1. On the namenode machine, go into the *cluster-setup/standalone-cluster/namenode* directory: `cd cluster-setup/standalone-cluster/namenode`
2. Create a subdirectory for the HDFS data: `mkdir data-master`
3. Create a `slaves` file in the `slaves-config` subdirectory, listing all slave node IP address or host names: `mkdir slaves-config`
4. Create a subdirectory for MapReduce/Spark deployments: `mkdir deployments`
5. Launch the new namenode: `docker-compose up -d`

#### Datanode setup

1. On each slave, go into the *cluster-setup/standalone-cluster/datanode* directory: `cd cluster-setup/standalone-cluster/datanode`
2. Create a subdirectory for the HDFS data: `mkdir data-slave`
3. Create a `slaves` file in the `slaves-config` subdirectory, listing all slave node IP address or host names: `mkdir slaves-config`
4. Launch the new datanode: `docker-compose up -d`

Starting the cluster
--------------------

Once either a local or standalone cluster is provisioned, follow the below steps:

1. Log in to the master node, e.g. `docker exec -it hadoop-master bash`
2. Become the *hadoop* user: `su hadoop`
3. Format the HDFS namenode: `~/utils/format-namenode.sh`

HDFS has to be restarted the first time before MapReduce jobs can be successfully ran.
This is because HDFS creates some data on the first run but stopping it can clean up
its state so MapReduce jobs can be ran through YARN afterwards.

1. Start Hadoop: `~/utils/start-hadoop.sh`
2. Stop Hadoop: `~/utils/stop-hadoop.sh`
3. Start Hadoop again: `~/utils/start-hadoop.sh`

Running the word count example
------------------------------

The script will create a directory called *input* with some sample files.
It'll upload them into the HDFS cluster and run a simple MapReduce job.
It'll print the results to the console.

1. Log in to the master node, e.g. `docker exec -it hadoop-master bash`
2. Become the *hadoop* user: `su hadoop`
3. Run `~/utils/run-wordcount.sh`

Web UI
------

- Namenode UI (system info & HDFS browser): http://[MASTER NODE]:50070
- Application Tracker UI (YARN job handling): http://[MASTER NODE]:8088

where [MASTER NODE] is the IP address or host name of the Hadoop master.

Running a sample Spark job
--------------------------

Running the word count example leaves some files in HDFS.
The below example Spark job reads those files and simply splits the file contents by whitespaces. It then prints out the results.

Once you're on the namenode, issue `spark-shell`:

    val input = sc.textFile("/user/hadoop/input")
    val splitContent = input.map(r => r.split(" "))
    splitContent.foreach(line => println(line.toSeq))
