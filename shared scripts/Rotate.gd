extends Node2D

const pointscene: PackedScene = preload("res://point.tscn")

@export var pointtexture: Texture2D = preload("res://pointR.png")
@export var Param0: int = 3140
@export var rotationpoint: int = 0 
@export var color: Color = Color(.92,.98,.98)
@export var railtexture: Texture2D = load("res://railwhite.png")
@onready var idnum = get_parent().get_parent().idnum

var locked = false
var segments = 1
var lines = []
var points = []
var loading = false
var speed = 2.5
var drag = false
var buttons = []
var firstpoint = true

var rail

var fillamount: int = 10 #amount of points for the interpolation tool/slope thing
var fillmode:bool = false

func focus_entered():
	$rotation.show()
	$speed.show()

func focus_exited():
	$rotation.hide()
	$speed.hide()

func _ready():
	$start.show()
	loading = get_parent().loading
	var inst = load("res://rail.tscn").instantiate()
	add_child(inst)
	move_child(inst, 0)
	
	
	rail = inst
	rail.texture = railtexture
	$rotation.connect("focus_entered", Callable(self, "focus_entered"))
	$rotation.connect("focus_exited", Callable(self, "focus_exited"))
	$speed.connect("focus_entered", Callable(self, "focus_entered"))
	$speed.connect("focus_exited", Callable(self, "focus_exited"))
	$speed.set_caret_column(7)
	if loading == false:
		$start.position = owner.get_parent().roundedmousepos
	else:
		$rotation.hide()
		$speed.hide()
	$crank.position = $start.position
	$rotation.position = $crank.position + Vector2(-20,-100)
	$speed.position = $crank.position + Vector2(-20,-156)
	buttons.append($crank/Button)
	rail.add_point($start.position)
	$crank.rail.add_point($start.position)
	
	$start.set_data()

var data:PackedStringArray = ["            - Points:"]

var previousdata:PackedStringArray
var previousend:PackedStringArray

@onready var end:PackedStringArray = ["              closed: CLOSE",
"              comment: !l -1",
"              id_name: rail" + str(idnum),
"              layer: LC",
"              link_info: []",
"              link_num: !l 0",
"              name: レール",
"              num_pnt: !l 2",
"              param0: " + str(Param0) + ".00000",
"              param1: " + str(int($rotation.text)), #max degree tilt
"              param2: "+str(speed)+"0000", #speed
"              param3: "+str(rotationpoint), #This is the point it rotates from: 0 = 1st 1 = 2nd ect.
"              param4: 0.00000",
"              param5: -1.00000",
"              param6: -1.00000",
"              param7: 3.00000",
"              param8: -1.00000",
"              param9: -1.00000",
"              type: Linear",
"              unit_name: Path"]

func propertyclose():
	#add the undo log
	var currentdata = get_data()
	if currentdata != previousdata or end != previousend:
		owner.get_parent().undolistadd({"Type":"PropertyRail","Data":[previousdata,currentdata,previousend,end],"Node":self})
		previousdata = currentdata
		previousend = end

func change_points(points_array:Array,startpoint,endpoint) -> Array:
	var linearray = []
	var previouspoint = null
	for point in points_array:
		point.reposition()
		if previouspoint != null:
			linearray.append([previouspoint.position,point.position])
		previouspoint = point
	startpoint.position = endpoint.position
	return linearray

func set_point_data(newdata:PackedStringArray):
	var pointdata = newdata.duplicate()
	if pointdata.size()<1:
		return
	data = [pointdata[0]]
	pointdata.remove_at(0)
	for point in points:
		point.pointdata = pointdata.slice(0,24)
		var loop = 24
		while loop > 0:
			pointdata.remove_at(0)
			loop -= 1



