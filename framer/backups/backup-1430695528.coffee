# using Framer with Snap SVG
# snapsvg.io

# This imports all the layers for "Framer and Snap" into framerAndSnapLayers
sketch = Framer.Importer.load "imported/Framer and Snap"

# create canvas
canvas = new Layer
	width: 750,
	height: 750,
	backgroundColor: "none"
canvas.center()

# create SVG element inside canvas and hook snap into it
canvas.html = "<svg id='svg' style='width:#{canvas.width}px;height:#{canvas.height}px;ignore-events:all;'></svg>"
snap = Snap(canvas.querySelector("#svg"))

# draw custom SVG object (exported vector from sketch, paste d attribute of path here)
# if artboard was the same width/size of the screen, the coordinates will match
# if not, apply object.transform("translate(50,45) scale(1.75)") to adjust
object = snap.path("M592.826683,342.697155 L241.171668,342.697155 C194.780659,342.697155 174.582972,376.032553 196.059495,417.155047 L198.664079,422.142214 C220.140323,463.264172 251.909002,461.841282 269.619837,418.967906 L389.138931,129.642942 C406.850471,86.7678617 421.7288,89.6222072 422.370435,136.00564 L428.982583,613.99436 C429.624296,660.383461 445.798522,663.801445 465.11884,621.606557 L592.826683,342.697155 Z")

# get to know path length
pathLength = object.getTotalLength()

# change path attribute
object.attr
	fill: "none"
	stroke: "hsb(0,0,.8)"
	strokeWidth: "6px"
	strokeLinejoin: "round"
	strokeLinecap: "round"
	strokeDasharray: pathLength + ' ' + pathLength
	strokeDashoffset: pathLength # set offset to pathlength makes the path invisible

# create a new reference layer that is at the same position as canvas
layerAtCanvas = new Layer
	x: canvas.x
	y: canvas.y
	backgroundColor: null
	clip: false # so we can have all objects inside this layer be visible

# create the layer we want to move along path animate and put into reference layer
logo = new Layer
	image: "images/framer-icon.png"
	superLayer: layerAtCanvas


# set up helper that we use for animation
redBox = new Layer { width: 10, height: 10, backgroundColor: "red" }
redBox.states.add { full: x: 100 }
redBox.states.animationOptions = curve: "cubic-bezier(.8,0,.6,1)", time: 3

# kickoff initial animation
redBox.states.next()

# animate everytime the button is pushed
sketch.button.on Events.Click, ->
	# animate
	redBox.states.next()

# change SVG when red box moves
redBox.on "change:x", (e) ->
		
	# offset dash in path from pathlength to 0
	object.attr { strokeDashoffset: Utils.modulate(e, [0,100], [pathLength,0], true) }
	
	# find point on path along
	pointOnPath = object.getPointAtLength ( Utils.modulate(e, [0,100], [0,pathLength], true) )
	# position circle at that point
	logo.midX = pointOnPath.x
	logo.midY = pointOnPath.y

	# change arc color depending on progress
	h = Utils.modulate(e, [0,75], [185/360,337/360], true)
	object.attr.stroke = "hsb(#{h},1,.5)"

