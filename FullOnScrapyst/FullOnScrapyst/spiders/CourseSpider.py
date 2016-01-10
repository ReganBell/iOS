# -*- coding: utf-8 -*-
import scrapy
from scrapy.shell import inspect_response
from ..items import Course

class CoursespiderSpider(scrapy.Spider):
    name = "Courses"
    allowed_domains = ["coursecatalog.harvard.edu"]
    start_urls = (
        'http://www.coursecatalog.harvard.edu/',
    )
    schools = []
    depts = []
    facultys = []
    terms = []
    meetings = []
    locations = []
    levels = []
    itemLimit = 500
    itemCount = 0
    headerKeyPairs = {'School': 'school', 'Department': 'department', 'Faculty': 'faculty', 'Term': 'term', 'Day and Time': 'meeting', 'Location': 'location'}

    def start_requests(self):
        yield scrapy.Request('https://coursecatalog.harvard.edu/icb/icb.do?keyword=CourseCatalog&panel=icb.pagecontent695860%3Arsearch%3Ffq_coordinated_semester_yr%3D%26fq_school_nm%3D%26q%3D%26sort%3Dcourse_title%2Basc%26start%3D0%26submit%3DSearch&pageid=icb.page335057&pageContentId=icb.pagecontent695860&#a_icb_pagecontent695860', callback=self.got_course_list)

    def extract_credit_level(self, response):
        for i, header in enumerate(response.xpath('//strong/text()').extract()):
            print header
            if header == 'Credit Level':
                header_node = header_node = response.xpath('//strong')[i]
                return header_node.xpath('./ancestor::td/text()').pop().extract()

    def extract_strong(self, response, extract_header, ancestor_type):
        for i, header in enumerate(response.xpath('//strong/text()').extract()):
            if header in extract_header:
                header_node = response.xpath('//strong')[i]
                xpath_string = './ancestor::' + ancestor_type + '/text()'
                ancestors = header_node.xpath(xpath_string)
                if header == 'Credits':
                    return ''.join(ancestors.extract())
                else:
                    return ancestors.pop().extract() if len(ancestors) != 0 else None

    # def extract_td(self, response, header):
    #     for i, header in enumerate() 

    def extract_from_tables(self, response, course, debug=False):
        course['title'] = response.xpath('//span[@class = "course_title"]/text()').extract()[0]
        course['number'] = response.xpath('//span[@class = "course_no"]/text()').extract()[0]
        for table in response.xpath('//table'):
            headers = table.xpath('.//th[@rowspan = "1"]/text()').extract()
            entries = table.xpath('.//td[@rowspan = "1"]/text()').extract()
            if debug:
                print zip(headers, entries)
            for header, entry in zip(headers, entries):
                if header in self.headerKeyPairs:
                    course[self.headerKeyPairs[header]] = entry
        if debug:
            print course
        return course

    def extract_map_location(self, response):
        for script in response.xpath('//script/text()').extract():
            if 'mapmarkers' in script:
                return script

    def got_course_info(self, response):
        course = Course()
        self.itemCount += 1
        self.extract_from_tables(response, course)
        # If faculty is a link and not plaintext
        faculty_link = response.xpath('//a[@target = "profile"]/text()').extract()
        if len(faculty_link) > 0:
            course['faculty'] = faculty_link[0]

        if course['school'] == 'Harvard Extension School':
            return None

        if 'location' in course:
            if 'p.m.' in course['location']:
                self.extract_from_tables(response, course, True)
                inspect_response(response, self)

        course['examGroup'] = self.extract_strong(response, 'Exam Group ', 'p')
        course['level'] = self.extract_strong(response, 'Credit Level', 'td')
        course['credits'] = self.extract_strong(response, 'Credits', 'td')
        course['description'] = self.extract_strong(response, 'Description', 'p')
        course['notes'] = self.extract_strong(response, 'Notes', 'p')
        course['prereqs'] = self.extract_strong(response, 'Prerequisite(s)', 'p')
        course['mapLocation'] = self.extract_map_location(response)
        return course

    def got_course_list(self, response):

        course_links = [scrapy.Request(course, self.got_course_info) for course in response.xpath('//tr[@class = "course"]/td/span/a/@href').extract()]

        next = response.xpath('//span[@class = "prevnext"]').pop()
        next_text = next.xpath('./a/text()').extract()[0]
        if next_text == "next »":
            next_url = next.xpath('./a/@href').extract()[0]
            course_links.append(scrapy.Request(next_url, callback=self.got_course_list))
        else:
            inspect_response(response, self)

        return course_links

