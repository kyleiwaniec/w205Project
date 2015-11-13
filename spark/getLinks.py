#execfile('/data/w205Project/spark/getLinks.py')

from pyspark.sql.functions import UserDefinedFunction
from pyspark.sql.types import *
from pyspark.sql import functions as F
from pyspark.sql.window import Window

sqlContext.sql("ADD JAR /data/w205Project/load/hive-serdes-1.0-SNAPSHOT.jar");


links = sqlContext.sql("select entities.urls.url[0] as tco, entities.urls.expanded_url[0] as link from tweets where entities.urls.url[0] IS NOT NULL");
#links.show(10) 
#links.count() #how many rows ~100K

uniqueLInks = links.dropDuplicates(['tco', 'link'])
#links.na.drop()

#uniqueLInks.toJSON()

uniqueLInks.write.mode('append').json("s3n://w205twitterproject/links.json")
#dataframe.repartition(1).save("s3n://mybucket/testfile","json")