func reposition():
	lines = change_points(points,$start,$end)
	for line in end:
		if line.begins_with("              param0:"): #get the point kind
			var newpointtexture = preload("res://point.png")
			var rotatetexture = preload("res://pivotR.png")
			$crank.rail.texture = preload("res://railPurple.png")
			rail.texture = preload("res://rail.png")
			$crank2.hide()
			remove_from_group("EndSpin")
			remove_from_group("AutoSpin")
			
			
			#spin
			if line.begins_with("              param0: 3110"):
				newpointtexture = preload("res://pointL.png")
				$crank.rail.texture = preload("res://railblue.png")
				rail.texture = preload("res://railwhite.png")
				rotatetexture = preload("res://crankL.png")
			if line.begins_with("              param0: 3111"):
				newpointtexture = preload("res://pointR.png")
				$crank.rail.texture = preload("res://rail.png")
				rail.texture = preload("res://railwhite.png")
				rotatetexture = preload("res://crankR.png")
			#L points
			if line.begins_with("              param0: 3140") or line.begins_with("              param0: 3150"):
				newpointtexture = preload("res://pointL.png")
				$crank.rail.texture = preload("res://railblue.png")
				rail.texture = preload("res://railwhite.png")
				rotatetexture = preload("res://pivotL.png")
			#R points
			if line.begins_with("              param0: 3141"):
				newpointtexture = preload("res://pointR.png")
				$crank.rail.texture = preload("res://rail.png")
				rail.texture = preload("res://railwhite.png")
			#Auto points
			if line.begins_with("              param0: 3200") or line.begins_with("              param0: 3300") or line.begins_with("              param0: 3322") or line.begins_with("              param0: 3423"):
				add_to_group("AutoSpin")
				newpointtexture = preload("res://pointA.png")
				$crank.rail.texture = preload("res://railGreen.png")
				rail.texture = preload("res://railwhite.png")
				rotatetexture = preload("res://pivotA.png")
			
			#End Points
			if line.begins_with("              param0: 3380"):
				newpointtexture = preload("res://PointE0.png")
				rotatetexture = preload("res://PivotE0.png")
			if line.begins_with("              param0: 3381"):
				newpointtexture = preload("res://PointE1.png")
				rotatetexture = preload("res://PivotE1.png")
			if line.begins_with("              param0: 3382"):
				newpointtexture = preload("res://PointE2.png")
				rotatetexture = preload("res://PivotE2.png")
			if line.begins_with("              param0: 3383"):
				newpointtexture = preload("res://PointE3.png")
				rotatetexture = preload("res://PivotE3.png")
			if line.begins_with("              param0: 3384"):
				newpointtexture = preload("res://PointE4.png")
				rotatetexture = preload("res://PivotE4.png")
			if line.begins_with("              param0: 3385"):
				newpointtexture = preload("res://PointE5.png")
				rotatetexture = preload("res://PivotE5.png")
			if line.begins_with("              param0: 3386"):
				newpointtexture = preload("res://PointE6.png")
				rotatetexture = preload("res://PivotE6.png")
			if line.begins_with("              param0: 3387"):
				newpointtexture = preload("res://PointE7.png")
				rotatetexture = preload("res://PivotE7.png")
			if line.begins_with("              param0: 3388"):
				newpointtexture = preload("res://PointE8.png")
				rotatetexture = preload("res://PivotE8.png")
			if line.begins_with("              param0: 3389"):
				newpointtexture = preload("res://PointE9.png")
				rotatetexture = preload("res://PivotE9.png")
			if line.begins_with("              param0: 3390"):
				newpointtexture = preload("res://PointE10.png")
				rotatetexture = preload("res://PivotE10.png")
			if line.begins_with("              param0: 3391"):
				newpointtexture = preload("res://PointE11.png")
				rotatetexture = preload("res://PivotE11.png")
			if line.begins_with("              param0: 3392") or line.begins_with("              param0: 3393") or line.begins_with("              param0: 3394"):
				newpointtexture = preload("res://pointE.png")
				rotatetexture = preload("res://pivotEnd.png")
			if line.begins_with("              param0: 3112"): # tilt platforsm
				newpointtexture = preload("res://pointL.png")
				$crank.rail.texture = preload("res://railblue.png")
				rail.texture = preload("res://railwhite.png")
				$crank2.show()
				$crank2.rail.texture = preload("res://raildarkblue.png")
				rotatetexture = preload("res://pivotLS.png")
			if line.begins_with("              param0: 3113"):
				newpointtexture = preload("res://pointR.png")
				$crank.rail.texture = preload("res://rail.png")
				rail.texture = preload("res://railwhite.png")
				$crank2.show()
				$crank2.rail.texture = preload("res://railmaroon.png")
				rotatetexture = preload("res://pivotRS.png")
			for point in points:
				point.texture = newpointtexture
			
			if $crank.rail.texture == preload("res://railPurple.png"):
				add_to_group("EndSpin")
			
			$end.texture = newpointtexture
			$start.texture = newpointtexture
			$crank/crank.texture = rotatetexture
			$crank2/crank2.texture = rotatetexture
	$crank.position = points[0].position
	var text = end[9]
	text = text.erase(0,22)
	if -float(text) == -int(text): #keeps number simple
		$rotation.text = str(-int(text))
	else:
		$rotation.text = str(-float(text))
	text = end[10].erase(0,22)
	if float(text) == int(text): #keeps number simple
		$speed.text = str(int(text))
	else:
		$speed.text = str(float(text))
	speed = float(text)
	$crank.target = float($rotation.text)
	$rotation.prev = $rotation.text
	$crank.rotation_degrees = 0
	$rotation.position = $crank.position + Vector2(-20,-100)
	$speed.position = $crank.position + Vector2(-20,-156)
	
	idnum = int(end[2].lstrip("              id_name: rail"))
	#update the visuals
	rail.points = []
	get_node("crank").rail.points = []
	for point in points:
		rail.add_point(point.position)
		get_node("crank").rail.add_point(point.position)
		rail.add_point(point.position)
		get_node("crank").rail.add_point(point.position)
		point.scale = Vector2(.25,.25)
	$end.scale = Vector2(.35,.35)
	changepivotpoint()

