# README

### Setup:

First of all make sure Hadoop is running as we will be creating some paths there. Assuming you are in /data/w205Project/spark/scala.

Then as root run the following script:

```
> . setup_scala.sh
```

Running collect_tweets (just collects data for examination and model parameter tweaking):

```
> . collect_tweets/start-tweet-collection.sh
```

The above application after it collects a 100K tweets.

In order to learn a model that can classify tweets as spam or ham:

```
> . learn_spam/start-learn-spam.sh
```

Once the model is stored, the streaming classification can be triggered.

```
> . classify_store_tweets/start-streaming-classification.sh
```

## Known Issues:

This is a WIP and incomplete at this point. Major reason for difficulties include:
1. REPL (spark-shell) and Spark-Submit do not exhibit similar behaviors.   
2. Lack of sufficient documentation, especially for advanced programming.   
3. Support for RDD to DF is not extensive.    
4. RDD to DF is easier when we can specify a schema and map to that schema by peering into the RDD. However, the twitter JSON content is especially challenging in this regard due to its nested structure. Thus the use of implicits or get<DType>(<Col-Num>) operations very challenging.   

<EOW> (End of Whining).

#### Issue #1:
Learn Spam uses spark-csv libraries from DataBricks to parse the training data. I am not sure where the EOF token is encountered (not familiar with CSV parsing rules). But this causes multiple errors on the logs when the training data is parsed. However, this does not cause a complete failure and we are able to complete the logistic regression with available data successfully.

#### Issue #2:
The following lines of code execute successfully in spark-shell, but fails due to an exception reported by scala-reflect (no such method error).

```
val tweetTable = hiveContext.read.format("json")
  .load("/user/spark/tweets/2015/12/19/tweetstream*/part*")
  tweetTable.registerTempTable("tweetTable")

val tweetData = sqlContext.sql("select user.followersCount, user.friendsCount, user.statusesCount, " +
	"length(user.screenName), length(user.description), size(split(text, ' ')) as numWords, " +
	"id as tweet_id from tweetTable")
```

Already tried compiling in 2.10.4, using selectExpr and using hive/sql Contexts. Need to research this further.

#### Issue #3:
Kind of the same issue when it comes to streaming classification. Ultimately the RDD must be processed and writing it into a DataFrame provides the best approach for inserting data into the postgres tables. I believe that understanding thoroughly the rules between RDD and DF and well as taking the time to pasrse a complicated, nested structure like the tweet object, could prove useful. 

#### Issue #4:
Zeppelin seems to work OK with reading into a DF from HDFS. However, there are some user permission issues that are unresolved. Streaming data is throwing errors at this time.
