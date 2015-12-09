#! /bin/bash

/data/spark15_hadoop24/bin/spark-submit \
--class "w205.ClassifyTweets" \
--master local[2] \
--jars /data/w205Project/spark/scala/classify_tweets/target/scala-2.11/classify_tweets-assembly-1.0-deps.jar \
/data/w205Project/spark/scala/classify_tweets/target/scala-2.11/classify_tweets_2.11-1.0.jar
