import scrapy
from snakebite.client import Client
import os
import tinys3
import spiders.util as util
import json
import logging

logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.DEBUG)

f= open('logs/spammy_urls.log','rb')

links = []
for line in f:
	json_obj = {"link":line.rstrip("\n")}
	links.append(json_obj)

key = os.environ.get("S3_ACCESS_KEY")
secret_key = os.environ.get("S3_SECRET_ACCESS_KEY")
endpoint = "s3-us-west-2.amazonaws.com"
bucket = "w205twitterproject"

conn = util.s3_connect(key, secret_key, endpoint,default_bucket=bucket)
response = util.get_json(conn,"links2.json")

logging.debug("original length of spammy urls list: %3f" % len(util.get_links(response)))

util.append_links(response,links)
logging.debug("after appending length of spammy urls list: %3f" % len(util.get_links(response)))
logging.debug(type(response))
logging.debug(type(json.dumps(response)))

upload = json.dumps(response)

with open('logs/test_links.json', 'w') as outfile:
    json.dump(response, outfile)

f = open('test_links.json','r')
util.upload_json(conn,"logs/test.json",f)

#new_response = util.get_json(conn,"test.json")

#logging.debug("original length of spammy urls list: %3f" % len(util.get_links(new_response)))
