window.bingKey = 'AmhVGlXcVJCaxAht83CRXIID37Krqr_RH8rFjLZMwaakg9s5IzLT2pNBNS7ovsvS';
window.flickrKey = '903614f7ec5aabd30fda3813428ff755';
window.flickrSecret = 'c43f15bcdc52ec65';

window.GlobalData = {}

window.get_location = function () {
  if (Modernizr.geolocation) {
    navigator.geolocation.getCurrentPosition(window.initialize_with_geocode);
  } else {
    window.initialize();
  }
};

query_server_for_data = function(type) {
  if (type == null) {
    type = 'cities';
  }
    $.ajax({
        url:'http://estate.allvbg.ru/iata_'+type+'.json',
        dataType: 'json'
    }).done(function(data){
        window.GlobalData[''+type+''] = data;
    });
  return true;
};

function disableInput(scene) {
    var controller = scene.getScreenSpaceCameraController();
    controller.enableTranslate = false;
    controller.enableZoom = false;
    controller.enableRotate = false;
    controller.enableTilt = false;
    controller.enableLook = false;
};

function enableInput(scene) {
    var controller = scene.getScreenSpaceCameraController();
    controller.enableTranslate = true;
    controller.enableZoom = true;
    controller.enableRotate = true;
    controller.enableTilt = true;
    controller.enableLook = true;
};

addMarker = function (lat, lon) {

    var image = new Image();
    image.onload = function() {
        var billboards = new Cesium.BillboardCollection();
        var textureAtlas = cesiumWidget.scene.getContext().createTextureAtlas({
            image : image
        });
        billboards.setTextureAtlas(textureAtlas);

        billboards.add({
            position : ellipsoid.cartographicToCartesian(Cesium.Cartographic.fromDegrees(lon, lat)),
            horizontalOrigin : Cesium.HorizontalOrigin.LEFT, // default
            verticalOrigin : Cesium.VerticalOrigin.BOTTOM, // default: CENTER
            imageIndex : 0
        });
        cesiumWidget.scene.getPrimitives().add(billboards);
    };
    image.src = 'http://estate.allvbg.ru/img/dart_small.png';
};

flyTo = function (lat, lon, height, time) {

    cesiumWidget.scene.getPrimitives().removeAll()

    if (height == null) {
        height = 1000000
    }
    if (time == null) {
        time = 3000;
    }

    var destination = Cesium.Cartographic.fromDegrees(lon, lat, height);

    // only fly there if it is not the camera's current position
    if (!ellipsoid.cartographicToCartesian(destination).equalsEpsilon(cesiumWidget.scene.getCamera().getPositionWC(), Cesium.Math.EPSILON6)) {
        disableInput(cesiumWidget.scene);
        var flight = Cesium.CameraFlightPath.createAnimationCartographic(cesiumWidget.scene.getFrameState(), {
            destination : destination,
            duration : time,
            onComplete : function() {
                enableInput(cesiumWidget.scene);
            }
        });
        cesiumWidget.scene.getAnimations().add(flight);
    }
};

thow_dart = function() {
    var max_random = Object.keys(window.GlobalData.wiki).length;
    var number = Math.floor((Math.random()*max_random));
    var random_code = Object.keys(GlobalData.wiki)[number];
    var random_point = window.GlobalData.wiki[random_code];
    thow_dart_animation(random_point);
};

thow_dart_animation = function(random_point) {

    lat = random_point.coordinates[0];
    lng = random_point.coordinates[1];

    var dart = $('.dart');
    var start_left = $(window).width();
    var start_top  = ($(window).height() / 100) * 15;
    var end_left   = start_left / 2 ;
    var end_top    = $(window).height() / 2;
    dart.css({'left':start_left+'px', 'top': start_top+'px'}).show();

    flyTo(lat, lng, 5000000, 2000);

    query_flickr_photos(random_point.flickr.place_id);

    setTimeout( function() {
        dart.animate({'left': end_left + (end_left / 100) * 25, 'top': 0, scale: '0.7'}, 700, function(){
            dart.animate({'left': end_left-103, 'top': end_top - 233, scale: '0.4'}, 700, function(){
                addMarker(lat, lng);
                dart.css({'display':'none'});
                flyTo(lat, lng, 2000000, 300);
                query_wikipedia_with_id(random_point.wikipedia_array.id, function(response){
                    console.log('from preloaded data',response);
                })
            });
        });
    }, 2000)
};

