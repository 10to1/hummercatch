module Hummercatch
  class Parser

    def parse(text)
      token_array = tokenize(text)
      token_array.each do |tokens|
        if index = tokens.find_index {|t| t.tags.collect(&:type).include?:preposition}
          unless tokens[index+1].tags.collect(&:type).include?(:sauce)
            metadata = tokens.slice!(index..-1).collect(&:word)
          end
        end
        food = extract_most_likely_matched_food(tokens)
        if tokens.collect(&:tags).flatten.any? {|t| t.salad?}
          food = extract_most_likely_matched_food(tokens)
          puts "een salade #{food}"
        else
          parts = {}
          parts[:size] = extract_type_from_tokens(:size, tokens)
          parts[:garnish] = extract_type_from_tokens(:garnish, tokens)
          parts[:bread_type] = extract_type_from_tokens(:bread_type, tokens)
          parts[:food] = food
          parts[:sauce] = extract_type_from_tokens(:sauce, tokens)
          parts[:metadata] =  metadata.join(" ") if metadata
          parts.delete_if{|k,v| v.nil?}
          puts parts
        end
      end
      true
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

    def extract_most_likely_matched_food(tokens)
      food_tokens = tokens.select{|t| t.tags.collect(&:type).include? :food}
      tags = tokens.collect(&:tags).flatten
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
      text.gsub!(/sa(m|n)dwh?ich/, "sandwich")
      text.gsub!(/kippen?wit/, "kippenwit")
      text
    end
  end
end
