models = require('../models/db')

exports.login = (req, res) ->
  res.render "login",
    title: "Test web page on node.js using Express and Mongoose"
    pagetitle: "Hello there"

exports.analitics = (req, res) ->
  res.render 'manager', { user: req.user }

exports.cities_index = (req, res) ->
  res.render 'manager_cities', { user: req.user}

exports.update_city = (req, res) ->
  data = req.body
  console.log data.city_name
  models.City.findOne
    _id: req.params.id
  , (err, doc) ->
    doc.city_name       = data.city_name
    doc.code            = data.code
    doc.coordinates     = data.coordinates
    doc.flickr          = data.flickr
    doc.wikipedia_array = data.wikipedia_array
    doc.country_code    = data.country_code
    doc.place_id        = data.place_id
    doc.places          = data.places
    doc.save((error) ->
      unless error
        res.send "OK"
    )

exports.create_city = (req, res) ->
  data = req.body
  city = new models.City()
  city.city_name       = data.city_name
  city.code            = data.code
  city.coordinates     = data.coordinates
  city.flickr          = data.flickr
  city.wikipedia_array = data.wikipedia_array
  city.country_code    = data.country_code
  city.place_id        = data.place_id
  city.places          = data.places
  city.save()
  res.redirect "/manager/cities"