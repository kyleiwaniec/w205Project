#! /bin/bash

/data/spark15_hadoop24/bin/spark-submit \
--class "w205.TrainOnTweets" \
--master local[2] \
--jars /data/w205Project/spark/scala/learn_spam/target/scala-2.11/learn_spam-assembly-1.0-deps.jar \
/data/w205Project/spark/scala/learn_spam/target/scala-2.11/learn_spam_2.11-1.0.jar