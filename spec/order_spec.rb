require "helper"

describe Order do

  {
    "grote smos mexicano met samurai" => {
      :food_id => "1b52f6",
      :sauce => "samurai",
      :size => :large,
      :garnish => true},
    "midden smos fitness oude kaas" => {
      :food_id => "8c0589",
      :sauce => nil,
      :size => :middle,
      :garnish => true,
      :bread_type => nil},
    "midden dalton" => {
      :food_id => "83fa8a",
      :sauce => nil,
      :size => :middle,
      :garnish => nil,
      :bread_type => nil},
    "midden fitness pollo" => {
      :food_id => "47756c",
      :sauce => nil,
      :size => :middle,
      :garnish => nil,
      :bread_type => :fitness}
  }.each do |string, value_hash|

    it "should understand #{string}" do
      assert_equal value_hash, Parser.new.parse(string).first
    end
  end
end
