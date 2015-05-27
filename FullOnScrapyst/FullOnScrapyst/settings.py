# -*- coding: utf-8 -*-

# Scrapy settings for FullOnScrapyst project
#
# For simplicity, this file contains only the most important settings by
# default. All the other settings are documented here:
#
#     http://doc.scrapy.org/en/latest/topics/settings.html
#

BOT_NAME = 'FullOnScrapyst'

SPIDER_MODULES = ['FullOnScrapyst.spiders']
NEWSPIDER_MODULE = 'FullOnScrapyst.spiders'
FEED_FORMAT = 'json'
ITEM_PIPELINES = {'FullOnScrapyst.pipelines.FullOnScrapystPipeline': 300}

# Crawl responsibly by identifying yourself (and your website) on the user-agent
#USER_AGENT = 'FullOnScrapyst (+http://www.yourdomain.com)'
