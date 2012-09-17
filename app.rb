# -*- coding: utf-8 -*-
require "rubygems"
require 'sinatra'
require "broach"
require "mail"

class App

  before do
    Broach.settings = {
      'account' => "10to1",
      'token' => "dc906dcf93d6277d4b62276441ffd9c55c90b5b2",
      'use_ssl' => true
    }
  end

  configure do
    require 'redis'
    if ENV["REDISTOGO_URL"]
      uri = URI.parse(ENV["REDISTOGO_URL"])
      $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    else
      $redis = Redis.connect(:url => 'redis://127.0.0.1', :thread_safe => true)
    end
  end

  helpers do

    def redis_set_name
      "hummercatch:ordered"
    end

    def redis_set_key_for_today
      Date.today.strftime("%Y%m%d")
    end

    def campfire_message(mail)
      puts mail.inspect
      message = mail.subject.split("Re:").first.strip

      if message =~ /Unsuccessful/
        message = "Epic Fail: #{message}"
      end

      if message =~ /^Successful/
        $redis.sadd(redis_key_for_set, redis_set_key_for_today)
        message = "Great Success: #{message}"
      end

      ":fax: #{message}"
    end

    def speak(message)
      campfire_room.speak(message)
    end

    def campfire_room
      Broach::Room.find_by_name("General")
    end
  end

  post '/mail' do
    return unless params[:message]

    speak campfire_message(Mail.new(params[:message]))
    status 200
  end

  get '/status' do
    if $redis.sismember(redis_set_name, redis_set_key_for_today)
      '{"ordered": true}'
    else
      '{"ordered": false}'
    end
  end

  get '/' do
    "Hummer catch catches Hubot's mail"
  end
end
