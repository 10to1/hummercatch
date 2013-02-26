module Hummercatch

  # The base exception class raised when errors are encountered.
  class Error < StandardError; end

  def self.config
    OpenStruct.new \
    :campfire_account => (ENV["campfire_account"] || yaml['campfire_account']),
    :campfire_token   => (ENV["campfire_token"] || yaml['campfire_token']),
    :campfire_room    => (ENV["campfire_room"] || yaml['campfire_room']),
    :hipchat_token    => (ENV["hipchat_token"] || yaml['hipchat_token']),
    :hipchat_room     => (ENV["hipchat_room"] || yaml['hipchat_room']),
    :hipchat_user     => (ENV["hipchat_user"] || yaml['hipchat_user']),
    :redis_uri        => (ENV["REDISTOGO_URL"] || "redis://127.0.0.1"),
    :secret           => yaml['gh_secret'],
    :client_id        => yaml['gh_key'],
    :gh_org           => yaml['gh_org']
  end

private

  def self.yaml
    if File.exist?('config/catch.yml')
      @yaml ||= YAML.load_file('config/catch.yml')
    else
      {}
    end
  end

end