query_wikipedia_with_id = function(id, callback) {
    var response = '';
    $.ajax({
        url:'http://en.wikipedia.org/w/api.php',
        method: 'GET',
        crossDomain: true,
        dataType: 'jsonp',
        cache: false,
        data: {
            'action': 'query',
            'format': 'json',
            'exchars': 500,
            'prop': 'extracts',
            'exlimit': 10,
            'exintro': true,
            'pageids': id,
            'redirects': true,
        }
    }).done(function(data){
        var pages = data.query.pages
        var title = '';
        var extracts = []
        for (key in pages) {
          title = pages[key].title;
          extracts.push(pages[key].extract);
        }
        var full_url = 'http://en.wikipedia.org/wiki/'+title
        var extract = $(extracts[0])
        extract.find('p').first().append("")
        response = extract.html() + "... <a href=\"http://en.wikipedia.org/w/index.php?curid="+id+"\" target='blank'> read more </a>"
        if (typeof callback !== "undefined" && callback !== null) {
            callback(response);
        };
    });
};

query_flickr_photos = function (id) {

    /*Size Suffixes

    The letter suffixes are as follows:

    s   small square 75x75
    q   large square 150x150
    t   thumbnail, 100 on longest side
    m   small, 240 on longest side
    n   small, 320 on longest side
    -   medium, 500 on longest side
    z   medium 640, 640 on longest side
    c   medium 800, 800 on longest side†
    b   large, 1024 on longest side*
    o   original image, either a jpg, gif or png, depending on source format
    */

    $('#photos_div').html('');
    $.ajax({
        url:'http://api.flickr.com/services/rest/?',
        method: 'GET',
        crossDomain: true,
        dataType: 'jsonp',
        jsonpCallback: 'jsonFlickrApi',
        cache: false,
        data: {
            'method': 'flickr.photos.search',
            'format': 'json',
            'accuracy': 11 ,
            'content_type': 1,
            'place_id': id,
            'radius': 1,
            'media': 'photos',
            'radius_units': 'km',
            'api_key': flickrKey
        }
    }).done(function(data){
        //console.log(data.photos.photo.length);

        var photos = data.photos.photo;
        var photo, _i, _len;
        var imgs = [];
        for (_i = 0, _len = photos.length; _i < _len; _i++) {
            photo = photos[_i];
            imgs.push("<img src='http://farm"+photo.farm+".staticflickr.com/"+photo.server+"/"+photo.id+"_"+photo.secret+"_z.jpg' />");
        }

        console.log(imgs);

        //$('#photos_div').html(imgs.join(''));
        //$('#photos_div').fadeIn(300);

    }); 
};

/* HELPER FUNCTIONS */

//window.GlobalData.cities_with_airports_and_coords = {};

yandex_geocode_ddos = function() {
    var city, coordinates;
    var cities   = window.GlobalData.cities_with_airports;
    window.GlobalData.cities_with_airports_and_coords = {};
    form_countries_object();
    for (code in cities) {
        city = cities[code];     
        var term = city.city_name.en+', '+window.GlobalData.countries_by_name[city.country_code].name.en;
        query_yandex(term, code, city);
    }
};

query_yandex =function (term, code, city) {
    $.ajax({
        url:'http://geocode-maps.yandex.ru/1.x/?',
        method: 'GET',
        crossDomain: true,
        dataType: 'jsonp',
        cache: false,
        data: {
            'geocode': term,
            'format': 'json',
            'kind': 'locality' ,
            'results': 1,
            'lang': 'en-US'
        }
    }).done(function(data){
        coordinates = city.coordinates;
        if (data.response.GeoObjectCollection.featureMember.length > 0 ) {
            var location = data.response.GeoObjectCollection.featureMember[0].GeoObject.Point.pos.split(' ');
            coordinates = [location[1], location[0]];
        }
        console.log('request done');
        window.GlobalData.cities_with_airports_and_coords["" + code] = {};
        window.GlobalData.cities_with_airports_and_coords["" + code].code = code;
        window.GlobalData.cities_with_airports_and_coords["" + code].country_code = city.country_code;
        window.GlobalData.cities_with_airports_and_coords["" + code].city_name = city.city_name;
        window.GlobalData.cities_with_airports_and_coords["" + code].coordinates = coordinates;
    });
};

flickr_recursion = function (index) {

    if (index <= Object.keys(GlobalData.experimental).length) {

        var city_code = Object.keys(GlobalData.experimental)[index];
        var city = GlobalData.experimental[city_code];

        setTimeout(flickr_recursion_helper(city, index), 5000);
    }
};

