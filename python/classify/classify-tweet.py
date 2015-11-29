#sudo pip install statsmodels
#sudo pip install patsy
import re
import pandas as pd
import statsmodels.api as sm
import numpy as np

# read the training data in
legitTweets = pd.read_csv("/Users/koza/Documents/UCBerkeley/205/project/w205Project/python/classify/sample_legit_tweets.csv")
polluterTweets = pd.read_csv("/Users/koza/Documents/UCBerkeley/205/project/w205Project/python/classify/sample_polluter_tweets.csv")

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

print allTweets.head()

train_cols = allTweets.columns[5:9]

logit = sm.Logit(allTweets['isPolluter'], allTweets[train_cols])
model = logit.fit()

print model.summary()

# Print the odds ratios
print "Odds Ratios: \n"
print np.exp(model.params)

# this will be replaced by the actual collected data
newdata = [ {'num_words' : 20, 'num_hashtags' : 0, 'num_urls' : 0, 'num_mentions' : 1},
			{'num_words' : 20, 'num_hashtags' : 2, 'num_urls' : 20, 'num_mentions' : 1},
			{'num_words' : 6, 'num_hashtags' : 1, 'num_urls' : 0, 'num_mentions' : 1}]

df = pd.DataFrame(newdata)

# set the isPulluter variable by predicting if tweet is spammy
df['isPolluter'] = model.predict(df[train_cols])

print "Predictions: \n"
print df.head()