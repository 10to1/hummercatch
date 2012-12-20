module Hummercatch
  # redis:
  #
  #   catch:food - A list of all Food ids
  #   catch:food:#{id}:name - A string with the name of the food
  #   catch:food:#{id}:categories - A list with the ids of its categories
  #   catch:food:#{id}:ingredients - A list with the ids of its ingredients
  #   catch:food:categories - A list of all category ids
  #   catch:food:category:#{id}:name - A string withy the category name
  #   catch:food:category:#{id}:food - A list with all food ids for this categories
  #   catch:food:ingredients - A list of ingredient ids
  #   catch:food:ingredient:#{id}:name
  #   catch:food:ingredient:#{id}:food - A list of foods with this ingredient

  class Food
    KEY = 'catch:food'

    # Name of the food item
    attr_accessor :name

    # Uniq id of the food item
    attr_accessor :id

    # String with the name of its category
    attr_accessor :category

    # String with comma seprated ingredient names
    attr_accessor :ingredients

    # Initializes a new food item
    #
    # name - Name of the food
    # category - Name of the category
    # ingredients - Comma seperated string of ingredients (optional)
    #
    # Returns a food item
    def initialize(name, category = nil, ingredients = nil)
      @name = name
      @id = Food.uniq_id_with_name(name)
      @r_category = category
      @r_ingredients = ingredients if ingredients
    end

    def create(name, category, ingredients = nil)
      self.class.new(name, category, ingredients).save
    end

    def ingredients
      return @r_ingredients if @r_ingredients

      @r_ingredients = $redis.smembers("#{KEY}:#{id}:ingredients").collect do |id|
        {id: id, name: $redis.get("#{KEY}:ingredient:#{id}:name")}
      end.collect{|a| a[:name]}.join(",")
    end

    def self.all_ingredients
      $redis.smembers("#{KEY}:ingredients").collect do |id|
        {id: id, name: $redis.get("#{KEY}:ingredient:#{id}:name")}
      end
    end

    def category
      return @r_category if @r_category

      puts "#{KEY}:#{id}:categories"
      @r_category = $redis.smembers("#{KEY}:#{id}:categories").collect do |id|
        puts "#{KEY}:category:#{id}:name"
        {id: id, name: $redis.get("#{KEY}:category:#{id}:name")}
      end.collect{|a| a[:name]}.first
    end

    def self.all_ids
      $redis.smembers(KEY)
    end

    def self.all
      all_ids.collect do |id|
        name = $redis.get("#{KEY}:#{id}:name")
        new(name)
      end
    end

    def self.all_categories
      $redis.smembers("#{KEY}:categories").collect do |id|
        {id: id, name: $redis.get("#{KEY}:category:#{id}:name")}
      end
    end

    def self.all_ingredients
      $redis.smembers("#{KEY}:ingredients").collect do |id|
        {id: id, name: $redis.get("#{KEY}:ingredient:#{id}:name")}
      end
    end

    def save
      # Food
      $redis.sadd(KEY, id)
      $redis.set("#{KEY}:#{id}:name", name)


      # Category
      category_id = Food.uniq_id_with_name(@r_category)
      $redis.sadd("#{KEY}:categories", category_id)
      $redis.set("#{KEY}:category:#{category_id}:name", @r_category)
      $redis.sadd("#{KEY}:category:#{category_id}:food", id)
      puts "$redis.sadd(#{KEY}:#{id}:categories), #{category_id})"
      $redis.sadd("#{KEY}:#{id}:categories", category_id)

     # Ingredient
      (@r_ingredients || "").split(",").collect(&:strip).each do |ingredient|
        ingredient_id = Food.uniq_id_with_name(ingredient)
        $redis.sadd("#{KEY}:ingredients", ingredient_id)
        $redis.set("#{KEY}:ingredient:#{ingredient_id}:name", ingredient)
        $redis.sadd("#{KEY}:ingredient:#{ingredient_id}:food", id)
        $redis.sadd("#{KEY}:#{id}:ingredients", ingredient_id)
      end
    end

    def self.uniq_id_with_name(name)
      Digest::MD5.hexdigest(name)[0..5]
    end

    def to_json
      if ingredients
        {id: id, name: name, category: category, ingredients: ingredients}
      else
        {id: id, name: name, category: category, ingredients: []}
      end
    end
  end
end
