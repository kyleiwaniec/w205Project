## Twitter API - A Quick Look

The information below is a based on analysis of twitter's documentation:
1) [Twitter API Overview]
[Twitter API Overview]: https://dev.twitter.com/overview/api

Note that since Nov 3, 2015, Twitter is using LIKE instead of FAVOURITE in some documentation.

### Twitter IDs

|Data|Data Type|Description|Example|Notes|
|----|---------|-----------|------|-----------|
|id|Int64|The tweet's unique ID|"id": 10765432100123456789|Not Recommended|
|id_str|String|The tweet's unique ID as String|"id_str": "10765432100123456789"|__The Recommended Approach__|

__Do we need to store this__
1) Yes. This is an unique identifier associated with each data point.
2) The main objects all have id and id_str.

### The Main Objects

1) Users
2) Tweets
3) Entities & Entities in Objects
4) Places

### Object - Users

* Anyone or anything that can tweet, follow and be followed; can be mentioned, looked-up and have a home timeline
* New fields could be added and/or ordering changed
* Whether a field is part of the data depends on the context
* Null = Empty = Missing field for practical purposes (also called Perspecivals)

__List of Fields to Retain__

|Data|Data Type|Description|Example|Notes|Reason|
|----|---------|-----------|------|-----------|-----|
|created_at|String|UTC datetime of User Account Creationg|"created_at": "Mon Nov 29 21:18:15 +0000 2010"|NA|Time Stamp always good to for querying, as well as a factor of credibility|
|description|String|User's description of their account|"description":"The Real Twitter API."|NA|Keywords may indicate spam|
|favourites_count|Int|# of tweets favorited by this account in all time|"favourites_count": 13|Note the British spelling|Factor of credibility|
|followers_count|Int|The number of followers the acct currently has|"followers_count": 21|Can temporarily be 0|Factor of Credibility|
|friends_count|Int|The number of users this acct is currently following|"followers_count": 21|Can temporarily be 0|Factor of Credibility|
|listed_count|Int|The number of public lists this user is a member of|"listed_count":1234|Factor of Credibility|
|name|String|Name chosen by the user to associate with the acct||Size subject to change (typically upto 20 chars|Maybe useful in keyword match for spam classification|
|screen_name|String|User name alias||Typically 15 chars, could change; id_str is recommended|Screen Name + Name could be used for spam classification|
|statuses_count|Int|The number of tweets (incl retweets) issued by the user|"statuses_count": 42|NA|Factor for classification|
|url|String|URL associated with the profile of the user|"url":"http://www.spam.com"|Nullable, may not even be there|Scrap this URL and use keywords for classification|
|verified|Boolean|Verified brand or key individual or company or group|"verified":false|Not available to public|Factor of Credibility - could be used to immediately classify as non-spam ([What is a verified account?])|
|withheld_in_countries|String|Country codes where acct is withheld|"withheld_in_countries": "GR, HK, MY"|May not be present; data type is Array of Strings in Tweets Object - is it an array here too?|Factor of classification - but consider the country's record as well|
|withheld_scope|String|Is the user or the tweet being withheld|"withheld_scope": "user"|May not be present|If the User is withheld, pay attention|
|status|Tweets|user’s most recent tweet or retweet.||See section Object - Tweets|Useful features listed in later section.|
|entities|Entities|Entities which have been parsed out of the url or description fields defined by the user.||See section Object - Entities|Useful features listed in later section.|

[What is a verified account?]: https://support.twitter.com/articles/119135

### Object - Tweets

* This object is nested under User as "Status"
* Tweets are something that can be embedded, replied to liked (fovourited), unliked (unfavourited) and deleted
* This can be NULL or Not Present
* [Embedded objects like tweets can be stale and inaccurate]. This is not a major problem for this project as accuracy as is, is sufficient.
* Tweets embeds Users, Entities and Places.
* Other nested objects (not used in this project) are: Contributors & Coordinates.
* Coordinates: the latitude & longtitude indicating the origin of the tweet.
* Places: the geo location info object associated with a tweet - does not indicate origin.

[Embedded objects like tweets can be stale and inaccurate]: https://dev.twitter.com/faq#41

__List of Fields to Retain__

|Data|Data Type|Description|Example|Notes|Reason|
|----|---------|-----------|------|-----------|------|
|created_at|String|UTC time when the tweet was created|"created_at":"Wed Aug 27 13:08:45 +0000 2008"|NA|Query window as well as Factor of Credibility|
|favorite_count|Int|How many twitter users liked this tweet|"favorite_count":1138|Nullable; approximate value|Factor of Credibility/Classfication|
|possibly_sensitive|Boolean|URL contained in the tweet may be sensitive|"possibly_sensitive":true|Null if there is no link in the tweet|NOT SURE IF USEFUL|
|scopes|Object|Key-Value pairs - who should the tweet be delivered to|"scopes":{"followers":false}|Used only by __PROMOTED__ tweets|Could we differentiate betn the good and bad in "promoted"?|
|retweet_count|Int|Number of times this tweet has been retweeted|"retweet_count":1585|NA|Factor of Credibility/Classification|
|retweeted_status|Tweet|The presence of this attribute indicates that the content is a retweet|<Tweet Object>|When many different users are retweeting a tweet with some content and/or URL, it becomes more credible|
|text|String|Actual content of the tweet|"text":"Tweet Button, Follow Button, and Web Intents javascript now support SSL http:\/\/t.co\/9fbA0oYy ^TS"|[Valid Chars]|Get kewords for classification from here|
|withheld_in_countries|Array of String|Country codes where acct is withheld; XX-> Withheld in all countries; XY->Withheld due to DMCA|"withheld_in_countries": "GR, HK, MY"|May not be present|Factor of classification - but consider the country's record as well|
|withheld_scope|String|Is the user or the tweet being withheld|"withheld_scope": "user"|May not be present|If the User is withheld, pay attention|
|user|User|The user who posted this tweet.||See section Object - Users|Useful features listed in later section.|
|entities|Entities|Entities which have been parsed out of the url or description fields defined by the user.||See section Object - Entities|Useful features listed in later section.|

[Valid Chars]: https://github.com/twitter/twitter-text/blob/master/rb/lib/twitter-text/regex.rb

### Object - Entities

* Entitities are tightly coupled to other Twitter Objects.
* Provide meta-data about twitter content.
* Only meaningful within its context.
* Instrumental in Resolving URLs. 
* Twitter URL Handling is essential knowledge for this project. [Read full documentation here.]

[Read full documentation here.]: https://dev.twitter.com/overview/t.co
 
__User Entities__

It describes: 
> The URL defined in the user defined URLs in __profile url__ or __profile description__

It does not describe:
> Hash tags or User mentions

User entitities can apply to multiple fields within its parent object. 
In order to access the appropriate entitity, a parent node for each field can be found inside the Entity Object.

Consider the following example:

```
 {
  "id": 6253282,
  "id_str": "6253282",
  "name": "Twitter API",
  "screen_name": "twitterapi",
  "location": "San Francisco, CA",
  "description": "The Real Twitter API. I tweet about API changes, service issues and happily answer questions about Twitter and our API. Don't get an answer? It's on my website.",
  "url": "http:\/\/t.co\/78pYTvWfJd",
  "entities": {
    "url": {
      "urls": [{
        "url": "http:\/\/t.co\/78pYTvWfJd",
        "expanded_url": "http:\/\/dev.twitter.com",
        "display_url": "dev.twitter.com",
        "indices": [0, 22]
      }]
    },
    "description": {
      "urls": []
    }
  }
  ...
}
```
There are two possible places where twitter links may exist in the User object: url and description.
The url in the User object is:
```
"url": "http:\/\/t.co\/78pYTvWfJd"
```
There is no t.co url in description. So we will ignore that in this example.

In order to access the expanded URL from the entities object:
```
entities/url/urls[0]
```

__Tweet Entities__

* Provide structured data from tweets.
* Categories: media, urls, user_mentions, hashtags, symbols, extended_entities.
* The user_mentions entity can be ignored for it does not provide any insight for classification directly.
* The hashtag entity can be used to get a count of hashtags appearing in the tweet content or the list of hashtag texts appearing in the tweet could be considered as keywords for classification
* The media and extended_entities (for videos etc) need not be delved into deeper; may be a count of such URLs is a sufficient feature for classification
* The purpose of the symbols entity is unclear - will ignore for now.
* The urls entity seems to be of most importance to this project.

__List of Fields to Retain__

|Data|Data Type|Description|Example|Notes|Reason|
|----|---------|-----------|------|-----------|------|
|hashtags|Array of Object|Hashtags that have been parsed out of tweet content|"hashtags":[{"indices":[32,36],"text":"lol"}]|NA|Number of hashtags per tweet was considered a top 10 indicator of spam ([Paper])|
|media|Array of Object|Media elements uploaded with the tweet|<Example is too big>|NA|Possible that it plays a similar role to hashtags|
|urls|Array of Object|Contains URLs from the tweet content or user profile url or description|<Example provided above in User Entities Section>|Nullable, may not be present|URLs in tweet content as well user profile is valuable for classification|

[Paper]: http://www.decom.ufop.br/fabricio/download/ceas10.pdf

__Notes for Transformation:__
* Store the count of hashtags as well as the hashtag texts concatenated by ","
* Store the count of media URLs. Discard the URLs to photos and videos. Too many of these objects could indicate spam though.

### Object - Places

* For this project, Places can be ignored.
* The only reason to consider would be for visualization purposes.
* Places are named locations with geo coordinates
* This is nested within the Tweets Object
* List of fields: attributes (hash of key-value pairs of arbitrary strings with some conventions like street_address, locality, region, postal_code etc), bounding_box (coordinates of the box that encloses the region), country, country_code, full_name (name of the place - human readable), place_type (eg: city), url (URL representing this location, provides additional meta data).

### Twitter API Response Error Codes

Example of an error message:
{"errors":[{"message":"Sorry, that page does not exist","code":34}]}

For more info: [Twitter API Response Error Codes]

[Twitter API Response Error Codes]: https://dev.twitter.com/overview/api/response-codes


