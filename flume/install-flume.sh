yum install flume-ng
mv /usr/lib/flume-ng/lib/twitter4j-core-3.0.3.jar /usr/lib/flume-ng/lib/twitter4j-core-3.0.3.jar.bak
mv /usr/lib/flume-ng/lib/twitter4j-stream-3.0.3.jar /usr/lib/flume-ng/lib/twitter4j-stream-3.0.3.jar.bak

<<<<<<< HEAD
sudo -u hdfs hdfs dfs -mkdir /user/flume/
sudo -u hdfs hdfs dfs -mkdir /user/flume/tweets/
=======

echo -n "Are you running this for the first time, and thus don't have /user/flume/tweets/ hdfs dirs [y/n]: "
read answer

if [[ "$answer" == "y" ]]; then
	sudo -u hdfs hdfs dfs -mkdir /user/flume
	sudo -u hdfs hdfs dfs -mkdir /user/flume/tweets/
	return 1
fi
>>>>>>> 386f86c66c824e0041d8575209fdab4c0af25f17
