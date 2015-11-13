#execfile('/data/w205Project/spark/getLinks.py')

from pyspark.sql.functions import UserDefinedFunction
from pyspark.sql.types import *
from pyspark.sql import functions as F
from pyspark.sql.window import Window

sqlContext.sql("ADD JAR /data/w205Project/load/hive-serdes-1.0-SNAPSHOT.jar");
sqlContext.sql("ADD JAR /usr/lib/hadoop/hadoop-aws.jar");
#sqlContext.sql("ADD JAR /usr/lib/hadoop/lib/aws-java-sdk-1.7.14.jar");

links = sqlContext.sql("select entities.urls.url[0] as tco, entities.urls.expanded_url[0] as link from tweets where entities.urls.url[0] IS NOT NULL");
#links.show(10) 
#links.count() #how many rows ~100K

uniqueLInks = links.dropDuplicates(['tco', 'link'])
#links.na.drop()

#uniqueLInks.rdd.saveAsTextFile("s3://w205twitterproject/attempt2/links2.json")
#uniqueLInks.toJSON("s3://w205twitterproject/attempt2/links.json")
#uniqueLInks.write.mode('append').json("s3://w205twitterproject/attempt2")
uniqueLInks.repartition(1).save("s3n://w205twitterproject/links3","json")