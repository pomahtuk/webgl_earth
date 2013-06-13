###
Module dependencies.
###
# coffee           = require 'coffee-script'
mongoose         = require 'mongoose'
#cities_raw       = require './public/json/iata_wiki.json'
#cities_raw       = require './public/json/iata_array.json'
cities_raw       = require './public/json/ru.json'
#countries_raw    = require './public/json/iata_countries.json'
countries_raw    = require './public/json/formed_regions.json'

citySchema = new mongoose.Schema
  code:               String
  country_code:       String
  city_name:
    en:               String
    ru:               String
  coordinates:        [Number]
  place_id:           String
  places:             mongoose.Schema.Types.Mixed
  flickr:             mongoose.Schema.Types.Mixed
  wikipedia_array:    mongoose.Schema.Types.Mixed
  wikipedia_array_ru: mongoose.Schema.Types.Mixed

countrySchema = new mongoose.Schema
  code:         String
  name:         mongoose.Schema.Types.Mixed
  un_name:      String
  region:       String
  sub_region:   String

City    = mongoose.model 'City', citySchema
Country = mongoose.model 'Country', countrySchema


conn = mongoose.connect 'mongodb://localhost/webgl_earth'

#console.log cities_raw

for city in cities_raw
  delete city._id
  delete city.__v
  delete city.place_id
  delete city.place_id
  if city.wikipedia_array_ru
    delete city.wikipedia_array_ru.type
    delete city.wikipedia_array_ru.mobileurl
    delete city.wikipedia_array_ru.lat
    delete city.wikipedia_array_ru.lng
  delete city.wikipedia_array.type
  delete city.wikipedia_array.mobileurl
  delete city.wikipedia_array.lat
  delete city.wikipedia_array.lng
  delete city.flickr.latitude
  delete city.flickr.longitude
  delete city.flickr.place_type
  delete city.flickr.place_type_id
  delete city.flickr.timezone
  delete city.places

console.log cities_raw.length

City.remove {}

save_city_wrap = (index = 0) ->
  if index < cities_raw.length
    city = cities_raw[index]
    save_city(city, index)
  else
    console.log 'done!'

save_city = (city, index) ->
  console.log index
  new City(city).save (err, doc) ->
    if err
      console.log err
    save_city_wrap(index + 1)

save_city_wrap()

# City.remove {}, (error) ->
#   i = 0
#   for city in cities_raw
#     new City(city).save (err, doc) ->
#       if err
#         console.log err
#     i++
#     console.log i

# Country.remove {}, (error) ->
#   for country, index in countries_raw
#     new Country(country).save (err, doc) ->
#       if err
#         console.log err
#     console.log index