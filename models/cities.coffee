mongoose = require 'mongoose'

citySchema = new mongoose.Schema
  code:            String
  country_code:    String
  city_name:
    en:            String
    ru:            String
  coordinates:     [Number]
  place_id:        String
  flickr:          mongoose.Schema.Types.Mixed
  wikipedia_array: mongoose.Schema.Types.Mixed

City = mongoose.model 'City', citySchema

mongoose.connect 'mongodb://localhost/webgl_earth'

exports.City = City

#Finds a random city based on how many there are in the collection
exports.random_city = random_city = (callback) ->
  City.count {}, (err, count) ->
    return callback(err) if err
    rand = Math.floor(Math.random() * count)
    City.findOne({}).skip(rand).exec (err, random) ->
      callback "", random

exports.citylist = citylist = (callback) ->
  City.find (err, cities) ->
    if err
      console.log err
    else
      callback "", cities

exports.certain_city = certain_city = (city_code, callback) ->
  City.find
    code: city_code
  , (err, city) ->
    if err
      console.log err
    else
      callback "", city