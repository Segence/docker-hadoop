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

For all below steps the Docker image `segence/hadoop:0.2.0` has to be built or
pulled from DockerHub.

- Build the current image locally: `./build-docker-image.sh`
- Pull from DockerHub: `docker pull segence/hadoop:0.2.0`

The default SSH port of the Docker containers is `2222`.
This is, so in a standalone cluster setup, each data node container can be ran
on separate physical servers (or virtual appliances). The servers can still use the default
SSH port `22` but the data nodes, running inside Docker containers will be using port `2222`.
This port is automatically exposed. It's import to note that all exposed ports have
to be open on the firewall of the servers.

### Setting up a local Hadoop cluster

This will set up a local Hadoop cluster using bridged networking with one master
and one slave node.

1. Go into the *cluster-setup/local-cluster* directory: `cd cluster-setup/local-cluster`
2. Edit the `slaves-config/slaves` file if you want to add more slaves other than the default one slave node. If you add more slaves then also edit the `docker-compose.yml`
by adding more slave node configuration.
3. Launch the new cluster: `docker-compose up -d`

You can log into the *namenode* (master) by issuing `docker exec -it hadoop-master bash`
and to the *datanode* (slave) by `docker exec -it hadoop-slave1 bash`.

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

Restarting HDFS has to be done **every time** it is stopped, otherwise the first
MapReduce job will always fail and the cluster will terminate.

Interacting with HDFS
---------------------

### Local access

When you're on the namenode, simply use the `hadoop dfs ...` command to interact with
the HDFS cluster.
E.g. listing the contens of the root of the cluster: `hdfs dfs -ls /`

### Remote access

1. Make sure you've got the same version of Hadoop downloaded and extracted on your local system
2. Go into your Hadoop installation directory, and then into the `bin` directory.
3. For example to list the contents of your HDFS cluster, use: `./hdfs dfs -ls hdfs://localhost:9000/`

Web interfaces
--------------

The main web interfaces are:

- Namenode UI (system info & HDFS browser): [http://localhost:50070](http://localhost:50070)
- WebHDFS REST API: [http://localhost:50070/webhdfs/v1](http://localhost:50070/webhdfs/v1)
- Application Tracker UI (YARN job handling): [http://localhost:8088](http://localhost:8088)

Change `localhost` to your master node's IP address or host name.

#### WebHDFS REST API

- Getting home directory: [http://localhost:50070/webhdfs/v1/?op=GETHOMEDIRECTORY](http://localhost:50070/webhdfs/v1/?op=GETHOMEDIRECTORY)
- List root of the HDFS volume: [http://localhost:50070/webhdfs/v1/?op=LISTSTATUS](http://localhost:50070/webhdfs/v1/?op=LISTSTATUS)

Running sample jobs using YARN
------------------------------

### Running the word count example

The script will create a directory called *input* with some sample files.
It'll upload them into the HDFS cluster and run a simple MapReduce job.
It'll print the results to the console.

1. Log in to the master node, e.g. `docker exec -it hadoop-master bash`
2. Become the *hadoop* user: `su hadoop`
3. Run `~/utils/run-wordcount.sh`

### Running a sample interactive Spark job

Running the word count example leaves some files in HDFS.
The below example Spark job reads those files and simply splits the file contents by whitespaces. It then prints out the results.

Once you're on the namenode, issue `spark-shell`:

    val input = sc.textFile("/user/hadoop/input")
    val splitContent = input.map(r => r.split(" "))
    splitContent.foreach(line => println(line.toSeq))
