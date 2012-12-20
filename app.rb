# -*- coding: utf-8 -*-
require "rubygems"
require 'sinatra'
require "broach"
require "mail"

class App

  before do
    Broach.settings = {
      'account' => "10to1",
      'token' => "dc906dcf93d6277d4b62276441ffd9c55c90b5b2",
      'use_ssl' => true
    }
  end

  configure do
    require 'redis'
    if ENV["REDISTOGO_URL"]
      uri = URI.parse(ENV["REDISTOGO_URL"])
      $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    else
      $redis = Redis.connect(:url => 'redis://127.0.0.1', :thread_safe => true)
    end
  end

  helpers do

    def ordered?
      $redis.sismember(redis_set_name, redis_set_key_for_today)
    end

    def redis_set_name
      "hummercatch:ordered"
    end

    def redis_set_key_for_today
      Date.today.strftime("%Y%m%d")
    end

    def campfire_message(mail)
      puts mail.inspect
      message = mail.subject.split("Re:").first.strip

      if message =~ /Unsuccessful/
        message = "Epic Fail: #{message}"
      end

      if message =~ /^Successful/
        $redis.sadd(redis_set_name, redis_set_key_for_today)
        message = "Great Success: #{message}"
      end

      ":fax: #{message}"
    end

    def speak(message)
      campfire_room.speak(message)
    end

    def campfire_room
      Broach::Room.find_by_name("General")
    end
  end

  post '/mail' do
    return unless params[:message]

    speak campfire_message(Mail.new(params[:message]))
    status 200
  end

  get '/status' do
    content_type :json
    if ordered?
      '{"ordered": true}'
    else
      '{"ordered": false}'
    end
  end

  get '/' do
    erb :home
  end

  get '/categories' do
    categories = [{:id=>"387ff3", :name=>"Kaas en Vlees"},
 {:id=>"e6b7e1", :name=>"Vis"},
 {:id=>"182971", :name=>"Warm"},
 {:id=>"004277", :name=>"Kip"},
 {:id=>"606848", :name=>"Diversen"},
 {:id=>"fac88d", :name=>"Salades"},
 {:id=>"749471", :name=>"Panini's"},
 {:id=>"2dcd68", :name=>"Soepen"},
 {:id=>"9c0db8", :name=>"Dranken"},
 {:id=>"0f41e8", :name=>"Ontbijt"},
 {:id=>"409730", :name=>"specialiteiten"}]
    content_type :json
    categories.to_json
  end

  get '/food' do
    food = [{:id=>"c05550", :name=>"Kaas", :category=>"Kaas en Vlees"},
 {:id=>"ee5d29", :name=>"Hesp", :category=>"Kaas en Vlees"},
 {:id=>"4f4a11", :name=>"Kaas + Hesp", :category=>"Kaas en Vlees"},
 {:id=>"e88261", :name=>"Prepar", :category=>"Kaas en Vlees"},
 {:id=>"a89d7e", :name=>"Martino", :category=>"Kaas en Vlees"},
 {:id=>"185e8d", :name=>"Balletjes in bbqsaus", :category=>"Kaas en Vlees"},
 {:id=>"2f0559", :name=>"Vleesbrood", :category=>"Kaas en Vlees"},
 {:id=>"a73ee3", :name=>"Serranoham", :category=>"Kaas en Vlees"},
 {:id=>"3e3302", :name=>"Gebraad", :category=>"Kaas en Vlees"},
 {:id=>"f18f7a", :name=>"Ham-prei sla", :category=>"Kaas en Vlees"},
 {:id=>"f53515", :name=>"Vleessla", :category=>"Kaas en Vlees"},
 {:id=>"31becf", :name=>"Pitasla", :category=>"Kaas en Vlees"},
 {:id=>"d147c8", :name=>"Pikante pitasla", :category=>"Kaas en Vlees"},
 {:id=>"13ecc0", :name=>"Brie", :category=>"Kaas en Vlees"},
 {:id=>"3ec416", :name=>"Salami", :category=>"Kaas en Vlees"},
 {:id=>"8c0589", :name=>"Oude kaas", :category=>"Kaas en Vlees"},
 {:id=>"ae31dd", :name=>"Mozarella/geitenkaa", :category=>"Kaas en Vlees"},
 {:id=>"5696a2", :name=>"Grijze garnaalsla", :category=>"Vis"},
 {:id=>"251f12", :name=>"Tonijnsla", :category=>"Vis"},
 {:id=>"f23d8c", :name=>"Tonijn pikant", :category=>"Vis"},
 {:id=>"4be299", :name=>"Krabsla", :category=>"Vis"},
 {:id=>"24f608", :name=>"Zalmsla", :category=>"Vis"},
 {:id=>"7c957a", :name=>"Scampi look", :category=>"Vis"},
 {:id=>"645fe2", :name=>"Scampi curry", :category=>"Vis"},
 {:id=>"4ecf8b", :name=>"Gerookte zalm", :category=>"Vis"},
 {:id=>"5eb08e", :name=>"Gerookte heilbot", :category=>"Vis"},
 {:id=>"10eb37", :name=>"Gerookte forel", :category=>"Vis"},
 {:id=>"fb780a", :name=>"Noordzeesla", :category=>"Vis"},
 {:id=>"7aa99f", :name=>"Hamburger", :category=>"Warm"},
 {:id=>"7ea624", :name=>"Cheeseburger", :category=>"Warm"},
 {:id=>"ec9ee9", :name=>"Currywors", :category=>"Warm"},
 {:id=>"f85481", :name=>"Curryworst speciale", :category=>"Warm"},
 {:id=>"1b52f6", :name=>"Mexicano", :category=>"Warm"},
 {:id=>"11e0b1", :name=>"Fishburger", :category=>"Warm"},
 {:id=>"a6fec6", :name=>"Kippenschnitzel", :category=>"Warm"},
 {:id=>"13c7d2", :name=>"Sat", :category=>"Warm"},
 {:id=>"f1cf60", :name=>"Boulet", :category=>"Warm"},
 {:id=>"580a62", :name=>"Kaaskroke", :category=>"Warm"},
 {:id=>"83ebfb", :name=>"Omelet natuu", :category=>"Warm"},
 {:id=>"30860e", :name=>"Omelet met spek", :category=>"Warm"},
 {:id=>"9dc771", :name=>"Omelet met kaas", :category=>"Warm"},
 {:id=>"c7449e", :name=>"Omelet kaas en hesp ", :category=>"Warm"},
 {:id=>"a937d4", :name=>"Gekookt kippenwit", :category=>"Kip"},
 {:id=>"0d2ba2", :name=>"Kippensla", :category=>"Kip"},
 {:id=>"307900", :name=>"Kipcurry", :category=>"Kip"},
 {:id=>"37c904", :name=>"Kip Andalouse", :category=>"Kip"},
 {:id=>"83ec8b", :name=>"Kip Hawai", :category=>"Kip"},
 {:id=>"6b82e0", :name=>"Kip Pepersaus", :category=>"Kip"},
 {:id=>"430e1f", :name=>"Gebakken kip", :category=>"Kip"},
 {:id=>"2cf7ad", :name=>"Eiersla", :category=>"Diversen"},
 {:id=>"37c121", :name=>"Komkommersla", :category=>"Diversen"},
 {:id=>"47e325", :name=>"Aardappelsla", :category=>"Diversen"},
 {:id=>"b9e0f6", :name=>"Lentesla", :category=>"Diversen"},
 {:id=>"7f7760", :name=>"Broodje gezond", :category=>"Diversen"},
 {:id=>"c9e4d1", :name=>"Choc", :category=>"Diversen"},
 {:id=>"af1e70", :name=>"Effi dille en komkomme", :category=>"Diversen"},
 {:id=>"18dbb8", :name=>"Vegetarisch", :category=>"SALADES"},
 {:id=>"26bb6e", :name=>"Russisch ei", :category=>"SALADES"},
 {:id=>"4151d8", :name=>"Tonijn", :category=>"SALADES"},
 {:id=>"2254c3", :name=>"Gebakken kip met anana", :category=>"SALADES"},
 {:id=>"f6f819", :name=>"Spek en appeltje", :category=>"SALADES"},
 {:id=>"96a042", :name=>"Carpacci", :category=>"SALADES"},
 {:id=>"04a2fd", :name=>"Tomaat garnaa", :category=>"SALADES"},
 {:id=>"0f9944",
  :name=>"A la minute: assortiment van vis",
  :category=>"SALADES"},
 {:id=>"ecf9ea",
  :name=>"Italiaans:tomaat, mozarella, Serranoham en pesto",
  :category=>"PANINI'S "},
 {:id=>"203e3c",
  :name=>"Indisch: kip, ananas en curry",
  :category=>"PANINI'S "},
{:id=>"35b51b", :name=>"Tomatensoep + brood", :category=>"SOEPEN "},
 {:id=>"a4aed4", :name=>"Dagsoep + brood", :category=>"SOEPEN "},
 {:id=>"f35b71", :name=>"Frisdranken 50 cl", :category=>"DRANKEN"},
 {:id=>"a7956c", :name=>"Cecemel, Fristi 30 cl", :category=>"DRANKEN"},
 {:id=>"0def50", :name=>"Water 50 cl: plat/bruis", :category=>"DRANKEN"},
 {:id=>"a7b411", :name=>"IceTea, Fruitsap", :category=>"DRANKEN"},
 {:id=>"078ced", :name=>"Multivitaminenwater", :category=>"DRANKEN"},
 {:id=>"6082d4", :name=>"Caprisun", :category=>"DRANKEN"},
 {:id=>"c9d996", :name=>"Aquarius 50 cl", :category=>"DRANKEN"},
 {:id=>"e4da86", :name=>"Red Bull - Nalu", :category=>"DRANKEN"},
 {:id=>"d0ca70", :name=>"Pintje 33 cl", :category=>"DRANKEN"},
 {:id=>"9862c6", :name=>"Koffie - Thee", :category=>"DRANKEN"},
 {:id=>"84bac9", :name=>"Koffie verkeerd, Cappuccino", :category=>"DRANKEN"},
 {:id=>"2ba142", :name=>"LUXE-ONTBIJT", :category=>"ONTBIJT"},
 {:id=>"90baa0",
  :name=>"A La Minute",
  :category=>"specialiteiten",
  :ingredients=>
   "gerookte zalm, heilbot, forel, ui, ijsbergsla,mosterd-honing vinaigrette "},
 {:id=>"f13c69",
  :name=>"ACROBAAT",
  :category=>"specialiteiten",
  :ingredients=>"gebraad, perzik, cresson, cocktailsaus "},
 {:id=>"480e74",
  :name=>"AMERICANO ",
  :category=>"specialiteiten",
  :ingredients=>"prepar, ui, cresson, tartaar "},
 {:id=>"f00ac5",
  :name=>"BELLISSIMA ",
  :category=>"specialiteiten",
  :ingredients=>"mozzarella, sla, zongedroogde tomaten, cresson, rode pesto "},
 {:id=>"df3cd5",
  :name=>"BOERKEN ",
  :category=>"specialiteiten",
  :ingredients=>"Serranoham, mosterd, ui, augurk, tomaat "},
 {:id=>"83fa8a",
  :name=>"DALTON ",
  :category=>"specialiteiten",
  :ingredients=>"gebakken spek, sla, tomaat, geroosterde ui, barbecuesaus "},
 {:id=>"25e92c",
  :name=>"FLINTSTONE ",
  :category=>"specialiteiten",
  :ingredients=>"gekruide gehaktbal, sla, tomaat, komkommer, barbecuesaus "},
 {:id=>"f3c0a6",
  :name=>"FRIKADELLEKE ",
  :category=>"specialiteiten",
  :ingredients=>
   "vleesbrood, sla, tomaat, komkommer, ei, worteltjes, cocktailsaus "},
 {:id=>"54f5f1",
  :name=>"GRANDISSIMO ",
  :category=>"specialiteiten",
  :ingredients=>"mozzarella, Serranoham, tomaat, pesto "},
 {:id=>"7fc278",
  :name=>"HONOLULU ",
  :category=>"specialiteiten",
  :ingredients=>"kipcurry, cresson, ananas "},
 {:id=>"e2bade",
  :name=>"KEMPENAER ",
  :category=>"specialiteiten",
  :ingredients=>"aardappelsla, ui, spek "},
 {:id=>"53b0b7",
  :name=>"MARIE-LOU ",
  :category=>"specialiteiten",
  :ingredients=>"prepar, ui, ei, mayo, ketchup "},
 {:id=>"2aa5db",
  :name=>"NAPOLEON ",
  :category=>"specialiteiten",
  :ingredients=>"brie, appel, ijsbergsla, pijnboompitten, honing "},
{:id=>"281c42",
  :name=>"NEMO ",
  :category=>"specialiteiten",
  :ingredients=>"gerookte heilbot, ui, cresson, tomaat "},
 {:id=>"70fcf4",
  :name=>"PECORINO ",
  :category=>"specialiteiten",
  :ingredients=>
   "carpaccio, pecorino, zongedroogde tomaatjes, balsamicosiroop, rucola "},
 {:id=>"eecbe4",
  :name=>"PICCADILLY ",
  :category=>"specialiteiten",
  :ingredients=>"kaas, augurk, cresson, pickels "},
 {:id=>"f7932e",
  :name=>"PINK PANTER ",
  :category=>"specialiteiten",
  :ingredients=>"zalmsla, perzik, cresson "},
 {:id=>"4a1b32",
  :name=>"PIRAAT ",
  :category=>"specialiteiten",
  :ingredients=>"gerookte zalm, ui, cresson, cocktailsaus "},
 {:id=>"2ab22c",
  :name=>"POLDERKE ",
  :category=>"specialiteiten",
  :ingredients=>"hesp, sla, tomaat, komkommer, ei, worteltjes, aardappelsla "},
 {:id=>"47756c",
  :name=>"POLLO ",
  :category=>"specialiteiten",
  :ingredients=>"gebakken kip, sla, ananas, barbecuesaus "},
 {:id=>"005fec",
  :name=>"PREPARINO ",
  :category=>"specialiteiten",
  :ingredients=>
   "warm gemalen rundsvlees, ijsbergsla, tomaat, ui, hot-shotsaus "},
 {:id=>"f8c247",
  :name=>"PORKY ",
  :category=>"specialiteiten",
  :ingredients=>"gebraad, cresson, augurk, mayo, licht pikante saus "},
 {:id=>"003aa2",
  :name=>"SALOMON ",
  :category=>"specialiteiten",
  :ingredients=>"gerookte zalm, effi dille-komkommer, cresson, tomaat "},
 {:id=>"05b620",
  :name=>"SMOS REGIME ",
  :category=>"specialiteiten",
  :ingredients=>
   "kippenwit, sla, tomaat, komkommer, ei, worteltjes, dressing "},
 {:id=>"8502c9",
  :name=>"SPAGNOLA ",
  :category=>"specialiteiten",
  :ingredients=>"chorizo, geitenkaas, rucola "},
 {:id=>"1a21ec",
  :name=>"TONINO ",
  :category=>"specialiteiten",
  :ingredients=>"tonijnsla, ui, augurk, martinosaus "},
 {:id=>"441468",
  :name=>"TROPICANA ",
  :category=>"specialiteiten",
  :ingredients=>"kaas, hesp, sla, ananas, cocktailsaus"},
 {:id=>"555cb4",
  :name=>"VEGGI ",
  :category=>"specialiteiten",
  :ingredients=>"lentesla, ijsbergsla, tomaat, komkommer, ei"}]
    content_type :json
    food.to_json
  end
end

__END__

@@ home

<html>
<head>
<title>Catching mail for 10to1's Hubot</title>
<link rel="shortcut icon" href="/favicon.ico">
<style>
</style>
</head>
<body>
<h1>Hummer catch catches Hubot's mail</h1>
<iframe width="560" height="315" src="http://www.youtube.com/embed/oxQtMHgRp5g" frameborder="0" allowfullscreen></iframe>
<p>Status can be found <a href="/status">here</a></p>
</body>
</html>
