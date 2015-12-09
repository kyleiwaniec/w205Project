package w205

import org.apache.spark.mllib.clustering.KMeansModel
import org.apache.spark.mllib.linalg.Vector
import org.apache.spark.streaming.twitter._
import org.apache.spark.streaming.{Seconds, StreamingContext}
import com.google.gson.Gson
import twitter4j.auth.OAuthAuthorization
import twitter4j.conf.ConfigurationBuilder
import org.apache.spark.streaming.twitter.TwitterUtils


object ClassifyTweets  {

	private var gson = new Gson()
    val CONSUMER_KEY = "j9X0NPb6xfqe4QBJ3Q6nUhTkI"
    val CONSUMER_SECRET = "JscwpITQVRRzJQrcbZ3zOxjLLlzrfolIt3qPi1uPKOqolCUhYL"
    val ACCESS_TOKEN = "4027615449-qDOnhw3kS8xedmoKIyxfqXcYIAQ0gO8JHFjNXfL"
    val ACCESS_TOKEN_SECRET = "g1ipl9amLVL3hUP6cYgHd3l1fpG0sLDErGNXm7YCHLl3v"

    def main(args: Array[String]) {

        val conf = new SparkConf().setAppName("Twitter Data Processing for Spam Detection")
        val sc = new SparkContext(conf)
        val sqlContext = new HiveContext(sc)
		
		val cb = new ConfigurationBuilder()
        cb.setDebugEnabled(true)
            .setOAuthConsumerKey(CollectTweets. CONSUMER_KEY)
            .setOAuthConsumerSecret(CollectTweets.CONSUMER_SECRET)
            .setOAuthAccessToken(CollectTweets.ACCESS_TOKEN)
            .setOAuthAccessTokenSecret(CollectTweets.ACCESS_TOKEN_SECRET)

        val modelFile = "/user/flume/tweets/training/km_model"
		val clusterNumber = 1
		val ssc = new StreamingContext(sc, Seconds(5))
		val tweets = TwitterUtils.createStream(ssc, Some(new OAuthAuthorization(cb.build())))
            .map(gson.toJson(_))
			
		println("Initalizaing the the KMeans model...")
		val model = new KMeansModel(ssc.sparkContext.objectFile[Vector](modelFile.toString).collect())
		
		tweetStream.foreachRDD((rdd, time) => {
            val filteredTweets = rdd.filter(t => model.predict(featurize(t.getString(17))) == clusterNumber)
            if (filteredTweets.toLocalIterator.nonEmpty) {
                val outputRDD = rdd.repartition(partitionsEachInterval)
                outputRDD.saveAsTextFile(hdfsPath  + "/spam_tweets_" + time.milliseconds.toString)  
				val opDf = outputRDD.toDF()
				opDf.select("urlEntities.expandedURL").saveAsTextFile(hdfsPath  + "/spam_tweet_urls_" + time.milliseconds.toString)  
            }
        })		
		
		// Start the streaming computation
		println("Initialization complete.")
		ssc.start()
		ssc.awaitTermination()
    }
}
