ENV['RACK_ENV'] = "test"

require "rubygems"
require "bundler"

require File.join(File.dirname(__FILE__), "..", "lib", "slogger.rb")

#
# RSpec setup
#

require "rspec"
