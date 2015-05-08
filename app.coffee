# This imports all the layers for "Framer and Snap" into framerAndSnapLayers
sketch = Framer.Importer.load "imported/Framer and Snap"

# replace sketch step counter with live text
sketch.seconds.image = null
sketch.seconds.html = "30"
sketch.seconds.style =
	color: "black"
	textAlign: "center"
	fontSize: "32px"
	fontWeight: "regular"
	lineHeight: ".8"

sketch.code.image = null
sketch.code.html = Utils.round(Utils.randomNumber(200000,90000))
sketch.code.style =
	color: "black"
	textAlign: "center"
	fontSize: "82px"
	fontWeight: "regular"
	lineHeight: ".8"

# create canvas
canvas = new Layer
	width: 750,
	height: 750,
	backgroundColor: "none"
	superLayer: sketch.secondsback.superLayer
canvas.center()
canvas.y = 390

# fix arrangement of layers
sketch.secondsback.bringToFront()
sketch.seconds.bringToFront()

# create SVG element inside canvas and hook snap into it
canvas.html = "<svg id='svg' style='width:#{canvas.width}px;height:#{canvas.height}px;ignore-events:all;'></svg>"
snap = Snap(canvas.querySelector("#svg"))

# set up some values used to draw the SVG
radius = 300
arc = null # make arc global so everyone can access it
strokeWidth = 20

# draw new arc (have to replace this everytime)
drawAngle = (angle) ->
	# some trigonometry to turn the angle into points on the path
	d = angle
	dr = angle-90 # make 0 degree begin at the top
	radians = Math.PI*(dr)/180 # convert angle to radians
	startx = canvas.width/2
	starty = canvas.height/2 - radius
	endx = canvas.width/2 + radius*Math.cos(radians)
	endy = canvas.height/2 + radius*Math.sin(radians)
	largeArc = 0; largeArc = 1 if d>180

	# remove arc if it already exists
	arc?.remove()

	# create arc using SVG path commands
	arc = snap.path("
				M#{startx},#{starty} # moveTo top of canvas
				# A rx ry x-axis-rotation large-arc-flag sweep-flag x y
				A#{radius},#{radius} 0 #{largeArc},1 #{endx},#{endy} # arc to
			")
			
	# set attributes of SVG path
	arc.attr
		fill: "none"
		stroke: "#FFDD79"
		strokeWidth: "#{strokeWidth}px"
		strokeLinecap: "round"


# draw base circle
circle = snap.circle(canvas.width/2, canvas.height/2, radius)
circle.attr
	fill: "none"
	stroke: "#f3f3f3"
	strokeWidth: "#{strokeWidth}px"

# draw initial angle (a blob)
drawAngle(10)


# set up helper that we use for animation
redBox = new Layer { width: 10, height: 10, backgroundColor: "red" }
redBox.states.add { full: x: 100 }
redBox.states.animationOptions = 
	curve: "linear",
	time: 30

# kickoff initial animation
Utils.delay .25, ->
	redBox.states.next()
	
# animate with the press of a button
sketch.button.on Events.Click, ->
	# animate
	redBox.states.next()

# change SVG when red box moves
redBox.on "change:x", (e) ->
	
	# find new angle
	newAngle = Utils.modulate(e, [0,100], [10,359], true)

	# change arc color depending on progress
	h = Utils.modulate(e, [0,75], [185/360,337/360], true)

	# let's draw!
	drawAngle(newAngle,h)
		
	# change step counter (throttled function)
	sketch.seconds.html = Utils.round(Utils.modulate(redBox.x, [0,100], [30,0], true))
	
		