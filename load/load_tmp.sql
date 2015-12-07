-- USING DATEHOUR DID NOT WORK WITH THE load.sql
-- FLUME SINK FILE CONFIG NEEDS TO MATCH THE EXPECTATIONS HERE
-- THIS IS A TEMP LOAD FILE UNTIL WE TEST AND CHOOSE THE BEST METHOD

-- add the JSON SERDE -- 
ADD JAR /data/w205Project/load/hive-serdes-1.0-SNAPSHOT.jar;

-- CLEAN-UP ALLOWS RERUNS OF THIS SCRIPT
DROP TABLE TWEETS;

-- CREATE AN EXTERNAL TABLE IN HIVE
-- THE CONTENT WAS ALREADY LOADED BY FLUME INTO HDFS
-- THE CONTENT CAN BE PARTITIONED BY DATE

CREATE EXTERNAL TABLE tweets (  
  id_str STRING,
  created_at STRING,
  source STRING,
  favorited BOOLEAN,
  retweet_count INT,
  retweeted BOOLEAN,
  retweeted_status STRUCT<text:STRING,retweet_count:INT>,
  entities STRUCT<
	urls:ARRAY<STRUCT<url:STRING,expanded_url:STRING>>,
	user_mentions:ARRAY<STRUCT<screen_name:STRING,name:STRING>>,
	hashtags:ARRAY<STRUCT<text:STRING>>>,
  text STRING,
  user STRUCT<
	created_at:STRING,
	id_str:STRING,
	url:STRING,
	screen_name:STRING,
	name:STRING,	
	friends_count:INT,
	followers_count:INT,
	statuses_count:INT,
	verified:BOOLEAN>
) 
PARTITIONED BY (tweets_date String)
ROW FORMAT SERDE 'com.cloudera.hive.serde.JSONSerDe'
LOCATION '/user/flume/tweets';

ALTER TABLE TWEETS ADD IF NOT EXISTS
PARTITION (tweets_date='2015/11/16')
LOCATION 'user/flume/tweets/2015/11/16';

-- sanity check
SELECT * FROM TWEETS LIMIT 1;

