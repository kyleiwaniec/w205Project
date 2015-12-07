import sbt.Keys._

name := "saving_data"

version := "1.0"

scalaVersion := "2.11.7"

libraryDependencies += "com.github.seratch" %% "awscala" % "0.5.+"

libraryDependencies += "com.google.code.gson" % "gson" % "2.3"

libraryDependencies ++= Seq(
	"org.apache.spark" %% "spark-core" % "1.5.2" % "provided",
	"org.apache.spark" %% "spark-sql" % "1.5.2" % "provided",
	"org.apache.spark" %% "spark-hive" % "1.5.2" % "provided"
)

resolvers ++= Seq(
	"bintray-spark-packages" at "https://dl.bintray.com/spark-packages/maven/",
	"AkkaRepository" at "http://repo.akka.io/releases/"
)

assemblyMergeStrategy in assembly := {
	case PathList("javax", "servlet", xs @ _*) => MergeStrategy.last
	case PathList("javax", "activation", xs @ _*) => MergeStrategy.last
	case PathList("org", "apache", xs @ _*) => MergeStrategy.last
	case PathList("com", "fasterxml", xs @ _*) => MergeStrategy.last
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
