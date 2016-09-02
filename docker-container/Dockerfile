FROM isuper/java-oracle:jdk_8

MAINTAINER Segence <segence@segence.com>

WORKDIR /tmp

RUN apt-get update && apt-get install -y openssh-server wget vim iputils-ping telnet dnsutils

RUN groupadd hadoop
RUN useradd -d /home/hadoop -g hadoop -m hadoop

# SSH without key
RUN mkdir /home/hadoop/.ssh
RUN ssh-keygen -t rsa -f /home/hadoop/.ssh/id_rsa -P '' && \
    cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys

# Installing Hadoop
RUN wget http://apache.rediris.es/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz
RUN tar -xzvf hadoop-2.7.2.tar.gz -C /usr/local/
RUN mv /usr/local/hadoop-2.7.2 /usr/local/hadoop
RUN chown -R hadoop:hadoop /usr/local/hadoop
ENV HADOOP_HOME=/usr/local/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop

# Installing Scala
RUN wget http://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.tgz
RUN tar -xzvf scala-2.11.8.tgz -C /usr/local/
RUN mv /usr/local/scala-2.11.8 /usr/local/scala
RUN chown -R root:root /usr/local/scala
ENV SCALA_HOME=/usr/local/scala

# Installing Spark
RUN wget http://d3kbcqa49mib13.cloudfront.net/spark-2.0.0-bin-without-hadoop.tgz
RUN tar -xzvf spark-2.0.0-bin-without-hadoop.tgz -C /usr/local/
RUN mv /usr/local/spark-2.0.0-bin-without-hadoop /usr/local/spark
ENV SPARK_HOME=/usr/local/spark
ENV LD_LIBRARY_PATH=$HADOOP_HOME/lib/native/:$LD_LIBRARY_PATH

# Configuring Hadoop classpath for Spark
RUN echo "export SPARK_DIST_CLASSPATH=$($HADOOP_HOME/bin/hadoop classpath)" > /usr/local/spark/conf/spark-env.sh

# Setting the PATH environment variable globally and for the Hadoop user
ENV PATH=$PATH:$JAVA_HOME/bin:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:$SCALA_HOME/bin:$SPARK_HOME/bin
RUN echo "PATH=$PATH:$JAVA_HOME/bin:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:$SCALA_HOME/bin:$SPARK_HOME/bin" >> /home/hadoop/.bashrc

# Hadoop configuration
COPY config/sshd_config /etc/ssh/sshd_config
COPY config/ssh_config /home/hadoop/.ssh/config
COPY config/hadoop-env.sh config/hdfs-site.xml config/hdfs-site.xml config/core-site.xml \
     config/core-site.xml config/mapred-site.xml config/yarn-site.xml config/yarn-site.xml \
     $HADOOP_HOME/etc/hadoop/

# Adding initialisation script
COPY hadoop-scripts/init-hadoop.sh $HADOOP_HOME/etc/hadoop/

# Adding utilities
RUN mkdir -p /home/hadoop/utils
COPY utils/start-hadoop.sh utils/stop-hadoop.sh utils/run-wordcount.sh utils/format-namenode.sh /home/hadoop/utils/

# Replacing Hadoop slave file with provided one and changing logs directory
RUN rm $HADOOP_HOME/etc/hadoop/slaves
RUN ln -s /config/slaves $HADOOP_HOME/etc/hadoop/slaves
RUN ln -s /data/logs/hadoop $HADOOP_HOME/logs

# Set permissions on Hadoop home
RUN chown -R hadoop:hadoop /home/hadoop

# Cleanup
RUN rm -rf /tmp/*

WORKDIR /root

EXPOSE  2222 4040 8030 8031 8032 8033 8088 9000 50010 50070 50090

VOLUME /data
VOLUME /config
VOLUME /deployments

ENTRYPOINT [ "sh", "-c", "$HADOOP_HOME/etc/hadoop/init-hadoop.sh; service ssh start; bash"]
