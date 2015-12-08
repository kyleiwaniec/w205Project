#! /bin/bash

/data/spark15_hadoop24/bin/spark-submit \
 --class "w205.CollectTweets" \
 --master local[2] \
 --jars /data/w205Project/spark/scala/collect_tweets/target/scala-2.11/collect_tweets-assembly-1.0-deps.jar \
  /data/w205Project/spark/scala/collect_tweets/target/scala-2.11/collect_tweets_2.11-1.0.jar

