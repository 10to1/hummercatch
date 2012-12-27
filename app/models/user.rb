module Hummercatch
  # redis:
  #
  #   catch:users                - A Set of all user IDs.
  #   catch:users:#{login}:email - The String email for the given `login`.
  #   catch:users:#{login}:token - The String token for the given `login`.
  #   catch:users:#{token}:login - The String login for the given `token`.
  class User
    # The redis key to stash User data.
    KEY = 'catch:users'

    # The username of the user's GitHub account.
    attr_accessor :login

    # Email address listed on GitHub.
    attr_accessor :email

    # Token used to auth with Hummercatch from a client
    attr_accessor :token

    # Initializes a user
    #
    # login - The String login of their GitHub account.
    # email - The String email address of their GitHub account.
    # token - The String used to auth with Hummercatch from a client.
    #
    # Returns the User.
    def initialize(login,email,token=nil)
      @login = login.downcase
      @email = email
      @token = token
    end

    # Creates a User.
    #
    # login - The String login of their GitHub account.
    # email - The String email address of their GitHub account.
    #
    # Returns the User.
    def self.create(login,email)
      User.new(login,email).save
    end

    # Returns all users
    def self.all
      logins = $redis.smembers KEY
      logins.map{|login| find(login)}
    end


    # Finds a User.
    #
    # login - The String login.
    #
    # Returns the User, nil if no User found.
    def self.find(login)
      login.downcase!
      return nil if !$redis.sismember(KEY, login)
      email = $redis.get "#{KEY}:#{login}:email"
      token = $redis.get "#{KEY}:#{login}:token"

      User.new(login,email,token)
    end

    # Finds a User by token.
    #
    # token - The String auth token.
    #
    # Returns the User, nil if no User found.
    def self.find_by_token(token)
      return nil if !login = $redis.get("#{KEY}:#{token}:login")
      self.find(login)
    end

    # Public: Saves the User.
    #
    # Returns itself.
    def save
      $redis.sadd KEY, login
      save_email
      save_token
      self
    end

    # Public: Saves the email.
    #
    # Returns bool.
    def save_email
      $redis.set  "#{KEY}:#{login}:email", email
    end

    # Public: Saves the token.
    #
    # Returns bool.
    def save_token
      self.token ||= Digest::MD5.hexdigest(login + Time.now.to_i.to_s)[0..5]
      $redis.set  "#{KEY}:#{login}:token", token
      $redis.set  "#{KEY}:#{token}:login", login
    end

    # Public: The MD5 hash of the user's email account. Used for showing their
    # Gravatar.
    #
    # Returns the String MD5 hash.
    def gravatar_id
      Digest::MD5.hexdigest(email) if email
    end

    def orders
      orders = $redis.lrange("#{KEY}:#{login}:orders", 0, -1)
      orders.collect{|id| Order.find(id)}
    end

    def order!(food)
      $redis.rpush("#{KEY}:#{login}:orders", food.id)
      true
    end

    def delete_last_order!
      $redis.rpop("#{KEY}:#{login}:orders")
      true
    end

  end

end