func changepivotpoint():
	var line = end[11]
	line = line.erase(19,1)
	if int(line.lstrip("              param: ")) != 0 and  int(line.lstrip("              param: ")) != -1:
		var oldpos = $crank.position
		var targetswappoint = null
		if points.size()-1 < int(line.lstrip("              param: ")):
			$crank.position = $end.position #last point not in point array aab
			targetswappoint = $end
			
		else:
			$crank.position = points[int(line.lstrip("              param: "))].position
			targetswappoint = points[int(line.lstrip("              param: "))]
			targetswappoint.scale = Vector2(.35,.35)
		targetswappoint.position = oldpos
	$start.position = $end.position

func _process(delta):
	#update the lines
	queue_redraw()
	if Input.is_action_just_pressed("accept"):
		$rotation.hide()
		$speed.hide()
	
	var amount = 0
	var pressed = false
	for button in buttons:
		if button.is_hovered():
			amount += 1
		if button.button_pressed:
			pressed = true
	
	if amount != 0: #button is hovered
		if Input.is_action_just_pressed("MoveToBack"):
			owner.get_parent().move_child(owner,10)
		match owner.get_parent().item:
			"tooledit":
				modulate = Color.GREEN_YELLOW
				if pressed:
					get_node("rotation").show()
					get_node("rotation").grab_focus()
					get_node("rotation").set_caret_column(7)
					get_node("speed").set_caret_column(7)
			"tooldelete":
				modulate = Color.RED
				if pressed:
					owner.get_parent().delete(owner)
					owner.get_parent().undolistadd({"Type":"Delete","Node":owner})
			"toolproperty":
				modulate = Color.LIGHT_SKY_BLUE
				if pressed and owner.get_parent().propertypanel == false:
					get_parent().get_parent().editednode = self
					get_parent().get_parent().propertypanel = true
					get_parent().get_parent().parse([get_data(),end])
					previousdata = get_data()
					previousend = end
					return
	else:
		modulate = Color.WHITE
	if locked == false and fillmode == false:
		if Input.is_action_just_pressed("addpoint"):
			newseg()
			
		if Input.is_action_just_pressed("bridge"):
			newseg()
			points.append($end)
			$end.segments = segments-1
			$end.set_data()
			loading = true
			locked = true
			end[9] = "              param1: " + str(-float($rotation.text)) #max degree tilt
			get_parent().get_parent().idnum += 1
			get_parent().get_parent().lineplacing = true
			buttons.append(get_node("end/Button"))
			$rotation.grab_focus()
			$rotation.set_caret_column(3)
	$crank.target = float($rotation.text)
	if Input.is_action_just_pressed("Shift"):
		fillmode = not fillmode
		

