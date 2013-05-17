#hash_processing = 

# form_countries_object = ->
#     countries_by_name = {}
#     countries   = window.GlobalData.countries
#     for country in countrues
#         countries_by_name[country.code] = {}
#         countries_by_name[country.code].code = country.code
#         countries_by_name[country.code].name = country.name

#     window.GlobalData.countries_by_name = countries_by_name

#     true

#                                             # @get_ready_for_filters = () ->
#                                             #     GlobalData.countries_with_regions = {}
#                                             #     GlobalData.regions_base = []
#                                             #     GlobalData.misspeled = []
#                                             #     console.log regions
#                                             #     for key, value of regions
#                                             #         unless value.length?
#                                             #             for sub_key, sub_value of value
#                                             #                 if sub_value.length?
#                                             #                     for element in sub_value
#                                             #                         #console.log element, 'region is', key, 'sub region is', sub_key
#                                             #                         @GlobalData.countries_with_regions[element] = 
#                                             #                             name: element
#                                             #                             region : key
#                                             #                             sub_region : sub_key
#                                             #         else
#                                             #             for element in value
#                                             #                 #console.log element
#                                             #                 GlobalData.countries_with_regions[element] = 
#                                             #                     name: element
#                                             #                     region : 'America'
#                                             #                     sub_region : key

#                                             #     get_ready_for_filters_recursion()

#                                             #     true

#                                             # get_ready_for_filters_recursion = (index = 0) ->
#                                             #     if index <= Object.keys(GlobalData.countries_with_regions).length - 1
#                                             #         country_key = Object.keys(GlobalData.countries_with_regions)[index]
#                                             #         country = GlobalData.countries_with_regions[country_key]
#                                             #         get_ready_for_filters_recursion_helper(country, index)
#                                             #     true

#                                             # country_name_prepare = (name) ->
#                                             #     new_name = name.substr(0, 12)
#                                             #     if new_name.indexOf('(') isnt -1
#                                             #         new_name = new_name.substr(0, new_name.indexOf('(') - 1)
#                                             #     #f name.indexOf('Democratic') isnt -1 
#                                             #     #console.log new_name
#                                             #     new_name

#                                             # get_ready_for_filters_recursion_helper = (country, index) ->
#                                             #     console.log country.name
#                                             #     $.ajax
#                                             #         url:"/countries/#{country_name_prepare(country.name)}"
#                                             #         method: 'GET'
#                                             #         dataType: 'json'
#                                             #     .done (data) ->
#                                             #         if data.length is 1 || country.name.indexOf('Congo') isnt -1
#                                             #             console.log data
#                                             #             base_country = data[0]
#                                             #             new_object = 
#                                             #                 code: base_country.code
#                                             #                 name: base_country.name
#                                             #                 un_name: country.name
#                                             #                 region: country.region
#                                             #                 sub_region: country.sub_region
#                                             #             GlobalData.regions_base.push new_object
#                                             #             get_ready_for_filters_recursion(index + 1)
#                                             #             console.log 'data formed'
#                                             #         else
#                                             #             GlobalData.misspeled.push country.name
#                                             #             get_ready_for_filters_recursion(index + 1)
#                                             #     true   

# @reform_geolocation = (index = 0) ->
#     if index < cities.length
#         city = cities[index]
#         reform_geolocation_helper(city, index)

# @stupid_idiot = (index = 0) ->
#     GlobalData.flickr_missed = JSON.parse localStorage.getItem('flickr_missed')
#     GlobalData.wikipedia_missed = JSON.parse localStorage.getItem('wikipedia_missed')
#     GlobalData.both_missed = JSON.parse localStorage.getItem('both_missed')
#     # /manager/cities/remove/:id
#     for city in GlobalData.both_missed
#         $.ajax
#             url:"/cities/#{city.code}"
#             method: 'GET'
#             dataType: 'json'
#         .done (data) ->
#             if data[0]
#                 id = data[0]._id
#                 console.log  'both_missed', id
#                 $.ajax
#                     url:"/manager/cities/remove/#{id}"
#                     method: 'POST'
#                     dataType: 'json'
#                 .done (data) ->
#                     console.log  'removed both_missed', id

#     true
 
