module Hummercatch

  def self.config
    OpenStruct.new \
    :campfire_account => (ENV["campfire_account"] || yaml['campfire_account']),
    :campfire_token   => (ENV["campfire_token"] || yaml['campfire_token']),
    :campfire_room    => (ENV["campfire_room"] || yaml['campfire_room']),
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
