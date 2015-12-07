-- add the JSON SERDE -- 
ADD JAR /data/w205Project/load/hive-serdes-1.0-SNAPSHOT.jar;

-- drop and create an external table partitioned by the date YYYY/MM/DD
-- we will collect data once a day

DROP TABLE tweets;
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
PARTITIONED BY (tweets_date STRING)
ROW FORMAT SERDE 'com.cloudera.hive.serde.JSONSerDe'
LOCATION '/user/flume/tweets';

-- Define the partition column by setting a starting point.
-- From here on, CRON will add partitions. We may ultimately take the below snippet out.

ALTER TABLE tweets ADD IF NOT EXISTS 
PARTITION (tweets_date = '2015/11/16/') 
LOCATION '/user/flume/tweets/2015/11/16';

-- sanity check
select * from tweets limit 1;
