# using Framer with Snap SVG
# snapsvg.io

# This imports all the layers for "Framer and Snap" into framerAndSnapLayers
sketch = Framer.Importer.load "imported/Framer and Snap"

# replace sketch step counter with live text
sketch.steps.image = null
sketch.steps.html = "0"
sketch.steps.style =
	color: "black"
	textAlign: "center"
	fontSize: "82px"
	fontWeight: "medium"
	lineHeight: ".8"

# create canvas
canvas = new Layer
	width: 750,
	height: 750,
	backgroundColor: "none"
canvas.center()

# create SVG element inside canvas and hook snap into it
canvas.html = "<svg id='svg' style='width:#{canvas.width}px;height:#{canvas.height}px;ignore-events:all;'></svg>"
snap = Snap(canvas.querySelector("#svg"))

# set up some values used to draw the SVG
radius = 300
arc = null # make arc global so everyone can access it
strokeWidth = 40

# draw new arc (have to replace this everytime)
drawAngle = (angle, hue) ->
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
		stroke: "hsb(#{hue},1,.96)"
		strokeWidth: "#{strokeWidth}px"
		strokeLinecap: "round"


# draw base circle
circle = snap.circle(canvas.width/2, canvas.height/2, radius)
circle.attr
	fill: "none"
	stroke: "#e0e0e0"
	strokeWidth: "#{strokeWidth}px"

# draw initial angle (a blob)
drawAngle(0,185/360)


# set up helper that we use for animation
redBox = new Layer { width: 10, height: 10, backgroundColor: "red" }
redBox.states.add { full: x: 82 }
redBox.states.animationOptions = curve: "cubic-bezier(.95,0,.4,1.16)", time: 3 # "spring(125,15,0)"

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
	newAngle = Utils.modulate(e, [0,100], [0,359], true)

	# change arc color depending on progress
	h = Utils.modulate(e, [0,75], [185/360,337/360], true)

	# let's draw!
	drawAngle(newAngle,h)
		
	# change step counter (throttled function)
	changeStepCounter()
	
changeStepCounter = Utils.throttle .05, ->
	sketch.steps.html = Utils.round(Utils.modulate(redBox.x, [0,100], [0,3756], true))
	
		