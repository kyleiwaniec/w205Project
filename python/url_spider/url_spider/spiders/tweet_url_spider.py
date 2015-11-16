import scrapy
from snakebite.client import Client
import os

# TODO:
# - Retrieve the urls that will start the crawler before initializing the crawler
# - Push urls to S3 bucket

def is_url(url):
	return url.startswith('http') or url.startswith('file') or url.startswith('ssh') or url.startswith('ftp') or url.startswith('ftp') or url.startswith('ssl')

def get_urls(response):
	extracted_urls_response = response.xpath('//a/@href').extract()
	extracted_urls = filter(lambda x: is_url(x), extracted_urls_response)
	return extracted_urls

# def hdfs_write(file):
	# client = Client("localhost", 8020, use_trash=False)
	

class TweetURLSpider(scrapy.Spider):
	name = "TweetURLSpider"
	start_urls = [
        "http://www.dmoz.org/Computers/Programming/Languages/Python/Books/",
        "http://www.dmoz.org/Computers/Programming/Languages/Python/Resources/"
    ]
	# hdfs_output = "hello"
	# print hdfs_output
	allowed_domains = ["dmoz.org"]

	def parse(self, response):
	#	filename = response.url.split("/")[-2] + '.hmtl'
	#	with open(filename, 'wb') as f:
	#		f.write(response.body)
		for href in get_urls(response):
			url = response.urljoin(href)
			filename = "spammy_urls.txt" 
			with open(filename, 'ab') as f:
				f.write(url + "\n")
			print "URL scraped at first level: ", url
			yield scrapy.Request(url, callback=self.parse_next_urls)

	def parse_next_urls(self, response):
		# hdfs_output = "hello"
		for href in get_urls(response):
			url = response.urljoin(href)
			filename = "spammy_urls.txt"
                        with open(filename, 'ab') as f:
                                f.write(url + "\n")
			print "URL scraped at second level: ", url
			# hdfs_output += hdfs_output + url + "\n"
			yield scrapy.Request(url, self.parse_next_urls)
		# os.system('echo "%s" | sudo -u hdfs hdfs dfs -put - /user/w205/test_tweets/test.txt' %(hdfs_output))
# TODO:
#	- Work on below code to retrieve urls
# get_urls = filter(lambda x: x.startswith('http') or x.startswith('file') or x.startswith('ssh') or x.startswith('ftp') or x.startswith('ssl'), response.xpath('//a/@href').extract())
	def get_start_urls(self):
		return self.start_urls()

	def set_start_urls(self, new_start_urls):
		self.start_urls = new_start_urls

