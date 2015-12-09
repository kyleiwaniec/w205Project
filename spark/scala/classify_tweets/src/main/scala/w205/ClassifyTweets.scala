package w205

import org.apache.spark.mllib.clustering.KMeansModel
import org.apache.spark.mllib.linalg.Vector
import org.apache.spark.streaming.twitter._
import org.apache.spark.streaming.{Seconds, StreamingContext}
import com.google.gson.Gson
import twitter4j.auth.OAuthAuthorization
import twitter4j.conf.ConfigurationBuilder
import org.apache.spark.streaming.twitter.TwitterUtils
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.sql.SQLContext
import org.apache.spark.mllib.linalg.Vector
import org.apache.spark.mllib.feature.HashingTF


object ClassifyTweets  {

    private var gson = new Gson()
    val CONSUMER_KEY = "j9X0NPb6xfqe4QBJ3Q6nUhTkI"
    val CONSUMER_SECRET = "JscwpITQVRRzJQrcbZ3zOxjLLlzrfolIt3qPi1uPKOqolCUhYL"
    val ACCESS_TOKEN = "4027615449-qDOnhw3kS8xedmoKIyxfqXcYIAQ0gO8JHFjNXfL"
    val ACCESS_TOKEN_SECRET = "g1ipl9amLVL3hUP6cYgHd3l1fpG0sLDErGNXm7YCHLl3v"
    val tf = new HashingTF(10000)

    def featurize(s: String): Vector = {
    	tf.transform(s.sliding(2).toSeq)
    }
    def main(args: Array[String]) {

        val conf = new SparkConf().setAppName("Twitter Data Processing for Spam Detection")
        val sc = new SparkContext(conf)
        val sqlContext = new SQLContext(sc)
	val partitionsEachInterval = 5		

	val cb = new ConfigurationBuilder()
        cb.setDebugEnabled(true)
            .setOAuthConsumerKey(ClassifyTweets. CONSUMER_KEY)
            .setOAuthConsumerSecret(ClassifyTweets.CONSUMER_SECRET)
            .setOAuthAccessToken(ClassifyTweets.ACCESS_TOKEN)
            .setOAuthAccessTokenSecret(ClassifyTweets.ACCESS_TOKEN_SECRET)

        val modelFile = "/user/flume/tweets/training/km_model"
        val hdfsPath = "/user/flume/tweets/training"
	val clusterNumber = 1
	val ssc = new StreamingContext(sc, Seconds(5))
	val tweetsStream = TwitterUtils.createStream(ssc, Some(new OAuthAuthorization(cb.build())))
            .map(gson.toJson(_))
			
	println("Initalizaing the the KMeans model...")
	val model = new KMeansModel(ssc.sparkContext.objectFile[Vector](modelFile.toString).collect())
		
	tweetsStream.foreachRDD((rdd, time) => {
	    val sqlContext = new SQLContext(sc) 
	    import sqlContext.implicits._
	    val tweets = rdd.toDF()
            val filteredTweets = tweets.select("text").map(t => model.predict(featurize(t.getString(0))) == clusterNumber)
            if (filteredTweets.toLocalIterator.nonEmpty) {
                val outputRDD = rdd.repartition(partitionsEachInterval)
                outputRDD.saveAsTextFile(hdfsPath  + "/spam_tweets_" + time.milliseconds.toString)  
		val opDf = outputRDD.toDF()
//		opDf.select("urlEntities.expandedURL").saveAsTextFile(hdfsPath  + "/spam_tweet_urls_" + time.milliseconds.toString)  
            }
        })		
		
	// Start the streaming computation
	println("Initialization complete.")
	ssc.start()
	ssc.awaitTermination()
    }
}
