import sbt.Keys._

name := "classify_tweets"

version := "1.0"

scalaVersion := "2.11.7"


libraryDependencies ++= Seq(
	"org.apache.spark" %% "spark-core" % "1.5.2" % "provided",
	"org.apache.spark" %% "spark-sql" % "1.5.2" % "provided",
	"org.apache.spark" %% "spark-hive" % "1.5.2" % "provided",
	"org.apache.spark" %% "spark-mllib" % "1.5.2",
	"org.apache.spark" %% "spark-streaming" % "1.5.2",
	"org.apache.spark" %% "spark-streaming-twitter" % "1.5.2",
	"com.google.code.gson" % "gson" % "2.3",
	"org.twitter4j" % "twitter4j-core" % "3.0.3",
	"org.twitter4j" % "twitter4j-stream" % "3.0.3"
)

resolvers += "bintray-spark-packages" at "https://dl.bintray.com/spark-packages/maven/"

resolvers += "AkkaRepository" at "http://repo.akka.io/releases/"

assemblyOption in assembly := (assemblyOption in assembly).value.copy(includeScala = false)

mainClass in assembly := Some("w205.ClassifyTweets")

assemblyMergeStrategy in assembly := {
	case PathList("javax", "servlet", xs @ _*) => MergeStrategy.last
	case PathList("javax", "activation", xs @ _*) => MergeStrategy.last
	case PathList("javax", "xml", xs @ _*) => MergeStrategy.last
	case PathList("org", "apache", xs @ _*) => MergeStrategy.last
	case PathList("com", "google", xs @ _*) => MergeStrategy.last
	case PathList("com", "esotericsoftware", xs @ _*) => MergeStrategy.last
	case PathList("com", "codahale", xs @ _*) => MergeStrategy.last
	case PathList("com", "yammer", xs @ _*) => MergeStrategy.last
	case "about.html" => MergeStrategy.rename
	case "META-INF/ECLIPSEF.RSA" => MergeStrategy.last
	case "META-INF/mailcap" => MergeStrategy.last
	case "META-INF/mimetypes.default" => MergeStrategy.last
	case "plugin.properties" => MergeStrategy.last
	case "log4j.properties" => MergeStrategy.last
	case x =>
		val oldStrategy = (assemblyMergeStrategy in assembly).value
		oldStrategy(x)
}
