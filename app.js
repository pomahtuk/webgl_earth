// Generated by CoffeeScript 1.7.1

/*
Module dependencies.
 */

(function() {
  var Connect, LocalStrategy, app, assetManager, assetManagerGroups, assetsManagerMiddleware, cities, coffee, connectDomain, countries, ensureAuthenticated, express, flash, fs, http, https, manager, models, passport, path, routes, spdy;

  express = require("express");

  coffee = require('coffee-script');

  routes = require("./routes");

  cities = require("./routes/cities");

  countries = require("./routes/countries");

  manager = require("./routes/manager");

  models = require("./models/db");

  http = require("http");

  https = require("https");

  spdy = require("spdy");

  path = require("path");

  fs = require('fs');

  Connect = require('connect');

  assetManager = require('connect-assetmanager');

  connectDomain = require('connect-domain');

  flash = require('connect-flash');

  passport = require('passport');

  LocalStrategy = require('passport-local').Strategy;

  passport.serializeUser(function(user, done) {
    return done(null, user.id);
  });

  passport.use(new LocalStrategy(function(username, password, done) {
    return models.User.findOne({
      'username': username
    }, function(err, user) {
      console.log(user);
      if (err) {
        return done(err);
      }
      if (!user) {
        return done(null, false, {
          message: "Incorrect username."
        });
      }
      if (user.password !== password) {
        return done(null, false, {
          message: "Incorrect password."
        });
      }
      return done(null, user);
    });
  }));

  ensureAuthenticated = function(req, res, next) {
    if (req.isAuthenticated()) {
      return next();
    }
    return res.redirect('/login');
  };

  passport.deserializeUser(function(id, done) {
    return models.User.findById(id, function(err, user) {
      return done(err, user);
    });
  });

  assetManagerGroups = {
    'css': {
      'route': /\/static\/css\/[0-9]+\/.*\.css/,
      'path': './public/stylesheets/',
      'dataType': 'css',
      'files': ['bootstrap.css', 'idangerous.swiper.css', 'normalize.css', 'style.css', 'base-admin-2.css']
    }
  };

  assetsManagerMiddleware = assetManager(assetManagerGroups);

  app = express();

  app.set("port", process.env.PORT || 3000);

  app.set("views", __dirname + "/views");

  app.set("view engine", "ejs");

  app.use(express.favicon('/public/images/favicon.ico'));

  app.use(express.logger("dev"));

  app.use(express.bodyParser());

  app.use(express.methodOverride());

  app.use(express.cookieParser("your secret here"));

  app.use(express.session({
    secret: "awesome unicorns",
    maxAge: new Date(Date.now() + 3600000)
  }));

  app.use(connectDomain());

  app.use(flash());

  app.use(passport.initialize());

  app.use(passport.session());

  app.use(app.router);

  app.use(require("less-middleware")({
    src: __dirname + "/public"
  }));

  app.use(express["static"](__dirname + '/public'));

  app.use(function(err, req, res, next) {
    console.log(err);
    return res.send(500, "Houston, we have a problem!\n");
  });

  app.get('/:script.js', function(req, res) {
    var cs, js;
    res.header('Content-Type', 'application/x-javascript');
    cs = fs.readFileSync("" + __dirname + "/public/coffee/" + req.params.script + ".coffee", "ascii");
    js = coffee.compile(cs);
    return res.send(js);
  });

  if ("development" === app.get("env")) {
    app.use(express.errorHandler());
  }

  app.get("/", routes.index);

  app.get("/swarm", function(req, res) {
    return res.render('skimmers', {
      user: req.user
    });
  });

  app.get("/public/template/pagination/pagination.html", function(req, res) {
    var template;
    template = fs.readFileSync("" + __dirname + "/public/template/pagination/pagination.html", "utf-8");
    return res.send(template);
  });

  app.get("/manager/cities-list.html", function(req, res) {
    var template;
    template = fs.readFileSync("" + __dirname + "/public/template/manager/cities-list.html", "utf-8");
    return res.send(template);
  });

  app.get("/manager/city-detail.html", function(req, res) {
    var template;
    template = fs.readFileSync("" + __dirname + "/public/template/manager/city-detail.html", "utf-8");
    return res.send(template);
  });

  app.get("/cities/random_city", cities.random);

  app.get("/cities/:code", cities.certain_city);

  app.get("/cities", cities.index);

  app.get("/countries/random_country", countries.random);

  app.get("/countries/:code", countries.certain_country);

  app.get("/countries", countries.index);

  app.get("/countries/region/:region", countries.country_by_region);

  app.get("/countries/sub_region/:sub_region", countries.country_by_sub_region);

  app.get("/countries/:region/:sub_region", countries.country_by_region_and_sub_region);

  app.get('/manager', ensureAuthenticated, manager.analitics);

  app.get('/manager/cities', ensureAuthenticated, manager.cities_index);

  app.get('/login', manager.login);

  app.get('/logout', function(req, res) {
    req.logout();
    return res.redirect('/login');
  });

  app.get("/manager/cities/:id", ensureAuthenticated, function(req, res) {
    return models.City.findById(req.params.id, function(err, title, body) {
      res.render("manager_cities_edit", {
        user: req.user,
        city: title
      });
      return console.log("Editing " + title._id);
    });
  });

  app.post('/login', passport.authenticate('local', {
    successRedirect: '/manager',
    failureRedirect: '/login',
    failureFlash: true
  }));

  app.post("/manager/cities", ensureAuthenticated, function(req, res) {
    var city;
    city = new models.City(req.body);
    city.save();
    console.log("Saved " + city._id);
    return res.redirect("/manager/cities");
  });

  app.post("/manager/cities/:id", ensureAuthenticated, function(req, res) {
    var data;
    data = req.body;
    console.log(data.city_name);
    return models.City.findOne({
      _id: req.params.id
    }, function(err, doc) {
      doc.city_name = data.city_name;
      doc.code = data.code;
      doc.coordinates = data.coordinates;
      doc.flickr = data.flickr;
      doc.wikipedia_array = data.wikipedia_array;
      doc.country_code = data.country_code;
      doc.place_id = data.place_id;
      return doc.save(function(error) {
        console.log(doc);
        if (!error) {
          return res.send("OK");
        }
      });
    });
  });

  app["delete"]("/manager/cities/:id", ensureAuthenticated, function(req, res) {
    return models.City.findById(req.params.id, function(err, city) {
      city.remove(city);
      console.log("Deleted " + city._id);
      return res.redirect("/manager/cities");
    });
  });

  http.createServer(app).listen(app.get("port"), function() {
    return console.log("Express server listening on port " + app.get("port"));
  });

}).call(this);
