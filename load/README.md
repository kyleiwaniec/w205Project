## Loading data from HDFS ##

Using the HIVE metastore, we'll load up just the fields we are interested in.

We'll create an external table, partioned by the day: YYYY/MM/DD   
Next TODO: write the CRON which will add partitions. The stub for the partition is in add-partition.sql

```
su w205
hive –f load.sql
```

For now this outputs one record to the console as a sanity check

####Next TODO:      

- [ ] run scraper on all links to determine "spam links", and store in S3 for use by plugin  
- [ ] parse (potentially using ML) to determine "spam user", and store in S3 for use by plugin  