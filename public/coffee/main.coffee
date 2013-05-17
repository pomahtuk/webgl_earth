bingKey = 'AmhVGlXcVJCaxAht83CRXIID37Krqr_RH8rFjLZMwaakg9s5IzLT2pNBNS7ovsvS';
flickrKey = '903614f7ec5aabd30fda3813428ff755';
flickrSecret = 'c43f15bcdc52ec65';

@GlobalData = {}
@GlobalData.new_cities = []
@GlobalData.flickr_missed = []
@GlobalData.wikipedia_missed = []
@GlobalData.both_missed = []

@currentMarker = {}

@language = 'en'

@regions = {
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
}

@get_location = ->
  if Modernizr.geolocation
    navigator.geolocation.getCurrentPosition(window.initialize_with_geocode)
  else
    initialize()

disableInput = (scene) -> 
    controller = scene.getScreenSpaceCameraController()
    controller.enableTranslate  = false
    controller.enableZoom       = false
    controller.enableRotate     = false
    controller.enableTilt       = false
    controller.enableLook       = false

    true

enableInput = (scene) ->
    controller = scene.getScreenSpaceCameraController()
    controller.enableTranslate  = true
    controller.enableZoom       = true
    controller.enableRotate     = true
    controller.enableTilt       = true
    controller.enableLook       = true

    true

addMarker = (lat, lon, dart = '/images/dart_small.png') ->
    image = new Image();
    image.onload = ->
        billboards = new Cesium.BillboardCollection();
        textureAtlas = cesiumWidget.scene.getContext().createTextureAtlas {
            image : image
        }
        billboards.setTextureAtlas textureAtlas

        billboards.add
            position : ellipsoid.cartographicToCartesian(Cesium.Cartographic.fromDegrees(lon, lat))
            horizontalOrigin : Cesium.HorizontalOrigin.LEFT
            verticalOrigin : Cesium.VerticalOrigin.BOTTOM
            imageIndex : 0

        cesiumWidget.scene.getPrimitives().add billboards

    image.src = dart;

    true

flyTo = (lat, lon, height = 1000000, time = 3000) ->
    cesiumWidget.scene.getPrimitives().removeAll()
    destination = Cesium.Cartographic.fromDegrees lon, lat, height
    #only fly there if it is not the camera's current position
    unless ellipsoid.cartographicToCartesian(destination).equalsEpsilon(cesiumWidget.scene.getCamera().getPositionWC(), Cesium.Math.EPSILON6)
        disableInput(cesiumWidget.scene)
        flight = Cesium.CameraFlightPath.createAnimationCartographic(cesiumWidget.scene.getFrameState(), 
            destination : destination
            duration : time
            onComplete : ->
                enableInput cesiumWidget.scene
        )
        cesiumWidget.scene.getAnimations().add(flight)

    true

@thow_dart = ->
    #$('#left_info_div').hide("slide", { direction: "left" }, 200)
    #$('#right_info_div').hide("slide", { direction: "right" }, 200)
    $('.current_content').slideUp(500)
    $('#photos_div').slideUp(500)
    $.ajax
        url:'/cities/random_city'
        method: 'GET'
        dataType: 'json'
    .done (data) ->
        window.currentMarker = data
        thow_dart_animation data
        window.location.hash = "#{data.code}"
    true

