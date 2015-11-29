package mids.w205.spark

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
 * This implementation reads the tweets stored in HDFS by Flume for a day
 * Then it creates two DFs to store the TwitterUser and Tweet information
 * The twitter users known to be spammers are stored everyday  to TwitterUserSpammers table
 * First we read the distinct users from there and remove them from TwitterUsers DF
 * Then we invoke the algorithm(?!) to first determine whether a user has a high likelihood of being a spammer
 * If the algorithm marks a user as spammer, then a record for this user,
 * including all past details are stored in TwitterUserSpammers
 * Then the URLs from the tweet entities object are stored in UrlsToScrape table
 * if they are already not stored
 *
 */


object TransformTweetsData  {

    def main(args: Array[String]) {

        val conf = new SparkConf().setAppName("Twitter Data Processing for Spam Detection")
        val sc = new SparkContext(conf)
        val sqlContext = new HiveContext(sc)

        //Prep: Load known spammers (user_ids) and URLs
        //We can use this list to not process users known to be spammers
        val knownSpamUsers = sqlContext.read.load("/user/w205/twitter_spammers.parquet").drop("is_spam")
        knownSpamUsers.registerTempTable("KNOWN_SPAMMERS")
        //Now we are ready to load tweets from today

        //Generate the load path based on Year/Month/Date folder structure in HDFS
        //This may need to be revisited based on scheduling

        val todaysPath = new StringBuilder(Calendar.getInstance().get(Calendar.YEAR).toString())
           todaysPath.append( "/" )
           todaysPath.append((Calendar.getInstance().get(Calendar.MONTH) + 1).toString())
           todaysPath.append( "/" )
           todaysPath.append((Calendar.getInstance().get(Calendar.DATE)).toString())

       // val todaysPath = "2015/11/16"
        val fileName = new StringBuilder("/user/flume/tweets/").append(todaysPath)

        // read JSON dataset actually loads the data into a Data Frame
        val tweetsToday = sqlContext.read.format("json").load(fileName.toString())
        //cache this Data Frame for performance
        tweetsToday.cache()
        //materialize the Data Frame to load it in cache
        tweetsToday.count()

        //register this Data Frame as a temp table to use SQL
        tweetsToday.registerTempTable("TWEETS_TODAY")

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
            sqlTwitterUser.append("FROM TWEETS_TODAY  T ")
            sqlTwitterUser.append("WHERE USER.VERIFIED IS NULL OR USER.VERIFIED <> TRUE ")

        //Create the twitterUser data frame
        val allUsers = sqlContext.sql(sqlTwitterUser.toString())
        //remove the known spammers in order to process a new set of users
        //two steps could be combined to 1 (join and except, leaving it in for readability
        //one day when Im a superstar scala programmer, I will write true FP code!
        val oldSpammers = allUsers.join(knownSpamUsers, Seq("user_id"))
        val twitterUsers = allUsers.except(oldSpammers)
        twitterUsers.cache()
        twitterUsers.registerTempTable("TWITTER_USERS_RAW_FLAT")

        //calculate summary of various scores for each user
        //this data frame will be used to:
        //1. classify users as spam or ham
        //2. update spam user and url list for further processing

        //let us try a UDF/UDAF function
        //this is a trivial implementation, but allows us to learn other techniques
        sqlContext.udf.register("getRatio", getRatio _)

        val sqlUsersSummary: StringBuilder  = new StringBuilder("select user_id, ")
        sqlUsersSummary.append("getRatio(max(number_of_followers), max(number_of_following)) as reputation_score, ")
        sqlUsersSummary.append("getRatio(count(tweet_id), max(number_of_tweets)) as avg_num_tweets_per_day, ")
        sqlUsersSummary.append("getRatio(count(tweeted_urls.url), count(tweet_id)) as avg_num_urls_per_tweet ")
        sqlUsersSummary.append(" from twitter_users_raw_flat group by user_id")
        val twitterUserSummary =  sqlContext.sql(sqlUsersSummary.toString())
        twitterUserSummary.cache()
        twitterUserSummary.registerTempTable("TWITTER_USER_SUMMARY")

        val schemaString = "user_id is_spam"
        val classifiedSchema = StructType(schemaString.split(" ").map(fieldName => StructField(fieldName, StringType, true)))
        val classified = sqlContext.createDataFrame(twitterUserSummary.map(r => classify(r)), classifiedSchema )
        classified.filter("is_spam='Y'").registerTempTable("SPAM_USERS")
        classified.filter("is_spam='Y'").write.format("parquet").mode(SaveMode.Append).save("/user/w205/twitter_spammers.parquet")


        val userUrls = twitterUsers.select("user_id", "tweeted_urls.expanded_url")
            .explode("expanded_url", "url_in_tweet"){c:TraversableOnce[String]=>c}
            .orderBy("user_id").drop("expanded_url")
        val suspiciousUrls = userUrls.intersect(classified.filter("is_spam='Y'"))
        suspiciousUrls.select("url_in_tweet").write.format("parquet").mode(SaveMode.Append).save("/user/w205/suspicious_urls.parquet")

        val twitterUsersClassified = twitterUserSummary.join(classified, Seq("user_id"))
        twitterUsersClassified .write.format("parquet").mode(SaveMode.Append).saveAsTable("/user/w205/classified_users.parquet")

        //TODO connect with outside datastores on the cloud
        /*

        ADD AWS DEPENDENCIES TO SBT FIRST:
        libraryDependencies += "com.amazonaws" % "aws-java-sdk-core" % "1.10.37"
        libraryDependencies += "com.amazonaws" % "aws-java-sdk-config" % "1.10.37"
        libraryDependencies += "com.amazonaws" % "aws-java-sdk-dynamodb" % "1.10.37"

        */
        /*

        DO WE NEED STOREHAUS?
         libraryDependencies += "com.twitter" %% "storehaus-dynamodb" % "0.12.0"
         libraryDependencies += "com.twitter" %% "storehaus-core" % "0.12.0"
         import com.twitter.storehaus._
         import com.twitter.storehaus.dynamodb._
         */

        /*
        import com.amazonaws.auth.BasicAWSCredentials
        import com.amazonaws.regions.{ Region, Regions }
        import com.amazonaws.services.dynamodbv2.{ AmazonDynamoDBClient, AmazonDynamoDB }
        import com.amazonaws.services.dynamodbv2.model._
        import com.amazonaws.services.dynamodbv2.document._
        val cred = new BasicAWSCredentials("AKIAJCHOVEWJZZ4L4PJQ", "MGPgq4R1FAgaAvoLb7TTSUZFH89dVRQtyBz7CzYV")
        val dynamoDB: DynamoDB = new DynamoDB(new AmazonDynamoDBClient(cred))
        val tableName = "twitter_users_processed"
        val table: Table = dynamoDB.getTable(tableName)
        val currentDate = new StringBuilder(Calendar.getInstance().get(Calendar.YEAR).toString())
        currentDate .append((Calendar.getInstance().get(Calendar.MONTH) + 1).toString())
        currentDate .append((Calendar.getInstance().get(Calendar.DATE)).toString())
        val item: Item = new Item()
            .withKeyComponent("user_name", "test_from_spark" )
            .withKeyComponent("date_YYYYMMDD", currentDate)
            .withNumber("Followers", 10)
            .withNumber("Following", 20)
            .withString("Tweet_Content", "Free Spam iPad Viagra")
            .withList("URLS", ("http://bit.ly/3920", "http://tiny.url/go/343"))

        try {

           val  outcome: PutItemOutcome = table.putItem(item)
            if (outcome != null) {
                println(outcome.getItem().toString())
            }
        } catch {
            case ex: Exception =>//TODO
        }
       */

    }

    def getRatio(n: Long, d: Long) : Float =
        if (d == 0)  0.0F  else  n.toFloat/d.toFloat

    def classify(r: Row): Row = {
        var score: Float = 0.0F;
        if (r.getAs[Float](r.fieldIndex("reputation_score"))>3) score += 4.0F
        if (r.getAs[Float](r.fieldIndex("avg_num_urls_per_tweet"))>2) score += 4.0F
        if (r.getAs[Float](r.fieldIndex("avg_num_urls_per_tweet"))>1) score += 3.0F
        if (r.getAs[Float](r.fieldIndex("avg_num_tweets_per_day"))>2) score += 2.0F
        if (score > 3.0D)  Row(r.getString(r.fieldIndex("user_id")), "Y")
        Row(r.getString(r.fieldIndex("user_id")), "N")
    }
}
