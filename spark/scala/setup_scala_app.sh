#! /bin/bash

## Setup Scala Spark Streaming Tweet Classification
echo "As we proceeded with the project, it appeared that too many disparate systems had to be clobbered together."
echo "At some point, we started wondering if it will be easier to work with Spark and the tools that it provides."
echo "We also wanted to test if Scala performed better and analyze the overall experience."
echo "More details are provided in the write-up as well as in code level documentation/comments."
echo "................................................."

sleep 3

echo "Now we have to setup up HDFS directories for Spark."
echo "Checking if Hadoop is running: "
for service in /etc/init.d/hadoop-hdfs-*; do $service status; done;

echo "Is Hadoop Running? Y/N: " $1
if $1 = "N" bash 


echo ".........................."
## Create necessary directories for spark-scala app
sudo -u hdfs hdfs dfs -rm -R /user/spark/honeypot
sudo -u hdfs hdfs dfs -mkdir /user/spark/honeypot/

echo "Leaving tweet data alone if it already exits. Otherwise new HDFS paths will be created."
echo ".........................."

sudo -u hdfs hdfs dfs -mkdir /user/spark
sudo -u hdfs hdfs dfs -mkdir /user/spark/tweets/
echo "Copying the training data for building the classification model"
echo ".........................."
sudo -u hdfs hdfs dfs -put  /data/w205Project/spark/scala/learn_spam/data/* /user/spark/honeypot/

echo "Building the scala apps. Using SBT and SBT Assembly. File naming conventions of JARS generated are used in spark-submit." 
cd /data/w205Project/spark/scala/collect_tweets
echo "Assembling JARs for Initial Tweet Collection. This is to work on the classification model."
sbt package
sleep 5
sbt assemblyPackageDependency
sleep 5
chmod -R u+x target/scala-2.11/*.jar
echo ".........................."
cd /data/w205Project/spark/scala/learn_spam
echo "Assembling JARs for building the classification model."
sbt package
sleep 5
sbt assemblyPackageDependency
sleep 5
chmod -R u+x target/scala-2.11/*.jar
echo ".........................."
cd /data/w205Project/spark/scala/classify_store_tweets
echo "Assembling JARs for classifying and storing streaming tweets."
sbt package
sleep 5
sbt assemblyPackageDependency
sleep 5
chmod -R u+x target/scala-2.11/*.jar
echo ".........................."

echo "To run each of the apps, readme is provided here: /data/w205Project/spark/scala/README.MD"

