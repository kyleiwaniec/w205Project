-- TODO: CRON will trigger the table partition addition based on date YYYY/MM/DD

ADD JAR /data/w205Project/load/hive-serdes-1.0-SNAPSHOT.jar;

ALTER TABLE tweets ADD IF NOT EXISTS 
  PARTITION (today_date = '2015/12/02')
  LOCATION '/user/flume/tweets/2015/12/02';
