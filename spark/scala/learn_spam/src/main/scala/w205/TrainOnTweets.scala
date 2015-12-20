package w205

import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.clustering.KMeans
import org.apache.spark.sql.SQLContext
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.mllib.linalg.Vector
import org.apache.spark.mllib.feature.HashingTF
/**
 * Created by Owner on 11/29/2015.
 */
object  TrainOnTweets {

    val numFeatures = 10000
    val tf = new HashingTF(numFeatures)

    /**
     * Create feature vectors by turning each tweet into bigrams of characters (an n-gram model)
     * and then hashing those to a length-1000 feature vector that we can pass to MLlib.
     * This is a common way to decrease the number of features in a model while still
     * getting excellent accuracy (otherwise every pair of Unicode characters would
     * potentially be a feature).
     */
    def featurize(s: String): Vector = {
        tf.transform(s.sliding(2).toSeq)
    }

    def kmeansMain(args: Array[String]) {
        val conf = new SparkConf().setAppName(this.getClass.getSimpleName)
        val sc = new SparkContext(conf)
        val sqlContext = new SQLContext(sc)

        /**
         * Read the stored collection of tweets into a data frame
         * Register as temp table so that can we can query the dataframe using simple SQL
         */
        val tweetTable = sqlContext.read.format("json").load("/user/flume/tweets/training/tweets*/part-*").cache()
        tweetTable.registerTempTable("tweetTable")

        /**
         * Let us try to cluster the tweets and see if there is any "spam" cluster that comes up
         */
        val numClusters: Int = 10
        val numIterations: Int = 20

        val texts = sqlContext.sql("SELECT text from tweetTable").map(_.toString)
        // Cache the vectors RDD since it will be used for all the KMeans iterations.
        val vectors = texts.map(featurize).cache()
        vectors.count()  // Calls an action on the RDD to populate the vectors cache.
        val model = KMeans.train(vectors, numClusters, numIterations)
        //persist the model
        sc.makeRDD(model.clusterCenters, numClusters).saveAsObjectFile("/user/flume/tweets/training/km_model")

        val some_tweets = tweetTable.take(1000)
        println("Example tweets from the clusters")
        //Interested in cluster 10 - this looks most promising in identifying spam
        val i = 9
        println(s"\nCLUSTER $i:")
        some_tweets.foreach { t =>
            if (model.predict(featurize(t.getString(17))) == i) {
                println(t)
            }
        }

    }
    
}
