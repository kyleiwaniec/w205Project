yum install flume-ng
mv /usr/lib/flume-ng/lib/twitter4j-core-3.0.3.jar /usr/lib/flume-ng/lib/twitter4j-core-3.0.3.jar.bak
mv /usr/lib/flume-ng/lib/twitter4j-stream-3.0.3.jar /usr/lib/flume-ng/lib/twitter4j-stream-3.0.3.jar.bak

# if running for first Time
 mkdir /data/flume
 mkdir /data/flume/conf
 cp /data/w205Project/flume/scripts/flume.conf /data/flume/conf
 cp /data/w205Project/flume/scripts/flume-env.sh /data/flume/conf
 cp /data/w205Project/flume/scripts/start-flume.sh /data/flume/

# # add this to /data/flume/conf/flume-env.conf
 export FLUME_CLASSPATH=/data/w205Project/flume/twitter4j-stream-2.2.6.jar:/data/w205Project/flume/flume-sources-1.0-SNAPSHOT.jar
 echo "export FLUME_CLASSPATH=/data/w205Project/flume/twitter4j-stream-2.2.6.jar:/data/w205Project/flume/flume-sources-1.0-SNAPSHOT.jar" >> /data/flume/conf/flume-env.conf
 sudo -u hdfs hdfs dfs -mkdir /user/flume
 sudo -u hdfs hdfs dfs -mkdir /user/flume/tweets/
