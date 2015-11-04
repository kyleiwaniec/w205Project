## Loading data from HDFS ##

Using the HIVE metastore, we'll load up just the fields we are interested in.

We'll create an external table, partioned by the day: YYYY/MM/DD
Next TODO: write the CRON which will add partitions. The stub for the partition is in add-partition.sql

```
su w205
hive –f load.sql
```

For now this outputs one record

Next TODO: 
1. send results to parse for bad links
2. run scraper on all links in found tweets to determine "spam links", and store in S3 for use by plugin
3. parse with ML to determine "spam user", and store in S3 for use by plugin