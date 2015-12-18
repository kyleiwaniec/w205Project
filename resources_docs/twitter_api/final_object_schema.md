## Final Schema to Store Transformed Data

__The Object Schema that is the O/P of Spark-SQL step:__

__Initial Iteration (Minimal Scope):__

* URLs from Tweet Content
Path: entities.urls[i].expanded_url

__Further Iterations:__


User Attributes:

* When was the user account created?
Path: user.created_at
* How many twitter users is this user following? 
Path: user.friends_count 
* How many twitter users are following this user?
Path: user.followers_count
* How many tweets has this user sent?
Path: user.statuses_count
* Is this user a verified twitter account (applies only to select few)?
Path: user.verified
* User's profile URL
Path: user.url
* Is this user withheld in any country under "user" scope?
Path: user.withheld_in_countries & user.withheld_scope

Tweet Attributes (assuming we consider only tweets without retweeted_status attribute):

* How many twitter users liked this tweet?
Path: favorite_count
* How many times was this tweet retweeted?
path: retweet_count
* How is this (promoted)tweet being broadcast?
Path: scopes.followers_count
* Has this tweet been withheld in any or all countries?
Path: withheld_in_countries
* Does this tweet content have many hashtags?
Path: entities.hashtags[i]
* Does this tweet content have many user mentions?
Path: entities.user_mentions[i]
* Does this tweet content have many embedded media?
Path: entities.media[i]
* Does the tweet content have too many URLs?
Path: entities.urls[i]