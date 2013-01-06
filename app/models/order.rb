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
      @sauce      = options[:sauce]
      @bread_type = options[:bread_type]
      @food_id    = options[:food_id]
      @metadata   = options[:metadata]
      @for        = options[:for]
      @by         = options[:by]
      @quantity   = options[:quantity]
      @ordered_at = options[:ordered_at]
    end

    def to_hubot
      parts = []
      parts << @size if @size
      parts << @bread_type if @bread_type
      parts << Food.find(@food_id).name if @food_id
      parts << "met #{@sauce}" if @sauce
      parts << @metadata if @metadata
      parts.join(" ")
    end

    def garnish?
      !!@garnish
    end

    def save
      raise Error, ":by is required" unless options[:by]
      unless options[:food] || options[:metadata]
        raise Error, "Either :food or :metadata is required"
      end
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
  end
end
