FROM isuper/java-oracle:jdk_8

MAINTAINER Segence <segence@segence.com>

WORKDIR /tmp

RUN apt-get update && apt-get install -y openssh-server wget vim iputils-ping telnet dnsutils bzip2 ntp
RUN update-rc.d ntp defaults

RUN groupadd hadoop
RUN useradd -d /home/hadoop -g hadoop -m hadoop

# SSH without key
RUN mkdir /home/hadoop/.ssh
RUN ssh-keygen -t rsa -f /home/hadoop/.ssh/id_rsa -P '' && \
    cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys

# Installing Hadoop
RUN wget http://apache.mirror.anlx.net/hadoop/common/hadoop-2.9.0/hadoop-2.9.0.tar.gz
RUN tar -xzvf hadoop-2.9.0.tar.gz -C /usr/local/
RUN mv /usr/local/hadoop-2.9.0 /usr/local/hadoop
ENV HADOOP_HOME=/usr/local/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop

# Installing Scala
RUN wget http://downloads.lightbend.com/scala/2.11.11/scala-2.11.11.tgz
RUN tar -xzvf scala-2.11.11.tgz -C /usr/local/
RUN mv /usr/local/scala-2.11.11 /usr/local/scala
RUN chown -R root:root /usr/local/scala
ENV SCALA_HOME=/usr/local/scala

# Installing Spark
RUN wget http://d3kbcqa49mib13.cloudfront.net/spark-2.2.0-bin-without-hadoop.tgz
RUN tar -xzvf spark-2.2.0-bin-without-hadoop.tgz -C /usr/local/
RUN mv /usr/local/spark-2.2.0-bin-without-hadoop /usr/local/spark
ENV SPARK_HOME=/usr/local/spark
ENV LD_LIBRARY_PATH=$HADOOP_HOME/lib/native/:$LD_LIBRARY_PATH

# Configuring Hadoop classpath for Spark
RUN echo "export SPARK_DIST_CLASSPATH=$($HADOOP_HOME/bin/hadoop classpath)" > /usr/local/spark/conf/spark-env.sh

# Installing the R language
RUN apt-get install -y libssl-dev libssh2-1-dev libcurl4-openssl-dev libssl-dev r-base
RUN R -e "install.packages('devtools', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('knitr', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('ggplot2', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages(c('devtools','mplot', 'googleVis'), repos = 'http://cran.us.r-project.org'); require(devtools); install_github('ramnathv/rCharts')"

# Installing Zeppelin
RUN wget http://mirrors.ukfast.co.uk/sites/ftp.apache.org/zeppelin/zeppelin-0.7.3/zeppelin-0.7.3-bin-netinst.tgz
RUN tar -xzvf zeppelin-0.7.3-bin-netinst.tgz -C /usr/local/
RUN mv /usr/local/zeppelin-0.7.3-bin-netinst /usr/local/zeppelin

ENV ZEPPELIN_HOME=/usr/local/zeppelin
COPY config/zeppelin-env.sh $ZEPPELIN_HOME/conf/zeppelin-env.sh
COPY config/zeppelin-site.xml $ZEPPELIN_HOME/conf/zeppelin-site.xml

RUN chown -R hadoop:hadoop $ZEPPELIN_HOME

# Setting the PATH environment variable globally and for the Hadoop user
ENV PATH=$PATH:$JAVA_HOME/bin:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:$SCALA_HOME/bin:$SPARK_HOME/bin:$ZEPPELIN_HOME/bin
RUN echo "PATH=$PATH:$JAVA_HOME/bin:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:$SCALA_HOME/bin:$SPARK_HOME/bin" >> /home/hadoop/.bashrc

# Hadoop configuration
COPY config/sshd_config /etc/ssh/sshd_config
COPY config/ssh_config /home/hadoop/.ssh/config
COPY config/hadoop-env.sh config/hdfs-site.xml config/hdfs-site.xml config/core-site.xml \
     config/core-site.xml config/mapred-site.xml config/yarn-site.xml config/yarn-site.xml \
     $HADOOP_CONF_DIR/

# Adding initialisation scripts
RUN mkdir $HADOOP_HOME/bin/init
COPY init-scripts/init-hadoop.sh $HADOOP_HOME/bin/init/
COPY init-scripts/start-hadoop.sh init-scripts/stop-hadoop.sh $HADOOP_HOME/bin/init/
COPY init-scripts/hadoop /etc/init.d/

# Adding utilities
RUN mkdir -p /home/hadoop/utils
COPY utils/run-wordcount.sh utils/format-namenode.sh /home/hadoop/utils/

# Replacing Hadoop slave file with provided one and changing logs directory
RUN rm $HADOOP_CONF_DIR/slaves
RUN ln -s /config/slaves $HADOOP_CONF_DIR/slaves

# Setting up log directories
RUN ln -s /data/logs/hadoop $HADOOP_HOME/logs
RUN ln -s $HADOOP_HOME/logs /var/log/hadoop
RUN ln -s $ZEPPELIN_HOME/logs /var/log/zeppelin

# Set permissions on Hadoop home
RUN chown -R hadoop:hadoop $HADOOP_HOME
RUN chown -R hadoop:hadoop /home/hadoop

# Cleanup
RUN rm -rf /tmp/*

WORKDIR /root

EXPOSE  2222 4040 8020 8030 8031 8032 8033 8042 8088 9001 50010 50020 50070 50075 50090 50100

VOLUME /data
VOLUME /config
VOLUME /deployments

ENTRYPOINT [ "sh", "-c", "service ntp start; $HADOOP_HOME/bin/init/init-hadoop.sh; service ssh start; bash"]
