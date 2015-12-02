#! bin/bash

today=$(date +"%Y/%m/%d")
location="/user/flume/tweets/$today"
hive -e "ADD JAR /data/w205Project/load/hive-serdes-1.0-SNAPSHOT.jar; ALTER TABLE tweets ADD IF NOT EXISTS PARTITION (today_date = '$today') location '$location';"
