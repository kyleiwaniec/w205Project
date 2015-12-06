###With a brand new instance and volume: ###
follow these steps in order:   

use this AMI:   
w205Project_V2.0 <-- has the works!

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
ssh into your instance   

```
ssh -i "xxx.pem" root@ec2-xx-x-xxx-xx.compute-1.amazonaws.com
fdisk –l
wget https://s3-us-west-2.amazonaws.com/w205twitterproject/provision.sh
. provision.sh <DEVICE PATH>
```

then run your personal git-keys script, or however you wan to to authorize git.   
here is a template, if you know what yer keys are: `git-keys-template.sh`
```
vi git-keys.sh # copypasta from the template
. git-keys.sh

git clone git@github.com:kyleiwaniec/w205Project.git
```
pull the repo, then run:  
```
cd /data/w205Project
git checkout testall # this will change to master when we're ready
. provision/bootstrap.sh
```

then run we'll the scheduler...


user is prompted to add twitter keys bootstrap script.
keywords have been set to all alphanumeric to capture all tweets: a,b,c,...,8,9,0

```
sudo -u hdfs bash /data/w205Project/flume/start-flume.sh
```

After a coouple of hours, kill flume, and load the tables.   
Executing from command line to be able to use variables. No easy way to do this directly in HIVE SQL.  
Also, Flume must be stopped before running transform 

```
. /data/w205Project/load/load-hive-table.sh
. /data/w205Project/transform/transform.sh

```

then pyspark:
```
/data/spark15/bin/spark-submit /data/w205Project/spark/getLinks.py
sudo restart shiny-server
```

then crawler: (ENV27 is already running, all the modules have been installed, and S3 passwords were entered via bootstrap script)   
TODO: fix Kyle's shitty encoding
```
cd /data/w205Project/python/url_spider/url_spider
scrapy crawl TweetURLSpider
python url_upload.py
```

GO TO YOUR INSTANCE's DASHBOARD:   
http://ec2-xx-x-xxx-xx.compute-1.amazonaws.com:10000/dashboard/
