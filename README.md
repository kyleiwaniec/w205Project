#See the documentation and the wiki for project details

##QUICK SETUP INSTRUCTIONS##

###With a brand new instance and volume: ###
follow these steps in order:   

use this AMI:   
__w205Project_V2.0__

create a new __m3.large__ instance with security group containing:

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
Attach a __100GB Volume__ in the same region   
ssh into your instance   

```
ssh -i "xxx.pem" root@ec2-xx-x-xxx-xx.compute-1.amazonaws.com
fdisk -l
wget https://s3-us-west-2.amazonaws.com/w205twitterproject/provision.sh
. provision.sh <DEVICE PATH> # run once
```

then run your personal git-keys script, or however you want to authorize git.   
here is a template, if you know what yer keys are: `git-keys-template.sh`
```
vi git-keys.sh # copypasta from the template
. git-keys.sh
cd /data
git clone git@github.com:kyleiwaniec/w205Project.git
```
pull the repo, then run:  
```
cd /data/w205Project
. provision/bootstrap.sh
```

user is prompted to add twitter keys and aws keys in the bootstrap script.
flume keywords have been set to top 100 words on twitter.


Run the scheduler:
```
crontab simple_shed_cron.txt
```

Watch it here: `tail -f /data/cronlog.log`   

***

The scheduler will run all of the following... these are for reference only:   

```
sudo -u hdfs bash /data/w205Project/flume/start-flume.sh
```

After a coouple of hours, kills flume, and loads the tables.   

Executing from command line to be able to use variables. No easy way to do this directly in HIVE SQL.  
Also, Flume must be stopped before running transform 


```
# loads external hive table
. /data/w205Project/load/load-hive-table.sh

# adds partition based on today's date, overrides the transformed table for classification
. /data/w205Project/transform/transform.sh 

```

then pyspark:
```
# classify and save to postgres, and json
/data/spark15/bin/spark-submit /data/w205Project/spark/getLinks.py 

# sometimes caching things happen, and server should be restarted
sudo restart shiny-server 
```

then crawler: (ENV27 is already running, all the modules have been installed, and S3 passwords were entered via bootstrap script)   
```
cd /data/w205Project/python/url_spider/url_spider
scrapy crawl TweetURLSpider
python url_upload.py
```

***

GO TO YOUR INSTANCE's DASHBOARD:   
http://ec2-xx-x-xxx-xx.compute-1.amazonaws.com:10000/dashboard/
