package w205

/*****************************************************************************
	Spark Context & SQL Import
*****************************************************************************/

import org.apache.spark.sql.{DataFrame, SQLContext}
import org.apache.spark.sql.hive.HiveContext
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.sql.types.{StructType, StructField, StringType, IntegerType, LongType};

/*****************************************************************************
	Spark CSV Libraries Databricks
*****************************************************************************/

import com.databricks.spark.csv._
import com.databricks.spark.csv._
import com.databricks.spark.csv.CsvRelation._
import org.apache.commons.csv._

/*****************************************************************************
	Spark Machine Learning Lib
*****************************************************************************/

import org.apache.spark.mllib.linalg._
import org.apache.spark.mllib.classification.{LogisticRegressionWithSGD, LogisticRegressionModel}
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.evaluation.MulticlassMetrics

/**
 * This class learns spam and ham classification for tweets.
 * Using LogisticRegression.
 * Feature selection based on other ML papers.
 *
 * Created by svelamur on 12/14/2015.
 * Updated by svelamur on 12/20/2015.
 */
object LearnSpamModel {

	def main(args: Array[String]): Unit = {

		/*****************************************************************************
			Initialize Spark Context
		*****************************************************************************/

		//TODO: Best practices - what configuration goes here?

		val conf = new SparkConf().setAppName(this.getClass.getSimpleName)
		val sc = new SparkContext(conf)
		val hiveContext = new HiveContext(sc)
		val sqlContext = new SQLContext(sc)

		import sqlContext.implicits._

		/*****************************************************************************
		 *  First get training data from the social honeypot to generate the model
		 *  Put the social honeypot training data in HDFS
		 *  sudo -u hdfs hdfs dfs -mkdir /user/spark/honeypot/
		 *  sudo -u hdfs hdfs dfs -put  /data/project/w205Project/spark/scala/learn_spam/data/\* /user/spark/honeypot/
		 *  Read the CSV into a DataFrame using DataBricks libraries
		 *****************************************************************************/

		val customSchema:StructType = StructType(Array(
			StructField("userId", StringType, true),
			StructField("tweetId", StringType, true),
			StructField("tweet", StringType, true),
			StructField("tweetCreatedAt", StringType, true),
			StructField("userCreatedAt", StringType, true),
			StructField("collectedAt", StringType, true),
			StructField("numFollowing", IntegerType, true),
			StructField("numFollowers", IntegerType, true),
			StructField("numTweets", LongType, true),
			StructField("screenNameLength", IntegerType, true),
			StructField("profileDescLength", IntegerType)))

		/*****************************************************************************
		 * Using the custom schema, load the legit CSV into a dataframe
		*****************************************************************************/

		val legitDF = sqlContext.read.format("com.databricks.spark.csv")
			.option("header", "true")
			.schema(customSchema)
			.load("/user/spark/honeypot/sample_legit_data.csv")

		/*****************************************************************************
		 * Using the custom schema, load the polluter CSV into a dataframe
		*****************************************************************************/

		val spamDF = sqlContext.read.format("com.databricks.spark.csv")
			.option("header", "true")
			.schema(customSchema)
			.load("/user/spark/honeypot/sample_polluter_data.csv")

		/*****************************************************************************
		  * add label for training data
		  * Dataframe from legit data gets label    isPolluter: 0
		  * Dataframe from polluter data gets label isPolluter: 1
		*****************************************************************************/

		val lDF = legitDF.withColumn("isPolluter", org.apache.spark.sql.functions.lit(0))
		val sDF = spamDF.withColumn("isPolluter", org.apache.spark.sql.functions.lit(1))

		/*****************************************************************************
		  * combine labels 1.0 and 0.0
		  * we need to train the model for both spam & ham.
		******************************************************************************/

		val trainData = lDF.unionAll(sDF)

		/*****************************************************************************
		  * get the columns needed for training the Logistic Regression Model
		  * the feature selection was simply based on other ML papers.
		 *****************************************************************************/

		val parsedData = trainData.selectExpr("isPolluter", "numFollowing", "numFollowers",
			"numTweets", "screenNameLength", "profileDescLength", "size(split(tweet, ' ')) as numWords")

		/*****************************************************************************
		  * Prepare for creating LabeledPoints
		  * The linalg package is needed here to generate the data
		  * Labels -> Double
		  * Features -> Vectors
		 *****************************************************************************/
		//TODO: redundant operations are going on - an opportunity to optimize?

		val labels = parsedData.map(r => r.getInt(0).toDouble)
		val features = parsedData.map(row => Vectors.dense(row.getInt(1).toDouble,
			row.getInt(2).toDouble, row.getLong(3).toDouble, row.getInt(4).toDouble,
			row.getInt(5).toDouble, row.getInt(6).toDouble))
		val labeledParsedData = labels.zip(features).map(lf => LabeledPoint(lf._1, lf._2))

		/*****************************************************************************
		  * randomly split the training set in train and validation
		 *****************************************************************************/

		val splits = labeledParsedData.randomSplit(Array(0.7, 0.3))
		val train = splits(0)
		val test = splits(1)
		val numIterations = 10

		/*****************************************************************************
		  * train the model with training data
		  * Using the validation data generate tuples of predicted, actual labels
		*****************************************************************************/
		val model = LogisticRegressionWithSGD.train(train, numIterations)
		val predictionAndLabels = test.map { case LabeledPoint(label, features) =>
			val prediction = model.predict(features)
			(prediction, label)
		}

		/*****************************************************************************
		  * validate the model using the data set aside from training
		  * precision: Double = 0.7405923228914593
		  * Lots of room for improvement here
		  * Once DFs and RDDs are conquered, then we will move on to ML!
		 *****************************************************************************/

		val metrics = new MulticlassMetrics(predictionAndLabels)
		val precision = metrics.precision
		println("*******************MODEL: PRECISION************************")
		println("Precision = " + precision)
		println("***********************************************************")

		/*****************************************************************************
		 * Save this model for everyday classification.
		 *****************************************************************************/
		//TODO: Try StreamingLogisticRegressionWithSGD to analyze classification performance.
		println("*******************MODEL: SAVING DONE********************")
		model.save(sc, "/user/spark/honeypot/lr_sgd")
		println("*********************************************************")
		println("Training Data in CSV had some issues; apache commons could not parse effectively.")
		println("Some training data was likely not processed because of data cleaning issues.")
		println("*********************************************************")
		println()
		println("*******************REPL vs Spark-Submit******************")
		println("Tried loading some collected tweets to examine further, but this fails in spark-submit.")
		println("The same lines of code work fine on spark-shell. Needs further research.")
		println("*********************************************************")

		//Later to load:
		//val model = LogisticRegressionModel.load(sc, "/user/spark/honeypot/lr_sgd")


//INFO: Somehow, the tweetData init is working in REPL, but not in spark-submit
//INFO: Already tried compiling in 2.10.4, using selectExpr and using hive/sql Contexts
//INFO: The model is saved, so some extra parts of the code that examine the tweets are commented out.
		/*****************************************************************************
		 * use the model on the tweets collected earlier.
		 * prepare the data from tweets just as training data above.
		 * FP is hard to read; using DF helps.
		 * Here, however, hard to read RDDs and FP syntax is used.
		 *****************************************************************************/
		//TODO: Nuances that make DFs harder sometimes to construct.
		//TODO: What if some datatype changes in the tweet object? More flexibile type handling.

		//val tweetTable = hiveContext.read.format("json")
		//	.load("/user/spark/tweets/2015/12/19/tweetstream*/part*")
		//tweetTable.registerTempTable("tweetTable")

/*
		val tweetData = sqlContext.sql("select user.followersCount, user.friendsCount, user.statusesCount, " +
			"length(user.screenName), length(user.description), size(split(text, ' ')) as numWords, " +
			"id as tweet_id from tweetTable")

		println("*******************TWEET DATA DONE**********************")
		println(tweetData.count())
		println("**********************************************************")

		val tweetsToClassify = tweetData.map(row => Vectors.dense(row.getLong(0).toDouble,
			row.getLong(1).toDouble, row.getLong(2).toDouble, row.getInt(3).toDouble,
			row.getInt(4).toDouble, row.getInt(5).toDouble))

		println("*******************TWEETS TO CLASSIFY DONE**************")
		println(tweetsToClassify.take(3))
		println("**********************************************************")
		//Would caching be beneficial here? Due to lazy init prevalent in Scala & Spark,
		//this question has been hard to figure out empirically.

		val predictedLabels = tweetsToClassify.map { features => (model.predict(features)) }
		println("*******************PREDICTED LABELS DONE******************")
		println(predictedLabels.count())
		println("**********************************************************")
*/
		 /*****************************************************************************
		  * Jump through hoops to get back a dataframe.
		  * RDDs can be zipped together; but not dataframes.
		  * Use the zipped RDD to generate a dataframe
		  * Rename columns and tdf can be joined with tweetTable to get more information
		  ****************************************************************************/
		//TODO: sqlContext.createDataFrame with schema definition is an easier way to do this.
/*
		val tRDD = predictedLabels.zip(tweetData.rdd)
		val tDF = tRDD.map(r => ( r._1, r._2.getLong(6))).toDF().withColumnRenamed("_1", "IS_POLLUTER").withColumnRenamed("_2", "TWEET_ID")
		tDF.registerTempTable("TDF")
		tweetTable.registerTempTable("TWEET_TABLE")

		println("*******************Joining two dataframes******************")
		println(tDF.count())
		println("**********************************************************")


		//TODO: Join requires spark tweaking - almost always spills to disk and runs forever
		val classifiedTweets = sqlContext.sql("Select IS_POLLUTER, ID, USER.ID, " +
			"TEXT FROM TDF, TWEET_TABLE WHERE TWEET_ID = ID")
*/
		/*****************************************************************************
		 * Examine a few of the good classified tweets and a few of the bad ones
		 * The label of classification is stored in IS_POLLUTER which takes a Double
		 *****************************************************************************/
/*
		println("The spam tweets:")
		classifiedTweets.filter("IS_POLLUTER=1.0").show()

		println("The ham tweets:")
		classifiedTweets.filter("IS_POLLUTER=0.0").show()
*/
	}
	
}
