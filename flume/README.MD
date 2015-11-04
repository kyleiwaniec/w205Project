### What is Flume
---
Flume is a part of the Hadoop Ecosystem used to collect, aggregate and move large amounts of log data. There are three important components in the Flume architecture: source, channel and sink.

##### Source
As the name implies, this is the point at which dataflow starts. This is the part of Flume that connects to the data source and processes the collected data as events and then passes them to the channels. Flume sources can be configured to use a push or a pull model. For this project, we are using a custom source called TwitterSource developed by Cloudera. It uses the twitter4j API to listen for new tweets. Whenever a new tweet comes in, the TwitterSource builds an "event" in which the tweet is stored as raw JSON and then it pushes it into the channel for further procesing.

##### Channel
A Flume channel is where the data travels from source to sink. An event is added by the source to the channel and consumed/deleted by the sink from the channel. Depending on the tolerance for agent failures, different types of channels may be configured. For this project, a Memory Channel is configured. Since the loss of some data is not detrimental to our application, we do not need to configure the channel for high availability.

##### Sink
Flume's sink is where the events go to rest. Various types of sinks are supported: HDFS, JDBC, Hive, HBase etc. For this poject, HDFS has been configured as the Sink. It may be worthwhile to check other types of sink for ease of querying and/or performance.

### Setup Flume for Twitter Data Ingestion
---
##### Prerequisites
Ability to launch an Amazon EC2 instance using the w205 AMI or a similar one. After starting-up, and the EBS store is mounted(/data), please start hadoop as well. Since we are going to use HDFS as the sink, this part needs to be up and running. You can try this AMI I created to see if flume is already installed and ready to go: ucbw205_complete_plus_postgres_py2.7

##### 1. Install Flume

If you are using the above AMI, run:
`. install-flume.sh`

Otherwise, for ubuntu and similar systems use:
>  sudo apt-get install flume-ng 

For red-hat compatible systems use:
> sudo yum install flume-ng 


If you are using the AMI for w205, flume will be installed here:
> /usr/lib/flume-ng 

You can verify the installation by using the following commands:
```
ls -l /usr/lib/flume-ng/conf
which flume-ng

```

Open `/data/w205Project/flume/conf/flume.conf` and add your twitter credentials

##### 2. Setup HDFS Directories
Since flume will be using HDFS as the sink, the HDFS directory structure is first defined. If you used the install script, this step is already done, and you can proceed to start flume
```
sudo -u hdfs hdfs dfs -mkdir /user/flume
sudo -u hdfs hdfs dfs -mkdir /user/flume/tweets/
```

##### Start Flume Twitter Data Ingestion
Start flume as "hdfs" so that the user will have write permissions on the file system:
```
sudo -u hdfs bash /data/w205Project/flume/start-flume.sh
```
In order to test whether the twitter streaming through flume is working, you can peer into the hdfs directories.
```
sudo -u hdfs hdfs dfs -ls /user/flume/tweets/2015/27/10/09
```

You should see some files like this:
```
-rw-r--r--   1 hdfs supergroup     216279 2015-10-27 09:00 /user/flume/tweets/2015/27/10/09/FlumeData.1445936401691
-rw-r--r--   1 hdfs supergroup     143561 2015-10-27 09:01 /user/flume/tweets/2015/27/10/09/FlumeData.1445936432777
-rw-r--r--   1 hdfs supergroup     127619 2015-10-27 09:01 /user/flume/tweets/2015/27/10/09/FlumeData.1445936463696
-rw-r--r--   1 hdfs supergroup     187743 2015-10-27 09:02 /user/flume/tweets/2015/27/10/09/FlumeData.1445936494487
-rw-r--r--   1 hdfs supergroup     154974 2015-10-27 09:02 /user/flume/tweets/2015/27/10/09/FlumeData.1445936524918
```

##### Using PySpark on Twitter Data
In order to verify as well as understand the twitter data, pyspark serves as a useful tool. 
(Note: Please follow documentation of the pyspark version you are using. These commands are for 1.3.1)
```
from pyspark.sql import SQLContext
sqlContext = SQLContext(sc)
df = sqlContext.jsonFile('/user/flume/tweets/2015/27/10/09')
df.printSchema()
df.first()
```

### TODO
---
1) Research other configurations for channel and sink.
2) Clustered setup and flume. Do we really need this?
3) Twitter authentication - use of personal tokens is concerning. Should read about this [here, on twitter dev].
[here, on twitter dev]: https://dev.twitter.com/oauth/application-only

### Resources Used
---
* [Flume Installation]
[Flume Installation]: http://www.cloudera.com/content/www/en-us/documentation/enterprise/latest/topics/cdh_ig_flume_installation.html
* [Flume Twitter Source]
[Flume Twitter Source]: http://blog.cloudera.com/blog/2012/10/analyzing-twitter-data-with-hadoop-part-2-gathering-data-with-flume/
* [Flume Twitter Source with Hive Integration]
[Flume Twitter Source with Hive Integration]: http://www.thecloudavenue.com/2013/03/analyse-tweets-using-flume-hadoop-and.html
* [Flume Twitter Source with Hive Integration Github Project]
[Flume Twitter Source with Hive Integration Github Project]:https://github.com/cloudera/cdh-twitter-example
* [Flume User Guide]
[Flume User Guide]: http://archive.cloudera.com/cdh5/cdh/5/flume-ng/FlumeUserGuide.html
* [Conflict - twitter4j-stream jar]
[Conflict - twitter4j-stream jar]: https://community.cloudera.com/t5/Data-Ingestion-Integration/Flume-TwitterSource-language-filter/td-p/23519
* [Downloading twitter4j without maven]
[Downloading twitter4j without maven]: http://twitter4j.org/maven2/org/twitter4j/twitter4j-stream/2.2.6/
* [Pyspark 1.3.1 documentation]
[Pyspark 1.3.1 documentation]: https://spark.apache.org/docs/1.3.1/api/python/pyspark.sql.html#pyspark.sql.DataFrame



