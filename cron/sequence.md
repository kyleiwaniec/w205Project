###With a brand new instance and volume: ###
run these scripts first:

use this AMI:   
~~w205Project_V1.1~~ <- nvm, this is f'd. can't pre-install shiny - boo hoo.

w205Project_V1.2

create a new m3.large instance with security group containing:

```
Ports	Protocol	Source	tableau
4040	tcp	0.0.0.0/0	✔
50070	tcp	0.0.0.0/0	✔
8080	tcp	0.0.0.0/0	✔
22		tcp	0.0.0.0/0	✔
10000	tcp	0.0.0.0/0	✔
8020	tcp	0.0.0.0/0	✔
8088	tcp	0.0.0.0/0	✔
```
Attach a 100GB Volume in the same region

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
cd /data/w205Project
git checkout testall
. provision/bootstrap.sh
```

then run we'll the scheduler...


Remember to add the twitter keys in /data/w205Project/flume/conf/flume.conf:   
(not sure how to script this, so my keys are in here)
```
sudo -u hdfs bash /data/w205Project/flume/start-flume.sh
```

After a coouple of hours, kill flume, and load the tables.   
###TODO: Write script to trigger the add-partition.sql###
####this whole thing needs some work - Sharmila?####

```
hive -f /data/w205Project/load/load.sql  
hive -f /data/w205Project/load/add-partition.sql  
hive -f /data/w205Project/transform/transform.sql

```



then pyspark:
```
/data/spark15/bin/spark-submit /data/w205Project/spark/getLinks.py
```

then crawler:
```
cd /data/w205Project/python/url_spider/url_spider
scrapy crawl TweetURLSpider
python url_upload.py
```

GO TO THE DASHBOARD:   
http://ec2-52-2-158-11.compute-1.amazonaws.com:10000/dashboard/
