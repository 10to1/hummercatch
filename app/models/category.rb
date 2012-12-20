module Hummercatch
  # redis:
  #
  #   catch:food:categorys - A list of category ids
  #   catch:food:category:#{id}:name
  #   catch:food:category:#{id}:food - A list of foods with this category

  class Category
    KEY = 'catch:food'

    attr_accessor :id, :name

    def initialize(name)
      @name = name
      @id = self.class.uniq_id_with_name(name)
    end

    def self.all
      $redis.smembers("#{KEY}:categories").collect do |id|
        find(id)
      end
    end

    def self.find(id)
      new($redis.get("#{KEY}:category:#{id}:name"))
    end

    def self.uniq_id_with_name(name)
      Digest::MD5.hexdigest(name)[0..5]
    end

    def food_ids
      $redis.smembers("#{KEY}:category:#{id}:food")
    end

    def food
      food_ids.collect {|id| Food.find(id)}
    end

    def save
      $redis.sadd("#{KEY}:categories", id)
      $redis.set("#{KEY}:category:#{id}:name", name)
    end

    def as_json
      {id: id, name: name}
    end
  end
end
