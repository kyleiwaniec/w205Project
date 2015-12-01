import scrapy
from snakebite.client import Client
import os
import util
import logging

logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.DEBUG)

def is_url(url):
	return url.startswith('http') or url.startswith('file') or url.startswith('ssh') or url.startswith('ftp') or url.startswith('ftp') or url.startswith('ssl')

def get_urls(response):
	extracted_urls_response = response.xpath('//a/@href').extract()
	extracted_urls = filter(lambda x: is_url(x), extracted_urls_response)
	return extracted_urls

class TweetURLSpider(scrapy.Spider):
	name = "TweetURLSpider"
	start_urls = util.retrieve_start_urls('logs/temp_urls.log')
	#start_urls = ["http://www.dmoz.org/Computers/Programming/Languages/Python/Books/", "http://www.dmoz.org/Computers/Programming/Languages/Python/Resources/"]
	logging.debug("The array of starting URLs is: %s" % start_urls)
	# By definition, we will NOT have an allowed domains restraint; the below should only be uncommented for testing purposes
	# allowed_domains = ["dmoz.org"]

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
