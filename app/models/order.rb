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
      @food_id       = options[:food_id]
      @metadata   = options[:metadata]
      @for        = options[:for]
      @by         = options[:by]
      @quantity   = options[:quantity]
      @ordered_at = options[:ordered_at]
    end

    def garnish?
      !!@garnish
    end

    def self.orders_from_freeform(by, string)
      string = string.downcase
      orders = []
      combination.each do |s|
        next unless string.index(" #{s} ")
        string.split(s).each do |s|
          orders << orders_from_freeform(by, s)
        end
      end

      return orders unless orders.empty?

      order = new(by: by)
      # Find a food item
      if food = Food.found_in_string(string)
        order.food_id = food.id
        string = string.gsub(food.name.downcase, "")
      end

      # Extract sauce
      if sauce = self.sauces.detect{|s| string =~ /#{s}/i}
        order.sauce = sauce
        string = string.gsub(/#{sauce}/i, "")
      end

      # Extract bread type
      if bread_type = self.bread_types.detect{|s| string =~ /#{s}/i}
        order.bread_type = bread_type
        string = string.gsub(/#{bread_type}/, "")
      end

      # Extract size
      self.sizes.each do |k, values|
        if size = values.detect{|v| string =~ /#{v}/}
          order.size = k
          string = string.gsub(/#{size}/, "")
          break
        end
      end

      # Extract garnish
      if garnish = self.garnishes.detect{|s| string =~ /#{s}/i}
        order.garnish = true
        string = string.gsub(/#{garnish}/, "")
      end
      [order]
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
