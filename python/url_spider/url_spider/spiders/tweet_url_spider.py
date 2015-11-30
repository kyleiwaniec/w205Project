import scrapy
from snakebite.client import Client
import os
import util
import logging

# TODO:
# - Retrieve the urls that will start the crawler before initializing the crawler
# - Push urls to S3 bucket - DONE

logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.DEBUG)

def is_url(url):
	return url.startswith('http') or url.startswith('file') or url.startswith('ssh') or url.startswith('ftp') or url.startswith('ftp') or url.startswith('ssl')

def get_urls(response):
	extracted_urls_response = response.xpath('//a/@href').extract()
	extracted_urls = filter(lambda x: is_url(x), extracted_urls_response)
	return extracted_urls

# def hdfs_write(file):
	# client = Client("localhost", 8020, use_trash=False)

#def retrieve_start_urls():
	# This function returns an array of urls to initiallize the crawler
	#
	# return start_urls_array
	#start_urls = []
	#f=open('logs/temp_urls.log','r')
	#for line in f:
		#logging.debug("retrieving url: %s" % str(line))
		#start_urls.append(str(line))
	#f.close()
	#return start_urls

class TweetURLSpider(scrapy.Spider):
	name = "TweetURLSpider"
	start_urls = util.retrieve_start_urls('logs/temp_urls.log')
	#start_urls = ["http://www.dmoz.org/Computers/Programming/Languages/Python/Books/", "http://www.dmoz.org/Computers/Programming/Languages/Python/Resources/"]
	logging.debug("The array of starting URLs is: %s" % start_urls)
	# By definition, we will NOT have an allowed domains restraint; the below is only for testing purposes
	allowed_domains = ["dmoz.org"]

	def parse(self, response):
		for href in get_urls(response):
			url = response.urljoin(href)
			filename = "logs/spammy_urls.log" 
			with open(filename, 'ab') as f:
				f.write(url + "\n")
			logging.debug("URL scraped at first level: %s" % url)
			yield scrapy.Request(url, callback=self.parse_next_urls)

	def parse_next_urls(self, response):
		for href in get_urls(response):
			url = response.urljoin(href)
			filename = "logs/spammy_urls.log"
                        with open(filename, 'ab') as f:
                                f.write(url + "\n")
			logging.debug("URL scraped at second level: %s" % url)
			yield scrapy.Request(url, self.parse_next_urls)
		# os.system('echo "%s" | sudo -u hdfs hdfs dfs -put - /user/w205/test_tweets/test.txt' %(hdfs_output))
# TODO:
#	- Work on below code to retrieve urls
# get_urls = filter(lambda x: x.startswith('http') or x.startswith('file') or x.startswith('ssh') or x.startswith('ftp') or x.startswith('ssl'), response.xpath('//a/@href').extract())
	def get_start_urls(self):
		return self.start_urls()

	def set_start_urls(self, new_start_urls):
		self.start_urls = new_start_urls
	#def retrieve_start_urls(self):
        # This function returns an array of urls to initiallize the crawler
        #
        # return start_urls_array
        #	start_urls = []
        #	f=open('logs/temp_urls.log','r')
        #	for line in f:
         #       	logging.debug("retrieving url: %s" % str(line))
          #      	start_urls.append(str(line))
        #	f.close()
        #	return start_urls
