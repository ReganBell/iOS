# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html

from scrapy.exceptions import DropItem
import json


def merge(a, b, path=None):

    if path is None: path = []
    for key in b:
        if key in a:
            if isinstance(a[key], dict) and isinstance(b[key], dict):
                    merge(a[key], b[key], path + [str(key)])
            elif a[key] == b[key]:
                pass  # same leaf value
            else:
                    print 'Merging:'
                    print json.dumps(a)
                    print json.dumps(b)
                    print 'Conflict at ' + key + ' values: ' + str(a[key]) + ' ' + str(b[key])
        else:
            a[key] = b[key]
    return a


class FullOnScrapystPipeline(object):

    finished_items = {}

    def process_item(self, item, spider):
        title = item['title']
        item_term_year = item['term'] + item['year']
        item_dict = dict(item)
        if title in self.finished_items:
            reports = self.finished_items[title]
            if item_term_year in reports:
                merged = merge(reports[item_term_year], item_dict)
                reports[item_term_year] = merged
            else:
                reports[item_term_year] = item_dict
        else:
            self.finished_items[title] = {item_term_year: item_dict}
        return item

    def close_spider(self, spider):
        with open('final_results.json', 'w') as f:

            json.dump(self.finished_items, f)