thow_dart_animation = (random_point) ->

    lat = random_point.coordinates[0]
    lng = random_point.coordinates[1]

    dart = $ '.dart'
    if $(window).width() >= 960
        start_left   = $(window).width()
        start_top    = ($(window).height() / 100) * 15
        end_left     = start_left / 2
        end_top      = $(window).height() / 2
        start_scale  = '0.7'
        end_scale    = '0.4'
        correction   = 233
        left_corr    = 103
        dart_img     = '/images/dart_small.png'
        photos_width = $(window).width() - 400
        slides       = Math.round(photos_width / 200)
    else
        start_left   = $(window).width()
        start_top    = 30
        end_left     = start_left / 2
        end_top      = 200
        start_scale  = '0.7'
        end_scale    = '0.4'
        correction   = 67
        left_corr    = 31
        dart_img     = '/images/dart_mobile.png'
        photos_width = $(window).width()
        slides       = Math.round(photos_width / 200)

    dart.css({'left':start_left+'px', 'top': start_top+'px'}).show()

    if full_version
        flyTo lat, lng, 5000000, 2000
        timeout = 2000
        timeout2 = 10
    else
        map.entities.clear()
        map.setView({center: new Microsoft.Maps.Location(lat, lng), zoom: 3, animate: true })
        timeout = 10
        timeout2 = 300

    flow.exec ->
        query_flickr_photos random_point.flickr.place_id, @MULTI("flickr")
        query_openweathermap random_point.coordinates, @MULTI("weather")
        query_wikipedia_with_id random_point.wikipedia_array.id, @MULTI("wikipedia")
    , (results) ->
        wikipedia_info = $('#left_info_div')
        images_div     = $('#photos_div')

        res_html =  "<h3>#{currentMarker.wikipedia_array.title}</h3>"
        res_html += currentMarker.info
        if currentMarker.weather?
            res_html += "<hr/>" + currentMarker.weather

        if currentMarker.places.marks.length > 0 
            res_html += "<hr/>"
            for mark, index in currentMarker.places.marks
                additional_class = 'hidden' if index >= 5
                res_html += "<div class='place #{additional_class}'>
                    <img src='#{mark.icon}'> <b>#{mark.name}</b>
                </div>"
                #<br/>#{mark.vicinity}
            res_html += "<a href='#' class='more_results'>Show more results</a><br>" if currentMarker.places.marks.length >= 5
            if currentMarker.places.legal.length > 0
                res_html += "<br><em>#{currentMarker.places.legal}</em>"

        wikipedia_info.html "<div class='current_content'>#{res_html}</div>"
        $('.current_content').slideUp(0).slideDown(500)
        #wikipedia_info.show("slide", { direction: "left" }, 300)

        $('a.more_results').click ->
            elem = $ @
            $('.place.hidden').removeClass 'hidden'
            elem.remove()

        unless typeof window.currentMarker.photos is 'undefined'
            images_html = "
                <div class='swiper-container'>
                  <div class='pagination-car'></div>
                  <div class='swiper-wrapper'>
            "
            for photo in currentMarker.photos.splice(0, 10)
                images_html += "
                  <div class='swiper-slide'>
                    #{photo}
                  </div>
                "
            images_html += "
                   </div>
                </div>
            "
            images_div.html images_html
            #images_div.width(photos_width)

            if currentMarker.photos.length > 0
                images_div.slideDown(500)
                mySwiper = $('.swiper-container').swiper
                    mode:'horizontal',
                    pagination:'.pagination-car'
                    loop: true
                    autoPlay: 3000
                    slidesPerSlide: slides
                mySwiper.startAutoPlay()
            
        #$('#right_info_div').show("slide", { direction: "right" }, 300)

    setTimeout ->
        dart.animate {'left': end_left + (end_left / 100) * 25, 'top': 0, scale: start_scale}, 800, ->
            dart.animate {'left': end_left-left_corr, 'top': end_top - correction, scale: end_scale}, 800, ->

                if full_version
                    addMarker(lat, lng, dart_img)
                    flyTo lat, lng, 2000000, 300
                else
                    anchor = new Microsoft.Maps.Point(0,134)
                    pushpinOptions = {icon: 'http://test.allvbg.ru/images/dart_small.png', text : ' ', visible: true, width: 138, height: 134, anchor: anchor}
                    pushpin        = new Microsoft.Maps.Pushpin(new Microsoft.Maps.Location(lat, lng), pushpinOptions);
                    map.entities.push(pushpin)
                    setTimeout ->
                        map.setView({center: new Microsoft.Maps.Location(lat, lng), zoom: 8, animate: true });
                    , 300

                setTimeout ->
                    dart.css {'display':'none'}
                , timeout2

                true
            true
    , timeout

    true

query_openweathermap = (coordinates = [10.6735399, -85.202766], callback) ->
    #http://api.openweathermap.org/data/2.5/weather?lat=35&lon=139
    $.ajax
        url:'http://api.openweathermap.org/data/2.5/weather?'
        method: 'GET'
        crossDomain: true
        dataType: 'jsonp'
        data:
            'lat': coordinates[0]
            'lon': coordinates[0]
    .done (data) ->
        html = "<div class='weather'>
            <img src='http://openweathermap.org/img/w/#{data.weather[0].icon}.png'>
        "
        if language is 'en'
            html += "<p>Current temperature is: #{Math.round(data.main.temp-273.15)}°C</p></div>"
        else 
            html += "<p>Текущая темпиратура: #{Math.round(data.main.temp-273.15)}°C</p></div>"

        currentMarker.weather = html
        callback data if callback

    .fail (data) ->
        callback data if callback

