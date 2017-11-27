# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'watir'
require 'headless'
# Note: Headless doesn't work on MacOS
#       Run XQuartz before trying Headless on MacOS

require './init.rb' # for config and infrastructure

require 'page-object'
require_relative 'pages/init' # uses CodePraise::App.config

HOST = 'http://localhost:9000'

# Helper methods
def homepage
  HOST
end
