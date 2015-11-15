## Loading data from HDFS ##

Using the HIVE metastore, we'll load up just the fields we are interested in.

We'll create an external table, partioned by the day: YYYY/MM/DD   

```
su w205
hive –f load.sql
```

For now this outputs one record to the console as a sanity check


###TODO:    
- [ ] Write the CRON which will add partitions. The stub for the partition is in add-partition.sql

####Next TODO:      

- [ ] run scraper on all links to determine "spam links", and store in S3 for use by plugin  
- [ ] parse (potentially using ML) to determine "spam user", and store in S3 for use by plugin  


{color: red}
#### Note from Sharmila
Added load_tmp.sql for two reasons:1
1) Unable to get partitions to work with load.sql. Also had to change the flume sink configuration.
2) Added some more fields for extraction. 
Once we review the fields extracted as well as the best way to establish partitions, we can update load.sql and delete the load_tmp.sql.
{color: red}