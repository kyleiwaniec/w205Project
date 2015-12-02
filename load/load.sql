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
  retweeted_status STRUCT<
    text:STRING,
    user:STRUCT<screen_name:STRING,name:STRING>,
    retweet_count:INT>,
  entities STRUCT<
    urls:ARRAY<STRUCT<url:STRING,expanded_url:STRING>>,
    user_mentions:ARRAY<STRUCT<screen_name:STRING,name:STRING>>,
    hashtags:ARRAY<STRUCT<text:STRING>>>,
  text STRING,
  user STRUCT<
    screen_name:STRING,
    id_str:string,
    created_at:STRING,
    name:STRING,
    screen_name:STRING,
    url:STRING,
    friends_count:INT,
    followers_count:INT,
    statuses_count:INT,
    verified:BOOLEAN,
    utc_offset:INT,
    time_zone:STRING>,
  in_reply_to_screen_name STRING
)
PARTITIONED BY (today_date STRING)
ROW FORMAT SERDE 'com.cloudera.hive.serde.JSONSerDe'
LOCATION '/user/flume/tweets';

-- Define the partition column by setting a starting point.
-- From here on, CRON will add partitions. We may ultimately take the below snippet out.

ALTER TABLE tweets ADD IF NOT EXISTS
  PARTITION (today_date = from_unixtime(unix_timestamp() ,  'yyyy/MM/dd') 
  LOCATION '/user/flume/tweets/'from_unixtime(unix_timestamp() ,  'yyyy/MM/dd');
--PARTITION (today_date = '2015/12/02')--
--LOCATION '/user/flume/tweets/2015/12/02';--

-- sanity check
select * from tweets limit 1;


-- SELECT
--     *
--   , from_unixtime(unix_timestamp() - (86400*2) ,  'yyyy/MM/dd')
-- FROM tweets;