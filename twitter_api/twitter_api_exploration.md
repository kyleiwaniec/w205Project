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

This is an unique identifier associated with each data point. The main objects all have id and id_str.

### The Main Objects

1) Tweets   
2) Users   
3) Entities & Entities in Objects   
4) Places   

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

### Object - Users

* Anyone or anything that can tweet, follow and be followed; can be mentioned, looked-up and have a home timeline
* New fields could be added and/or ordering changed
* Whether a field is part of the data depends on the context
* Null = Empty = Missing field for practical purposes (also called Perspecivals)
 
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

### Object - Places

* For this project, Places can be ignored.
* The only reason to consider would be for visualization purposes.
* Places are named locations with geo coordinates
* This is nested within the Tweets Object
* List of fields: attributes (hash of key-value pairs of arbitrary strings with some conventions like street_address, locality, region, postal_code etc), bounding_box (coordinates of the box that encloses the region), country, country_code, full_name (name of the place - human readable), place_type (eg: city), url (URL representing this location, provides additional meta data).

### Twitter StreamAPI Object-Schema Diagram   
Zero or more --> Null, Empty or Not Present (Perspectival).   
* A Tweet has one user (of type User).
* A Tweet has (one each of) entities and extended_entities (of type Entities).
* A Tweet has zero or more retweeted_status(of type Tweet).
* An Entity has one or more Array of Objects.
* The entitites object has one of each: media[], hashtags[], user_mentions[], symbols[] and urls[].
* The extended_entities has one of media[].

![](https://github.com/kyleiwaniec/w205Project/blob/sharmila_dev/twitter_api/Tweet_Object_Diagram.png)

__Tweet - List of Fields to Retain__

|Data|Data Type|Description|Access Path|
|----|---------|-----------|-----------|
|created_at|String|UTC time when the tweet was created|created_at|
|favorite_count|Int|How many twitter users liked this tweet|favorite_count|
|scopes|Object|Key-Value pairs - who should the tweet be delivered to (Promoted content)|scopes.followers|
|retweet_count|Int|Number of times this tweet has been retweeted|retweet_count|
|retweeted_status|Tweet|The presence of this attribute indicates that the content is a retweet|<Tweet Object>|
|text|String|Actual content of the tweet|text|
|withheld_in_countries|Array of String|Country codes where acct is withheld; XX-> Withheld in all countries; XY->Withheld due to DMCA|withheld_in_countries|
|withheld_scope|String|Is the user or the tweet being withheld|withheld_scope|
|user|User|The user who posted this tweet.||See section Object - Users|Useful features listed in later section.|
|entities|Entities|Entities which have been parsed out of the url or description fields defined by the user.||See section Object - Entities|Useful features listed in later section.|

[Valid Chars]: https://github.com/twitter/twitter-text/blob/master/rb/lib/twitter-text/regex.rb

__User - List of Fields to Retain__

|Data|Data Type|Description|Access Path|
|----|---------|-----------|-----------|
|created_at|String|UTC datetime of User Account Creation|user.created_at|
|description|String|User's description of their account|user.description|
|favourites_count|Int|# of tweets favorited by this account in all time|user.favourites_count|
|followers_count|Int|The number of followers the acct currently has|user.followers_count|
|friends_count|Int|The number of users this acct is currently following|user.friends_count|
|listed_count|Int|The number of public lists this user is a member of|user.listed_count|
|name|String|Name chosen by the user to associate with the acct|user.name|
|statuses_count|Int|The number of tweets (incl retweets) issued by the user|user.statuses_count|
|url|String|URL associated with the profile of the user|user.url|
|verified|Boolean|Verified brand or key individual or company or group ([What is a verified account?])|user.verified|
|withheld_in_countries|String|Country codes where acct is withheld|user.withheld_in_countries|
|withheld_scope|String|Is the user or the tweet being withheld|user.withheld_scope|

[What is a verified account?]: https://support.twitter.com/articles/119135

__Entities - List of Fields to Retain__

|Data|Data Type|Description|Access Path|Reason|
|----|---------|-----------|------|-----------|------|
|hashtags|Array of Object|Hashtags that have been parsed out of tweet content|entities.media[i]|Number of hashtags per tweet is an indicator of spam [[1]]|
|user_mentions|Array of Object|User mentions that have been parsed out of tweet content|entities.user_mentions[i]|Number of user mentions per tweet is an indicator of spam ([[2]])|
|urls|Array of Object|Contains URLs from the tweet content or user profile url or description|entities.urls[i]|URLs in tweet content as well user profile is valuable for classification|

[1]: http://www.decom.ufop.br/fabricio/download/ceas10.pdf
[2]: http://download.springer.com/static/pdf/677/chp%253A10.1007%252F978-3-642-13739-6_25.pdf?originUrl=http%3A%2F%2Flink.springer.com%2Fchapter%2F10.1007%2F978-3-642-13739-6_25&token2=exp=1447051146~acl=%2Fstatic%2Fpdf%2F677%2Fchp%25253A10.1007%25252F978-3-642-13739-6_25.pdf%3ForiginUrl%3Dhttp%253A%252F%252Flink.springer.com%252Fchapter%252F10.1007%252F978-3-642-13739-6_25*~hmac=16519c3db14cc4a6722de4ba09fd330e51f0395d832504cbed7ac6d16c4587dc

__Notes for Transformation:__
* Counts are more appropriate in some cases. For example, the number of hastags and the number of user_mentions are more useful in spam classification than the actual texts associatedw with the entities.
* Ints, Booleans usually do not call for transformations.
* Strings may involve some transformations. For example, the description of the user profile may throw some light on whether the user account is spam or not. For that reason, one may have to parse the description string to extract keywords.

### Twitter API Response Error Codes

Example of an error message:
{"errors":[{"message":"Sorry, that page does not exist","code":34}]}

For more info: [Twitter API Response Error Codes]

[Twitter API Response Error Codes]: https://dev.twitter.com/overview/api/response-codes

