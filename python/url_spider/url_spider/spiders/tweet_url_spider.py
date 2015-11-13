import scrapy

class TweetURLSpider(scrapy.Spider):
	name = "TweetURLSpider"
	start_urls = [
        "http://www.dmoz.org/Computers/Programming/Languages/Python/Books/",
        "http://www.dmoz.org/Computers/Programming/Languages/Python/Resources/"
    ]
	allowed_domains = ["dmoz.org"]

	def parse(self, response):
		filename = response.url.split("/")[-2] + '.hmtl'
		with open(filename, 'wb') as f:
			f.write(response.body)
# TODO:
#	- Work on below code to retrieve urls
# get_urls = filter(lambda x: x.startswith('http') or x.startswith('file') or x.startswith('ssh') or x.startswith('ftp') or x.startswith('ssl'), response.xpath('//a/@href').extract())
	def get_start_urls(self):
		return self.start_urls()

	def set_start_urls(self, new_start_urls):
		self.start_urls = new_start_urls

