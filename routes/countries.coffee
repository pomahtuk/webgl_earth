models = require('../models/db')

exports.index = (req, res) ->
  models.countrylist (err, countrylist) ->
    res.header 'Content-Type', 'application/json'
    res.send JSON.stringify(countrylist)

exports.certain_country = (req, res) ->
  console.log req.params.code
  models.certain_country req.params.code, (err, country) ->
    res.header 'Content-Type', 'application/json'
    res.send JSON.stringify(country)

exports.random = (req, res) ->
  models.random_country (err, random) ->
    res.header 'Content-Type', 'application/json'
    res.send JSON.stringify(random)

exports.country_by_region = (req, res) ->
  models.country_by_region req.params.region, (err, countries) ->
    res.header 'Content-Type', 'application/json'
    res.send JSON.stringify(countries)

exports.country_by_sub_region = (req, res) ->
  models.country_by_sub_region req.params.sub_region, (err, countries) ->
    res.header 'Content-Type', 'application/json'
    res.send JSON.stringify(countries)

exports.country_by_region_and_sub_region = (req, res) ->
  models.country_by_region_and_sub_region req.params.region, req.params.sub_region, (err, countries) ->
    res.header 'Content-Type', 'application/json'
    res.send JSON.stringify(countries)