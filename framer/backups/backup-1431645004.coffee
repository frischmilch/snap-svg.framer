# using Framer with Snap SVG
# snapsvg.io

# This imports all the layers for "Framer and Snap" into framerAndSnapLayers
sketch = Framer.Importer.load "imported/Framer and Snap"

background = new BackgroundLayer
	backgroundColor: "white"

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
template = snap.path("M592.826683,342.697155 L157.173317,342.697155 L237.550258,496.600106 L421.20851,52.0107422 L430.144507,697.989258 L592.826683,342.697155 Z")
template.attr
	fill: "none"
	stroke: "hsb(0,0,.85)"
	strokeWidth: "6px"
	strokeDasharray: pathLength + ' ' + pathLength
	strokeDashoffset: pathLength # set offset to pathlength makes the path invisible

object = snap.path("M592.826683,342.697155 L157.173317,342.697155 L237.550258,496.600106 L421.20851,52.0107422 L430.144507,697.989258 L592.826683,342.697155 Z")

# get to know path length
pathLength = object.getTotalLength()

# change path attributes
object.attr
	fill: "none"
	stroke: "hsb(0,0,0)"
	strokeWidth: "6px"
	strokeLinejoin: "round"
	strokeLinecap: "round"
	strokeDasharray: pathLength + ' ' + pathLength
	strokeDashoffset: pathLength # set offset to pathlength makes the path invisible

# set up PTR object
sketch.ptrCanvas.image = null
sketch.ptrCanvas.html = "<svg id='ptr' style='width:#{sketch.ptrCanvas.width}px;height:#{sketch.ptrCanvas.height}px;ignore-events:all;'></svg>"
ptr = Snap(sketch.ptrCanvas.querySelector("#ptr"))


logo = ptr.path("M82.7308069,45.1461494 L17.2691931,45.1461494 L29.3466948,68.2717265 L56.9433267,1.46738281 L58.2860566,98.5326172 L82.7308069,45.1461494 Z")
logo.transform("translate(0,4) scale(.9)")

logoPath = logo.getTotalLength()

logo.attr
	fill: "none"
	stroke: "hsb(0,0,0)"
	strokeWidth: "3px"
	strokeLinejoin: "round"
#	strokeLinecap: "round"
	strokeDasharray: logoPath + ' ' + logoPath
	strokeDashoffset: logoPath # set offset to pathlength makes the path invisible

# set up helper that we use for animation
redBox = new Layer { width: 10, height: 10, backgroundColor: null }
redBox.states.add { full: x: 100 }
redBox.states.animationOptions = curve: "cubic-bezier(.8,0,.6,1)", time: 2

# show launch image
sketch.launchimage.visible = true
sketch.launchimage.bringToFront()

# hide header
sketch.header.y = sketch.header.height*-1

# create scrollable content
scroller = ScrollComponent.wrap(sketch.list)
scroller.contentInset = 
	top: sketch.header.height
	bottom: 40
scroller.y = 0
scroller.height = Screen.height
scroller.scrollHorizontal = false

# hide scroller
scroller.opacity = 0
scroller.y = 130

# fade out image
Utils.delay 1.5, ->
	sketch.launchimage.animate
		properties:
			opacity: 0
		time: .5

	# kickoff initial animation
	Utils.delay .75, ->
		redBox.states.next()

counter = 1

# change SVG when red box moves
redBox.on "change:x", (e) ->
	
	# offset dash in path from pathlength to 0
	object.attr { strokeDashoffset: Utils.modulate(e, [0,100], [pathLength,0], true) }
	
	# in the end, repeat
	if e >= 100
		if counter < 3
			Utils.delay .3, ->
				counter++
				redBox.states.switchInstant "default"
				redBox.states.next()
		else
			# switch states
			canvas.animate
				properties:
					scale: .5
					opacity: 0
				time: .4
				curve: "ease-in"
			# show content
			sketch.main.placeBehind(sketch.home)
			sketch.main.visible = true
			sketch.header.animate
				properties:
					y: 0
				time: .5
				curve: "ease-out"
				
			# show scrollable content
			Utils.delay .4, ->
				sketch.browsepage.placeBehind(sketch.main)
				sketch.browsepage.visible = true
				scroller.animate
					properties:
						y: 0
						opacity: 1

threshold = 130				

# pull to refresh vector
scroller.on Events.Move, (e) ->
	scrollPos = scroller.scrollY*-1
	
	if scrollPos > 0
		logo.attr
			strokeDashoffset: Utils.modulate(scrollPos, [75,threshold], [logoPath,0], true)
#			stroke: "hsb(0,0,#{Utils.modulate(scrollPos, [75,threshold], [.85,0], true)})"


scroller.on Events.ScrollEnd, (e) ->
	scrollPos = scroller.scrollY*-1

	if scrollPos >= threshold
#		print "released after threshold!"
		# stop animating the content
		scroller.content.animateStop()
		scroller.scrollToPoint(
		    {x:0, y:threshold*-1}, # BUG? cannot scroll to negative value
		    animate = true,
    		animationOptions = {curve:"ease", time:.35}
    	)
    	
    	# reset logo
		logo.attr
    		strokeDashoffset: logoPath
    	
	
	




		

