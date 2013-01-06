module Hummercatch
  # Web API just for Hubot.
  class Hubot < Sinatra::Base

    get "/all_orders_in" do

    end

    get "/no_more_orders" do

    end

    get "/no_order_for_me" do

    end

    post "/order" do
      order_string = params[:order]
      s = Parser.new.parse(order_string).collect do |hash|
        Order.new(hash).to_hubot
      end.join(" en een ")
      " => #{s}"
    end

    get "/food" do
      Category.all.inject([]) do |lines, cat|
        lines << cat.name.upcase
        lines << ""
        cat.food.each do |food|
          lines << "  #{food.name}"
          unless food.ingredients.empty?
            lines << "   -> (#{food.ingredients.collect(&:name).join(",")})"
          end
        end
        lines << ""
        lines
      end.join("\n")
    end

    post "/order_all" do

    end

    get "/help" do
      content_type "text/plain"
      <<-EOS

EOS
    end
  end
end