# reform_geolocation_helper = (city, index) ->    
#     $.ajax
#         url:"/countries/#{city.country_code}"
#         method: 'GET'
#         dataType: 'json'
#     .done (data) ->
#         if data[0]?
#             geocode_data = city.city_name.en+', '+data[0].name.en
#             GlobalData.missed_countries.push city.country_code
#         else 
#             geocode_data = city.city_name.en+', '+city.country_code
#         #console.log geocode_data
#         flow.exec ->
#             #ajax_get "http://geocode-maps.yandex.ru/1.x/", {geocode:geocode_data, lang:'en-US', kind:'locality', format:'json', limit:1}, 'jsonp', @MULTI("yandex")
#             ajax_get "http://maps.googleapis.com/maps/api/geocode/json", {address:plussify(geocode_data), sensor: false}, 'json', @MULTI("google")
#             ajax_get "http://api.flickr.com/services/rest/", {method:'flickr.places.find', api_key:flickrKey, query:geocode_data, format:'json'}, 'jsonp_flickr', @MULTI("flickr")
#             ajax_get "http://geocoding.cloudmade.com/abbf3a9af5c7416bb53408e4ee447cd0/geocoding/v2/find.js", {query:geocode_data}, 'jsonp', @MULTI("cloudmade")
#             #ajax_get "http://dev.virtualearth.net/REST/v1/Locations", {query:geocode_data, key:bingKey, o:'json'}, 'json_extra', @MULTI("bing")
#         , (results) ->
#             #console.log results
#             # if results.yandex.response.GeoObjectCollection.featureMember.length > 0
#             #     yandex_coordinates = results.yandex.response.GeoObjectCollection.featureMember[0].GeoObject.Point.pos.split(' ').reverse().join(',')
#             #     yandex_name = results.yandex.response.GeoObjectCollection.featureMember[0].GeoObject.name + ', and description: ' + results.yandex.response.GeoObjectCollection.featureMember[0].GeoObject.description
#             if results.google.results
#                 if results.google.results.length > 0
#                     google_coordinates = results.google.results[0].geometry.location.lat + ', ' + results.google.results[0].geometry.location.lng
#                     google_name = results.google.results[0].formatted_address
#             if results.cloudmade.features
#                 if results.cloudmade.features.length > 0
#                     cloudmade_coordinates = results.cloudmade.features[0].centroid.coordinates.join(', ')
#                     cloudmade_name = results.cloudmade.features[0].properties.name + ', and description: '+results.cloudmade.features[0].properties.is_in
#             if results.flickr.places.place
#                 if results.flickr.places.place.length > 0
#                     flickr_coordinates = results.flickr.places.place[0].latitude + ', ' + results.flickr.places.place[0].longitude
#                     flickr_name = results.flickr.places.place[0]._content

#             #console.log yandex_coordinates, yandex_name
#             #console.log google_coordinates, google_name
#             #console.log cloudmade_coordinates, cloudmade_name
#             #console.log flickr_coordinates, flickr_name
#             if google_coordinates?
#                 coordinates = google_coordinates
#             else if cloudmade_coordinates?
#                 coordinates = google_coordinates
#             else if flickr_coordinates?
#                 coordinates = flickr_coordinates

#             if coordinates?
#                 flow.exec ->
#                     wikilocation_info coordinates.split(', '), @MULTI("wiki")
#                     flickr_info coordinates.split(', '), @MULTI("flickr")
#                 , (full_results) ->
#                     new_city = city
#                     new_city.coordinates = coordinates
#                     new_city.wikipedia_array = full_results.wiki.articles[0]
#                     new_city.flickr = full_results.flickr.places.place[0]
#                     #console.log new_city
#                     GlobalData.new_cities.push new_city
#                     console.log 'request done'
#                     reform_geolocation(index + 1)
#             else
#                 reform_geolocation(index + 1)

# plussify = (string) ->
#     result = string.split(' ').join('+')
#     result

# wikilocation_info = (coordinates, callback) ->
#     $.ajax(
#       url: "http://api.wikilocation.org/articles"
#       method: "GET"
#       crossDomain: true
#       dataType: "jsonp"
#       jsonpCallback: "addPoi"
#       cache: true
#       data:
#         lng: coordinates[1]
#         lat: coordinates[0]
#         limit: 10
#         radius: 10000
#         jsonp: "addPoi"
#     ).done (data) ->
#         callback data if callback

# flickr_info = (coordinates, callback) ->
#     $.ajax(
#       url: "http://api.flickr.com/services/rest/?"
#       method: "GET"
#       crossDomain: true
#       dataType: "jsonp"
#       jsonpCallback: "jsonFlickrApi"
#       cache: false
#       data:
#         method: "flickr.places.findByLatLon"
#         format: "json"
#         accuracy: 9
#         lat: coordinates[0]
#         lon: coordinates[1]
#         api_key: flickrKey
#     ).done (data) ->
#         callback data if callback

# ajax_get = (url, q_data, type='jsonp', callback) ->
#     if type is 'jsonp_flickr'
#         $.ajax(
#             method: 'GET'
#             url: url
#             crossDomain: true
#             dataType: 'jsonp'
#             jsonpCallback: 'jsonFlickrApi'
#             data: q_data
#         ).done (data) ->
#             callback data if callback
#     else if type is 'jsonp'
#         $.ajax(
#             method: 'GET'
#             url: url
#             dataType: 'jsonp'
#             data: q_data
#         ).done (data) ->
#             callback data if callback
#     else
#         $.ajax(
#             method: 'GET'
#             url: url
#             data: q_data
#         ).done (data) ->
#             callback data if callback
#     true

# @form_google_places = (index = GlobalData.new_cities.length) ->
#     if index < cities.length
#         city = cities[index]
#         form_google_places_helper(city, index) 

# form_google_places_helper = (city, index) ->
#     flow.exec ->
#         google_ajax_get city, 'en', @MULTI("en")
#         #google_ajax_get city, 'ru', @MULTI("ru")
#     , (results) ->
#         new_city = city
#         new_city.places = {}
#         new_city.places.marks = results.en.results
#         new_city.places.legal = results.en.html_attributions
#         GlobalData.new_cities.push new_city
#         console.log 'request done'
#         form_google_places index + 1

# google_ajax_get = (city, lang, callback) ->
#     $.ajax
#         url:'/gmaps/'
#         method: 'GET'
#         dataType: 'json'
#         data:
#             'location': city.coordinates.join(',')
#             'language': lang
#     .done (data) ->
#         if data.status is 'OK' or data.status is 'ZERO_RESULTS'
#             callback data if callback
#         else
#             console.log 1/0