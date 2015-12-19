package w205

import java.sql.{Date, Timestamp}
import java.util.Calendar
import org.apache.spark.sql._
import org.apache.spark.sql.types._
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.sql.SQLContext;
import org.apache.spark.sql.hive.HiveContext;
import org.apache.spark.sql.DataFrame;
import org.apache.spark.sql.Row;


/**
 * Created by SharmilaVelamur on 11/22/2015.
 * This implementation simply reads collected tweets into a dataframe
 * Applies the logistic regression prediction model on each of the tweet
 * Tweets classified as spam are stored in a parquet file
 * The processed tweets are stored in the postgres twitter database (twitters table)
 * This scala app must be invoked using a scheduler such as cron
 */


object ClassifyStoreTweetsUrls  {

    def main(args: Array[String]) {

        val conf = new SparkConf().setAppName("Classify_Store_Tweets_URLs")
        val sc = new SparkContext(conf)
        val sqlContext = new HiveContext(sc)

        //Generate the load path based on Year/Month/Date folder structure in HDFS
        val todaysPath = new StringBuilder(Calendar.getInstance().get(Calendar.YEAR).toString())
           todaysPath.append( "/" )
           todaysPath.append((Calendar.getInstance().get(Calendar.MONTH) + 1).toString())
           todaysPath.append( "/" )
           todaysPath.append((Calendar.getInstance().get(Calendar.DATE)).toString())

        val hdfsPath = new StringBuilder("/user/spark/tweets/").append(todaysPath)
        //The last part of the path is what CollectTweets app generates
        hdfsPath.append("/tweetstream_*/part*")

        // read JSON dataset actually loads the data into a Data Frame
        val tweetsToday = sqlContext.read.format("json").load(hdfsPath.toString())
        //register this Data Frame as a temp table to use SQL
        tweetsToday.registerTempTable("TWEETS_TODAY")

        /*
         * Twitter public stream data is the tweet object in which the user info is embedded
         * We need to transform this so that the main object is the user and
         * tweets are meaningful in the context of this user.
         *
         * uUe SQL on the tweets today temp table to retrieve all users
         */

        val sqlTwitterUser: StringBuilder =  new StringBuilder("SELECT ")
            sqlTwitterUser.append("user.Id AS USER_ID, ")
            sqlTwitterUser.append("id AS TWEET_ID, ")
            sqlTwitterUser.append("text AS TWEET, ")
            sqlTwitterUser.append("SIZE(SPLIT(text,' ')) AS NUM_WORDS, ")
            sqlTwitterUser.append("CURRENT_TIMESTAMP as CREATED_TS, ")
            sqlTwitterUser.append("user.createdAt AS USER_CREATED_TS, ")
            sqlTwitterUser.append("createdAt AS TWEET_CREATED_TS, ")
            sqlTwitterUser.append("user.screenName AS SCREEN_NAME, ")
            sqlTwitterUser.append("user.name AS NAME, " )
            sqlTwitterUser.append("user.followersCount AS NUM_FOLLOWING, " )
            sqlTwitterUser.append("user.friendsCount AS NUM_FOLLOWERS, " )
            sqlTwitterUser.append("user.statusesCount AS NUM_TWEETS,  ")
            sqlTwitterUser.append("retweetedStatus is not null AS RETWEETED_STATUS, ")
            sqlTwitterUser.append("retweetCount AS RETWEET_COUNT, ")
            sqlTwitterUser.append("COUNT(urlEntities) AS NUM_URLS, ")
            sqlTwitterUser.append("COUNT(userMentionEntities) AS NUM_MENTIONS, ")
            sqlTwitterUser.append("COUNT(hashtagEntities) AS NUM_HASHTAGS, ")
            sqlTwitterUser.append("user.url AS USER_PROFILE_URL, ")
            sqlTwitterUser.append("urlEntities AS TWEETED_URLS ")
            sqlTwitterUser.append("FROM TWEETS_TODAY  T ")
            sqlTwitterUser.append("GROUP BY user, id, text, createdAt, retweetedStatus, retweetCount, ")
            sqlTwitterUser.append("urlEntities, userMentionEntities, hashtagEntities")

        //Create the twitterUser data frame
        val allUsersToday = sqlContext.sql(sqlTwitterUser.toString())

        /*
         * Load the JDBC Data Frame for Postgres.
         * We can get the known spam users from here.
         * We should still append the information, but there is not need to classify again.
         */
        val twittersDF = sqlContext.read.format("jdbc").options(
           Map("url" -> "jdbc:postgresql://localhost:5432/twitter?user=postgres",
               "dbtable" -> "twitters")
        ).load()
        println (" Twitters DF loaded from Postgres: " + twittersDF.count())
        /*
         * Classify users based on tweet texts and other user attributes.
         * We already built this model using the learn_spam app.
         * First this method is registered as UDF so that we can access it from SQL.
         */
        sqlContext.udf.register("classify", (r:Row) => classify(r))

        //For JDBC testing, we simply take a 1000 records and call a dummy classify
        allUsersToday.take(1000).map(classify(_))
        val resultsDF = sqlContext.sql("update tweets_today set is_polluter = classify limit 100")

    }

    def classify(r: Row): Double = {
        //get the model and predict whether the current user is spam

        (0.80D)
    }
}
