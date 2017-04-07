#!/usr/bin/env ruby
# Fetch N random "view it" events for a given day
# Usage (get 20 random events from Jan 1 2017): 
#   sample_viewit_events.rb 2017-01-01 20
#
require './ga_sevice.rb'
require 'yaml'

abort "provide a date (YYYY-MM-DD)" if ARGV.empty?
start_date = end_date = ARGV.shift
abort "provide a number page views" if ARGV.empty?
number = ARGV.shift.to_i

config = YAML.load_file("ga_config.yml")
ga_service = GoogleAnalyticsService.new(config)
result = ga_service.query(dimension: 'ga:eventLabel', 
                          metric: 'ga:totalEvents', 
                          sort: '-ga:eventLabel', 
                          filter: 'ga:eventCategory==Alma Resolver;ga:eventAction==ViewIt',
                          start_date: start_date,
                          end_date: end_date)

result.data.rows.shuffle.take(number).each {|r| puts r[0]}

