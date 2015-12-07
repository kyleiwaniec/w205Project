#! /bin/bash

/data/spark15_hadoop24/bin/spark-submit \
 --class "w205.CollectTweets" \
 --master local[2] \
 --jars /data/w205Project/spark/user_classification/target/scala-2.11/user_classification-assembly-1.0-deps.jar \
  /data/w205Project/spark/user_classification/target/scala-2.11/user_classification_2.11-1.0.jar

