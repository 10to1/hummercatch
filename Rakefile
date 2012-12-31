#!/usr/bin/env rake

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/app')

require 'boot'

task :default do
  ENV['RACK_ENV'] = 'test'
  Rake::Task['test'].invoke
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'specs'
  test.pattern = 'specs/**/*_spec.rb'
  test.verbose = false
end

desc "Open an pry session with Yesplan loaded"
task :console do
  sh "pry -r ./app/boot"
end
