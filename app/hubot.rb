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
(applause|applaud|bravo|slow clap) - Get applause
<bit.ly link> - returns info about the link (title, created_by)
<spotify link> - returns info about the link (track, artist, etc.)
alot - Shows a picture of an alot
beer me - returns the latest beer discussed on beer advocate with picture
card 2 - Displays two answers for questions with two blanks
card me - Displays an answer
check domain <domainname> - returns whether a domain is available
cue <person_name>
dance - Display a dancing Carlton
deal with it - display a "deal with it" gif
generate meme <type> with <line1>, <line2> - generates a meme with the specified type. You can add up to two lines of text, seperated by a comma.
good night
haters - Returns a random haters gonna hate url
http://replygif.net/<id> - Embeds image from ReplyGif with that id.
hubot <anything related to size, speed, quality, specific body parts> - Hubot will "that's what she said" that ish
hubot <text> (SUCCESS|NAILED IT) - Generates success kid with the top caption of <text>
hubot <text> ALL the <things>    - Generates ALL THE THINGS
hubot <text> TOO DAMN <high> - Generates THE RENT IS TOO DAMN HIGH guy
hubot <text>, BITCH PLEASE <text> - Generates Yao Ming
hubot <text>, COURAGE <text> - Generates Courage Wolf
hubot <user> is a badass guitarist - assign a role to a user
hubot <user> is not a badass guitarist - remove a role from a user
hubot ALL YOUR <text> ARE BELONG TO US - Generates Zero Wing with the caption of <text>
hubot I don't always <something> but when i do <text> - Generates The Most Interesting man in the World
hubot IF YOU <text> GONNA HAVE A BAD TIME - Ski Instructor
hubot IF YOU <text> TROLLFACE <text> - Troll Face
hubot If <text>, <word that can start a question> <text>? - Generates Philosoraptor
hubot Not sure if <text> or <text> - Generates Futurama Fry
hubot ONE DOES NOT SIMPLY <text> - Generates Boromir
hubot Y U NO <text> - Generates the Y U NO GUY with the bottom caption of <text>
hubot Yo dawg <text> so <text> - Generates Yo Dawg
hubot achievement get <achievement> [achiever's gravatar email] - life goals are in reach
hubot animate me <query> - The same thing as `image me`, except adds a few parameters to try to return an animated GIF instead.
hubot ascii me <text> - Show text in ascii art
hubot bestel alle broodjes - Stuurt een fax naar A La Minute
hubot bestel een <broodje> - Bestel ene broodje voor vandaag
hubot broodjes - Toont een lijst van bestelde broodjes
hubot chuck norris -- random Chuck Norris awesomeness
hubot chuck norris me <user> -- let's see how <user> would do as Chuck Norris
hubot ci - show usage
hubot convert me <expression> to <units> - Convert expression to given units.
hubot die - End hubot process
hubot echo <text> - Reply back with <text>
hubot eightball <query> - Ask the magic eight ball a question
hubot forget me - de-map your user to your github login
hubot geen broodje meer voor (iemand) - No longer show person in "iedereen besteld" list
hubot geen broodjes - Verdwijdert alle broodjes voor vandaag
hubot help - Displays all of the help commands that Hubot knows about.
hubot help <query> - Displays all help commands that match <query>.
hubot i am `maddox` - map your user to the github login `maddox`
hubot iedereen besteld - Check om te zien of iedereen besteld heeft
hubot image me <query> - The Original. Queries Google Images for <query> and returns a random top result.
hubot is it christmas ?  - returns whether is it christmas or not
hubot is it xmas ?  - returns whether is it christmas or not
hubot lod <name> - gives back the character for the look of disapproval, optionally @name
hubot map me <query> - Returns a map view of the area returned by `query`.
hubot math me <expression> - Calculate the given expression.
hubot mustache me <query> - Searches Google Images for the specified query and mustaches it.
hubot mustache me <url> - Adds a mustache to the specified URL.
hubot ping - Reply with pong
hubot pug bomb N - get N pugs
hubot pug me - Receive a pug
hubot question <question> - Searches Wolfram Alpha for the answer to the question
hubot rands - A nugget of Randsian wisdom is dispensed
hubot rands count - The number of wisdom nuggets is returned
hubot replygif <keyword> - Embeds random ReplyGif with the keyword.
hubot replygif me <keyword> - Same as `hubot replygif <keyword>`.
hubot rotten [me] <movie>
hubot show storage - Display the contents that are persisted in the brain
hubot show users - Display all users that hubot knows about
hubot spell <word> - Hubot will spel out the word in caps.
hubot stallman - Returns a Richard Stallman fact.
hubot the rules - Make sure hubot still knows the rules.
hubot time - Reply with current time
hubot translate me <phrase> - Searches for a translation for the <phrase> and then prints that bad boy out.
hubot translate me from <source> into <target> <phrase> - Translates <phrase> from <source> into <target>. Both <source> and <target> are optional
hubot urban define me <term>  - Searches Urban Dictionary and returns definition
hubot urban example me <term> - Searches Urban Dictionary and returns example
hubot urban me <term>         - Searches Urban Dictionary and returns definition
hubot voor mij geen broodje - Verwijdert je bestelling voor vandaag
hubot wat - Random WAT
hubot welke broodjes - Toon een lijst van alle mogelijke broodjes
hubot what's coming out in theaters?
hubot what's coming out on (dvd|bluray)? - there is not a distinction between dvd and bluray
hubot what's in theaters?
hubot who am i - reveal your mapped github login
hubot who do you know - List all the users with github logins tracked by Hubot
hubot who is <user> - see what roles a user has
hubot wiki me <query> - Searches for <query> on Wikipedia.
hubot xkcd <num> - XKCD comic <num>
hubot xkcd [latest]- The latest XKCD comic
hubot xkcd random - XKCD comic <num>
hubot youtube me <query> - Searches YouTube for the query and returns the video embed link.
q card - Returns a question
scotch me - supply a user with scotch
what memes - gives you a list of all supported meme types.
EOS
    end
  end
end
