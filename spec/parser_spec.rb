require "helper"

describe Parser do

  describe "normalizing text" do
    it "should transfrom + een to en een" do
      assert_equal "eiersla en een curryrol", Parser.new.normalize("eiersla + een curryrol")
    end

    it "should transfrom en ne to en een" do
      assert_equal "eiersla en een curryrol", Parser.new.normalize("eiersla en ne curryrol")
    end

    it "should treat curryrol specially" do
      assert_equal "eiersla en een curryrol", Parser.new.normalize("eiersla + curryrol")
    end
  end

  def fake_food(name)
    OpenStruct.new(:name => name)
  end

  describe "finding the correct food from tokens" do

    it "should extract the food with the most occurrences" do
      one = Token.new("one")
      one.tags = [Tag.new(:food, fake_food("1")), Tag.new(:food, fake_food("2"))]
      two = Token.new("two")
      two.tags = [Tag.new(:food, fake_food("1"))]
      assert_equal "1", Parser.new.extract_most_likely_matched_food([one, two]).name
    end

    it "should find the food with the best match in case of a tie" do
      one = Token.new("hesp")
      one.tags = [Tag.new(:food, fake_food("hesp")), Tag.new(:food, fake_food("hesp + kaas"))]
      assert_equal "hesp", Parser.new.extract_most_likely_matched_food([one]).name
    end

  end

  describe "fetching metadata" do
    it "should set metadata as the string after a preposition" do
      string = "klein broodje hesp zonder boter"
      Parser.new.parse(string).first[:metadata].must_equal "zonder boter"
    end

    it "shouldn't set metadata if not found" do
      string = "klein broodje hesp"
      Parser.new.parse(string).first[:metadata].must_be_nil
    end

    it "should not set preposition + sauce as metadata" do
      string = "klein broodje hesp met samurai"
      Parser.new.parse(string).first[:metadata].must_be_nil
    end

    it "should not set preposition + food as metadata" do
      string = "klein broodje hesp met kaas"
      Parser.new.parse(string).first[:metadata].must_be_nil
    end

    it "should set preposition + food + preposition as metada" do
      string = "klein broodje hesp met kaas zonder augurken"
      Parser.new.parse(string).first[:metadata].must_equal "zonder augurken"
    end

    it "should set handle preposition thingie and preposition thingie" do
      string = "klein broodje hesp zonder augurken en zonder pickles"
      Parser.new.parse(string).first[:metadata].must_equal "zonder augurken en zonder pickles"
    end
  end

  describe "tokenizing" do

    describe "parsing 'samdwich met oude kaas en tomaat en een sandwich met hesp'" do
      before do
        string = "samdwich met oude kaas en tomaat en een sandwich met hesp"
        @token_array = Parser.new.tokenize(string)
      end

      it "should detect sandwhich as a size" do
        assert_equal @token_array.first.first.tags.first.type, :size
        assert_equal @token_array.first.first.tags.first.value, :sandwich
      end

      it "should detect it as a double order" do
        assert_equal 2, @token_array.count
      end
    end


    it "should extract sandwhich as a size" do

    end

  end
end
