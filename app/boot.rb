$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require "rubygems"
require "bundler/setup"

require 'redis'
require 'sinatra/base'
require "json"

require 'hummercatch'
require 'models/food'

require 'app'

uri = URI.parse(Hummercatch.config.redis_uri)
$redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
