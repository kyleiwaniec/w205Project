## TRANSFORMING TWEETS

#### Tweets to Users_Tweets_Attributes

We are simply extracting most relevant fields from the tweets table for further spam analysis and classification.
Based on my best judgement, defering the more complciated transformations for the Spark programming API.
Example:
Finding out how long a user's account has existed in the twitter universe requires subtracting the  account created date from the current date.
This is not a simple or intuitive task in Hive. UDTF only works with SELECT.
Also created_at needs to go through string manipulation before it can be treated as date in Hive.
Spark- scala should make this a lot easier.

