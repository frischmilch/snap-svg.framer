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
object = snap.path("M296.050781,171.402344 L78.9492188,171.402344 L119.003906,248.097656 L210.527344,26.5429688 L214.980469,348.457031 L296.050781,171.402344 Z")

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

# adjust object size and position (the coordinates from sketch are not exactly where we need them)
object.transform("translate(50,45) scale(1.75)")



sketch.button.on Events.Click, ->
	# animate
	redBox.states.next()
			
# set up helper that we use for animation
redBox = new Layer { width: 10, height: 10, backgroundColor: "red" }
redBox.states.add { full: x: 100 }
redBox.states.animationOptions = curve: "cubic-bezier(.8,0,.6,1)", time: 2

# kickoff initial animation
Utils.delay .25, ->
	redBox.states.next()

# change SVG when red box moves
redBox.on "change:x", (e) ->
	
	# offset dash in path from pathlength to 0
	object.attr { strokeDashoffset: Utils.modulate(e, [0,100], [pathLength,0], true) }

	# change arc color depending on progress
	h = Utils.modulate(e, [0,75], [185/360,337/360], true)
	object.attr.stroke = "hsb(#{h},1,.5)"