query_wikipedia_with_id = (id, callback) ->
    response = '';
    $.ajax
        url:"http://en.wikipedia.org/w/api.php"
        method: 'GET'
        crossDomain: true
        dataType: 'jsonp'
        cache: false
        data:
            'action': 'query',
            'format': 'json',
            'exchars': 500,
            'prop': 'extracts',
            'exlimit': 10,
            'exintro': true,
            'pageids': id,
            'redirects': true,
    .done (data) ->
        pages = data.query.pages
        title = '';
        extracts = []
        for key of pages
          title = pages[key].title
          extracts.push(pages[key].extract)

        full_url = "http://en.wikipedia.org/wiki/#{ title }"
        extract = $(extracts[0])
        #extract.find('p').first().append("")
        response = extract.html() + "... <a href='http://en.wikipedia.org/w/index.php?curid=#{ id }' target='blank'> read more </a>"
        currentMarker.info = response
        callback data if callback

    .fail (data) ->
        currentMarker.info = "<a href='http://en.wikipedia.org/w/index.php?curid=#{ id }' target='blank'>Read about this place</a>"
        callback data if callback

    true

query_flickr_photos = (id, callback) -> 
    # Size Suffixes
    # The letter suffixes are as follows:
    # s   small square 75x75
    # q   large square 150x150
    # t   thumbnail, 100 on longest side
    # m   small, 240 on longest side
    # n   small, 320 on longest side
    # -   medium, 500 on longest side
    # z   medium 640, 640 on longest side
    # c   medium 800, 800 on longest side†
    # b   large, 1024 on longest side*
    # o   original image, either a jpg, gif or png, depending on source format
    $.ajax
        url:'http://api.flickr.com/services/rest/?'
        method: 'GET'
        crossDomain: true
        dataType: 'jsonp'
        jsonpCallback: 'jsonFlickrApi'
        cache: false
        data:
            'method': 'flickr.photos.search'
            'format': 'json'
            'accuracy': 11
            'content_type': 1
            'place_id': id
            'radius': 1
            'media': 'photos'
            'radius_units': 'km'
            'api_key': flickrKey
    .done (data) ->
        photos = data.photos.photo;
        imgs = [];
        for photo in photos            
            imgs.push "<img src='http://farm#{ photo.farm }.staticflickr.com/#{ photo.server }/#{ photo.id }_#{ photo.secret }_q.jpg' />"

        currentMarker.photos = imgs
        callback data if callback

    .fail (data) ->
        callback data if callback

    true

@ru_wikilocation_recursion = (index = 0, limit = 1000) ->
    if index <= cities.length && index <= limit
        city = cities[index]
        wikilocation_info(city, index, (city, index, data) ->
            city.wikipedia_array_ru = data.articles[0]
            GlobalData.new_cities.push city
            ru_wikilocation_recursion(index + 1)
        )

wikilocation_info = (city, index, callback) ->
    $.ajax(
      url: "http://api.wikilocation.org/articles"
      method: "GET"
      crossDomain: true
      dataType: "jsonp"
      jsonpCallback: "addPoi"
      cache: true
      data:
        lng: city.coordinates[1]
        lat: city.coordinates[0]
        limit: 10
        radius: 10000
        locale: 'ru'
        jsonp: "addPoi"
    ).done (data) ->
        callback city, index, data if callback

$ ->
    $.ajax
        url:'/cities/'
        method: 'GET'
        dataType: 'json'
    .done (data) ->
        window.cities = data
    true

    if window.WebGLRenderingContext
    # if false
        window.full_version = true
        window.cesiumWidget = new Cesium.CesiumWidget 'earth_div'
        window.ellipsoid = Cesium.Ellipsoid.WGS84;
        layers = cesiumWidget.centralBody.getImageryLayers(); 
        bing = new Cesium.BingMapsImageryProvider
            url : 'http://dev.virtualearth.net'
            key: 'AmhVGlXcVJCaxAht83CRXIID37Krqr_RH8rFjLZMwaakg9s5IzLT2pNBNS7ovsvS'
            mapStyle : Cesium.BingMapsStyle.AERIAL_WITH_LABELS
        layers.addImageryProvider bing
        layers.removeAll()
        layers.addImageryProvider(bing)
    else
        window.map    = new Microsoft.Maps.Map(document.getElementById('earth_div'), {credentials: 'AmhVGlXcVJCaxAht83CRXIID37Krqr_RH8rFjLZMwaakg9s5IzLT2pNBNS7ovsvS', mapTypeId:Microsoft.Maps.MapTypeId.aerial, enableSearchLogo: false, showDashboard: false, zoom: 3, center: new Microsoft.Maps.Location(47.609771, -122.2321543125)})
        window.full_version = false     

    hash = window.location.hash.split('#')[1]

    if hash
        $.ajax
            url:"/cities/#{hash}"
            method: 'GET'
            dataType: 'json'
        .done (data) ->
            if data.length > 0
                window.currentMarker = data[0]
                thow_dart_animation data[0]
                #window.location.hash = "#{data.code}"

    $('#demo_action_button').click ->
        thow_dart()
        false

    true