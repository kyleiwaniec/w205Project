To use S3, make sure to add your keys to AWS, and enable s3 and s3native filesystem

vi /etc/hadoop/conf/core-site.xml
#vi /etc/hadoop/conf/hdfs-site.xml <- not usre if it has to go in here.


<property>
	<name>fs.s3.impl</name>
	<value>org.apache.hadoop.fs.s3.S3FileSystem</value>
</property>

<property>
	<name>fs.s3n.impl</name>
	<value>org.apache.hadoop.fs.s3native.NativeS3FileSystem</value>
</property>

<property>
	<name>fs.s3n.awsAccessKeyId</name>
	<value>aws_access_key_id</value>
</property>
<property>
	<name>fs.s3.awsAccessKeyId</name>
	<value>aws_access_key_id</value>
</property>

<property>
	<name>fs.s3n.awsSecretAccessKey</name>
	<value>aws_secret_access_key</value>
</property>
<property>
	<name>fs.s3.awsSecretAccessKey</name>
	<value>aws_secret_access_key</value>
</property>


# check connection:
hdfs dfs -ls s3n://w205twitterproject/

# spark version has to be built for hadoop 2.4. Don't know what that's going to break
wget http://mirror.olnevhost.net/pub/apache/spark/spark-1.5.2/spark-1.5.2-bin-hadoop2.4.tgz
tar -xvf spark-1.5.2-bin-hadoop2.4.tgz
mkdir /data/spark15_h24
mv spark-1.5.2-bin-hadoop2.4/* /data/spark15_h24/
cp /data/spark15/conf/hive-site.xml /data/spark15_h24/conf

to run run pyspark, do:
/data/spark15_h24/bin/pyspark

then in pyspark, exec the file:
execfile('/data/w205Project/spark/getLinks.py')



