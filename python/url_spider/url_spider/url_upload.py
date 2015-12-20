#=============   File Info   ============#

__version__ = "1.0"

#DESCRIPTION: This script uploads scraped urls to S3 for plugin solution

#========================================#

import scrapy
from snakebite.client import Client
import os
import tinys3
import spiders.util as util
import json
import logging

logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.DEBUG)

key = os.environ.get("S3_ACCESS_KEY")
secret_key = os.environ.get("S3_SECRET_ACCESS_KEY")
endpoint = "s3-us-west-2.amazonaws.com"
bucket = "w205twitterproject"
spam_url_location = "logs/spammy_urls.log"
S3_url_location = "links2.json"

f= open(spam_url_location,'rb')

links = []
for line in f:
	json_obj = {"link":line.rstrip("\n")}
	links.append(json_obj)

conn = util.s3_connect(key, secret_key, endpoint,default_bucket=bucket)
response = util.get_json(conn,S3_url_location)

logging.debug("original length of spammy urls list: %3f" % len(util.get_links(response)))

util.append_links(response,links)

logging.debug("after appending length of spammy urls list: %3f" % len(util.get_links(response)))

upload = json.dumps(response)

with open('logs/test_links.json', 'w') as outfile:
    json.dump(response, outfile)

f = open('test_links.json','r')
util.upload_json(conn,"links3.json",f)
