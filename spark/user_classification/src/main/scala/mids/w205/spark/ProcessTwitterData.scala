package mids.w205.spark

import java.sql.{Date, Timestamp}
import java.util.Calendar
import org.apache.spark.sql._
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.sql.SQLContext
import org.apache.spark.sql.hive.HiveContext
import org.apache.spark.sql.DataFrame
import org.apache.spark.sql.Row

/**
 * Created by SharmilaVelamur on 11/22/2015.
 * This implementation reads the tweets stored in HDFS by Flume for a day
 * Then it creates two DFs to store the TwitterUser and Tweet information
 * The twitter users known to be spammers are stored everyday  to TwitterUserSpammers table
 * First we read the distinct users from there and remove them from TwitterUsers DF
 * Then we invoke the algorithm to first determine whether a user has a high likelihood of being a spammer
 * If the algorithm marks a user as spammer, then a record for this user,
 * including all past details are stored in TwitterUserSpammers
 * Then the URLs from the tweet entities object are stored in UrlsToScrape table
 * if they are already not stored
 *
 */


object TransformTweetsData  {

    def main(args: Array[String]) {
        case class TwitterUserSummary(
             user_id: String,
             existedForDays: Int,
             avgTweets: Float,
             avgWordsPerTweet: Float,
             avgUrlsPerTweet: Float,
             avgUserMentionsPerTweet: Float,
             avgNumOfHashTagsPerTweet: Float,
             reputationScore: Float,
             avgTimeBetweenTweets: Float,
             avgRetweets: Float,
             isSpamAccount: Boolean
             )

        val conf = new SparkConf().setAppName("Twitter Data Processing for Spam Detection")
        val sc = new SparkContext(conf)
        val sqlContext = new HiveContext(sc)

        //Prep: Load known spammers (user_ids) and URLs
        //We can use this list to not process users known to be spammers
        //Also, we will not reprocess URLs already marked as spam
        //val knownSpamUsers = sqlContext.read.format("")


        //Now we are ready to load tweets from today

        //Generate the load path based on Year/Month/Date folder structure in HDFS
        //This may need to be revisited based on scheduling

       /* val todaysPath = new StringBuilder(Calendar.getInstance().get(Calendar.YEAR).toString())
           todaysPath.append( "/" )
           todaysPath.append((Calendar.getInstance().get(Calendar.MONTH) + 1).toString())
           todaysPath.append( "/" )
           todaysPath.append((Calendar.getInstance().get(Calendar.DATE)).toString())*/

        val todaysPath = "2015/11/16"
        val fileName = new StringBuilder("/user/flume/tweets/").append(todaysPath)

        // read JSON dataset actually loads the data into a Data Frame
        val tweetsToday = sqlContext.read.format("json").load(fileName.toString())
        //cache this Data Frame for performance
        tweetsToday.cache()
        //materialize the Data Frame to load it in cache
        tweetsToday.count()

        //register this Data Frame as a temp table to use SQL
        tweetsToday.registerTempTable("TWEETS_TODAY")
        sqlContext.cacheTable("TWEETS_TODAY")

        //Twitter public stream data is the tweet object in which the user info is embedded
        //We need to transform this so that the main object is the user and
        //tweets are meaningful in the context of this user

        //use SQL on the tweets today temp table to retrieve all users
        val sqlTwitterUser: StringBuilder =  new StringBuilder("SELECT USER.ID_STR AS USER_ID, ")
            sqlTwitterUser.append("ID_STR AS TWEET_ID, CREATED_AT AS TWEET_CREATED_TS, ")
            sqlTwitterUser.append("USER.CREATED_AT AS USER_CREATED_TS, ")
            sqlTwitterUser.append("USER.SCREEN_NAME, USER.NAME, " )
            sqlTwitterUser.append("USER.FOLLOWERS_COUNT AS NUMBER_OF_FOLLOWING, " )
            sqlTwitterUser.append("USER.FRIENDS_COUNT AS NUMBER_OF_FOLLOWERS, " )
            sqlTwitterUser.append("USER.STATUSES_COUNT AS NUMBER_OF_TWEETS,  ")
            sqlTwitterUser.append("TEXT AS TWEET_TEXT, ")
            sqlTwitterUser.append("RETWEETED, RETWEET_COUNT, ")
            sqlTwitterUser.append("ENTITIES.URLS AS TWEETED_URLS, ")
            sqlTwitterUser.append("ENTITIES.HASHTAGS AS TWEETED_HASHTAGS, ")
            sqlTwitterUser.append("ENTITIES.USER_MENTIONS AS USERMENTIONS ")
            sqlTwitterUser.append("FROM TWEETS_TODAY  ")
            sqlTwitterUser.append("WHERE USER.VERIFIED <> TRUE ")
        //Create the twitterUser data frame
        val twitterUsers = sqlContext.sql(sqlTwitterUser.toString())
        twitterUsers.cache()
        twitterUsers.registerTempTable("TWITTER_USERS_RAW_FLAT")

        //calculate summary of various scores for each user
        //this data frame will be used to:
        //1. classify users as spam or ham
        //2. update spam user and url list for further processing

        //create a formatter to parse date for calculations
        val format = new java.text.SimpleDateFormat("E MMM dd HH mm ss Z yyyy")
        //twitterUsers.select()

    }

    /*def calculateStats(user: DataFrame) = {
        val numOfTweetsuser.
    }*/


}
