// Generated by CoffeeScript 1.7.1
(function() {
  var addMarker, bingKey, destroy_maps, disableInput, enableInput, flickrKey, flickrSecret, flyTo, form_select2_countries_data, form_select2_regions_data, form_select2_sub_regions_data, format, init_2d_map, init_cessium_map, query_flickr_photos, query_openweathermap, query_webcams, query_wikipedia_with_id, thow_dart_animation, webcams_devid;

  bingKey = 'AmhVGlXcVJCaxAht83CRXIID37Krqr_RH8rFjLZMwaakg9s5IzLT2pNBNS7ovsvS';

  flickrKey = '903614f7ec5aabd30fda3813428ff755';

  flickrSecret = 'c43f15bcdc52ec65';

  webcams_devid = 'd2a3f882246031d44de64607d65981fd';

  this.GlobalData = {};

  this.GlobalData.booking_missed = [];

  this.currentMarker = {};

  this.language = 'en';

  this.regions = {
    "Africa": {
      "Eastern Africa": ["Burundi", "Comoros", "Djibouti", "Eritrea", "Ethiopia", "Kenya", "Madagascar", "Malawi", "Mauritius", "Mayotte", "Mozambique", "Réunion", "Rwanda", "Seychelles", "Somalia", "South Sudan", "Uganda", "United Republic of Tanzania", "Zambia", "Zimbabwe"],
      "Middle Africa": ["Angola", "Cameroon", "Central African Republic", "Chad", "Congo", "Democratic Republic of the Congo", "Equatorial Guinea", "Gabon", "Sao Tome and Principe"],
      "Northern Africa": ["Algeria", "Egypt", "Libya", "Morocco", "Sudan", "Tunisia", "Western Sahara"],
      "Southern Africa": ["Botswana", "Lesotho", "Namibia", "South Africa", "Swaziland"],
      "Western Africa": ["Benin", "Burkina Faso", "Cape Verde", "Cote d'Ivoire", "Gambia", "Ghana", "Guinea", "Guinea-Bissau", "Liberia", "Mali", "Mauritania", "Niger", "Nigeria", "Saint Helena", "Senegal", "Sierra Leone", "Togo"]
    },
    "Latin America and the Caribbean": {
      "Caribbean": ["Anguilla", "Antigua and Barbuda", "Aruba", "Bahamas", "Barbados", "Bonaire, Saint Eustatius and Saba", "British Virgin Islands", "Cayman Islands", "Cuba", "Curaçao", "Dominica", "Dominican Republic", "Grenada", "Guadeloupe", "Haiti", "Jamaica", "Martinique", "Montserrat", "Puerto Rico", "Saint-Barthélemy", "Saint Kitts and Nevis", "Saint Lucia", "Saint Martin (French part)", "Saint Vincent and the Grenadines", "Sint Maarten (Dutch part)", "Trinidad and Tobago", "Turks and Caicos Islands", "United States Virgin Islands"],
      "Central America": ["Belize", "Costa Rica", "El Salvador", "Guatemala", "Honduras", "Mexico", "Nicaragua", "Panama"],
      "South America": ["Argentina", "Bolivia", "Brazil", "Chile", "Colombia", "Ecuador", "Falkland Islands", "French Guiana", "Guyana", "Paraguay", "Peru", "Suriname", "Uruguay", "Venezuela"]
    },
    "Northern America": ["Bermuda", "Canada", "Greenland", "Saint Pierre and Miquelon", "United States of America"],
    "Asia": {
      "Central Asia": ["Kazakhstan", "Kyrgyzstan", "Tajikistan", "Turkmenistan", "Uzbekistan"],
      "Eastern Asia": ["China", "China, Hong Kong Special Administrative Region", "China, Macao Special Administrative Region", "Democratic People's Republic of Korea", "Japan", "Mongolia", "Republic of Korea"],
      "Southern Asia": ["Afghanistan", "Bangladesh", "Bhutan", "India", "Iran (Islamic Republic of)", "Maldives", "Nepal", "Pakistan", "Sri Lanka"],
      "South-Eastern Asia": ["Brunei Darussalam", "Cambodia", "Indonesia", "Lao People's Democratic Republic", "Malaysia", "Myanmar", "Philippines", "Singapore", "Thailand", "Timor-Leste", "Viet Nam"],
      "Western Asia": ["Armenia", "Azerbaijan", "Bahrain", "Cyprus", "Georgia", "Iraq", "Israel", "Jordan", "Kuwait", "Lebanon", "Oman", "Qatar", "Saudi Arabia", "State of Palestine", "Syrian Arab Republic", "Turkey", "United Arab Emirates", "Yemen"]
    },
    "Europe": {
      "Eastern Europe": ["Belarus", "Bulgaria", "Czech Republic", "Hungary", "Poland", "Republic of Moldova", "Romania", "Russian Federation", "Slovakia", "Ukraine"],
      "Northern Europe": ["Åland Islands", "Channel Islands", "Denmark", "Estonia", "Faeroe Islands", "Finland", "Guernsey", "Iceland", "Ireland", "Isle of Man", "Jersey", "Latvia", "Lithuania", "Norway", "Sark", "Svalbard and Jan Mayen Islands", "Sweden", "United Kingdom of Great Britain and Northern Ireland"],
      "Southern Europe": ["Albania", "Andorra", "Bosnia and Herzegovina", "Croatia", "Gibraltar", "Greece", "Holy See", "Italy", "Malta", "Montenegro", "Portugal", "San Marino", "Serbia", "Slovenia", "Spain", "The former Yugoslav Republic of Macedonia"],
      "Western Europe": ["Austria", "Belgium", "France", "Germany", "Liechtenstein", "Luxembourg", "Monaco", "Netherlands", "Switzerland"]
    },
    "Oceania": {
      "Australia and New Zealand": ["Australia", "New Zealand", "Norfolk Island"],
      "Melanesia": ["Fiji", "New Caledonia", "Papua New Guinea", "Solomon Islands", "Vanuatu"],
      "Micronesia": ["Guam", "Kiribati", "Marshall Islands", "Micronesia", "Nauru", "Northern Mariana Islands", "Palau", "Polynesia", "American Samoa", "Cook Islands", "French Polynesia", "Niue", "Pitcairn", "Samoa", "Tokelau", "Tonga", "Tuvalu", "Wallis and Futuna Islands"]
    }
  };

  this.get_location = function() {
    if (Modernizr.geolocation) {
      return navigator.geolocation.getCurrentPosition(window.initialize_with_geocode);
    } else {
      return initialize();
    }
  };

  disableInput = function(scene) {
    var controller;
    controller = scene.getScreenSpaceCameraController();
    controller.enableTranslate = false;
    controller.enableZoom = false;
    controller.enableRotate = false;
    controller.enableTilt = false;
    controller.enableLook = false;
    return true;
  };

  enableInput = function(scene) {
    var controller;
    controller = scene.getScreenSpaceCameraController();
    controller.enableTranslate = true;
    controller.enableZoom = true;
    controller.enableRotate = true;
    controller.enableTilt = true;
    controller.enableLook = true;
    return true;
  };

  addMarker = function(lat, lon, dart) {
    var image;
    if (dart == null) {
      dart = '/images/dart_2_small.png';
    }
    image = new Image();
    image.onload = function() {
      var billboards, textureAtlas;
      billboards = new Cesium.BillboardCollection();
      textureAtlas = cesiumWidget.scene.getContext().createTextureAtlas({
        image: image
      });
      billboards.setTextureAtlas(textureAtlas);
      billboards.add({
        position: ellipsoid.cartographicToCartesian(Cesium.Cartographic.fromDegrees(lon, lat)),
        horizontalOrigin: Cesium.HorizontalOrigin.LEFT,
        verticalOrigin: Cesium.VerticalOrigin.BOTTOM,
        pixelOffset: new Cesium.Cartesian2(0, -28),
        imageIndex: 0
      });
      return cesiumWidget.scene.getPrimitives().add(billboards);
    };
    image.src = dart;
    return true;
  };

  flyTo = function(lat, lon, height, time) {
    var destination, flight;
    if (height == null) {
      height = 1000000;
    }
    if (time == null) {
      time = 3000;
    }
    cesiumWidget.scene.getPrimitives().removeAll();
    destination = Cesium.Cartographic.fromDegrees(lon, lat, height);
    if (!ellipsoid.cartographicToCartesian(destination).equalsEpsilon(cesiumWidget.scene.getCamera().getPositionWC(), Cesium.Math.EPSILON6)) {
      disableInput(cesiumWidget.scene);
      flight = Cesium.CameraFlightPath.createAnimationCartographic(cesiumWidget.scene.getFrameState(), {
        destination: destination,
        duration: time,
        onComplete: function() {
          return enableInput(cesiumWidget.scene);
        }
      });
      cesiumWidget.scene.getAnimations().add(flight);
    }
    return true;
  };

  this.thow_dart = function() {
    $('.current_content').slideUp(500);
    $('#photos_div').slideUp(500);
    $.ajax({
      url: '/cities/random_city',
      method: 'GET',
      dataType: 'json'
    }).done(function(data) {
      window.currentMarker = data;
      thow_dart_animation(data);
      window.location.hash = "" + data.code;
      return $('title').text(currentMarker.city_name.en + '. DartTrip. Travel to a random city. Throw a dart!');
    });
    return true;
  };

  thow_dart_animation = function(random_point) {
    var correction, dart, dart_img, end_left, end_scale, end_top, lat, left_corr, lng, photos_width, slides, start_left, start_scale, start_top, timeout, timeout2;
    lat = random_point.coordinates[0];
    lng = random_point.coordinates[1];
    dart = $('.dart');
    if ($(window).width() >= 960) {
      start_left = $(window).width();
      start_top = ($(window).height() / 100) * 15;
      end_left = start_left / 2;
      end_top = $(window).height() / 2;
      start_scale = '0.7';
      end_scale = '0.4';
      correction = 261;
      left_corr = 103;
      dart_img = '/images/dart_2_small.png';
      photos_width = $(window).width() - 400;
      slides = Math.round(photos_width / 200);
    } else {
      start_left = $(window).width();
      start_top = 30;
      end_left = start_left / 2;
      end_top = 200;
      start_scale = '0.7';
      end_scale = '0.4';
      correction = 60;
      left_corr = 31;
      dart_img = '/images/dart_mobile.png';
      photos_width = $(window).width();
      slides = Math.round(photos_width / 200);
    }
    dart.css({
      'left': start_left + 'px',
      'top': start_top + 'px'
    }).show();
    if (full_version) {
      flyTo(lat, lng, 5000000, 2000);
      timeout = 2000;
      timeout2 = 10;
    } else {
      window.map.entities.clear();
      window.map.setView({
        center: new Microsoft.Maps.Location(lat, lng),
        zoom: 3,
        animate: true
      });
      timeout = 10;
      timeout2 = 10;
    }
    flow.exec(function() {
      query_flickr_photos(random_point.flickr.place_id, this.MULTI("flickr"));
      query_openweathermap(random_point.coordinates, this.MULTI("weather"));
      query_webcams(random_point.coordinates, this.MULTI("webcams"));
      return query_wikipedia_with_id(random_point.wikipedia_array.id, this.MULTI("wikipedia"));
    }, function(results) {
      var cam, images_div, images_html, mySwiper, photo, res_html, wikipedia_info, _i, _j, _len, _len1, _ref, _ref1;
      wikipedia_info = $('#left_info_div');
      images_div = $('#photos_div');
      res_html = "<h3>" + currentMarker.wikipedia_array.title + "</h3>";
      res_html += currentMarker.info;
      if (currentMarker.weather != null) {
        res_html += "<hr/>" + currentMarker.weather;
      }
      if (currentMarker.cams.length > 0) {
        res_html += "<hr/><h3>WebCams nearby</h3> <ul class='thumbnails'>";
        _ref = currentMarker.cams.slice(0, 4);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          cam = _ref[_i];
          res_html += "<li><a href='" + cam.url + "' class='thumbnail' target='_blank'> <img src='" + cam.thumbnail_url + "' /> </a></li>";
        }
        res_html += '</ul>';
      }
      res_html += "<div class='partner_buttons'><a class='flight_ticket' target='_blank' href='http://nano.aviasales.ru/searches/new?destination_iata=" + window.currentMarker.code + "&with_request=true&marker=20466'>TICKET</a>";
      res_html += "<a class='book_hotel' target='_blank' href='http://www.booking.com/searchresults.html?aid=364956&latitude=" + window.currentMarker.coordinates[0] + "&longitude=" + window.currentMarker.coordinates[1] + "&radius=100'>HOTEL</a></div>";
      wikipedia_info.html("<div class='current_content'>" + res_html + "</div>");
      $('meta[name=description]').attr('content', currentMarker.info);
      $('.current_content').slideUp(0).slideDown(500);
      if (typeof window.currentMarker.photos !== 'undefined') {
        images_html = "<div class='swiper-container'> <div class='pagination-car'></div> <div class='swiper-wrapper'>";
        _ref1 = currentMarker.photos.splice(0, 10);
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          photo = _ref1[_j];
          images_html += "<div class='swiper-slide'> " + photo + " </div>";
        }
        images_html += "</div> </div>";
        images_div.html(images_html);
        if (currentMarker.photos.length > 0) {
          images_div.slideDown(500);
          mySwiper = $('.swiper-container').swiper({
            mode: 'horizontal',
            pagination: '.pagination-car',
            loop: true,
            autoPlay: 3000,
            slidesPerSlide: slides
          });
          return mySwiper.startAutoPlay();
        }
      }
    });
    setTimeout(function() {
      return dart.animate({
        'left': end_left + (end_left / 100) * 25,
        'top': 0,
        scale: start_scale
      }, 800, function() {
        dart.animate({
          'left': end_left - left_corr,
          'top': end_top - correction,
          scale: end_scale
        }, 800, function() {
          var anchor, pushpin, pushpinOptions;
          if (full_version) {
            addMarker(lat, lng, dart_img);
            flyTo(lat, lng, 250000, 300);
          } else {
            if ($(window).width() >= 960) {
              anchor = new Microsoft.Maps.Point(0, 134);
              pushpinOptions = {
                icon: 'http://test.allvbg.ru/images/dart_2_small.png',
                text: ' ',
                visible: true,
                width: 138,
                height: 134,
                anchor: anchor
              };
              pushpin = new Microsoft.Maps.Pushpin(new Microsoft.Maps.Location(lat, lng), pushpinOptions);
              window.map.entities.push(pushpin);
              setTimeout(function() {
                return window.map.setView({
                  center: new Microsoft.Maps.Location(lat, lng),
                  zoom: 10,
                  animate: true
                });
              }, 300);
            } else {
              anchor = new Microsoft.Maps.Point(0, 62);
              pushpinOptions = {
                icon: 'http://test.allvbg.ru/images/dart_mobile.png',
                text: ' ',
                visible: true,
                width: 50,
                height: 62,
                anchor: anchor
              };
              pushpin = new Microsoft.Maps.Pushpin(new Microsoft.Maps.Location(lat, lng), pushpinOptions);
              window.map.entities.push(pushpin);
              setTimeout(function() {
                return window.map.setView({
                  center: new Microsoft.Maps.Location(lat, lng),
                  zoom: 10,
                  animate: true
                });
              }, 300);
            }
          }
          setTimeout(function() {
            return dart.css({
              'display': 'none'
            });
          }, timeout2);
          return true;
        });
        return true;
      });
    }, timeout);
    return true;
  };

  query_openweathermap = function(coordinates, callback) {
    if (coordinates == null) {
      coordinates = [10.6735399, -85.202766];
    }
    return $.ajax({
      url: 'http://api.openweathermap.org/data/2.5/weather?',
      method: 'GET',
      crossDomain: true,
      dataType: 'jsonp',
      data: {
        'lat': coordinates[0],
        'lon': coordinates[0]
      }
    }).done(function(data) {
      var html;
      html = "<div class='weather'> <img src='http://openweathermap.org/img/w/" + data.weather[0].icon + ".png'>";
      if (language === 'en') {
        html += "<p>Current temperature is: " + (Math.round(data.main.temp - 273.15)) + "°C</p></div>";
      } else {
        html += "<p>Текущая темпиратура: " + (Math.round(data.main.temp - 273.15)) + "°C</p></div>";
      }
      currentMarker.weather = html;
      if (callback) {
        return callback(data);
      }
    }).fail(function(data) {
      if (callback) {
        return callback(data);
      }
    });
  };

  query_wikipedia_with_id = function(id, callback) {
    var response;
    response = '';
    $.ajax({
      url: "http://en.wikipedia.org/w/api.php",
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
        'redirects': true
      }
    }).done(function(data) {
      var extract, extracts, full_url, key, pages, title;
      pages = data.query.pages;
      title = '';
      extracts = [];
      for (key in pages) {
        title = pages[key].title;
        extracts.push(pages[key].extract);
      }
      full_url = "http://en.wikipedia.org/wiki/" + title;
      extract = $(extracts[0]);
      response = extract.html() + ("... <a href='http://en.wikipedia.org/w/index.php?curid=" + id + "' target='blank'> read more </a>");
      currentMarker.info = response;
      if (callback) {
        return callback(data);
      }
    }).fail(function(data) {
      currentMarker.info = "<a href='http://en.wikipedia.org/w/index.php?curid=" + id + "' target='blank'>Read about this place</a>";
      if (callback) {
        return callback(data);
      }
    });
    return true;
  };

  query_flickr_photos = function(id, callback) {
    $.ajax({
      url: 'http://api.flickr.com/services/rest/?',
      method: 'GET',
      crossDomain: true,
      dataType: 'jsonp',
      jsonpCallback: 'jsonFlickrApi',
      cache: false,
      data: {
        'method': 'flickr.photos.search',
        'format': 'json',
        'accuracy': 11,
        'content_type': 1,
        'place_id': id,
        'radius': 1,
        'media': 'photos',
        'radius_units': 'km',
        'api_key': flickrKey
      }
    }).done(function(data) {
      var imgs, photo, photos, _i, _len;
      photos = data.photos.photo;
      imgs = [];
      for (_i = 0, _len = photos.length; _i < _len; _i++) {
        photo = photos[_i];
        imgs.push("<img src='http://farm" + photo.farm + ".staticflickr.com/" + photo.server + "/" + photo.id + "_" + photo.secret + "_q.jpg' />");
      }
      currentMarker.photos = imgs;
      if (callback) {
        return callback(data);
      }
    }).fail(function(data) {
      if (callback) {
        return callback(data);
      }
    });
    return true;
  };

  query_webcams = function(coordinates, callback) {
    if (coordinates == null) {
      coordinates = [10.6735399, -85.202766];
    }
    return $.ajax({
      url: ' http://api.webcams.travel/rest?',
      method: 'GET',
      crossDomain: true,
      dataType: 'jsonp',
      cache: false,
      data: {
        'method': 'wct.webcams.list_nearby',
        'format': 'json',
        'devid': webcams_devid,
        'lat': coordinates[0],
        'lng': coordinates[1],
        'radius': 10,
        'unit': 'km'
      }
    }).done(function(data) {
      if (data.webcams != null) {
        currentMarker.cams = data.webcams.webcam;
      }
      if (callback) {
        return callback(data);
      }
    });
  };

  form_select2_regions_data = function() {
    var region, result, value;
    result = [];
    for (region in regions) {
      value = regions[region];
      result.push({
        id: region,
        text: region
      });
    }
    return result;
  };

  format = function(item) {
    return item.text;
  };

  form_select2_countries_data = function(sub_regions_array) {
    var country, region, regions_array, result, sub_region, value, _i, _j, _len, _len1, _ref;
    regions_array = $('#region').select2("val");
    console.log(sub_regions_array, regions_array);
    result = [];
    $('#country').select2("val", "").select2("destroy");
    if (regions_array.length > 0) {
      for (_i = 0, _len = regions_array.length; _i < _len; _i++) {
        region = regions_array[_i];
        _ref = regions["" + region];
        for (sub_region in _ref) {
          value = _ref[sub_region];
          if (sub_region.length > 1) {
            for (_j = 0, _len1 = value.length; _j < _len1; _j++) {
              country = value[_j];
              result.push({
                id: country,
                text: country
              });
            }
          }
        }
      }
      return $('#country').select2({
        data: result,
        allowClear: true,
        placeholder: "Any country",
        formatSelection: format,
        formatResult: format,
        multiple: true
      }).unbind('change').change(function(event) {});
    }
  };

  form_select2_sub_regions_data = function(regions_array) {
    var region, result, sub_region, value, _i, _len, _ref;
    result = [];
    $('#sub_region').select2("val", "").select2("destroy");
    if (regions_array.length > 0) {
      for (_i = 0, _len = regions_array.length; _i < _len; _i++) {
        region = regions_array[_i];
        _ref = regions["" + region];
        for (sub_region in _ref) {
          value = _ref[sub_region];
          if (sub_region.length > 1) {
            result.push({
              id: sub_region,
              text: sub_region
            });
          } else {
            result.push({
              id: value,
              text: value
            });
          }
        }
      }
      return $('#sub_region').select2({
        data: result,
        allowClear: true,
        placeholder: "Any subregion",
        formatSelection: format,
        formatResult: format,
        multiple: true
      }).unbind('change').change(function(event) {
        return form_select2_countries_data(event.val);
      });
    }
  };

  init_cessium_map = function() {
    var bing, layers;
    window.cesiumWidget = new Cesium.CesiumWidget('earth_div');
    window.ellipsoid = Cesium.Ellipsoid.WGS84;
    layers = cesiumWidget.centralBody.getImageryLayers();
    bing = new Cesium.BingMapsImageryProvider({
      url: 'http://dev.virtualearth.net',
      key: 'AmhVGlXcVJCaxAht83CRXIID37Krqr_RH8rFjLZMwaakg9s5IzLT2pNBNS7ovsvS',
      mapStyle: Cesium.BingMapsStyle.AERIAL_WITH_LABELS
    });
    layers.addImageryProvider(bing);
    layers.removeAll();
    layers.addImageryProvider(bing);
    return window.full_version = true;
  };

  init_2d_map = function() {
    window.map = new Microsoft.Maps.Map(document.getElementById('earth_div'), {
      credentials: 'AmhVGlXcVJCaxAht83CRXIID37Krqr_RH8rFjLZMwaakg9s5IzLT2pNBNS7ovsvS',
      mapTypeId: Microsoft.Maps.MapTypeId.aerial,
      enableSearchLogo: false,
      showDashboard: false,
      zoom: 3,
      center: new Microsoft.Maps.Location(47.609771, -122.2321543125)
    });
    return window.full_version = false;
  };

  destroy_maps = function() {
    if (window.cesiumWidget) {
      if (!window.cesiumWidget.isDestroyed()) {
        window.cesiumWidget.destroy();
      }
    }
    if (window.map) {
      return window.map.dispose();
    }
  };

  $(function() {
    var canvas, gl, hash;
    if (window.self !== window.top) {
      $('#right_info_div').hide();
    }
    window.full_version = false;
    window.current_mode = 'simple';
    if (window.WebGLRenderingContext) {
      canvas = document.getElementById("webgl-logo");
      gl = canvas.getContext("webgl");
      if (gl) {
        window.full_version = true;
        window.current_mode = '3d';
        init_cessium_map();
      }
    }
    if (window.full_version === false) {
      $('.switch_versions a.3d').hide();
      init_2d_map();
    }
    $('.switch_versions a.3d').click(function() {
      var dart_img, lat, lng;
      if (window.current_mode !== '3d') {
        destroy_maps();
        init_cessium_map();
        window.current_mode = '3d';
        if (window.currentMarker.coordinates) {
          lat = window.currentMarker.coordinates[0];
          lng = window.currentMarker.coordinates[1];
          if ($(window).width() >= 960) {
            dart_img = '/images/dart_2_small.png';
          } else {
            dart_img = '/images/dart_mobile.png';
          }
          addMarker(lat, lng, dart_img);
          return flyTo(lat, lng, 250000, 0);
        }
      }
    });
    $('.switch_versions a.simple').click(function() {
      var anchor, lat, lng, pushpin, pushpinOptions;
      if (window.current_mode !== 'simple') {
        destroy_maps();
        init_2d_map();
        window.current_mode = 'simple';
        if (window.currentMarker.coordinates) {
          lat = window.currentMarker.coordinates[0];
          lng = window.currentMarker.coordinates[1];
          if ($(window).width() >= 960) {
            anchor = new Microsoft.Maps.Point(0, 134);
            pushpinOptions = {
              icon: 'http://test.allvbg.ru/images/dart_2_small.png',
              text: ' ',
              visible: true,
              width: 138,
              height: 134,
              anchor: anchor
            };
          } else {
            anchor = new Microsoft.Maps.Point(0, 62);
            pushpinOptions = {
              icon: 'http://test.allvbg.ru/images/dart_mobile.png',
              text: ' ',
              visible: true,
              width: 50,
              height: 62,
              anchor: anchor
            };
          }
          pushpin = new Microsoft.Maps.Pushpin(new Microsoft.Maps.Location(lat, lng), pushpinOptions);
          window.map.entities.push(pushpin);
          return window.map.setView({
            center: new Microsoft.Maps.Location(lat, lng),
            zoom: 10,
            animate: true
          });
        }
      }
    });
    hash = window.location.hash.split('#')[1];
    if (hash) {
      $.ajax({
        url: "/cities/" + hash,
        method: 'GET',
        dataType: 'json'
      }).done(function(data) {
        if (data.length > 0) {
          window.currentMarker = data[0];
          return thow_dart_animation(data[0]);
        }
      });
    }
    $('#demo_action_button').click(function() {
      thow_dart();
      return false;
    });
    return true;
  });

}).call(this);
