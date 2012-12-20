module Hummercatch

  def self.config
    OpenStruct.new \
    :campfire_account => (ENV["campfire_account"] || yaml['campfire_account']),
    :campfire_token => (ENV["campfire_token"] || yaml['campfire_token']),
    :redis_uri => (ENV["REDISTOGO_URL"] || "redis://127.0.0.1")
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
