PATH=/root/ENV27/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/jdk1.7.0_79/bin:/usr/lib/spark/bin:/usr/lib/hadoop/bin:/root/bin

su --shell=/bin/bash --session-command=". /data/w205Project/flume/start-flume.sh" hdfs &

/bin/sleep 60 # lets flume gather data for 1 hour

#kill -SIGINT $(pgrep -u hdfs | tail -n 1 | sudo xargs)

#su --shell=/bin/bash --session-command="pgrep -u hdfs | tail -n 1 | sudo xargs kill -SIGINT" root

/usr/bin/pgrep -u hdfs | /usr/bin/tail -n -1 | /usr/bin/xargs  /bin/kill -SIGINT

. /data/w205Project/load/load-hive-table.sh
. /data/w205Project/transform/transform.sh

/data/spark15/bin/spark-submit /data/w205Project/spark/getLinks.py

#cd /data/w205Project/python/url_spider/url_spider

/root/ENV27/bin/scrapy crawl /data/w205Project/python/url_spider/url_spider/TweetURLSpider

/root/ENV27/bin/python /data/w205Project/python/url_spider/url_spider/url_upload.py