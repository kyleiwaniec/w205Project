package mids.w205.spark

/**
 * Adapted from databricks streaming data examples & cloudera's flume source
 * Created by Owner on 11/29/2015.
 */

import org.apache.spark.streaming.twitter.TwitterUtils
import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.spark.{SparkConf, SparkContext}
import twitter4j.json.DataObjectFactory
import com.google.gson.Gson
import twitter4j.auth.OAuthAuthorization
import twitter4j.conf.ConfigurationBuilder

/**
 * Collect at least the specified number of tweets into json text files.
 */
object CollectTweets {
	private var numTweetsCollected = 0L
	private var partNum = 0
	private var gson = new Gson()

	val CONSUMER_KEY = "j9X0NPb6xfqe4QBJ3Q6nUhTkI"
	val CONSUMER_SECRET = "JscwpITQVRRzJQrcbZ3zOxjLLlzrfolIt3qPi1uPKOqolCUhYL"
	val ACCESS_TOKEN = "4027615449-qDOnhw3kS8xedmoKIyxfqXcYIAQ0gO8JHFjNXfL"
	val ACCESS_TOKEN_SECRET = "g1ipl9amLVL3hUP6cYgHd3l1fpG0sLDErGNXm7YCHLl3v"

	def main(args: Array[String]) {

		val hdfsPath = "hdfs://localhost:8020/user/flume/tweets/training"
		val numTweetsToCollect = 500000
		val intervalSecs = 60
		val partitionsEachInterval = 1

		val cb = new ConfigurationBuilder()
		cb.setDebugEnabled(true)
			.setOAuthConsumerKey(CollectTweets. CONSUMER_KEY)
			.setOAuthConsumerSecret(CollectTweets.CONSUMER_SECRET)
			.setOAuthAccessToken(CollectTweets.ACCESS_TOKEN)
			.setOAuthAccessTokenSecret(CollectTweets.ACCESS_TOKEN_SECRET)

		println("Initializing Streaming Spark Context...")
		val conf = new SparkConf().setAppName(this.getClass.getSimpleName)
		val sc = new SparkContext(conf)
		val ssc = new StreamingContext(sc, Seconds(intervalSecs))

		val tweetStream = TwitterUtils.createStream(ssc, Some(new OAuthAuthorization(cb.build())))