func newseg():
	lines.append([$start.position,$end.position])
	rail.add_point($end.position)
	$crank.rail.add_point($end.position)
	rail.add_point($end.position)
	$crank.rail.add_point($end.position)
	var newpoint = pointscene.instantiate()
	newpoint.texture = pointtexture
	newpoint.position = $start.position
	if firstpoint == true:
		newpoint.hide()
		firstpoint = false
		$start.self_modulate.a = 1
	add_child(newpoint)
	points.append(newpoint)
	buttons.append(newpoint.get_node("Button"))
	$end.set_data()
	segments += 1
	
	if segments == 2:
		newpoint.get_node("start").queue_free()
		newpoint.frame = 0
	$start.position = $end.position
	$start.frame = 1

func _on_speed_change():
	speed = float($speed.text)
	var loop = 0
	for dat in end:
		if dat.begins_with("              param2:"):
			break
		loop += 1
	end[loop] = "              param2: " + str(speed)
	$crank.rotation_degrees = 0

func done():
	points.append($end)
	$end.segments = segments-1
	$end.set_data()
	locked = true
	get_parent().get_parent().idnum += 1
	get_parent().get_parent().lineplacing = true
	buttons.append(get_node("end/Button"))

func _input(event):
	if event is InputEventMouseButton and fillmode and locked == false and loading == false:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			fillamount += 1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and fillamount > 2:
			fillamount -= 1

func pointcurve():
	if fillmode and locked == false:
		var changerate = 1.0/fillamount
		var weight = changerate
		var dots = []
		var cycle = fillamount
		while cycle > 1:
			dots.append($start.position.cubic_interpolate($end.position,$start/handle.global_position+$start/handle.position,$end/handle.global_position+$end/handle.position,weight))
			weight += changerate
			cycle -= 1
		for point in dots:
			draw_circle(point,5,Color.DIM_GRAY)
		if Input.is_action_just_pressed("addpoint") and not $end/handle.is_hovered() and not $start/handle.is_hovered() or Input.is_action_just_pressed("bridge"):
			dots.append($end.position)
			for point in dots:
				$end.position = point
				newseg()
			fillmode = false
			$start/handle.position = Vector2(-45,-14)
			$end/handle.position = Vector2(20,-14)
		if Input.is_action_just_pressed("bridge"):
			loading = true
			locked = true
			end[9] = "              param1: " + str(-float($rotation.text)) #max degree tilt
			get_parent().get_parent().idnum += 1
			get_parent().get_parent().lineplacing = true
			buttons.append(get_node("end/Button"))
			$rotation.grab_focus()
			$rotation.set_caret_column(3)

func _draw():
	if loading == false and locked == false and fillmode == false:
		$end.position = owner.get_parent().roundedmousepos
	draw_line($start.position,$end.position,color,4.5)
	if loading == false and locked == false:
		pointcurve()

func get_data():
	var totalpointdata:PackedStringArray = []
	for point in points:
		totalpointdata.append_array(point.pointdata)
	return data + totalpointdata

func EXPORT():
	if end != null:
		if end[9] != null:
			end[9] = "              param1: " + str(-$crank.target)
			get_parent().get_parent().bridgedata += get_data() + end
