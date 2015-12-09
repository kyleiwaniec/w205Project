psql (8.4.20)
You are now connected to database "twitter".
twitter=# \d+ twitters
                               Table "public.twitters"
      Column      |            Type             | Modifiers | Storage  | Description
------------------+-----------------------------+-----------+----------+-------------
 index            | bigint                      |           | plain    |
 user_id          | text                        |           | extended |
 tweet_id         | text                        |           | extended |
 tweet            | text                        |           | extended |
 num_words        | double precision            |           | plain    |
 created_ts       | timestamp without time zone |           | plain    |
 user_created_ts  | text                        |           | extended |
 tweet_created_ts | text                        |           | extended |
 screen_name      | text                        |           | extended |
 name             | text                        |           | extended |
 num_following    | double precision            |           | plain    |
 num_followers    | double precision            |           | plain    |
 num_tweets       | double precision            |           | plain    |
 retweeted        | boolean                     |           | plain    |
 retweet_count    | double precision            |           | plain    |
 num_urls         | double precision            |           | plain    |
 num_mentions     | double precision            |           | plain    |
 num_hastags      | double precision            |           | plain    |
 user_profile_url | text                        |           | extended |
 tweeted_urls     | text                        |           | extended |
 isPolluter       | double precision            |           | plain    |
Indexes:
    "ix_twitters_index" btree (index)
Has OIDs: no