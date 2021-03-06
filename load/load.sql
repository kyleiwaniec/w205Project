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

-- From here on, CRON will add partitions.
