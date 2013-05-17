citydata = require('../models/db');

# exports.index = (req, res) ->
#   citydata.citylist 'ABA', (err, citylist) ->
#     res.render "index",
#       title: "Test web page on node.js using Express and Mongoose"
#       pagetitle: "Hello there"
#       cities: citylist

exports.index = (req, res) ->
  res.render "index",
    title: "Test web page on node.js using Express and Mongoose"
    pagetitle: "Hello there"