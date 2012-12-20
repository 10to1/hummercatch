module Hummercatch
  # redis:
  #
  #   catch:food:#{id}:ingredients - A list with the ids of its ingredients
  #   catch:food:ingredients - A list of ingredient ids
  #   catch:food:ingredient:#{id}:name
  #   catch:food:ingredient:#{id}:food - A list of foods with this ingredient

  class Ingredient
    KEY = 'catch:food'

    attr_accessor :id, :name

    def initialize(name)
      @name = name.strip
      @id = self.class.uniq_id_with_name(name)
    end

    def self.all
      $redis.smembers("#{KEY}:ingredients").collect do |id|
        find(id)
      end
    end

    def self.find(id)
      new($redis.get("#{KEY}:ingredient:#{id}:name"))
    end

    def self.uniq_id_with_name(name)
      Digest::MD5.hexdigest(name)[0..5]
    end

    def food_ids
      $redis.smembers("#{KEY}:ingredient:#{id}:food")
    end

    def food
      food_ids.collect {|id| Food.find(id)}
    end

    def save
      $redis.sadd("#{KEY}:ingredients", id)
      $redis.set("#{KEY}:ingredient:#{id}:name", name)
    end

    def as_json
      {id: id, name: name}
    end
  end
end
