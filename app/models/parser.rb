module Hummercatch
  class Parser

    def parse(text)
      raise "Geen text" unless text
      token_array = tokenize(text)
      orders = token_array.inject([]) do |orders, tokens|
        parts = {}
        metadata = extract_metadata(tokens)
        if tokens.collect(&:tags).flatten.any? {|t| t.salad?}
          food = extract_most_likely_matched_food(tokens, true)
          parts[:food_id] = food.id
          parts[:metadata] =  metadata.join(" ") if metadata
        else
          food = extract_most_likely_matched_food(tokens)
          parts[:size] = extract_type_from_tokens(:size, tokens)
          parts[:garnish] = extract_type_from_tokens(:garnish, tokens)
          parts[:bread_type] = extract_type_from_tokens(:bread_type, tokens)
          parts[:food_id] = food.id
          parts[:sauce] = extract_type_from_tokens(:sauce, tokens)
          parts[:metadata] =  metadata.join(" ") if metadata
        end
        parts = parts.reject{|k,v| v.nil?}
        orders << parts
      end
      orders
    end

    def find_tag_with_type(token_array, type)
      token_array.find_index do |token|
        token.tags.collect(&:type).include? type
      end
    end

    def contains_tag_with_type?(token_array, type)
      !!find_tag_with_type(token_array, type)
    end

    def extract_metadata(tokens)
      metadata = []
      if index = find_tag_with_type(tokens, :preposition)
        if next_index = find_tag_with_type(tokens[index+1..-1], :preposition)
          metadata << d = extract_metadata(tokens[(index + 1 + next_index)..-1])
          tokens = tokens[0..(index + next_index)]
        end
        next_token_tags = tokens[index+1].tags.collect(&:type)
        unless next_token_tags.include?(:sauce) || next_token_tags.include?(:food)
          metadata << d = tokens.slice(index..-1).collect(&:word)
          puts "outer : #{d}"
        end

      end
      data = metadata.reverse.flatten
      data.empty? ? nil : data
    end

    def extract_type_from_tokens(type, tokens)
      if tag = tokens.collect(&:tags).flatten.detect{|t| t.type == type}
        tag.value
      end
    end

    def distance a, b, opts={}
      ignore_case = opts[:ignore_case]
      distance = 0
      as, bs = a.to_s, b.to_s

      if ignore_case
        as.downcase!
        bs.downcase!
      end

      short, long = [as, bs].sort

      long.chars.zip(short.chars).each {|ac, bc| distance += 1 if ac != bc }

      distance
    end

    def extract_most_likely_matched_food(tokens, salad = false)
      food_tokens = tokens.select{|t| t.tags.collect(&:type).include? :food}
      tags = tokens.collect(&:tags).flatten.reject{|t| t.type != :food}
      if salad
        tags = tags.select{|t| t.value.category.name == "SALADES"}
      end
      if ordered_tags = tags.group_by{|t| t.value.name}.group_by{|k,v| v.count}
        most_occurring_tags = ordered_tags.fetch(ordered_tags.keys.max)
        if most_occurring_tags.count == 1
          most_occurring_tags.first.last.last.value
        else
          best_match = [100, nil, nil]
          food_tokens.each do |token|
            token.tags.each do |t|
              next unless t.type == :food

              if best_match.first > distance(token.word, t.value.name)
                best_match[0] = distance(token.word, t.value.name)
                best_match[1] = token
                best_match[2] = t
              end
            end
          end
          best_match.last.value
        end
      end
    end

    def tokenize(text)
      text = normalize(text)
      text.split("en een").inject([]) do |orders, string|
        tokens = string.split(' ').collect { |word| Token.new(word)}
        Tag.scan(tokens, {})
        orders << tokens
        orders
      end
    end

    def normalize(text)
      text = text.downcase.strip
      text.gsub!(/\bsamo?urai\b/, 'samurai')
      text.gsub!(/\ben ne\b/, 'en een')
      text.gsub!(/(en|\+) (een|ne)/, 'en een')
      text.gsub!("+ curryrol", 'en een curryrol')
      text.gsub!(/\bslaatje\b/, "salade")
      text.gsub!(/\hawaii?\b/, "hawai")
      text.gsub!("heps", "heps")
      text.gsub!(/\bkip curry\b/, "kipcurry")
      text.gsub!(/sa(m|n)dwh?ich/, "sandwich")
      text.gsub!(/kippen?wit/, "kippenwit")
      text
    end
  end
end
