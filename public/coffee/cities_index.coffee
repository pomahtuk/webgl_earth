@app = angular.module("myApp", ["ui.bootstrap"]).config ($routeProvider) ->
  $routeProvider.when("/cities", {templateUrl: "/manager/cities-list.html", controller: cities_controller})
  .when("/cities/new", {templateUrl: "/manager/city-detail.html", controller: cities_create_controller})
  .when("/cities/:cityid", {templateUrl: "/manager/city-detail.html", controller: cities_edit_controller})
  .otherwise({redirectTo: "/cities"})
  true

@app.filter "startFrom", ->
  (input, start) ->
    if input
      start = +start #parse to int
      return input.slice(start)
    []

@stripSlashes = (string) ->
    string.replace(/\\(.)/mg, "$1")

google_initialize = ($scope) ->
 
  if $scope.city.coordinates?
    coordinates = $scope.city.coordinates
  else
    coordinates = [-34.397, 150.644]

  mapOptions =
    center: new google.maps.LatLng(coordinates[0], coordinates[1])
    zoom: 8
    mapTypeId: google.maps.MapTypeId.ROADMAP

  map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions)

  myLatlng = new google.maps.LatLng(coordinates[0], coordinates[1])
  marker = new google.maps.Marker
    position: myLatlng
    map: map
    draggable: true

  google.maps.event.addListener marker, "dragend", ->
    $scope.city.coordinates = [marker.position.lat(), marker.position.lng()]
    $scope.$digest()

@cities_create_controller = ($scope, $http, $routeParams, $location) ->
  $scope.city  = {}

  $scope.save_data = ->
    $http.post("/manager/cities/", $scope.city).success () ->
      $location.path( "/cities" )

  $scope.to_list = ->
    $location.path( "/cities" )

  $scope.wiki_modal = ($event) ->
    $http.jsonp("http://api.wikilocation.org/articles?lng=#{$scope.city.coordinates[1]}&lat=#{$scope.city.coordinates[0]}&limit=10&radius=50000&jsonp=JSON_CALLBACK").success (data) ->
      $scope.wiki_response = data.articles
      $('#wiki_modal').modal('show')
    $event.preventDefault()

  $scope.google_modal = ($event) ->
    $http.get("/gmaps/?language=en&location=#{$scope.city.coordinates.join(',')}").success (data) ->
      $scope.google_response = data
      $('#google_modal').modal('show')
    $event.preventDefault()

  $scope.flickr_modal = ($event) ->
    $event.preventDefault()
    $http.jsonp("http://api.flickr.com/services/rest/?method=flickr.places.findByLatLon&format=json&accuracy=11&lat=#{$scope.city.coordinates[0]}&lon=#{$scope.city.coordinates[1]}&api_key=903614f7ec5aabd30fda3813428ff755&jsoncallback=JSON_CALLBACK").success (data) ->
      $scope.flickr_response = data.places.place
      $('#flickr_modal').modal('show')

  $scope.apply_flickr = () ->
    $scope.city.flickr = $scope.flickr_response[0]

  $scope.apply_wikipedia = () ->
    $scope.city.wikipedia_array = JSON.parse $scope.wiki_response.selected

  $scope.apply_google = () ->
    $scope.city.places = {}
    $scope.city.places.marks = $scope.google_response.results
    $scope.city.places.legal = $scope.google_response.html_attributions

  setTimeout ->
    google_initialize($scope)
  , 10

@cities_edit_controller = ($scope, $http, $routeParams, $location, $filter) ->
  $http.get("/cities/#{$routeParams.cityid}").success (data) ->
    $scope.city = data[0]
    console.log $scope.city
    google_initialize($scope)

  $scope.city  = {}

  $scope.save_data = ->
    $http.post("/manager/cities/#{$scope.city._id}", $scope.city).success () ->
      $location.path( "/cities" )

  $scope.to_list = ->
    $location.path( "/cities" )

  $scope.wiki_modal = ($event) ->
    $http.jsonp("http://api.wikilocation.org/articles?lng=#{$scope.city.coordinates[1]}&lat=#{$scope.city.coordinates[0]}&limit=10&radius=50000&jsonp=JSON_CALLBACK").success (data) ->
      $scope.wiki_response = data.articles
      $('#wiki_modal').modal('show')
    $event.preventDefault()

  $scope.google_modal = ($event) ->
    $http.get("/gmaps/?language=en&location=#{$scope.city.coordinates.join(',')}").success (data) ->
      $scope.google_response = data
      $('#google_modal').modal('show')
    $event.preventDefault()

  $scope.flickr_modal = ($event) ->
    $event.preventDefault()
    $http.jsonp("http://api.flickr.com/services/rest/?method=flickr.places.findByLatLon&format=json&accuracy=11&lat=#{$scope.city.coordinates[0]}&lon=#{$scope.city.coordinates[1]}&api_key=903614f7ec5aabd30fda3813428ff755&jsoncallback=JSON_CALLBACK").success (data) ->
      $scope.flickr_response = data.places.place
      $('#flickr_modal').modal('show')

  $scope.apply_flickr = () ->
    $scope.city.flickr = $scope.flickr_response[0]

  $scope.apply_wikipedia = () ->
    $scope.city.wikipedia_array = JSON.parse $scope.wiki_response.selected

  $scope.apply_google = () ->
    $scope.city.places = {}
    $scope.city.places.marks = $scope.google_response.results
    $scope.city.places.legal = $scope.google_response.html_attributions

@cities_controller = ($scope, $http, $filter, $location) ->
  $scope.currentPage = 1 #current page
  $scope.maxSize     = 11 #pagination max size
  $scope.entryLimit  = 10 #max rows for data table  

  # # init pagination with $scope.cities 
  $scope.setPage = (pageNo) ->
    $scope.currentPage = pageNo

  $scope.cities  = []
  $scope.search  = ''

  $http.get('/cities/?manager=true').success (data) ->
    $scope.cities = data
    $scope.noOfPages = Math.ceil($scope.cities.length / $scope.entryLimit)

  $scope.filter = ->
    $scope.filtered  = $filter("filter")($scope.cities, $scope.search).length
    $scope.noOfPages = Math.ceil($scope.filtered / $scope.entryLimit)

  $scope.delete_city = ($event) ->
    id = $event.target.hash.split('#')[1]
    if confirm("Are you sure? Thic action can't be undone! Delete this city?") is true
      $http.delete("/manager/cities/#{id}").success (data) ->
        $location.path( "/cities" )
    else
      console.log 'cancel'
    $event.preventDefault()