flickr_recursion_helper = function(new_city, index) {
    //console.log(new_city);
    $.ajax({
        url:'http://api.flickr.com/services/rest/?',
        method: 'GET',
        crossDomain: true,
        dataType: 'jsonp',
        jsonpCallback: 'jsonFlickrApi',
        cache: false,
        data: {
            'method': 'flickr.places.findByLatLon',
            'format': 'json',
            'accuracy': 11 ,
            'lat': new_city.coordinates[0],
            'lon': new_city.coordinates[1],
            'api_key': flickrKey
        }
    }).done(function(data){
        // var first_part = new_city.coordinates[0].split('.')[0]
        // var second_part = new_city.coordinates[1].split('.')[0]
        // var flickr_first_part = data.places.place[0].latitude.split('.')[0]
        // var flickr_second_part = data.places.place[0].longitude.split('.')[0]
        // if (((first_part === flickr_first_part) && (second_part === flickr_second_part)) || ((first_part + 1 === flickr_first_part) && (second_part + 1 === flickr_second_part)) || ((first_part - 1 === flickr_first_part) && (second_part - 1 === flickr_second_part)) || ((first_part + 1 === flickr_first_part) && (second_part - 1 === flickr_second_part)) || ((first_part -+ 1 === flickr_first_part) && (second_part + 1 === flickr_second_part))) {
        console.log('request success');
        window.GlobalData.cities_with_airports_and_coords["" + new_city.code] = new_city;
        window.GlobalData.cities_with_airports_and_coords["" + new_city.code].flickr = data.places.place[0];
        // } else {
        //     console.log(new_city, data.places.place[0]);
        // }

        flickr_recursion(index + 1);

    });
};

wikilocation_recursion = function (index) {

    if (index <= Object.keys(GlobalData.flickr).length) {

        var city_code = Object.keys(GlobalData.flickr)[index];
        var city = GlobalData.flickr[city_code];
        var wiki = GlobalData.wiki[city_code];

        if (typeof wiki === "undefined" || wiki === null) {
            setTimeout(wikilocation_recursion_helper(city, index), 1000);
        } else {
            console.log('allready in object');
            wikilocation_recursion(index + 1);
        }
    }
};

wikilocation_recursion_helper = function (new_city, index) {
    $.ajax({
        url:'http://api.wikilocation.org/articles',
        method: 'GET',
        crossDomain: true,
        dataType: 'jsonp',
        jsonpCallback: 'addPoi',
        cache: true,
        data: {
            'lng': new_city.coordinates[1],
            'lat': new_city.coordinates[0],
            'limit': 10,
            'radius': 10000,
            'jsonp': 'addPoi'
        }
    }).done(function(data){
        console.log('request done');
        var articles = data.articles;
        var article, _i, _len;

        for (_i = 0, _len = articles.length; _i < _len; _i++) {
          article = articles[_i];
          if (article.type === 'city') {
            break;
          }
        }

        window.GlobalData.cities_with_airports_and_coords["" + new_city.code] = new_city;
        window.GlobalData.cities_with_airports_and_coords["" + new_city.code].wikipedia_array = article;

        wikilocation_recursion(index + 1);
  })
};

process_server_data = function() {
    var cities_with_airports, key, value, airports, cities, city_name, country_code, code, key_, value_;

    cities_with_airports = {};

    cities   = window.GlobalData.cities;
    airports = window.GlobalData.airports;

    for (_i = 0, _len = cities.length; _i < _len; _i++) {
      var city = cities[_i];
      code = city.code;
      country_code = city.country_code;
      city_name = {};
      city_name = city.name;
      for (_j = 0, _len1 = airports.length; _j < _len1; _j++) {
        var airport = airports[_j];
        if (code === airport.city_code) {
          cities_with_airports["" + code] = {};
          cities_with_airports["" + code].code = code;
          cities_with_airports["" + code].country_code = country_code;
          cities_with_airports["" + code].city_name = {};
          cities_with_airports["" + code].city_name = city_name;
          cities_with_airports["" + code].coordinates = airport.coordinates;
        };
      };
    };

    window.GlobalData.cities_with_airports = cities_with_airports;
};

form_countries_object = function () {
    var countries_by_name = {};
    var countries   = window.GlobalData.countries;
    var country, _i, _len;
    for (_i = 0, _len = countries.length; _i < _len; _i++) {
        country = countries[_i];
        countries_by_name["" + country.code] = {};
        countries_by_name["" + country.code].code = country.code;
        countries_by_name["" + country.code].name = country.name;
    }
    window.GlobalData.countries_by_name = countries_by_name;
};

$(document).ready(function(){
   //get_location();

    window.cesiumWidget = new Cesium.CesiumWidget('earth_div');

    window.ellipsoid = Cesium.Ellipsoid.WGS84;

    var layers = cesiumWidget.centralBody.getImageryLayers();
    //layers.removeAll();
    var bing = new Cesium.BingMapsImageryProvider({
        url : 'http://dev.virtualearth.net',
        key: 'AmhVGlXcVJCaxAht83CRXIID37Krqr_RH8rFjLZMwaakg9s5IzLT2pNBNS7ovsvS',
        mapStyle : Cesium.BingMapsStyle.AERIAL_WITH_LABELS
    });
    layers.addImageryProvider(bing);
    layers.removeAll();
    layers.addImageryProvider(bing);

   // query_server_for_data('cities');
   // query_server_for_data('airports');
   query_server_for_data('countries');
   //query_server_for_data('flickr');
   query_server_for_data('wiki');
   //query_server_for_data('cities_with_airports');
   //query_server_for_data('experimental');
});