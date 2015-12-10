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


legit_data = pd.read_csv("/data/w205Project/honeypot/sample_legit_data.csv")
spam_data = pd.read_csv("/data/w205Project/honeypot/sample_polluter_data.csv")
# name the columns 
legit_data.columns = ["user_id",
				"tweet_id",
				"tweet",
				"tweet_created_at",
				"user_created_at",
				"collected_at",
				"num_following",
				"num_followers",
				"num_tweets",
				"LengthOfScreenName",
				"LengthOfDescriptionInUserProfile"]

spam_data.columns = ["user_id",
				"tweet_id",
				"tweet",
				"tweet_created_at",
				"user_created_at",
				"collected_at",
				"num_following",
				"num_followers",
				"num_tweets",
				"LengthOfScreenName",
				"LengthOfDescriptionInUserProfile"]

legit_data['isPolluter'] = 0
spam_data['isPolluter'] = 1


allData = pd.concat([legit_data,spam_data])






#regex to get counts from the tweet text alone:
words = re.compile('\S+')
hashtags = re.compile('^\\#')
urls = re.compile('^(http|www)')
mentions = re.compile('^\\@')

allData['num_words'] = allData['tweet'].apply(lambda x: len(words.findall(x)))
allData['num_hashtags'] = allData['tweet'].apply(lambda x: len(hashtags.findall(x)))
allData['num_urls'] = allData['tweet'].apply(lambda x: len(urls.findall(x)))
allData['num_mentions'] = allData['tweet'].apply(lambda x: len(mentions.findall(x)))

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

# Index([u'user_id', 
# 1		u'tweet_id', 
# 2		u'tweet', 
# 3		u'tweet_created_at',
# 4		u'user_created_at', 
# 5		u'collected_at', 
# 6		u'num_following', 
# 7		u'num_followers',
# 8		u'num_tweets', 
# 9		u'LengthOfScreenName',
# 10		u'LengthOfDescriptionInUserProfile', 
# 11		u'isPolluter', 
# 12		u'num_words',
# 13		u'num_hashtags', 
# 14		u'num_urls', 
# 15		u'num_mentions'],
#       dtype='object')

print "fitting the model..."

train_cols = allData.columns[[6,7,8,12]]
print train_cols
# Index([u'num_following', u'num_followers', u'num_tweets', u'num_words',
#        u'num_hashtags', u'num_urls', u'num_mentions'],
#       dtype='object')

logit = sm.Logit(allData['isPolluter'], allData[train_cols])
model = logit.fit()

'''
print model.summary()
print "Odds Ratios: \n"
print np.exp(model.params)
'''

# USERS_TWEETS_ATTRIBUTES:
# user_id|tweet_id|tweet|num_words|created_ts|user_created_ts|tweet_created_ts|screen_name|name|num_following|num_followers|num_tweets|retweeted|retweet_count|num_urls|num_mentions|num_hashtags|user_profile_url|tweeted_urls

newdata = sqlContext.sql("select * from USERS_TWEETS_ATTRIBUTES")


pdf = newdata.toPandas()

predict_cols = pdf.columns[[9,10,11,3]]
print predict_cols
# Index([u'num_following', u'num_followers', u'num_tweets', u'num_words',
#        u'num_hastags', u'num_urls', u'num_mentions'],
#       dtype='object')

pdf['is_polluter'] = model.predict(pdf[predict_cols])


'''
print "Predictions: \n"
print pdf.head()
'''

# set a threshhold of 85% probability to flag as spammer
polluters = pdf[pdf.is_polluter > 0.85]

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

from sqlalchemy import create_engine
engine = create_engine('postgresql://postgres:pass@localhost:5432/twitter')
con = engine.connect()
print pdf.shape
print pdf.columns
pdf.to_sql(con=con, name='twitters', if_exists='replace', flavor='postgresql')

'''
if_exists: {'fail', 'replace', 'append'}, default 'fail'
     fail: If table exists, do nothing.
     replace: If table exists, drop it, recreate it, and insert data.
     append: If table exists, insert data. Create if does not exist.
'''

