package w205

//Spark Related Imports

import org.apache.spark.sql._
import org.apache.spark.sql.types._
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.spark.sql.SQLContext;
import org.apache.spark.sql.DataFrame;
import org.apache.spark.sql.Row
import org.apache.spark.streaming.twitter.TwitterUtils
import org.apache.spark.streaming.{Seconds, StreamingContext}

/*****************************************************************************
	Spark Machine Learning Lib
*****************************************************************************/

import org.apache.spark.mllib.linalg._
import org.apache.spark.mllib.classification.{LogisticRegressionWithSGD, LogisticRegressionModel}

/*****************************************************************************
	Twitter4j utils, JSON Utils
*****************************************************************************/

import twitter4j.auth.OAuthAuthorization
import twitter4j.conf.ConfigurationBuilder
import com.google.gson.Gson


/**
 * Created by SharmilaVelamur on 11/22/2015.
 * Streaming tweets are to be classified based on the
 * logisitic regression model stored in learn_spam
 */


object ClassifyStoreTweetsUrls  {

    /****************************************************************************
      * Need to pick up these keys from CLI or by configuring Twitter4j Properties
      **************************************************************************/
    val CONSUMER_KEY = "j9X0NPb6xfqe4QBJ3Q6nUhTkI"
    val CONSUMER_SECRET = "JscwpITQVRRzJQrcbZ3zOxjLLlzrfolIt3qPi1uPKOqolCUhYL"
    val ACCESS_TOKEN = "4027615449-qDOnhw3kS8xedmoKIyxfqXcYIAQ0gO8JHFjNXfL"
    val ACCESS_TOKEN_SECRET = "g1ipl9amLVL3hUP6cYgHd3l1fpG0sLDErGNXm7YCHLl3v"

    def main(args: Array[String]) {
        /****************************************************************************
         * Setup Twitter Credentials to start streaming. Need to make this safer.
         **************************************************************************/
        val cb = new ConfigurationBuilder()
        cb.setDebugEnabled(true)
            .setOAuthConsumerKey(ClassifyStoreTweetsUrls. CONSUMER_KEY)
            .setOAuthConsumerSecret(ClassifyStoreTweetsUrls.CONSUMER_SECRET)
            .setOAuthAccessToken(ClassifyStoreTweetsUrls.ACCESS_TOKEN)
            .setOAuthAccessTokenSecret(ClassifyStoreTweetsUrls.ACCESS_TOKEN_SECRET)

        /****************************************************************************
         * Initialize Spark Context incl. Streaming
         **************************************************************************/
        //TODO: Best practices - what configuration goes here?

        val gson = new Gson()
        val intervalSecs = 300
        val partitionsEachInterval = 1

        println("Initializing Streaming Spark Context...")
        val conf = new SparkConf().setAppName(this.getClass.getSimpleName)
        val sc = new SparkContext(conf)
        val ssc = new StreamingContext(sc, Seconds(intervalSecs))
        val sqlContext = new SQLContext(sc)

        import sqlContext.implicits._


        /****************************************************************************
         * Start streaming. Get twitter data and process as JSON.
         **************************************************************************/

        val tweetStream = TwitterUtils.createStream(ssc, Some(new OAuthAuthorization(cb.build())))
            .map(gson.toJson(_))

        /****************************************************************************
         * Keep the classification model loaded & ready.
         **************************************************************************/
        val model = LogisticRegressionModel.load(sc, "/user/spark/honeypot/lr_sgd")
        println ("Loaded Logistic Regression Model.....")

        /*******************************************************************************
         * Load the JDBC Data Frame for Postgres.
         * We can get the known spam users from here.
         * We should still append the information, but there is not need to classify again.
         *******************************************************************************/
        val jdbcUrl = "jdbc:postgresql://localhost:5432/twitter?user=postgres"
        val tableName = "twitters"
        val twittersDF = sqlContext.read.format("jdbc").options(
            Map("url" -> jdbcUrl, "dbtable" -> tableName)
        ).load()
        println (" Twitters DF loaded from Postgres: " + twittersDF.count())

        /*******************************************************************************
         * Twitter public stream data is the tweet object in which the user info is embedded
         * We need to transform this so that the main object is the user and
         * tweets are meaningful in the context of this user.
         * The temp table registered should be named TWEETS
         ********************************************************************************/

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
            sqlTwitterUser.append("FROM TWEETS  ")
            sqlTwitterUser.append("GROUP BY user, id, text, createdAt, retweetedStatus, retweetCount, ")
            sqlTwitterUser.append("urlEntities, userMentionEntities, hashtagEntities")

        //Schema for the DataFrame
        println("SQL to generate dataframe for Twitters in Postgres: " + sqlTwitterUser.toString())

        /****************************************************************************
         * As the tweets stream in, classify as spam or ham
         * Store the data in postgres
         **************************************************************************/

        tweetStream.foreachRDD((rdd, time) => {

            val sqlContext = new SQLContext(sc)
            import sqlContext.implicits._

            if (rdd.toLocalIterator.nonEmpty) {
                val outputRDD = rdd.repartition(partitionsEachInterval)
                outputRDD.map(r => println(r))
                // Now extract features from this RDD including tweet id

                // Classify the tweets as spam or ham
                // Extract twitter postgres schema for each tweet
                // Combine the classification with all the other columns

                // Write to postgres
                /* classifiedTweetsDF.write.jdbc(jdbcUrl, tableName)*/

                // Whew done!

            }
        })

        ssc.start()
        ssc.awaitTermination()

    }


}
