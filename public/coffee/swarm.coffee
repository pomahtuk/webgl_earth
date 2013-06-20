@swarm_controller = ($scope) ->
  $scope.oil_radius     = 75
  $scope.oil_volume     = 840
  $scope.remove_time    = 10
  $scope.skimmers_count = 14

  $scope.spots_count    = 5

  $scope.count_agents = () ->
    console.log 'change'    

  $scope.start_animation = ($event) ->
    $('.step_1').hide()
    $('.step_2').show()
    $event.preventDefault()

    paper.install window
    canvas = document.getElementById("paperCanvas")
    paper.setup canvas
    size = new Size(800, 800)
    view.viewSize = size
    tool = new Tool()

    paper.Item.inject
      myRotate: (angle) ->
        @my_rotation += angle
        @rotate angle

      my_rotation: 0

    values =
      paths: $scope.spots_count
      minPoints: 5
      maxPoints: 15
      minRadius: 130
      maxRadius: 400

    hitOptions =
      segments: true
      stroke: true
      fill: true
      tolerance: 5

    createPaths = ->
      radiusDelta = values.maxRadius - values.minRadius
      pointsDelta = values.maxPoints - values.minPoints

      for i in  [0..values.paths-1]
        radius = values.minRadius + Math.random() * radiusDelta
        radius = values.maxRadius-50 if i is 0
        points = values.minPoints + Math.floor(Math.random() * pointsDelta)
        path = createBlob(view.size.multiply(Point.random()), radius, points)
        lightness = (Math.random() - 0.5) * 0.4 + 0.4
        hue = Math.random() * 360
        path.position = paper.view.center
        path.fillColor = "#000"
        path.strokeColor = "black"
        path.opacity = 0.4

    createBlob = (center, maxRadius, points) ->
      path = new Path()
      path.closed = true

      for i in [0..points-1]
        delta = new Point(
          length: (maxRadius * 0.5) + (Math.random() * maxRadius * 0.5)
          angle: (360 / points) * i
        )
        path.add(center.add(delta))

      path.smooth()
      path

    window.oilLayer = new Layer();

    createPaths()

    window.skimmersDrawLayer = new Layer();
    window.skimmersLayer = new Layer();

    window.sectorsLayer = new Layer();

    circle_path = new Path.Circle {
        center: view.center
        radius: 120
        strokeColor: 'red'
    }
    circle_path.strokeWidth = 5
    outer_circle_path = new Path.Circle {
        center: view.center
        radius: 385
        strokeColor: 'red'
    }
    outer_circle_path.strokeWidth = 5
    horizon_line = new Path(
      segments: [[15, view.size._height/2],[view.size._width - 15, view.size._height/2]]
      strokeColor: "red"
      strokeWidth: 2
    )
    vertical_line = new Path(
      segments: [[view.size._width/2, 15],[view.size._width/2, view.size._height - 15]]
      strokeColor: "red"
      strokeWidth: 2
    )
    vertical_line_1 = new Path(
      segments: [[486, 318],[667, 125]]
      strokeColor: "red"
      strokeWidth: 2
    )
    vertical_line_2 = new Path(
      segments: [[486, 484],[667, 681]]
      strokeColor: "red"
      strokeWidth: 2
    )
    vertical_line_3 = new Path(
      segments: [[313, 484],[138, 681]]
      strokeColor: "red"
      strokeWidth: 2
    )
    vertical_line_4 = new Path(
      segments: [[313,318],[136,122]]
      strokeColor: "red"
      strokeWidth: 2
    )

    skimmersLayer.activate()

    window.skimmer = new Path.Rectangle
      point: {y: 300, x: 500}
      size: [15, 15]
      strokeColor: 'green'
      fillColor: 'green'

    skimmersDrawLayer.activate()

    # window.skimmer_path = new Path
    #   segments: [{y: 300, x: 500}]
    #   strokeColor: "white"
    #   strokeWidth: 15
    #   opacity: 0.6

    center_of_movenment =
      radius: 100
      center: new Point(400, 400)

    change      = 100
    decrease    = false
    create_path = true

    angle = 0

    view.onFrame = (event) ->
      if decrease is true
        change -= 1
      else
        change += 1
      if change >= center_of_movenment.radius
        decrease    = true
        create_path = true
      if change <= -center_of_movenment.radius
        decrease    = false
        create_path = true

      x = center_of_movenment.center.x + change

      y_change = (change*change) / 100
      #y = (x*x - center_of_movenment.center.x*center_of_movenment.center.x) / 1000 + center_of_movenment.center.y
      y = center_of_movenment.center.y - y_change
      #console.log y

      #console.log change

      # x = center_of_movenment.center.x + Math.round(center_of_movenment.radius*Math.cos(angle))
      # y = center_of_movenment.center.y + Math.round(center_of_movenment.radius*Math.sin(angle))
      # angle = angle + Math.PI/66
      # angle = 0 if angle >= 360

      #console.log y

      skimmer.position = new Point ({y: y, x: x})
      if create_path is true
        if window.skimmer_path
          window.skimmer_path.simplify 10
          window.skimmer_path.smooth
        window.skimmer_path = new Path
          segments: [{y: y, x: x}]
          strokeColor: "white"
          strokeWidth: 15
          opacity: 0.6
        create_path = false
      else
        window.skimmer_path.add skimmer.position
      #skimmer_path.smooth()
      #console.log angle
      #skim_angle = skimmer.my_rotation%360
      #skimmer.rotate(Math.PI/66)


    # draw_path = undefined
    # segment = undefined
    # path = undefined
    # movePath = false

    # tool.onMouseDown = (event) ->
    #   draw_path.selected = false if draw_path      
    #   draw_path = new Path(
    #     segments: [event.point]
    #     strokeColor: "white"
    #     strokeWidth: 1
    #     fullySelected: false
    #     #opacity: 0.5
    #   )

      # segment = path = null
      # hitResult = project.hitTest(event.point, hitOptions)
      # return  unless hitResult
      # if event.modifiers.shift
      #   hitResult.segment.remove()  if hitResult.type is "segment"
      #   return
      # if hitResult
      #   path = hitResult.item
      #   if hitResult.type is "segment"
      #     segment = hitResult.segment
      #   else if hitResult.type is "stroke"
      #     location = hitResult.location
      #     segment = path.insert(location.index + 1, event.point)
      #     path.smooth()
      # movePath = hitResult.type is "fill"
      # project.activeLayer.addChild hitResult.item  if movePath

    # tool.onMouseDrag = (event) ->
    #   draw_path.add event.point
    #   if segment
    #     segment.point = event.point
    #     path.smooth()
    #   path.position += event.delta  if movePath

    # tool.onMouseUp = (event) ->
    #   window.ppp = event.point
    #   draw_path.simplify 10      
    #   #draw_path.fullySelected = true
    tool.onMouseMove = (event) ->
      project.activeLayer.selected = false
      for layer in project.layers
        layer.selected = false
      event.item.selected = true  if event.item

    view.draw()

    true

  $scope.show_parameters = ($event) ->
    $('.step_2').hide()
    $('.step_1').show()
    $event.preventDefault()