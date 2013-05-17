###
Module dependencies.
###
express       = require "express"
coffee        = require 'coffee-script'
routes        = require "./routes"
cities        = require "./routes/cities"
countries     = require "./routes/countries"
manager       = require "./routes/manager"
models        = require "./models/db"
http          = require "http"
https         = require "https"
path          = require "path"
fs            = require 'fs'


####
## USERS BASE FUNCTIONALITY
####
flash         = require('connect-flash')
passport      = require('passport')
LocalStrategy = require('passport-local').Strategy

passport.serializeUser (user, done) ->
  done null, user.id

passport.use new LocalStrategy (username, password, done) ->
  models.User.findOne
    'username': username
  , (err, user) ->
    console.log user
    return done(err)  if err
    unless user
      return done(null, false,
        message: "Incorrect username."
      )
    unless user.password is password
      return done(null, false,
        message: "Incorrect password."
      )
    done null, user

ensureAuthenticated = (req, res, next) ->
  if req.isAuthenticated() 
    return next()
  res.redirect('/login')

passport.deserializeUser (id, done) ->
  models.User.findById id, (err, user) ->
    done err, user

####
## MAIN APP CODE
####

app = express()

# all environments
app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "ejs"
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser("your secret here")
#app.use express.session()

app.use express.session
  secret: "awesome unicorns"
  maxAge: new Date(Date.now() + 3600000)

app.use flash()
app.use passport.initialize()
app.use passport.session()
app.use app.router
app.use require("less-middleware")(src: __dirname + "/public")
app.use express.static(__dirname + '/public')

#coffee for client
app.get '/:script.js', (req, res) ->
  res.header 'Content-Type', 'application/x-javascript'
  cs = fs.readFileSync "#{__dirname}/public/coffee/#{req.params.script}.coffee", "ascii"
  js = coffee.compile cs 
  res.send js

# development only
app.use express.errorHandler()  if "development" is app.get("env")

####
## ROUTING 
####
app.get "/", routes.index

app.get "/gmaps/", (req, res) ->
  request_data = req.query['location']
  language = req.query['language']
  console.log request_data

  options =
    host: "maps.googleapis.com"
    path: "/maps/api/place/nearbysearch/json?language=#{language}&location=#{request_data}&radius=10000&name=hotel&sensor=false&key=AIzaSyBbz6bDv-hv_vgELswW4gqDFl4y4eFEauQ"
    #path: "/maps/api/place/nearbysearch/json?language=#{language}&location=#{request_data}&radius=10000&name=hotel&sensor=false&key=AIzaSyD14OufYp_JgKFOjTuBjKNLroBp14cUdEM"
    #path: "/maps/api/place/nearbysearch/json?language=#{language}&location=#{request_data}&radius=10000&name=hotel&sensor=false&key=AIzaSyBLGMGDcOJd8g3-G2ZDANn6oeBFTds4da8"
    #path: "/maps/api/place/nearbysearch/json?language=#{language}&location=#{request_data}&radius=10000&name=hotel&sensor=false&key=AIzaSyB0sn9mKI72i0lNsXvfq2fj0MWXnOwt098"

  callback = (response) ->
    str = ""    
    response.on "data", (chunk) ->
      str += chunk
    response.on "end", ->
      res.header 'Content-Type', 'application/json'
      res.send str

  https.request(options, callback).end()


#angular templates
app.get "/public/template/pagination/pagination.html", (req, res) ->
  template = fs.readFileSync "#{__dirname}/public/template/pagination/pagination.html", "utf-8"
  res.send template

app.get "/manager/cities-list.html", (req, res) ->
  template = fs.readFileSync "#{__dirname}/public/template/manager/cities-list.html", "utf-8"
  res.send template

app.get "/manager/city-detail.html", (req, res) ->
  template = fs.readFileSync "#{__dirname}/public/template/manager/city-detail.html", "utf-8"
  res.send template

# app.get "/manager/city-detail.html", (req, res) ->
#   template = fs.readFileSync "#{__dirname}/public/template/manager/city-detail.html", "utf-8"
#   res.send template
# #end of angular templates

app.get "/cities/random_city", cities.random
app.get "/cities/:code", cities.certain_city
app.get "/cities", cities.index

app.get "/countries/random_country", countries.random
app.get "/countries/:code", countries.certain_country
app.get "/countries", countries.index
app.get "/countries/region/:region", countries.country_by_region
app.get "/countries/sub_region/:sub_region", countries.country_by_sub_region
app.get "/countries/:region/:sub_region", countries.country_by_region_and_sub_region

app.get '/manager', ensureAuthenticated, manager.analitics
app.get '/manager/cities', ensureAuthenticated, manager.cities_index
app.get '/login', manager.login
app.get '/logout', (req, res) ->
  req.logout()
  res.redirect('/login')

# Edit a record
app.get "/manager/cities/:id", ensureAuthenticated, (req, res) ->
  models.City.findById req.params.id, (err, title, body) ->
    # res.header 'Content-Type', 'application/json'
    # res.send JSON.stringify(title)
    res.render "manager_cities_edit", {user: req.user, city: title}
    console.log "Editing " + title._id

app.post '/login', passport.authenticate 'local', { successRedirect: '/manager', failureRedirect: '/login', failureFlash: true}

app.post "/manager/cities", ensureAuthenticated, (req, res) ->
  city = new models.City(req.body)
  city.save()
  console.log "Saved " + city._id
  res.redirect "/manager/cities"

app.post "/manager/cities/:id", ensureAuthenticated, (req, res) ->
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
    doc.save((error) ->
      console.log doc
      unless error
        res.send "OK"
    )

app.delete "/manager/cities/:id", ensureAuthenticated, (req, res) ->
  models.City.findById req.params.id, (err, city) ->
    city.remove city
    console.log "Deleted " + city._id
    res.redirect "/manager/cities"

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")