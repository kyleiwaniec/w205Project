name := "user_classification"

version := "1.0"

scalaVersion := "2.11.7"

libraryDependencies += "org.apache.spark" %% "spark-core" % "1.5.2"

libraryDependencies += "com.twitter" %% "storehaus-dynamodb" % "0.12.0"

libraryDependencies += "org.apache.spark" %% "spark-sql" % "1.5.2"

libraryDependencies += "org.apache.spark" %% "spark-hive" % "1.5.2"
