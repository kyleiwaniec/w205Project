yum install flume-ng
mv /usr/lib/flume-ng/lib/twitter4j-core-3.0.3.jar /usr/lib/flume-ng/lib/twitter4j-core-3.0.3.jar.bak
mv /usr/lib/flume-ng/lib/twitter4j-stream-3.0.3.jar /usr/lib/flume-ng/lib/twitter4j-stream-3.0.3.jar.bak

sudo -u hdfs hdfs dfs -mkdir /user/flume/
sudo -u hdfs hdfs dfs -mkdir /user/flume/tweets/
