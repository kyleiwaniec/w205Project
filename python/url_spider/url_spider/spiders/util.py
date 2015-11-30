import scrapy
from snakebite.client import Client
import os
import tinys3
import logging

def s3_connect(key, secret_key,endpoint,default_bucket):
	conn = tinys3.Connection(key,secret_key,tls=True,endpoint=endpoint,default_bucket=default_bucket)
	return conn

def get_json(conn,file):
	response = conn.get(file)
	json_response = response.json()
	print len(json_response)
	return json_response

def get_links(response):
	return response['links']

def append_links(response,new_array):
	response['links'].extend(new_array)

def upload_json(conn, file_name, upload_file):
	conn.upload(file_name, upload_file)

def retrieve_start_urls(file):
        # This function returns an array of urls to initiallize the crawler
        # return start_urls_array
        start_urls = []
        f=open(file,'r')
        for line in f:
        	logging.debug("retrieving url: %s" % str(line))
        	start_urls.append(str(line).rstrip("\n"))
        f.close()
        return start_urls

if __name__ == "__main__":
	logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.DEBUG)
	starts = retrieve_start_urls('logs/temp_urls.log')
	key = os.environ.get("S3_ACCESS_KEY")
	secret_key = os.environ.get("S3_SECRET_ACCESS_KEY")
	endpoint = "s3-us-west-2.amazonaws.com"
	bucket = "w205twitterproject"
	conn = s3_connect(key, secret_key, endpoint,default_bucket=bucket)
	response = conn.get("links2.json")
	response_json = response.json()
	print len(response_json['links'])
