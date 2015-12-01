
#=============   File Info   ============#

__version__ = "1.0"

#DESCRIPTION: This script pulls urls to initiate crawler

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
init_store = "links2.json"
local_store = "logs/temp_urls.log"

f= open(local_store,'w')

conn = util.s3_connect(key, secret_key, endpoint,default_bucket=bucket)
response = util.get_json(conn, init_store)

links = util.get_links(response)

for link in links:
	try:
		tmp_link = str(link['link'])
		f.write(tmp_link+'\n')
		logging.debug("Writing to store %s , link %s" % (local_store, tmp_link))
	except:
		pass
f.close()


