-- TODO: CRON will trigger the table partition addition based on date YYYY/MM/DD

ADD JAR /data/w205Project/spark/hive-serdes-1.0-SNAPSHOT.jar;

ALTER TABLE tweets ADD IF NOT EXISTS 
	PARTITION (datehour = ${DATEHOUR}) 
	LOCATION '${DATEHOUR}';
