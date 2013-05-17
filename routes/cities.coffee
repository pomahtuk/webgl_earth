models = require('../models/db')

exports.index = (req, res) ->
  console.log req.query['manager']
  unless req.query['manager'] is 'true'
    models.citylist (err, citylist) ->
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(citylist)
  else
    models.citylist_manager (err, citylist) ->
      res.header 'Content-Type', 'application/json'
      res.send JSON.stringify(citylist)

exports.certain_city = (req, res) ->
  console.log req.params.code
  models.certain_city req.params.code, (err, city) ->
    res.header 'Content-Type', 'application/json'
    res.send JSON.stringify(city)

exports.random = (req, res) ->
  models.random_city (err, random) ->
    res.header 'Content-Type', 'application/json'
    res.send JSON.stringify(random)
    # res.render "index",
    #   title: "Test web page on node.js using Express and Mongoose"
    #   pagetitle: "Hello there"
    #   city: random