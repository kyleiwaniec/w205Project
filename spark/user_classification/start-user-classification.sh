#! /bin/bash

/data/spark15_hadoop24/bin/spark-submit \
--class "TransformTweetsData" \
--master local[4] \
/data/w205Project/spark/user_classification/target/scala-2.11/user_classification_2.11-1.0.jar
