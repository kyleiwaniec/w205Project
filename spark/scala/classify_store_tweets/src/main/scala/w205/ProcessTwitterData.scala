package w205

//Spark Related Imports


import java.util.Properties

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.spark.sql.{DataFrame, SQLContext}
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


object ClassifyStoreTweetsUrls extends Serializable {

    def start(ssc: StreamingContext) = {
        ssc.start()
        println("We just started the Spark StreamingContext and we are now downloading Twitter tweets as of: "
            + new java.util.Date())
    }

    def stop() = {
        StreamingContext.getActive.map { ssc =>
            ssc.stop(stopSparkContext=false)
            println("We just stopped the StreamingContext, as of: " + new java.util.Date())
        }
    }

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


        /****************************************************************************
         * Start streaming. Get twitter data and process as JSON.
         **************************************************************************/

        val tweetStreamAsRDD = TwitterUtils.createStream(ssc, Some(new OAuthAuthorization(cb.build())))
            .map(gson.toJson(_))

        /****************************************************************************
         * Keep the classification model loaded & ready.
         **************************************************************************/
        val model = LogisticRegressionModel.load(sc, "/user/spark/honeypot/lr_sgd")
        println ("Loaded Logistic Regression Model.....")

        /****************************************************************************
         * As the tweets stream in, classify as spam or ham
         * Store the data in postgres & URLs in HDFS
         * Case Class defines the schema of the tweet dataframe for storing
         * Case Class defines the schema of the tweet features for classification
         **************************************************************************/
        case class TweetFeatures (
            numFollowers: Int, numFollowing: Int,
            numTweets: Long, screenNameLength: Int,
            profileDescLength: Int, numWords: Int
        )
        case class Tweets (
             USER_ID: String, TWEET_ID: String,
             TWEET: String, CREATED_TS: String,
             USER_CREATED_TS: String,
             TWEET_CREATED_TS: String,
             SCREEN_NAME: String, NAME: String,
             NUM_FOLLOWING: Int, NUM_FOLLOWERS: Int,
             NUM_TWEETS: Long, RETWEET_COUNT: Int,
             NUM_URLS: Int, NUM_HASHTAGS: Int,
             IS_POLLUTER: Double
        )
        /*******************************************************************************
          * Load the JDBC Data Frame for Postgres.
          * We can get the known spam users from here.         *
          *******************************************************************************/
        //TODO: We should still append the information, but there is not need to classify again.
        val jdbcUrl = "jdbc:postgresql://localhost:5432/twitter"
        val connProps = new Properties()
        connProps.setProperty("user", "postgres")
        val tableName = "classified_tweets_simple"
        /*val twittersDF = sqlContext.read.format("jdbc").options(
            Map("url" -> jdbcUrl, "dbtable" -> tableName)
        ).load()
        println (" Twitters DF loaded from Postgres: " + twittersDF.count())*/


        tweetStreamAsRDD.foreachRDD((rdd, time) => {
            if (rdd.toLocalIterator.nonEmpty) {

                val sqlContext = new SQLContext(sc)
                import sqlContext.implicits._

                val tweetsRDD = rdd.repartition(partitionsEachInterval)
                //Will this work since the data is already mapped to json?
                val tweetsDF = sqlContext.read.json(tweetsRDD)
                tweetsDF.registerTempTable("tweets")
                tweetsDF.show()

                //Trying using Spark-SQL:
                val tweetData = sqlContext.sql("select user.followersCount, user.friendsCount, user.statusesCount, " +
                    "length(user.screenName), length(user.description), size(split(text, ' ')) as numWords, " +
                    "id as tweet_id from tweets")
                //TODO: Try case class for schema construction
                //Extract features from the tweetData, we need Vectors here:
                val tweetsToClassify = tweetData.map(row => Vectors.dense(row.getLong(0).toDouble,
                    row.getLong(1).toDouble, row.getLong(2).toDouble, row.getInt(3).toDouble,
                    row.getInt(4).toDouble, row.getInt(5).toDouble))
                //Use the model to classify the tweets
                val predictedLabels = tweetsToClassify.map { features => (model.predict(features)) }
                //zip rdd and make df
                val tRDD = predictedLabels.zip(tweetData.rdd)
                val tDF = tRDD.map(r => ( r._1, r._2.getLong(6))).toDF().withColumnRenamed("_1", "IS_POLLUTER").withColumnRenamed("_2", "TWEET_ID")
                //if we come up to here, then we can store to Postgres
                tDF.write.jdbc(jdbcUrl, tableName, connProps)

            }
        })


        this.start(ssc)
        ssc.awaitTermination()

    }


}
