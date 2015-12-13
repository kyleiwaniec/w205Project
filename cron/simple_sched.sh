sudo -u hdfs bash /data/w205Project/flume/start-flume.sh

sleep 3600 # lets flume gather data for 1 hour

pgrep -u hdfs | tail -n 1 | sudo xargs kill -SIGINT # kills flume process

. /data/w205Project/load/load-hive-table.sh

. /data/w205Project/transform/transform.sh

/data/spark15/bin/spark-submit /data/w205Project/spark/getLinks.py

sudo restart shiny-server

cd /data/w205Project/python/url_spider/url_spider

scrapy crawl TweetURLSpider

python url_upload.py
