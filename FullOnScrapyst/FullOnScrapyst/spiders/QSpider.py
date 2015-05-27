__author__ = 'regan'

import scrapy
import urllib
import urlparse
import re
from scrapy.shell import inspect_response
from ..items import Course

class QSpider(scrapy.Spider):
    name = "Q"
    base = "https://webapps.fas.harvard.edu/course_evaluation_reports/fas/"
    scraped_courses = set()
    count = 0
    active_items = set()

    def log_in(self, response):
        request = scrapy.FormRequest.from_response(response,
                                                 formdata={'username': '10907373',
                                                           'password': 'Fogs79,obis',
                                                           'compositeAuthenticationSourceType': 'PIN'},
                                                 callback=self.logged_in,
                                                 dont_filter=True)
        request.meta['year'] = response.meta['year']
        request.meta['term'] = response.meta['term']
        return [request]

    def start_requests(self):
        fall_2012 = scrapy.Request('https://webapps.fas.harvard.edu/course_evaluation_reports/fas/list?yearterm=2012_1',
                               callback=self.log_in)
        spring_2012 = scrapy.Request('https://webapps.fas.harvard.edu/course_evaluation_reports/fas/list?yearterm=2012_2',
                               callback=self.log_in)
        fall_2013 = scrapy.Request('https://webapps.fas.harvard.edu/course_evaluation_reports/fas/list?yearterm=2013_1',
                               callback=self.log_in)
        spring_2013 = scrapy.Request('https://webapps.fas.harvard.edu/course_evaluation_reports/fas/list?yearterm=2013_2',
                               callback=self.log_in)
        fall_2014 = scrapy.Request('https://webapps.fas.harvard.edu/course_evaluation_reports/fas/list?yearterm=2014_1',
                               callback=self.log_in)
        for fall in [fall_2012, fall_2013, fall_2014]:
            fall.meta['term'] = 'fall'
        for spring in [spring_2012, spring_2013]:
            spring.meta['term'] = 'spring'
        for twelve in [fall_2012, spring_2012]:
            twelve.meta['year'] = '2012'
        for thirteen in [fall_2013, spring_2013]:
            thirteen.meta['year'] = '2013'
        fall_2014.meta['year'] = '2014'
        return [fall_2014, spring_2013, fall_2013, fall_2012, spring_2012]

    @staticmethod
    def parse_baseline(alt_texts):
        div_list = [t for t in alt_texts if "division" in t]
        group_list = [t for t in alt_texts if "group" in t]
        size_list = [t for t in alt_texts if "size" in t]
        dept_list = [t for t in alt_texts if "dept" in t]
        lists = [('division', div_list), ('group', group_list), ('size', size_list), ('dept', dept_list)]
        baseline_dict = {}
        for item in lists:
            key, list = item
            if not len(list) == 0:
                n = float(re.compile("\d.\d+").search(list[0]).group())
                baseline_dict.update({key: n})
        return baseline_dict

    def got_baseline(self, response):

        course = response.meta['course']
        source = response.meta['source_question']
        if 'instructor' in response.meta:
            instructor = response.meta['instructor']
            instructor_dict = course['faculty'][instructor]
            answer = instructor_dict[source]
        else:
            answers = course['answers']
            answer = answers[source]
        alt_texts = response.xpath('//img/@alt').extract()
        three_years = [t for t in alt_texts if "three_years" in t]
        single_term = [t for t in alt_texts if "single_term" in t]
        if len(three_years) == 0 or len(single_term) == 0:
            print response.body
            return course
        answer['baselines'] = {'three_years': self.parse_baseline(three_years),
                               'single_term': self.parse_baseline(single_term)}
        return course

    def parse_row(self, row, course, instructor):

        img_list = row.xpath('.//img/@alt').extract()
        if len(img_list) == 0:
            return
        alt_text = img_list[0]
        if 'Segments' not in alt_text:
            return
        baseline_suffix = row.xpath('.//a/@href').extract()[0]
        baseline_url = 'https://webapps.fas.harvard.edu/course_evaluation_reports/fas/' + baseline_suffix
        baseline_request = scrapy.Request(baseline_url, callback=self.got_baseline)
        breakdown = [int(s) for s in alt_text.split() if s.isdigit()]
        print breakdown
        w_sum = 0
        midpoint = sum(breakdown) / 2.0
        median = 1
        x = 0
        for i, n in enumerate(breakdown, start=1):
            w_sum += i * n
            if x + n > midpoint and x < midpoint:
                median = i
            elif x + n == midpoint:
                median = i + 0.5
            else:
                median = median
            x += n
        mean = w_sum / float(sum(breakdown))

        title = row.xpath('./td[1]/strong/text()').extract()[0]
        if len(instructor):
            faculty_dict = course['faculty'] if 'faculty' in course else {}
            instructor_dict = faculty_dict[instructor] if instructor in faculty_dict else {}
            instructor_dict[title] = {'mean': mean, 'median': median, 'breakdown': breakdown}
            faculty_dict[instructor] = instructor_dict
            course['faculty'] = faculty_dict
            baseline_request.meta['instructor'] = instructor
        else:
            answers = course['answers'] if 'answers' in course else {}
            answers[title] = {'mean': mean, 'median': median, 'breakdown': breakdown}
            course['answers'] = answers
        baseline_request.meta['course'] = course
        baseline_request.meta['source_question'] = title
        return baseline_request

    def got_comments(self, response):
        comments = response.xpath('//div[@class = "response"]/p/text()').extract()
        course = response.meta['course']
        course['comments'] = comments
        return course

    def parse_faculty(self, response):
        rows = response.xpath('//tr')
        requests = []
        instructor = response.xpath('//h3[@class = "instructor"]/text()').extract()
        if len(instructor) == 0:
            print response.body
            return
        for row in rows:
            baseline_request = self.parse_row(row, response.meta['course'], instructor[0])
            if baseline_request is not None:
                requests.append(baseline_request)
        return requests

    def got_faculty(self, response):
        if 'No data available' in response.body:
            return
        course = response.meta['course']
        requests = self.parse_faculty(response)
        options = response.xpath('//ul[@class = "instructorSelect"]//option/@value').extract()
        base = self.base + 'inst-tf_summary.html?' + 'current_instructor_or_tf_huid_param='
        course_id = response.url.split('?')[1]
        end = '&current_tab=2&benchmark_type=Division&benchmark_range=single_term&sect_num='
        instructor_urls = [base + v + '&' + course_id + end for v in options][1:]
        requests += [scrapy.Request(url, callback=self.parse_faculty) for url in instructor_urls]
        for request in requests:
            request.meta['course'] = course
        return requests

    def got_course(self, response):

        course_title = response.xpath('//h1/text()').extract()
        if len(course_title) > 0:
            raw_enrollment = response.xpath('//div[@id = "summaryStats"]/text()').extract()
            enrollment = re.compile("[0-9]+").search(raw_enrollment[0]).group()
            course = Course()
            course['title'] = course_title[0]
            course['enrollment'] = enrollment
            course['term'] = response.meta['term']
            course['year'] = response.meta['year']
            requests = []
            course_id = response.url.split('?')[1]
            comment_url = self.base + 'view_comments.html?' + course_id + '&qid=1487&sect_num='
            comment_request = scrapy.Request(comment_url, self.got_comments)
            comment_request.meta['course'] = course
            faculty_url = self.base + 'inst-tf_summary.html?' + course_id
            faculty_request = scrapy.Request(faculty_url, self.got_faculty)
            faculty_request.meta['course'] = course
            requests.append(comment_request)
            requests.append(faculty_request)
            rows = response.xpath('//tr')
            for row in rows:
                baseline_request = self.parse_row(row, course, '')
                if baseline_request is not None:
                    requests.append(baseline_request)
            return requests
        else:
            print response.body

    def fix_xml(self, response):
        old_body = response.body
        new_body = old_body.replace('<?xml version="1.0" encoding="ISO-8859-1"?>', '<div>') + '</div>'
        return response.replace(body=new_body)

    def got_department(self, response):
        response = self.fix_xml(response)
        course_links = response.xpath('//li[@class="course"]/a/@href').extract()
        requests = []
        self.count += len(course_links)
        print "Scraping %d courses -- total %d" % (len(course_links), self.count)
        for course_link in course_links:
            url = self.base + course_link
            request = scrapy.Request(url, callback=self.got_course)
            request.meta['term'] = response.meta['term']
            request.meta['year'] = response.meta['year']
            requests.append(request)
        return requests

    def logged_in(self, response):
        departments = response.xpath('//a[@class="remove_link"]/span/@title').extract()
        base = "https://webapps.fas.harvard.edu/course_evaluation_reports/fas/guide_dept?dept="
        params = "&term=2&year=2013"
        requests = []
        print "Number of departments %d" % len(departments)
        for department in departments:
            url = "%s%s%s" % (base, department, params)
            request = scrapy.Request(url, callback=self.got_department)
            request.meta['term'] = response.meta['term']
            request.meta['year'] = response.meta['year']
            requests.append(request)
        return requests

    # def parse(self, response):





