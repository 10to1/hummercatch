require File.expand_path(File.dirname(__FILE__) + '/app/boot')
map('/')         { run Hummercatch::App }
map('/hubot')    { run Hummercatch::Hubot}
