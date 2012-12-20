require "json"

module Hummercatch
  # redis:
  #
  #   catch:food:#{id}:name - A string with the name of the food
  #   catch:food - A list of all Food ids
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
    def initialize(name, category, ingredients = nil)
      @name = name
      @id = Food.uniq_id_with_name(name)
      @category = category
      @ingredients = ingredients if ingredients
    end

    def create(name, category, ingredients = nil)
      self.class.new(name, category, ingredients).save
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
      $redis.set("#{KEY}:food:#{id}:name", name)

      # Category
      category_id = Food.uniq_id_with_name(category)
      $redis.sadd("#{KEY}:categories", category_id)
      $redis.set("#{KEY}:category:#{category_id}:name", category)
      $redis.sadd("#{KEY}:category:#{category_id}:food", id)

     # Ingredient
      (ingredients || "").split(",").collect(&:strip).each do |ingredient|
        ingredient_id = Food.uniq_id_with_name(ingredient)
        $redis.sadd("#{KEY}:ingredients", ingredient_id)
        $redis.set("#{KEY}:ingredient:#{ingredient_id}:name", ingredient)
        $redis.sadd("#{KEY}:ingredient:#{ingredient_id}:food", id)
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
