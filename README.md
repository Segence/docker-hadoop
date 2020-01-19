Segence Hadoop Docker container
===============================

Overview
--------

This Docker container contains a full Hadoop distribution with the following components:

- Hadoop 2.9.2 (including YARN)
- Oracle JDK 8
- Scala 2.11.11
- Spark 2.4.4
- Zeppelin 0.8.2

Setting up a new Hadoop cluster
-------------------------------

For all below steps, the Docker image `segence/hadoop:latest` has to be built or pulled from [DockerHub](https://hub.docker.com/r/segence/hadoop/).

- Build the current image locally: `./build-docker-image.sh`
- Pull from DockerHub: `docker pull segence/hadoop:latest`

The default SSH port of the Docker containers is `2222`.
This is, so in a standalone cluster setup, each *namenode* and *datanode*
can be ran on separate physical server (or virtual appliances). The servers can
still use the default SSH port `22` but the *datanodes*, running inside Docker containers,
will be using port `2222`. This port is automatically exposed.
It's important to note that all exposed ports have to be open on the firewall of
the physical servers, so other nodes in the cluster can access them.

Hadoop host names have to follow the **hadoop-*** format.
Automatic acceptance of SSH host key fingerprints is enabled for any hosts with
the domain name `hadoop-*`. This is so Hadoop nodes on the cluster can establish
SSH connections between each other without manually accepting host keys.
This means that the Docker hosts, which run the Hadoop *namenode* and *datanode*
containers have to be mapped to DNS names. One can use for example
Microsoft Windows Server to set up a DNS server.

### Setting up a local Hadoop cluster

This will set up a local Hadoop cluster using bridged networking with one *namenode*
and one *datanode*.

1. Go into the *cluster-setup/local-cluster* directory: `cd cluster-setup/local-cluster`
2. Edit the `slaves-config/slaves` file if you want to add more slaves (*datanodes*)
other than the default one slave node. If you add more slaves then also edit the
`docker-compose.yml` file by adding more slave node configurations.
3. Launch the new cluster: `docker-compose up -d`

You can log into the *namenode* (master) by issuing `docker exec -it hadoop-namenode bash`
and to the *datanode* (slave) by `docker exec -it hadoop-datanode1 bash`.

By default, the HDFS replication factor is set to 1, because it is assumed that
a local Docker cluster will be started with a single datanode.
To override the replication setting simply change the `HDFS_REPLICATION_FACTOR`
environment variable in the `docker-compose.yml` file (and also add more datanodes).
Adding more data nodes adds the complexity of exposing all datanode UI ports to
`localhost`. In this scenario, no UI ports should be exposed to avoid the conflict.

### Setting up a standalone Hadoop cluster

#### Preparation

Create the `hadoop` user on the host system, e.g. `useradd hadoop`

*RHEL/CentOS note*

If you encounter the following error message when running a Docker container:
`WARNING: IPv4 forwarding is disabled. Networking will not work.`
then turn on packet forwading (RHEL 7): `/sbin/sysctl -w net.ipv4.ip_forward=1`

[More info](https://www.centos.org/docs/5/html/Virtual_Server_Administration/s1-lvs-forwarding-VSA.html)

You can use the script `cluster-setup/standalone-cluster/setup-rhel.sh` to achieve
the above, as well as to create the required directories and change their ownership
(as in point 1 and 2 below, so you can skip them if you used the RHEL setup script).

The cluster setup runs with host networking, so the Hadoop nodes will get the hostname
and DNS settings directly from the host machine.
Make sure IP addresses and DNS names, as well as DNS resolution is correctly set up on the host machines.

#### Namenode setup

1. Create the following directories on the host:
  - Directory for the HDFS data: `/hadoop/data`
  - Directory for MapReduce/Spark deployments: `/hadoop/deployments`
2. Make the `hadoop` user own the directories: `chown -R hadoop:hadoop /hadoop`
3. Create the file `/hadoop/slaves-config/slaves` listing all slave node host names on a separate line
4. Copy the `start-namenode.sh` file onto the system (e.g. into `/hadoop/start-namenode.sh`)
5. Launch the new *namenode*:
`/hadoop/start-namenode.sh [HDFS REPLICATION FACTOR]`,
where *HDFS REPLICATION FACTOR* is the replication factor for HDFS blocks (defaults to 2).

#### Datanode setup

1. Create the directory for the HDFS data: `/hadoop/data`
2. Make the `hadoop` user own the directories: `chown -R hadoop:hadoop /hadoop`
3. Create the file `/hadoop/slaves-config/slaves` listing all slave node host names on a separate line
4. Copy the `start-datanode.sh` file onto the system (e.g. into `/hadoop/start-datanode.sh`)
5. Launch the new *datanode* with its ID:
`/hadoop/start-datanode.sh <NAMENODE HOST NAME> [HDFS REPLICATION FACTOR]`,
where *NAMENODE HOST NAME* is the host name of the *namenode* and *HDFS REPLICATION FACTOR*
is the replication factor for HDFS blocks (defaults to 2, and has to be consistent throughout
all cluster nodes).

Starting the cluster
--------------------

Once either a local or standalone cluster is provisioned, follow the below steps:

1. Log in to the *namenode*, e.g. `docker exec -it hadoop-namenode bash`
2. Become the *hadoop* user: `su hadoop`
3. Format the HDFS namenode: `~/utils/format-namenode.sh`

HDFS has to be restarted the first time before MapReduce jobs can be successfully ran.
This is because HDFS creates some data on the first run but stopping it can clean up
its state so MapReduce jobs can be ran through YARN afterwards.

Execute the following commands as `root`:

1. Start Hadoop: `service hadoop start`
2. Stop Hadoop: `service hadoop stop`
3. Start Hadoop again: `service hadoop start`

Restarting HDFS has to be done **after formatting the namenode**, otherwise running
the first MapReduce job will always fail and the cluster will terminate.

Verify that the *datanodes* are correctly registered, issue on *namenode*: `hdfs dfsadmin -report`

Interacting with HDFS
---------------------

### Local access

When you're logged into the *namenode*, simply use the `hadoop dfs ...` command
to interact with the HDFS cluster.
E.g. listing the contents of the root of the file system: `hdfs dfs -ls /`

### Remote access

1. Make sure you've got the same version of Hadoop downloaded and extracted on
your local system
2. Go into your Hadoop installation directory, and then into the `bin` directory.
3. For example to list the contents of your HDFS cluster, use: `./hdfs dfs -ls hdfs://localhost:8020/`

Web interfaces
--------------

### List of web interfaces

| **Web UIs**                   | **URL**                                                                |
|:------------------------------|:-----------------------------------------------------------------------|
| *Hadoop Name Node*            | [http://localhost:50070](http://localhost:50070)                       |
| *Hadoop Data Node*            | [http://localhost:50075](http://localhost:50075)                       |
| *WebHDFS REST API*            | [http://localhost:50070/webhdfs/v1](http://localhost:50070/webhdfs/v1) |
| *NodeManager UI on Data Node* | [http://localhost:8042](http://localhost:8042)                         |
| *YARN Resource Manager*       | [http://localhost:8088](http://localhost:8088)                         |
| *Spark UI*                    | [http://localhost:4040](http://localhost:4040)                         |
| *Zeppelin UI*                 | [http://localhost:9001](http://localhost:9001)                         |

Change `localhost` to the IP address or host name of the *namenode*.

### WebHDFS REST API

- Getting home directory: [http://localhost:50070/webhdfs/v1/?op=GETHOMEDIRECTORY](http://localhost:50070/webhdfs/v1/?op=GETHOMEDIRECTORY)
- List root of the HDFS volume: [http://localhost:50070/webhdfs/v1/?op=LISTSTATUS](http://localhost:50070/webhdfs/v1/?op=LISTSTATUS)

Running sample jobs using YARN
------------------------------

### Running the word count example

The script will create a directory called *input* with some sample files.
It'll upload them into the HDFS cluster and run a simple MapReduce job.
It'll print the results to the console.

1. Log in to the *namenode*, e.g. `docker exec -it hadoop-namenode bash`
2. Become the *hadoop* user: `su hadoop`
3. Go into the home directory of the *hadoop* user: `cd`
4. Run `~/utils/run-wordcount.sh`

### Running a sample interactive Spark job

Running the word count example leaves some files in HDFS.
The below example Spark job reads those files and simply splits the file contents by whitespaces. It then prints out the results.

Once you're on the *namenode*, issue `spark-shell`:

```
val input = sc.textFile("/user/hadoop/input")
val splitContent = input.map(r => r.split(" "))
splitContent.foreach(line => println(line.toSeq))
```

To run it against the YARN cluster, launch with `spark-shell --master=yarn`.
In this way, `println` does not execute in the driver since you are executing it on
elements of the RDD. It executes in an executor, which can happen to
execute in-process in local mode. In general you should not expect this to print
results in the driver.

### Running a notebook in Zeppelin

Zeppelin has to be ran as the *hadoop* user, so make sure to start the
service as the *hadoop* user. It won't run properly with all interpreters
under a different user!

1. Log in to the *namenode*, e.g. `docker exec -it hadoop-namenode bash`
2. Become the *hadoop* user: `su hadoop`
3. Go into the home directory of the *hadoop* user: `cd`
4. Start Zeppelin: `zeppelin-daemon.sh start`
5. Open the [Zeppelin UI](http://localhost:9001) in your browser
6. On the home page, click on 'Create new note'
7. The below snippet is written in R. It loads the directory content of the input files used in the sample MapReduce job:

```
%r
df <- read.df(sqlContext, "/user/hadoop/input/", source = "text")
head(df)
```
