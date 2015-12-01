###With a brand new volume: ###
run these scripts first:
```
fdisk –l
wget https://s3-us-west-2.amazonaws.com/w205twitterproject/provision.sh
. provision.sh <DEVICE PATH>
```
then run your personal git-keys script, or however you wan to to authorize git.   
here is a template, if you know what yer keys are:   
git-keys-template.sh

git clone git@github.com:kyleiwaniec/w205Project.git

pull the repo, then run:  
```
. w205Project/provision/bootstrap.sh
```

then run scheduler...


```
sudo -u hdfs bash /data/w205Project/flume/start-flume.sh

hive -f /data/w205Project/load/load.sql  
hive -f /data/w205Project/transform/transform.sql


```

then pyspark:
```
	/data/spark15/bin/pyspark
	execfile('/data/w205Project/spark/getLinks.py')
```
TODO: convert to submit-spark (or whatever..), just need to put the context lines at the top of the file

```
cd url_spider/url_spider
scrapy crawl TweetURLSpider
python url_upload.py
```

GO TO THE DASHBOARD:   
http://ec2-52-2-158-11.compute-1.amazonaws.com:10000/dashboard/
