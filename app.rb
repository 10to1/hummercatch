# -*- coding: utf-8 -*-
require "rubygems"
require 'sinatra'

class App

  before do
  end

  configure do
  end

  get '/' do
    erb :index
  end
end
