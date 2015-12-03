#execfile('/data/w205Project/spark/getLinks.py') <-- don't use. use spark-submit instead.

from pyspark import SparkContext, HiveContext
sc = SparkContext()
sqlContext = HiveContext(sc)


from pyspark.sql.functions import UserDefinedFunction
from pyspark.sql.types import *
from pyspark.sql import functions as F
from pyspark.sql.window import Window

sqlContext.sql("ADD JAR /data/w205Project/load/hive-serdes-1.0-SNAPSHOT.jar");
# sqlContext.sql("ADD JAR /usr/lib/hadoop/hadoop-aws.jar");
#sqlContext.sql("ADD JAR /usr/lib/hadoop/lib/aws-java-sdk-1.7.14.jar");

###############################################
#    EXTRACT ALL THE LINKS INDISCRIMINATELY   #
###############################################

'''
links = sqlContext.sql("select entities.urls.url[0] as tco, entities.urls.expanded_url[0] as link from tweets where entities.urls.url[0] IS NOT NULL");
uniqueLInks = links.dropDuplicates(['tco', 'link'])
uniqueLInks.repartition(1).save("s3n://w205twitterproject/links5","json")
'''


###############################################
#                  ANALYZE                    #
###############################################

# pip install pandas
# pip install statsmodels (Installing collected packages: numpy, scipy, six, python-dateutil, pytz, pandas, patsy, statsmodels)
# pip install numpy
import re
import pandas as pd
import statsmodels.api as sm
import numpy as np


# TODO: set paths as env vars os.environ["TRAINING_DATA"]

# get the honeypot tweets data
legitTweets = pd.read_csv("/data/w205Project/honeypot/sample_legit_tweets.csv")
polluterTweets = pd.read_csv("/data/w205Project/honeypot/sample_polluter_tweets.csv")
legitTweets['isPolluter'] = False
polluterTweets['isPolluter'] = True
allTweets = pd.concat([legitTweets,polluterTweets])
# name the columns 
allTweets.columns = ["user_id",
				"tweet_id",
				"tweet",
				"created_at",
				"isPolluter"]


# Get the honeypot user data
legitUsers = pd.read_csv("/data/w205Project/honeypot/legitimate_users.csv")
polluterUsers = pd.read_csv("/data/w205Project/honeypot/content_polluters.csv")
# rename the columns 
legitUsers.columns = ["user_id",
				"user_created_at",
				"collected_at",
				"num_following",
				"num_followers",
				"num_tweets",
				"LengthOfScreenName",
				"LengthOfDescriptionInUserProfile"]
polluterUsers.columns = ["user_id",
				"user_created_at",
				"collected_at",
				"num_following",
				"num_followers",
				"num_tweets",
				"LengthOfScreenName",
				"LengthOfDescriptionInUserProfile"]	
legitUsers['isPolluter'] = False
polluterUsers['isPolluter'] = True
allUsers = pd.concat([legitUsers,polluterUsers])


# merge tweets and users for use in regression
# This merge is not quite what we're looking for, and is not currently in use:
allData = allTweets.merge(allUsers, how='left', left_on='user_id', right_on='user_id')


#regex to get counts from the tweet text alone:
words = re.compile('\S+')
hashtags = re.compile('^\\#')
urls = re.compile('^(http|www)')
mentions = re.compile('^\\@')

allTweets['num_words'] = allTweets['tweet'].apply(lambda x: len(words.findall(x)))
allTweets['num_hashtags'] = allTweets['tweet'].apply(lambda x: len(hashtags.findall(x)))
allTweets['num_urls'] = allTweets['tweet'].apply(lambda x: len(urls.findall(x)))
allTweets['num_mentions'] = allTweets['tweet'].apply(lambda x: len(mentions.findall(x)))

#list(allData.columns.values)

#################################################################################################################
#
#   SO... I RAN OUTTA TIME. MERGING TWEETS AND USERS PRODUCED SOME FUNKY RESULTS
#   AND I WAS NOT ABLE TO RUN THE REGRESSION PROPERLY.
#
#   USING ONLY THE allTweets DATA, DIDN'T PRODUCE ANY SPAMMERS - MAYBE THEY GOT SMART SINCE THAT PAPER WAS WRITTEN.
#   USING THE allUsers DATA TO FIT A MODEL DOES INDEED PRODUCE RESULTS. IN THE INTEREST OF SEEING SOMETHING
#   AT ALL, I'M JUST GONNA GO WITH IT.
#
#   THE BIG CAVEAT IS... THE MODEL IS NOT SO AWESOME. HENSE, FOR DEMONSTRATION PURPOSES ONLY. 
#   HOWEVER, IT IS NOT THE FOCUS OF THE PROJECT, SO BE IT... THIS ML IS IS SUPER NAIVE ANYWAY (I HAVE NOT TAKEN 207 YET!)
#
#################################################################################################################


print "fitting the model..."
train_cols = allUsers.columns[3:5]

logit = sm.Logit(allUsers['isPolluter'], allUsers[train_cols])
model = logit.fit()

'''
print model.summary()
print "Odds Ratios: \n"
print np.exp(model.params)
'''

# USERS_TWEETS_ATTRIBUTES:
# user_id|tweet_id|tweet|num_words|created_ts|user_created_ts|tweet_created_ts|screen_name|name|num_following|num_followers|num_tweets|retweeted|retweet_count|num_urls|num_mentions|num_hastags|user_profile_url|tweeted_urls

newdata = sqlContext.sql("select * from USERS_TWEETS_ATTRIBUTES")

pdf = newdata.toPandas()
pdf['isPolluter'] = model.predict(pdf[train_cols])

'''
print "Predictions: \n"
print pdf.head()
'''

# set a threshhold of 85% probability to flag as spammer
polluters = pdf[pdf.isPolluter > 0.85]

#.to_json(orient="records")
links = polluters.tweeted_urls
links_df = sqlContext.createDataFrame(pd.DataFrame(links))
links_df = links_df.select(['tweeted_urls.url', 'tweeted_urls.expanded_url'])
uniqueLInks = links_df.dropDuplicates(['url', 'expanded_url'])

# forget about S3:
# uniqueLInks.repartition(1).save("s3n://w205twitterproject/temp_urls","json")
print "saving file to /data/w205Project/honeypot/temp_urls.json...."
# instead, save to file on local disk for use by scrapy
uniqueLInks.toPandas().to_json(orient="records",path_or_buf='/data/w205Project/python/url_spider/url_spider/logs/temp_urls.log')


#################################################################################################################
#    APPEND CLASSIFIED DATA TO POSTGRES FOR DASHBOARD
#################################################################################################################

# pip install sqlalchemy
# pip install psycopg2

from sqlalchemy import create_engine
engine = create_engine('postgresql://postgres:pass@localhost:5432/twitter')
con = engine.connect()

pdf.to_sql(con=con, name='twitters', if_exists='append', flavor='postgresql')

'''
if_exists: {'fail', 'replace', 'append'}, default 'fail'
     fail: If table exists, do nothing.
     replace: If table exists, drop it, recreate it, and insert data.
     append: If table exists, insert data. Create if does not exist.
'''

