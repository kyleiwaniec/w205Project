
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

