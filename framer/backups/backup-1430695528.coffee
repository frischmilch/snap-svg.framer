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
object = snap.path("M592.826683,342.697155 L157.173317,342.697155 L237.550258,496.600106 L421.20851,52.0107422 L430.144507,697.989258 L592.826683,342.697155 Z")

# get to know path length
pathLength = object.getTotalLength()

# change path attribute
object.attr
	fill: "none"
	stroke: "hsb(0,0,0)"
	strokeWidth: "6px"
	strokeLinejoin: "round"
	strokeLinecap: "round"
	strokeDasharray: pathLength + ' ' + pathLength
	strokeDashoffset: pathLength # set offset to pathlength makes the path invisible


# set up helper that we use for animation
redBox = new Layer { width: 10, height: 10, backgroundColor: "red" }
redBox.states.add { full: x: 100 }
redBox.states.animationOptions = curve: "cubic-bezier(.8,0,.6,1)", time: 2

# kickoff initial animation
Utils.delay .25, ->
	redBox.states.next()

# animate with the press of a button
sketch.button.on Events.Click, ->
	# animate
	redBox.states.next()

# change SVG when red box moves
redBox.on "change:x", (e) ->
	
	# offset dash in path from pathlength to 0
	object.attr { strokeDashoffset: Utils.modulate(e, [0,100], [pathLength,0], true) }

