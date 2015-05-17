__author__ = 'regan'

import scrapy
import urllib
import urlparse

class QSpider(scrapy.Spider):
    name = "Q"

    def log_in(self, response):
        return [scrapy.FormRequest.from_response(response,
                                                 formdata={'username': '10907373',
                                                          'password': '',
                                                          'compositeAuthenticationSourceType': 'PIN'},
                                                 callback=self.logged_in,
                                                 dont_filter=True)]

    def start_requests(self):
        return [scrapy.Request('https://webapps.fas.harvard.edu/course_evaluation_reports/fas/list?yearterm=2013_2',
                               callback=self.log_in)]

    def logged_in(self, response):
        links = response.xpath('//div[@class="course-block-head"]/a/@href').extract()
        requests = []
        for link in links:
            joined = urlparse.urljoin(response.url, link)
            print joined
            requests.append(scrapy.Request(joined))
        return requests

    def parse(self, response):
        print response.body




