#!/bin/bash

export PATH=/root/ENV27/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/jdk1.7.0_79/bin:/usr/lib/spark/bin:/usr/lib/hadoop/bin:/root/bin

su --shell=/bin/bash --session-command=". /data/w205Project/flume/start-flume.sh" hdfs &

/bin/sleep 60 # lets flume gather data for 1 hour


# /bin/kill -TERM $(/bin/cat /data/script.pid) && /bin/rm /data/script.pid
# so after 10,000 desperate attemps to get the flume pid, and at the point of "I'm just about to blow my brains out",
# what follows is a nasty hack to kill flume. enjoy thy schadenfreude. 

/bin/kill -TERM $(/usr/bin/pgrep -u hdfs | /usr/bin/tail -n -1 | /usr/bin/xargs)
# or more simply: kill -TERM $(pgrep -u hdfs | tail -1)

. /data/w205Project/load/load-hive-table.sh
. /data/w205Project/transform/transform.sh

/data/spark15/bin/spark-submit /data/w205Project/spark/getLinks.py


source ~/.passwords
source ~/ENV27/bin/activate

cd /data/w205Project/python/url_spider/url_spider

scrapy crawl TweetURLSpider

/root/ENV27/bin/python /data/w205Project/python/url_spider/url_spider/url_upload.py