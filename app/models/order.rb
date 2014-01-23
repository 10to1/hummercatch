module Hummercatch

  class Order
    KEY = 'catch:orders'

    # Persistent ID
    attr_accessor :id

    # Small, middle or large
    attr_accessor :size

    # String containing the sauce
    attr_accessor :sauce

    # ID reference to a Food instance
    attr_accessor :food_id

    # Bool if food is with garnish or not.
    attr_accessor :garnish

    # Kind of bread
    # :fitness or :regular
    attr_accessor :bread_type

    # A string value with a name
    #
    # e.g. a sandwhich for Bob
    attr_accessor :for

    attr_accessor :metadata
    attr_accessor :by
    attr_accessor :quantity
    attr_accessor :ordered_at

    def initialize(options)
      options = self.class.sensible_defaults.merge(options)
      @id         = options[:id]
      @size       = options[:size]
      @garnish    = options[:garnish]
      @sauce      = options[:sauce]
      @bread_type = options[:bread_type]
      @food_id    = options[:food_id]
      @metadata   = options[:metadata]
      @for        = options[:for]
      @by         = options[:by]
      @quantity   = options[:quantity]
      @ordered_at = options[:ordered_at]
    end

    def self.orders_from_string(string)
      Parser.new.parse(string).collect do |hash|
        Order.new(hash)
      end
    end

    def to_hubot
      parts = []
      parts << translate(@size) if @size
      parts << translate(@bread_type) if @bread_type
      parts << translate(:garnish) if @garnish
      parts << Food.find(@food_id).name.downcase if @food_id
      parts << "met #{@sauce}" if @sauce
      parts << @metadata if @metadata
      parts.join(" ")
    end

    def translate(symbol)
      translations.fetch(symbol, symbol.to_s)
    end

    def translations
      {
        large: "grote", small: "kleine", middle: "midden",
        garnish: "smos",
        salad: "salade"
      }
    end

    def self.find(login, date = Time.now)
      h = $redis.hgetall("#{KEY}:#{date.strftime("%Y%m%d")}:#{login.downcase}")
      return nil if h.empty?
      h = h.each_with_object({}){|(k,v), h| h[k.to_sym] = v}
      Order.new(h)
    end

    def garnish?
      !!@garnish
    end

    def to_hash
      %w(id size garnish sauce bread_type food_id metadata for by quantity ordered_at).inject({}) do |result, key|
        value = instance_variable_get("@#{key}")
        result[key] = value if value
        result
      end
    end

    def save
      raise Error, ":by is required" unless @by
      unless @food_id || @metadata
        raise Error, "Either :food or :metadata is required"
      end
      date = Time.now.strftime("%Y%m%d")
      $redis.hmset("#{KEY}:#{date}:#{@by}",to_hash.inject([]){|r,k| r << k; r}.flatten)
    end

    def self.combination
      %w(en +)
    end

    def self.sauces
      %w(andalouse samurai samourai cocktailsaus)
    end

    def self.bread_types
      [:fitness]
    end

    def self.garnishes
      %w(smos)
    end

    def self.sizes
      {
        small: %w(klein kleine small),
        middle: %w(middel midden normaal middle),
        large: %w(groot grote large)
      }
    end

    def self.sensible_defaults
      {:quantity => 1,
        :ordered_at => Time.now}
    end

    def self.all_ids
      $redis.smembers(KEY)
    end
  end
end
