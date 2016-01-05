# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy

class Course(scrapy.Item):
	title = scrapy.Field()
	number = scrapy.Field()
	school = scrapy.Field()
	department = scrapy.Field()
	faculty = scrapy.Field()
	term = scrapy.Field()
	meeting = scrapy.Field()
	location = scrapy.Field()
	level = scrapy.Field()
	credits = scrapy.Field()
	description = scrapy.Field()
	notes = scrapy.Field()
	prereqs = scrapy.Field()
	examGroup = scrapy.Field()
	mapLocation = scrapy.Field()

class QCourse(scrapy.Item):

    title = scrapy.Field()
    enrollment = scrapy.Field()
    responses = scrapy.Field()
    comments = scrapy.Field()
    faculty = scrapy.Field()
    term = scrapy.Field()
    year = scrapy.Field()