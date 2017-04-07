#!/usr/bin/env ruby
# Fetch N random OpenURL page views for a given day
# Usage (get 20 random page views from Jan 1 2017): 
#   sample_openurl_pageviews.rb 2017-01-01 20
#
require './ga_sevice.rb'
require 'yaml'

abort "provide a date (YYYY-MM-DD)" if ARGV.empty?
start_date = end_date = ARGV.shift
abort "provide a number page views" if ARGV.empty?
number = ARGV.shift.to_i

config = YAML.load_file("ga_config.yml")
ga_service = GoogleAnalyticsService.new(config)
result = ga_service.query(dimension: 'ga:pagePath', 
                          metric: 'ga:pageViews', 
                          sort: '-ga:pageViews', 
                          filter: 'ga:pagePath=~\/openurl\?',
                          start_date: start_date,
                          end_date: end_date)

result.data.rows.shuffle.take(number).each {|r| puts r[0]}

