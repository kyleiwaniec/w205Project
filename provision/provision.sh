#! /bin/bash

cd $HOME
umount /data

echo "using drive " $1
echo "WARNING!! This will format the drive at" $1
read -rsp $'Press any key to continue or control-C to quit...\n' -n1 key

#make a new ext4 filesystem
mkfs.ext4 $1

#mount the new filesystem under /data
mount -t ext4 $1 /data
chmod a+rwx /data


#set up directories for postgres
mkdir /data/pgsql
mkdir /data/pgsql/data
mkdir /data/pgsql/logs
chown -R postgres /data/pgsql
sudo -u postgres initdb -D /data/pgsql/data

#setup pg_hba.conf
sudo -u postgres echo "host    all         all         0.0.0.0         0.0.0.0               md5" >> /data/pgsql/data/pg_hba.conf

#setup postgresql.conf
sudo -u postgres echo "listen_addresses = '*'" >> /data/pgsql/data/postgresql.conf
sudo -u postgres echo "standard_conforming_strings = off" >> /data/pgsql/data/postgresql.conf

#make start postgres file
cd /data
cat > /data/start_postgres.sh <<EOF
#! /bin/bash
sudo -u postgres pg_ctl -D /data/pgsql/data -l /data/pgsql/logs/pgsql.log start
EOF
chmod +x /data/start_postgres.sh

#make a stop postgres file
cat > /data/stop_postgres.sh <<EOF
#! /bin/bash
sudo -u postgres pg_ctl -D /data/pgsql/data -l /data/pgsql/logs/pgsql.log stop
EOF
chmod +x /data/stop_postgres.sh

#start postgres
/data/start_postgres.sh

sleep 5

#write setup script for hive metastore
cat > /data/setup_hive_for_postgres.sql <<EOF
CREATE USER hiveuser WITH PASSWORD 'hive';
CREATE DATABASE metastore;
\c metastore
\i /usr/lib/hive/scripts/metastore/upgrade/postgres/hive-schema-1.1.0.postgres.sql
\i /usr/lib/hive/scripts/metastore/upgrade/postgres/hive-txn-schema-0.13.0.postgres.sql
\c metastore
\pset tuples_only on
\o /tmp/grant-privs
SELECT 'GRANT SELECT,INSERT,UPDATE,DELETE ON "'  || schemaname || '". "' ||tablename ||'" TO hiveuser ;'
FROM pg_tables
WHERE tableowner = CURRENT_USER and schemaname = 'public';
\o
\pset tuples_only off
\i /tmp/grant-privs
\q
EOF

#run the metastore creation sql
sudo -u postgres psql -f /data/setup_hive_for_postgres.sql

#make the new hive configuration directory
sudo -u hadoop mkdir -p /data/hadoop/hive/conf

#setup the hive-site file
cat > /data/hadoop/hive/conf/hive-site.xml <<EOF
<?xml version="1.0"?>
<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>

<!-- Hive Configuration can either be stored in this file or in the hadoop configuration files  -->
<!-- that are implied by Hadoop setup variables.                                                -->
<!-- Aside from Hadoop setup variables - this file is provided as a convenience so that Hive    -->
<!-- users do not have to edit hadoop configuration files (that may be managed as a centralized -->
<!-- resource).                                                                                 -->

<!-- Hive Execution Parameters -->

<property>
  <name>javax.jdo.option.ConnectionURL</name>
  <value>jdbc:postgresql://localhost:5432/metastore</value>
</property>

<property>
  <name>javax.jdo.option.ConnectionDriverName</name>
  <value>org.postgresql.Driver</value>
</property>

<property>
  <name>javax.jdo.option.ConnectionUserName</name>
  <value>hiveuser</value>
</property>

<property>
  <name>javax.jdo.option.ConnectionPassword</name>
  <value>hive</value>
</property>

<property>
  <name>datanucleus.autoCreateSchema</name>
  <value>false</value>
</property>

<property>
  <name>hive.metastore.uris</name>
  <value>thrift://localhost:9083</value>
  <description>IP address (or fully-qualified domain name) and port of the metastore host</description>
</property>


<property>
<name>hive.metastore.schema.verification</name>
<value>true</value>
</property>

</configuration>
EOF



# make the start_metastore file
cat > /data/start_metastore.sh <<EOF
#! /bin/bash
nohup hive --service metastore &
EOF
 
# make the stop_metastore file
cat > /data/stop_metastore.sh <<EOF
#! /bin/bash
ps aux|grep org.apache.hadoop.hive.metastore.HiveMetaStore|awk '{print $2}'|xargs kill -9
EOF

cat > /data/stop-all.sh <<EOF
#! /bin/bash
. /root/stop-hadoop.sh
. /data/stop_postgres.sh
. /data/stop_metastore.sh
sudo stop shiny-server
EOF

# download and install spark
mkdir /data/spark15
cd ~
wget http://mirror.nexcess.net/apache/spark/spark-1.5.2/spark-1.5.2-bin-hadoop2.6.tgz
tar -xvf spark-1.5.2-bin-hadoop2.6.tgz
sudo mv spark-1.5.2-bin-hadoop2.6/* /data/spark15
ln -s /data/spark15 $HOME/spark15

#####################################
# CONFIGURE HADOOP
#####################################

#sudo -u hdfs hdfs namenode -format
chown hdfs:hdfs /data
chmod 777 /data
sudo -u hdfs hdfs namenode -format


# make sure the hive metastore is set
cp /data/hadoop/hive/conf/hive-site.xml /etc/hive/conf.dist/hive-site.xml

# start servers
echo "starting Hadoop"
. /root/start-hadoop.sh
sudo /usr/lib/hadoop/libexec/init-hdfs.sh # HistoryServer needs this.. 

