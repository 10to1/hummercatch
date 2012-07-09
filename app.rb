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

  helpers do

    def campfire_message(mail)
      message = mail.subject.split("Re:").first.stript

      if message =~ /Unsuccessful/
        message = "Epic Fail: #{message}"
      end

      if message =~ /^Successful/
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

  get '/' do
    "Hummer catch catches Hubot's mail"
  end
end
