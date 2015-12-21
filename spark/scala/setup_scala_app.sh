#! /bin/bash

## Setup Scala Spark Streaming Tweet Classification
echo "Are you sure Hadoop-HDFS is running? "
read -rsp $'If Hadoop is running press any key to continue; if not press control-C to quit...\n' -n1 key

echo ".........................."
echo "Setting up SBT"
cd
curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo 
sudo yum install sbt
echo "Sanity Check:"
which sbt
echo "........................."
echo "Creating a simple test table in twitter database - postgres"
sudo -u postgres psql -f /data/w205Project/spark/scala/postgres/create_table.sql
echo
echo
echo ".........................."
## Create necessary directories for spark-scala app
echo
echo "Leaving tweet data alone if it already exits. Otherwise new HDFS paths will be created."
echo ".........................."
echo
sudo -u hdfs hdfs dfs -mkdir /user/spark
sudo -u hdfs hdfs dfs -mkdir /user/spark/tweets/
echo
echo "Copying the training data for building the classification model"
echo ".........................."
sudo -u hdfs hdfs dfs -rm -R /user/spark/honeypot
sudo -u hdfs hdfs dfs -mkdir /user/spark/honeypot/
sudo -u hdfs hdfs dfs -put  /data/w205Project/spark/scala/learn_spam/data/* /user/spark/honeypot/
echo
echo
echo "Building the scala apps. Using SBT and SBT Assembly. File naming conventions of JARS generated are used in spark-submit." 
cd /data/w205Project/spark/scala/collect_tweets
echo "Assembling JARs for Initial Tweet Collection. This is to work on the classification model."
sbt package
sbt assemblyPackageDependency
chmod -R u+x target
echo
echo ".........................."
cd /data/w205Project/spark/scala/learn_spam
echo "Removing an existing model if already stored."
sudo -u hdfs hdfs dfs -rm -R /user/spark/honeypot/lr_sgd
echo "Assembling JARs for building the classification model."
sbt package
sbt assemblyPackageDependency
chmod -R u+x target
echo
echo ".........................."
cd /data/w205Project/spark/scala/classify_store_tweets
echo "Assembling JARs for classifying and storing streaming tweets."
sbt package
sbt assemblyPackageDependency
chmod -R u+x target
echo ".........................."
echo
echo "The apps should now be ready for spark-submit."
echo
echo
echo "To run collect_tweets, type the following two commands:"
echo "su w205"
echo ". /data/w205Project/spark/scala/collect_tweets/start-tweet-collection.sh"
echo
echo "To run learn_spam, type the following two commands:"
echo "su w205"
echo ". /data/w205Project/spark/scala/learn_spam/start-learn-spam.sh"
echo
echo "To start streaming classification, type the following two commands:"
echo "su w205"
echo ". /data/w205Project/spark/scala/classify_store_tweets/start-streaming-classification"
echo
echo 