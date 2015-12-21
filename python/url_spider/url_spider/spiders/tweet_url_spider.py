#=============   File Info   ============#

__version__ = "1.0"

#DESCRIPTION: This script describes the behavior
# of the scraper.

#========================================#

import scrapy
from snakebite.client import Client
import os
import util
import logging

logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.DEBUG)

# function that validates whether a string is a url
def is_url(url):
	return url.startswith('http') or url.startswith('file') or url.startswith('ssh') or url.startswith('ftp') or url.startswith('ftp') or url.startswith('ssl')

# function used to extract URLs from responses obtained by crawler
def get_urls(response):
	extracted_urls_response = response.xpath('//a/@href').extract()
	extracted_urls = filter(lambda x: is_url(x), extracted_urls_response)
	return extracted_urls

# Class that describes the crawler
class TweetURLSpider(scrapy.Spider):
	name = "TweetURLSpider"
	logging.debug("Retrieving start URLs from logs/temp_urls.log")
	# pull the initial urls to crawl
	start_urls = util.retrieve_start_urls('logs/temp_urls.log')
	logging.debug("The array of starting URLs is: %s" % start_urls)

	# parser function that goes through the initial urls to be crawled
	def parse(self, response):
		for href in get_urls(response):
			url = response.urljoin(href)
			# unescaping URLs encoded with '\\'
			url = url.replace("\\","")
			logging.debug("About to crawl URL:%s" % url)
			filename = "logs/spammy_urls.log"
			# opening and writing to temp file that holds crawled urls
			with open(filename, 'ab') as f:
				f.write(url + "\n")
			logging.debug("URL scraped at first level: %s" % url)
			# calling further crawling function
			yield scrapy.Request(url, callback=self.parse_next_urls)

	# parser function that crawls through subsequent urls obtained from calling parse and itself
	def parse_next_urls(self, response):
		for href in get_urls(response):
			url = response.urljoin(href)
			# unescaping URLs encoded with '\\'
			url = url.replace("\\","")
			logging.debug("About to crawl URL:%s" % url)
			filename = "logs/spammy_urls.log"
			# opening and writing to temp file that holds crawled urls
			with open(filename, 'ab') as f:
				f.write(url + "\n")
			logging.debug("URL scraped at second level: %s" % url)
			# recursive call of crawling function
			yield scrapy.Request(url, self.parse_next_urls)
