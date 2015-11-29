#execfile('/data/w205Project/spark/getLinks.py')

from pyspark.sql.functions import UserDefinedFunction
from pyspark.sql.types import *
from pyspark.sql import functions as F
from pyspark.sql.window import Window

sqlContext.sql("ADD JAR /data/w205Project/load/hive-serdes-1.0-SNAPSHOT.jar");
sqlContext.sql("ADD JAR /usr/lib/hadoop/hadoop-aws.jar");
#sqlContext.sql("ADD JAR /usr/lib/hadoop/lib/aws-java-sdk-1.7.14.jar");

###############################################
#    EXTRACT ALL THE LINKS INDISCRIMINATELY   #
###############################################

'''
links = sqlContext.sql("select entities.urls.url[0] as tco, entities.urls.expanded_url[0] as link from tweets where entities.urls.url[0] IS NOT NULL");
uniqueLInks = links.dropDuplicates(['tco', 'link'])
uniqueLInks.repartition(1).save("s3n://w205twitterproject/links3","json")
'''


###############################################
#                  ANALYZE                    #
###############################################


tweets = sqlContext.sql("""
	select 
		text as tweet, 
		entities.urls as urls, 
		entities.user_mentions as mentions, 
		entities.hashtags as hashtags, 
		user.friends_count as num_friends, 
		user.followers_count as num_followers,
		user.verified
	from tweets 
	""");

print tweets.take(5)


# pip install pandas
# pip install statsmodels
# pip install numpy
import re
import pandas as pd
import statsmodels.api as sm
import numpy as np

# read the training data in
# TODO: JOIN the users tables to get the follwers/following counts
# TODO: set paths as env vars os.environ["TRAINING_DATA"]
legitTweets = pd.read_csv("/data/w205Project/python/classify/sample_legit_tweets.csv")
polluterTweets = pd.read_csv("/data/w205Project/python/classify/sample_polluter_tweets.csv")

legitTweets['isPolluter'] = False
polluterTweets['isPolluter'] = True

allTweets = pd.concat([legitTweets,polluterTweets])

# rename the columns 
allTweets.columns = ["user_id","tweet_id","tweet","created_at","isPolluter"]

#regex
words = re.compile('\S+')
hashtags = re.compile('^\\#')
urls = re.compile('^(http|www)')
mentions = re.compile('^\\@')

allTweets['num_words'] = allTweets['tweet'].apply(lambda x: len(words.findall(x)))
allTweets['num_hashtags'] = allTweets['tweet'].apply(lambda x: len(hashtags.findall(x)))
allTweets['num_urls'] = allTweets['tweet'].apply(lambda x: len(urls.findall(x)))
allTweets['num_mentions'] = allTweets['tweet'].apply(lambda x: len(mentions.findall(x)))

#print allTweets.head()

train_cols = allTweets.columns[5:9]

logit = sm.Logit(allTweets['isPolluter'], allTweets[train_cols])
model = logit.fit()

#print model.summary()

# Print the odds ratios
print "Odds Ratios: \n"
print np.exp(model.params)

# this will be replaced by the actual collected data
newdata = [ {'num_words' : 20, 'num_hashtags' : 0, 'num_urls' : 0, 'num_mentions' : 1},
			{'num_words' : 20, 'num_hashtags' : 2, 'num_urls' : 20, 'num_mentions' : 1},
			{'num_words' : 6, 'num_hashtags' : 1, 'num_urls' : 0, 'num_mentions' : 1}]


newdata = tweets.select(
	#(len(tweets.tweet.split(' '))).alias('num_words'), 
	(tweets.hashtags.map(lambda x : len(x)).alias('num_hashtags')
	#(len(tweets.urls)).alias('num_urls'), 
	#(len(tweets.mentions)).alias('num_mentions'))

newdata.show(5)

'''

df = pd.DataFrame(newdata)

# set the isPulluter variable by predicting if tweet is spammy
df['isPolluter'] = model.predict(df[train_cols])

print "Predictions: \n"
print df.head()

'''