#execfile('/data/w205Project/spark/getLinks.py')

from pyspark.sql.functions import UserDefinedFunction
from pyspark.sql.types import *
from pyspark.sql import functions as F
from pyspark.sql.window import Window

sqlContext.sql("ADD JAR /data/w205Project/load/hive-serdes-1.0-SNAPSHOT.jar");
sqlContext.sql("ADD JAR /usr/lib/hadoop/hadoop-aws.jar");
sqlContext.sql("ADD JAR /usr/lib/hadoop/lib/aws-java-sdk-1.7.14.jar");

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

legitUsers = pd.read_csv("/data/w205Project/python/classify/legitimate_users.csv")
polluterUsers = pd.read_csv("/data/w205Project/python/classify/content_polluters.csv")

legitUsers['isPolluter'] = False
polluterUsers['isPolluter'] = True
legitUsers.columns = ["user_id","user_created_at","collected_at","num_following","num_followers","num_tweets","LengthOfScreenName","LengthOfDescriptionInUserProfile","isPolluter"]
polluterUsers.columns = ["user_id","user_created_at","collected_at","num_following","num_followers","num_tweets","LengthOfScreenName","LengthOfDescriptionInUserProfile","isPolluter"]


allTweets = pd.concat([legitTweets,polluterTweets])
# rename the columns 
allTweets.columns = ["user_id","tweet_id","tweet","created_at","isPolluter"]

allUsers = pd.concat([legitUsers,polluterUsers])
# rename the columns 
allUsers.columns = ["user_id","user_created_at","collected_at","num_following","num_followers","num_tweets","LengthOfScreenName","LengthOfDescriptionInUserProfile","isPolluter"]


allData = allTweets.merge(allUsers, how='left', left_on='user_id', right_on='user_id')


#regex
words = re.compile('\S+')
hashtags = re.compile('^\\#')
urls = re.compile('^(http|www)')
mentions = re.compile('^\\@')

allData['num_words'] = allData['tweet'].apply(lambda x: len(words.findall(x)))
allData['num_hashtags'] = allData['tweet'].apply(lambda x: len(hashtags.findall(x)))
allData['num_urls'] = allData['tweet'].apply(lambda x: len(urls.findall(x)))
allData['num_mentions'] = allData['tweet'].apply(lambda x: len(mentions.findall(x)))

#list(allData.columns.values)


train_cols = allUsers.columns[3:5]

logit = sm.Logit(allUsers['isPolluter'], allUsers[train_cols])
model = logit.fit()

'''
print model.summary()
print "Odds Ratios: \n"
print np.exp(model.params)
'''

# USERS_TWEETS_ATTRIBUTES
# user_id|tweet_id|tweet|num_words|created_ts|user_created_ts|tweet_created_ts|screen_name|name|num_following|num_followers|num_tweets|retweeted|retweet_count|num_urls|num_mentions|num_hastags|user_profile_url|tweeted_urls

newdata = sqlContext.sql("select * from USERS_TWEETS_ATTRIBUTES")

pdf = newdata.toPandas()

# set the isPulluter variable by predicting if tweet is spammy
pdf['isPolluter'] = model.predict(pdf[train_cols])

print "Predictions: \n"
print pdf.head()


polluters = pdf[pdf.isPolluter > 0.85]

print polluters.head()
#.to_json(orient="records")
links = polluters.tweeted_urls

df = sqlContext.createDataFrame(pd.DataFrame(links))
df = df.select(['tweeted_urls.url', 'tweeted_urls.expanded_url'])
uniqueLInks = df.dropDuplicates(['url', 'expanded_url'])

uniqueLInks.repartition(1).save("s3n://w205twitterproject/temp_urls","json")





