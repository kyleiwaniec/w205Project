#execfile('/data/w205Project/spark/getLinks.py')

from pyspark.sql.functions import UserDefinedFunction
from pyspark.sql.types import *
from pyspark.sql import functions as F
from pyspark.sql.window import Window

sqlContext.sql("ADD JAR /data/w205Project/load/hive-serdes-1.0-SNAPSHOT.jar");


links = sqlContext.sql("select entities.urls.url[0], entities.urls.expanded_url[0] from tweets where entities.urls.url[0] IS NOT NULL")
