module Hummercatch
  class Tag

    attr_accessor :type
    attr_accessor :value

    # type - The Symbol type of this tag.
    def initialize(type, value)
      @type = type
      @value = value
    end

    def salad?
      return false unless type == :salad
      !!value
    end

    def to_s
      if value.respond_to?(:name)
        "#{type} -> #{value.name}"
      else
        "#{type} -> #{value}"
      end
    end

    def self.scan(tokens, options)
      tokens.each do |token|
        if t = scan_for_sauces(token) then token.tag(t); next end
        if t = scan_for_sizes(token) then token.tag(t); next end
        if t = scan_for_bread_types(token) then token.tag(t); next end
        if t = scan_for_garnish(token) then token.tag(t); next end
        if t = scan_for_salad(token) then token.tag(t); next end
        if t = scan_for_prepositions(token) then token.tag(t); next end
        scan_for_food_items(token)
      end
    end

    def self.food_items
      @food_items ||= Food.all.inject([]) do |result, food|
        parts = food.name.downcase.split(" ").uniq.reject do |p|
          %w(+ - met en cl broodje).include?(p) || p.length < 2
        end
        result << parts.inject({}) do |result, part|
          result[/\b#{part}\b/] = food
          result
        end
        result
      end
    end

    def self.scan_for_food_items(token)
      food_items.each do |hash|
        if t = scan_for(token, :food, hash)
          token.tag(t)
        end
      end
    end

    def self.scan_for_sauces(token)
      scan_for token, :sauce,
      {
        /andalouse/ => :andalouse,
        /samurai/ => :samurai,
        /cocktailsaus/ => :cocktailsaus,
        /mayo/ => :mayonaise,
        /ketchup/ => :ketchup
      }
    end

    def self.scan_for_sizes(token)
      scan_for token, :size,
      {
        /groo?te?/ => :large,
        /large/ => :large,
        /midden?/ => :middle,
        /medium/ => :middle,
        /middle/ => :middle,
        /small/ => :small,
        /kleine?/ => :small,
        /sandwich/ => :sandwich
      }
    end

    def self.scan_for_bread_types(token)
      scan_for token, :bread_type,
      {
        /fitness?/ => :fitness,
        /meergranen?/ => :fitness,
        /bruin/ => :fitness
      }
    end

    def self.scan_for_garnish(token)
      scan_for token, :garnish,
      {
        /smos/ => true,
        /soms/ => true
      }
    end

    def self.scan_for_salad(token)
      scan_for token, :salad,
      {
        /slaatje/ => true,
        /salade?/ => true,
        /konijnevoer/ => true
      }
    end

    def self.scan_for_prepositions(token)
      scan_for token, :preposition,
      {
        /met/ => true,
        /zonder/ => true
      }
    end

    class << self
      private

      def scan_for(token, type, items={})
        items.each do |regex, value|
          return self.new(type, value) if token.word =~ regex
        end
        nil
      end
    end
  end
end
