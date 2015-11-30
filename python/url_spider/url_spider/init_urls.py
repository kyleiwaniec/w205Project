import scrapy
from snakebite.client import Client
import os
import tinys3
import spiders.util as util
import json
import logging

logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.DEBUG)

f= open('logs/temp_urls.log','w')

key = os.environ.get("S3_ACCESS_KEY")
secret_key = os.environ.get("S3_SECRET_ACCESS_KEY")
endpoint = "s3-us-west-2.amazonaws.com"
bucket = "w205twitterproject"

conn = util.s3_connect(key, secret_key, endpoint,default_bucket=bucket)
response = util.get_json(conn,"links2.json")

links = util.get_links(response)

for link in links:
	try:
		# link = unicode(str(link['link']).decode('utf-8'), errors='ignore')
		f.write(str(link['link'])+'\n')
		# logging.debug("Encoded")
	except:
		pass #logging.debug("Couldn't encode")
f.close()


