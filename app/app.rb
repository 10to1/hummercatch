# -*- coding: utf-8 -*-
require "rubygems"
require 'sinatra'
require "broach"
require "mail"

module Hummercatch
  class App < Sinatra::Base
    before do
      Broach.settings = {
        'account' => Hummercatch.config.campfire_account,
        'token' => Hummercatch.config.campfire_token,
        'use_ssl' => true
      }
    end

    helpers do

      def ordered?
        $redis.sismember(redis_set_name, redis_set_key_for_today)
      end

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
          $redis.sadd(redis_set_name, redis_set_key_for_today)
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
      content_type :json
      if ordered?
        '{"ordered": true}'
      else
        '{"ordered": false}'
      end
    end

    get '/' do
      erb :home
    end

    get '/categories' do
      content_type :json
      Hummercatch::Food.all_categories.inject({}) {|r, o| r[o.id] = o.name; r}.to_json
    end

    get '/ingredients' do
      content_type :json
      Hummercatch::Food.all_ingredients.collect {|r, o| r[o.id] = o.name}.to_json
    end

    get '/food' do
      content_type :json
      foodz = Hummercatch::Food.all.collect(&:to_json)
      foodz.to_json
    end
  end
end
