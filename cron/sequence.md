###What is currently working:###


as root: start all the services, hadoop, postgres metastore, etc..   

`. /data/bootstrap.sh`   

`sudo -u hdfs bash /data/w205Project/flume/start-flume.sh`

as w205

`hive -f /data/w205Project/load/load.sql`   
`hive -f /data/w205Project/transform/transform.sql`


as root:
(so as to be able to access hdfs and write to S3, see readme in /data/w205Project/spark/readme.md to set your keys)

```
virtualenv -p python2.7 env27
source env27/bin/activate

pip install pandas
pip install statsmodels
pip install numpy
```

run the version that plays nice with S3
```
/data/spark15_h24/bin/pyspark
```
then in pyspark:
	`execfile('/data/w205Project/spark/getLinks.py')`

```
pip install -r requirements.txt

cd url_spider/url_spider
pip install snakebite
pip install tinys3

scrapy crawl TweetURLSpider

export S3_ACCESS_KEY=xxx
export S3_SECRET_ACCESS_KEY=xxx

python url_upload.py
```


