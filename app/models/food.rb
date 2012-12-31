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

    # A category object
    attr_accessor :category

    # An array of ingredients
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
      @r_category = Category.new(category) if category
      @r_ingredients = ingredients.split(",").collect{|i| Ingredient.new(i)} if ingredients
    end

    def create(name, category, ingredients = nil)
      self.class.new(name, category, ingredients).save
    end

    # Returns the name of the food, will always try to pretty print it.
    #
    # E.g. PINK PANTER => Pink Panter
    #
    # Returns a String
    def name
      @name.split(" ").collect(&:downcase).collect(&:capitalize).join(" ")
    end

    def ingredients
      return @r_ingredients if @r_ingredients

      @r_ingredients = $redis.smembers("#{KEY}:#{id}:ingredients").collect do |id|
        OpenStruct.new(id: id, name: $redis.get("#{KEY}:ingredient:#{id}:name"))
      end
    end

    def self.all_ingredients
      $redis.smembers("#{KEY}:ingredients").collect do |id|
        Ingredient.new($redis.get("#{KEY}:ingredient:#{id}:name"))
      end
    end

    def category
      return @r_category if @r_category

      @r_category = $redis.smembers("#{KEY}:#{id}:categories").collect do |id|
        Category.new($redis.get("#{KEY}:category:#{id}:name"))
      end.first
    end

    def self.all_ids
      $redis.smembers(KEY)
    end

    def self.find(id)
      name = $redis.get("#{KEY}:#{id}:name")
      new(name)
    end

    def self.find_by_name(name)
      all.detect do |f|
        f.name.downcase =~ /#{name}/i
      end
    end

    def self.found_in_string(string)
      all.detect do |f|
        string =~ /#{f.name}/i
      end
    end

    def self.all
      all_ids.collect do |id|
        find(id)
      end
    end

    def save
      # Food
      $redis.sadd(KEY, id)
      $redis.set("#{KEY}:#{id}:name", name)


      # Category
      @r_category.save
      category_id = @r_category.id
      $redis.sadd("#{KEY}:category:#{category_id}:food", id)
      $redis.sadd("#{KEY}:#{id}:categories", category_id)

     # Ingredient
      (@r_ingredients || []).each do |ingredient|
        ingredient.save
        ingredient_id = ingredient.id
        $redis.sadd("#{KEY}:ingredient:#{ingredient_id}:food", id)
        $redis.sadd("#{KEY}:#{id}:ingredients", ingredient_id)
      end
    end

    def self.uniq_id_with_name(name)
      Digest::MD5.hexdigest(name)[0..5]
    end

    def as_json
      if ingredients
        {id: id, name: name, category: {category.id => category.name}, ingredients: ingredients.collect{|i| {i.id => i.name}}}
      else
        {id: id, name: name, category: {category.id => category.name}, ingredients: []}
      end
    end
  end
end
