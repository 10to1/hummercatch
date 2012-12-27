# -*- coding: utf-8 -*-
require "rubygems"
require 'sinatra'
require "broach"
require "mail"

module Hummercatch
  class App < Sinatra::Base

    register Sinatra::Auth::Github

    enable :sessions
    set    :session_secret, "DA_SEKRET"

    class Octobouncer < Sinatra::Base
      # Handle bad authenication, clears the session and redirects to login.
      get '/unauthenticated' do
        if session[:user].nil?
          redirect '/'
        else
          session.clear
          redirect '/403.html'
        end
      end
    end

    set :github_options, {
      :secret    => Hummercatch.config.secret,
      :client_id => Hummercatch.config.client_id,
      :failure_app => Octobouncer,
      :organization => Hummercatch.config.gh_org,
      :github_scopes => 'user,offline_access'
    }

    Broach.settings = {
      'account' => Hummercatch.config.campfire_account,
      'token' => Hummercatch.config.campfire_token,
      'use_ssl' => true
    }

    before do
      content_type :json

      session_not_required = request.path_info =~ /\/login/ ||
                             request.path_info =~ /\/auth/ ||
                             request.path_info =~ /\/images\/art\/.*.png/

      if session_not_required || @current_user
        true
      else
        login
      end
    end

    def api_request
      !!params[:token] || !!request.env["HTTP_AUTHORIZATION"]
    end

    def login
      if api_request
        login = request.env["HTTP_X_CATCH_LOGIN"] || params[:login] || ""
        user = User.find_by_login(login)
      else
        github_organization_authenticate!(Hummercatch.config.gh_org)
        user   = User.find(github_user.login)
        user ||= User.create(github_user.login,github_user.email)
      end

      halt 401 if !user
      @current_user = session[:user] = user
    end

    def current_user
      @current_user
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
      content_type :html
      erb :home
    end

    get '/categories' do
      content_type :json
      Hummercatch::Category.all.inject({}) {|r, o| r[o.id] = o.name; r}.to_json
    end

    get '/categories/:id' do |id|
      content_type :json
      category = Hummercatch::Category.find(id)
      foodz = category.food.collect(&:as_json)
      {:name => category.name, :food => foodz}.to_json
    end

    get '/ingredients' do
      content_type :json
      Hummercatch::Ingredient.all.inject({}) {|r, o| r[o.id] = o.name; r}.to_json
    end

    get '/ingredients/:id' do |id|
      content_type :json
      ingredient = Hummercatch::Ingredient.find(id)
      foodz = ingredient.food.collect(&:as_json)
      {:name => ingredient.name, :food => foodz}.to_json
    end

    get '/food' do
      content_type :json
      foodz = Hummercatch::Food.all.collect(&:as_json)
      foodz.to_json
    end
  end
end
