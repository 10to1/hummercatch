module Hummercatch
  class Parser

    def parse(text)
      tokens = tokenize(text)
    end

    def tokenize(text)
      text = normalize(text)
      tokens = text.split(' ').collect { |word| Token.new(word)}
      Tag.scan(tokens, {})
      tokens
    end

    def normalize(text)
      text = text.downcase.strip
      text.gsub!(/\bsamo?urai\b/, 'samurai')
      text.gsub!(/\bslaatje\b/, "salade")
      text.gsub!(/\hawaii?\b/, "hawai")
      text
    end
  end
end
