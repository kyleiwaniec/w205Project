#! /bin/bash

/data/spark15/bin/spark-submit \
--class "w205.ClassifyStoreTweetsUrls" \
--master local[2] \
--jars /data/w205Project/spark/scala/learn_spam/target/scala-2.11/classify_store_tweets-assembly-1.0-deps.jar \
/data/w205Project/spark/scala/learn_spam/target/scala-2.11/classify_store_tweets_2.11-1.0.jar
