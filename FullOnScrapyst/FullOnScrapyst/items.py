# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy

class Course(scrapy.Item):
    # define the fields for your item here like:
    title = scrapy.Field()
    enrollment = scrapy.Field()
    responses = scrapy.Field()
    comments = scrapy.Field()
    faculty = scrapy.Field()
    term = scrapy.Field()
    year = scrapy.Field()