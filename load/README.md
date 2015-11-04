## Loading data from HDFS ##

Using the HIVE metastore, we'll load up just the fields we are interested in.

Create an external table, partioned by the day: YYYY/MM/DD

```
su w205
hive –f load.sql
```

