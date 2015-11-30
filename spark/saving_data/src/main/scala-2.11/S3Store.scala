import awscala._, s3._
import com.google.gson.Gson

class S3Store {

	def main(args: Array[String]) {

		val credentials = BasicCredentialsProvider("AKIAJCHOVEWJZZ4L4PJQ", "MGPgq4R1FAgaAvoLb7TTSUZFH89dVRQtyBz7CzYV")
		implicit val s3 = S3()

		val buckets: Seq[Bucket] = s3.buckets
		val bucket: Bucket = s3.createBucket("w205-mids")
		val summaries: Seq[S3ObjectSummary] = bucket.objectSummaries

		val jsonAsString = "[{expanded_url: \"https://vine.co/v/Orw22rqKp5b\", url: \"https://t.co/8sbb1Om662\"}," +
							"{expanded_url: \"https://bbb.co/v/Orw22\", url: \"https://t.co/dewOm662\"}]"
		val gson = new Gson()
		gson.toJson(jsonAsString)

		bucket.put("SPAM_URLS", new java.io.File("sample.txt"))

		val s3obj: Option[S3Object] = bucket.getObject("sample.txt")

		s3obj.foreach { obj =>
			obj.publicUrl // http://unique-name-xxx.s3.amazonaws.com/sample.txt
			obj.generatePresignedUrl(DateTime.now.plusMinutes(10)) // ?Expires=....
			bucket.delete(obj) // or obj.destroy()
		}
	}

}
