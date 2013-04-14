source 'https://rubygems.org'
gem "sinatra"
gem "sinatra-contrib"

gem 'json', '~> 1.7.5'

gem "broach", "~> 0.2.1"
gem "mail", "~> 2.4.4"

# A sinatra extension for easy oauth integration with github
# [sinatra_auth_github](http://github.com/atmos/sinatra_auth_github)
gem 'sinatra_auth_github', '~> 0.12.0'

# [redis](https://github.com/redis/redis-rb)
gem 'redis', '~> 3.0.1'
gem 'rake'

group :development, :test do
  # An IRB alternative and runtime developer console
  # [pry](http://pry.github.com)
  gem 'pry', '~> 0.9.10'

  # Process manager for applications with multiple components
  # [foreman](http://github.com/ddollar/foreman)
  gem 'foreman', '~> 0.60.2'

  # Turn provides a set of alternative runners for MiniTest, both colorfu...
  # [turn](http://rubygems.org/gems/turn)
  gem 'turn', '~> 0.9.6'

  # Using guard to run the tests autmoatically on file change.
  # Just run `guard` in the root of the folder
  #
  # [guard](https://github.com/guard/guard)
  gem 'guard', '~> 1.5.0'
end

group :test do
  # Adding rake for Travis.
  gem 'rake'

  # [rack-test](http://github.com/brynary/rack-test)
  gem 'rack-test', '~> 0.6.2'

  # minitest provides a complete suite of testing facilities...
  # [minitest](https://github.com/seattlerb/minitest)
  gem 'minitest'

  # Adds color to your MiniTest output
  gem "minitest-rg", "~> 1.0.0"

  # [mocha](http://gofreerange.com/mocha/docs)
  gem 'mocha', '~> 0.13.0'

  gem 'guard-minitest'
end

# Workaround for Heroku:
# [More info](http://www.johnplummer.com/rails/heroku-error-conditional-rbfsevent-gem.html)
group :test, :darwin do
  # OS X
  gem 'terminal-notifier-guard'
  gem 'rb-fsevent', :require => false
end
