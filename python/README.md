#TODO:
- Connect to Hive to obtain the tweet URLS
- Scrape pages from the URLs in the tweets URL Hive table
- Magnify the URL list through reverse DNS lookup
- Pump the total URLs into S3 -> DONE

###Installation prerequisites

To run the python scripts for URL retrieval you will need to ensure that you have this set of packages: libxml2, libxml2-dev, libxslt-devel, python-dev, python-setuptools (all with yum).

You should create a virtualenv with Python2.7 explicitly and the following packages and their respective versions:

```
cffi==1.3.0
characteristic==14.3.0
cryptography==1.1
cssselect==0.9.1
enum34==1.0.4
futures==3.0.3
idna==2.0
ipaddress==1.0.14
lxml==3.4.4
ordereddict==1.1
protobuf==2.6.1
psycopg2==2.6.1
pyasn1==0.1.9
pyasn1-modules==0.0.8
pycparser==2.14
pyOpenSSL==0.15.1
queuelib==1.4.2
requests==2.8.1
Scrapy==1.0.3
service-identity==14.0.0
six==1.10.0
snakebite==2.7.2
tinys3==0.1.11
Twisted==15.4.0
w3lib==1.13.0
wheel==0.24.0
zope.interface==4.1.3
```
Note that you will need to run all the scripts in the virtualenv.

Actual setup commands:
```
yum install libxml2 libxml2-dev libxslt-devel python-dev python-setuptools

pip install virtualenv

# VIRTUALENV_NAME is the name you are giving your autoenv and requirements.txt contains the packages above
virtualenv -p python2.7 VIRTUALENV_NAME 

source VIRTUALENV_NAME/bin/activate

pip install -r requirements.txt

```

#URL crawl work flow

**NOTE**: Below code is run from the w205Project/python/url_spider/url_spider folder.

You will need to set the s3 credentials in your `~/.passwords` file as follows 

To proactively crawl the new suspicious URLs, you can run the following from the command line:
```
scrapy crawl TweetURLSpider
```
The crawler goes through the URLs that have been stored in HDFS and logs them in `logs/spammy_urls.log`.

Next we update the urls used by our plugin by running `python url_upload.py` from the command line.

The above work flow is repeated every day using cron.
