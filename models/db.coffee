mongoose = require 'mongoose'

citySchema = new mongoose.Schema
  code:            String
  country_code:    String
  city_name:
    en:            String
    ru:            String
  coordinates:     [Number]
  place_id:        String
  places:          mongoose.Schema.Types.Mixed
  flickr:          mongoose.Schema.Types.Mixed
  wikipedia_array: mongoose.Schema.Types.Mixed

countrySchema = new mongoose.Schema
  area:     Number
  code:     String
  name:     mongoose.Schema.Types.Mixed
  subarea:  Number

userSchema = new mongoose.Schema
  password:     String
  username:     String

User    = mongoose.model 'User', userSchema
City    = mongoose.model 'City', citySchema
Country = mongoose.model 'Country', countrySchema

mongoose.connect 'mongodb://localhost/webgl_earth'

exports.User = User
exports.City = City
exports.Country = Country

#
# Cities functions
#
exports.random_city = (callback) ->
  City.count {}, (err, count) ->
    return callback(err) if err
    rand = Math.floor(Math.random() * count)
    City.findOne({}).skip(rand).exec (err, random) ->
      callback "", random

exports.citylist = (callback) ->
  City.find (err, cities) ->
    if err
      console.log err
    else
      callback "", cities

exports.citylist_manager = (callback) ->
  City.find {}, 'code country_code city_name wikipedia_array.id coordinates flickr.place_id', (err, cities) ->
    if err
      console.log err
    else
      callback "", cities

exports.certain_city = (code, callback) ->
  if code?
    City.find { $or: [{'code': new RegExp(code)}, {'city_name.en':  new RegExp(code)}, {'city_name.ru': new RegExp(code)}] }, (err, city) ->
      if err
        console.log err
      else
        callback "", city
  else
    callback "", 'no querry found'

#
# Countries functions
#

exports.random_country = random_country = (callback) ->
  Country.count {}, (err, count) ->
    return callback(err) if err
    rand = Math.floor(Math.random() * count)
    Country.findOne({}).skip(rand).exec (err, random) ->
      #console.log random
      callback "", random

exports.countrylist = country_list = (code, callback) ->
  Country.find (err, countries) ->
    if err
      console.log err
    else
      callback "", countries

exports.certain_country = certain_country = (code, callback) ->
  if code?
    Country.find { 'code': new RegExp(code) }, (err, country) ->
      if err
        console.log err
      else
        callback "", country
  else
    callback "", 'no querry found'

exports.country_by_region = country_by_region = (region, callback) ->
  if region?
    Country.find { 'region' : region }, (err, countries) ->
      if err
        console.log err
      else
        callback "", countries
  else
    callback "", 'no querry found'

exports.country_by_sub_region = country_by_sub_region = (sub_region, callback) ->
  if region?
    Country.find { 'sub_region' : sub_region }, (err, countries) ->
      if err
        console.log err
      else
        callback "", countries
  else
    callback "", 'no querry found'


exports.country_by_region_and_sub_region = country_by_sub_region = (region, sub_region, callback) ->
  if region?
    Country.find { 'sub_region' : sub_region, 'region' : region  }, (err, countries) ->
      if err
        console.log err
      else
        callback "", countries
  else
    callback "", 'no querry found'