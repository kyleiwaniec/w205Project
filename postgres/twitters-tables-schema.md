(ENV27)(reclassify) root@ip-172-31-21-9:spark $ psql -U postgres twitter
psql (8.4.20)
Type "help" for help.

twitter=# \d+ twitters
                                                    Table "public.twitters"
      Column      |            Type             |                      Modifiers                       | Storage  | Description
------------------+-----------------------------+------------------------------------------------------+----------+-------------
 id               | bigint                      | not null default nextval('twitter_id_seq'::regclass) | plain    |
 index            | integer                     |                                                      | plain    |
 row_created      | timestamp without time zone | not null default now()                               | plain    |
 user_id          | text                        |                                                      | extended |
 tweet_id         | text                        |                                                      | extended |
 tweet            | text                        |                                                      | extended |
 num_words        | integer                     |                                                      | plain    |
 created_ts       | text                        |                                                      | extended |
 user_created_ts  | text                        |                                                      | extended |
 tweet_created_ts | text                        |                                                      | extended |
 screen_name      | text                        |                                                      | extended |
 name             | text                        |                                                      | extended |
 num_following    | integer                     |                                                      | plain    |
 num_followers    | integer                     |                                                      | plain    |
 num_tweets       | integer                     |                                                      | plain    |
 retweeted        | boolean                     |                                                      | plain    |
 retweet_count    | integer                     |                                                      | plain    |
 num_urls         | integer                     |                                                      | plain    |
 num_mentions     | integer                     |                                                      | plain    |
 num_hastags      | integer                     |                                                      | plain    |
 user_profile_url | text                        |                                                      | extended |
 tweeted_urls     | text                        |                                                      | extended |
 is_polluter      | double precision            |                                                      | plain    |
Has OIDs: no