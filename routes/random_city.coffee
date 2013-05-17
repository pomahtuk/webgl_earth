citydata = require('../models/db');

# exports.index = (req, res) ->
#   citydata.citylist 'ABA', (err, citylist) ->
#     res.render "index",
#       title: "Test web page on node.js using Express and Mongoose"
#       pagetitle: "Hello there"
#       cities: citylist

exports.index = (req, res) ->
  citydata.random_city (err, random) ->
    res.header 'Content-Type', 'application/json'
    res.send JSON.stringify(random)
    # res.render "index",
    #   title: "Test web page on node.js using Express and Mongoose"
    #   pagetitle: "Hello there"
    #   city: random