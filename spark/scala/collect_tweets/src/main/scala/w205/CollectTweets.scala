package w205

/**************************************************************************
 * Adapted from databricks streaming data examples & cloudera's flume source
 * Created by svelamur on 11/29/2015.
 ************************************************************************/

//Spark related imports
import org.apache.spark.streaming.twitter.TwitterUtils
import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.spark.{SparkConf, SparkContext}

//Twitter4j utils, JSON Utils
import twitter4j.auth.OAuthAuthorization
import twitter4j.conf.ConfigurationBuilder
import com.google.gson.Gson
import java.util.Calendar

/**************************************************************************
 * Collect at least the specified number of tweets into json text files.
 *************************************************************************/

object CollectTweets {

    private var numTweetsCollected = 0L
    private var partNum = 0
    private var gson = new Gson()

    /****************************************************************************
      * Need to pick up these keys from CLI or by configuring Twitter4j Properties
      **************************************************************************/
    val CONSUMER_KEY = "xxx"
    val CONSUMER_SECRET = "xxx"
    val ACCESS_TOKEN = "xxx-xxx"
    val ACCESS_TOKEN_SECRET = "xxx"

    def main(args: Array[String]) {

        /****************************************************************************
         * Set-up for tweet collection
         * ***********************************************************************/

        //Generate the load path based on Year/Month/Date folder structure in HDFS
        //This may need to be revisited based on scheduling
        val todaysPath = new StringBuilder(Calendar.getInstance().get(Calendar.YEAR).toString())
        todaysPath.append( "/" )
        todaysPath.append((Calendar.getInstance().get(Calendar.MONTH) + 1).toString())
        todaysPath.append( "/" )
        todaysPath.append((Calendar.getInstance().get(Calendar.DATE)).toString())

        // Example: todaysPath = "2015/11/16"
        val hdfsPath = new StringBuilder("/user/spark/tweets/").append(todaysPath)

        val numTweetsToCollect = 100000
        val intervalSecs = 300
        val partitionsEachInterval = 1

        val cb = new ConfigurationBuilder()
        cb.setDebugEnabled(true)
            .setOAuthConsumerKey(CollectTweets. CONSUMER_KEY)
            .setOAuthConsumerSecret(CollectTweets.CONSUMER_SECRET)
            .setOAuthAccessToken(CollectTweets.ACCESS_TOKEN)
            .setOAuthAccessTokenSecret(CollectTweets.ACCESS_TOKEN_SECRET)

        /****************************************************************************
         * Initialize Spark Context incl. Streaming
         **************************************************************************/
        //TODO: Best practices - what configuration goes here?

        println("Initializing Streaming Spark Context...")
        val conf = new SparkConf().setAppName(this.getClass.getSimpleName)
        val sc = new SparkContext(conf)
        val ssc = new StreamingContext(sc, Seconds(intervalSecs))

        /****************************************************************************
         * Start streaming. Get twitter data and process as JSON.
         **************************************************************************/

        val tweetStream = TwitterUtils.createStream(ssc, Some(new OAuthAuthorization(cb.build())))
            .map(gson.toJson(_))

        /****************************************************************************
         * Every 5 minutes, create a partition & store tweets.
         * Stop when the num tweets desired are (at least) reached.
         **************************************************************************/

        tweetStream.foreachRDD((rdd, time) => {
            val count = rdd.count()
            if (count > 0) {
                val outputRDD = rdd.repartition(partitionsEachInterval)
                outputRDD.saveAsTextFile(hdfsPath  + "/tweets_" + time.milliseconds.toString)
                numTweetsCollected += count
                if (numTweetsCollected > numTweetsToCollect) {
                    System.exit(0)
                }
            }
        })

        ssc.start()
        ssc.awaitTermination()
    }
}
