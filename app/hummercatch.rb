module Hummercatch

  # The base exception class raised when errors are encountered.
  class Error < StandardError; end

  def self.config
    OpenStruct.new \
    :campfire_account => (ENV["campfire_account"] || yaml['campfire_account']),
    :campfire_token   => (ENV["campfire_token"] || yaml['campfire_token']),
    :campfire_room    => (ENV["campfire_room"] || yaml['campfire_room']),
    :redis_uri        => (ENV["REDISTOGO_URL"] || "redis://127.0.0.1"),
    :secret           => (ENV["GH_SECRET"] || yaml['gh_secret']),
    :client_id        => (ENV["GH_KEY"] || yaml['gh_key']),
    :gh_org           => (ENV["GH_ORG"] || yaml['gh_org'])
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
