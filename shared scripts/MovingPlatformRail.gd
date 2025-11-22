extends Rail


var speed = 2
var mode = 0 #0 = path 1 = platform
var childrail = null
@export var railscene: PackedScene = preload("res://RMove.tscn")


var previousplatdata: PackedStringArray
var previousplatend: PackedStringArray


func _ready():
	if end[9].begins_with("              param1: 0"): # invisible
		color = Color(.7,.7,.7,.5)
	else:
		color = Color(.2,.2,.2)
	if loading == false:
		$start.position = get_parent().roundedmousepos
	
	data = ["            - Points:",
"                - comment: !l -1",
"                  dir_x: 0.00000",
"                  dir_y: 0.00000",
"                  dir_z: 0.00000",
"                  id_name: rail" + str(idnum) + "/0",
"                  link_info: []",
"                  link_num: !l 0",
"                  param0: -1.00000",
"                  param1: -1.00000",
"                  param2: -1.00000",
"                  param3: -1.00000",
"                  pnt0_x: " + str($start.position.x),
"                  pnt0_y: " + str(-$start.position.y),
"                  pnt0_z: 0.00000",
"                  pnt1_x: " + str($start.position.x),
"                  pnt1_y: " + str(-$start.position.y),
"                  pnt1_z: 0.00000",
"                  pnt2_x: " + str($start.position.x),
"                  pnt2_y: " + str(-$start.position.y),
"                  pnt2_z: 0.00000",
"                  scale_x: 1.00000",
"                  scale_y: 1.00000",
"                  scale_z: 1.00000",
"                  unit_name: Point"]

func propertyclose():
	#add the undo log
	if data != previousdata or end != previousend or childrail.data != previousplatdata or childrail.endplat != previousplatend:
		get_parent().undolistadd({"Type":"PropertyMoveRail","Data":[previousdata,data,previousend,end,previousplatdata,childrail.data,previousplatend,childrail.endplat],"Node":self})
		previousdata = data
		previousend = end
		previousplatdata = childrail.data
		previousplatend = childrail.endplat

func reposition():
	lines = []
	for point in points:
		point.reposition()
		lines.append(point.position)
	idnum = int(end[2].lstrip("              id_name: rail"))
	childrail.path = []
	for line in points:
		childrail.path.append(line.position)
	childrail.path.append($end.position)
	childrail.get_node("preview").offset = Vector2.ZERO
	
	for line in childrail.endplat: #change appearence of things based on their type
		if line.begins_with("              param0:"): #get the point kind
			var pointtexture = preload("res://point.png")
			childrail.get_node("preview").rail.texture = preload("res://railPurple.png")
			childrail.rail.texture = preload("res://rail.png")
			childrail.midImage = null
			remove_from_group("AutoMove")
			remove_from_group("EndMove")
			
			#fan
			if line.begins_with("              param0: 2150"):
				childrail.midImage = preload("res://fan.png")
				childrail.rail.texture = preload("res://railwhite.png")
			#L points
			elif line.begins_with("              param0: 21"):
				pointtexture = preload("res://pointL.png")
				childrail.get_node("preview").rail.texture = preload("res://railblue.png")
				childrail.rail.texture = preload("res://railwhite.png")
			if line.begins_with("              param0: 2110"):
				childrail.midImage = preload("res://crankL.png")
			#R points
			if line.begins_with("              param0: 2141") or line.begins_with("              param0: 2111"):
				pointtexture = preload("res://pointR.png")
				childrail.get_node("preview").rail.texture = preload("res://rail.png")
				childrail.rail.texture = preload("res://railwhite.png")
			if line.begins_with("              param0: 2111"):
				childrail.midImage = preload("res://crankR.png")
			#Auto points
			if line.begins_with("              param0: 2200") or line.begins_with("              param0: 2300") or line.begins_with("              param0: 2000") or line.begins_with("              param0: 4300"):
				add_to_group("AutoMove")
				pointtexture = preload("res://pointA.png")
				childrail.get_node("preview").rail.texture = preload("res://railGreen.png")
				childrail.rail.texture = preload("res://railwhite.png")
			#End Points
			if line.begins_with("              param0: 2380"):
				pointtexture = preload("res://PointE0.png")
			if line.begins_with("              param0: 2381"):
				pointtexture = preload("res://PointE1.png")
			if line.begins_with("              param0: 2382"):
				pointtexture = preload("res://PointE2.png")
			if line.begins_with("              param0: 2383"):
				pointtexture = preload("res://PointE3.png")
			if line.begins_with("              param0: 2384"):
				pointtexture = preload("res://PointE4.png")
			if line.begins_with("              param0: 2385"):
				pointtexture = preload("res://PointE5.png")
			if line.begins_with("              param0: 2386"):
				pointtexture = preload("res://PointE6.png")
			if line.begins_with("              param0: 2387"):
				pointtexture = preload("res://PointE7.png")
			if line.begins_with("              param0: 2388"):
				pointtexture = preload("res://PointE8.png")
			if line.begins_with("              param0: 2389"):
				pointtexture = preload("res://PointE9.png")
			if line.begins_with("              param0: 2390"):
				pointtexture = preload("res://PointE10.png")
			if line.begins_with("              param0: 2391"):
				pointtexture = preload("res://PointE11.png")
			if line.begins_with("              param0: 2392") or line.begins_with("              param0: 2393") or line.begins_with("              param0: 2394"):
				pointtexture = preload("res://pointE.png")
			for point in childrail.points:
				point.texture = pointtexture
			if childrail.get_node("preview").rail.texture == preload("res://railPurple.png") and not line.begins_with("              param0: 2150"):
				add_to_group("EndMove")
			childrail.get_node("end").texture = pointtexture
			childrail.get_node("start").texture = pointtexture
		if line.begins_with("              param2: "):
			var text = line
			if float(text.erase(0,22)) == int(text.erase(0,22)): #keeps number simple
				text = str(int(text.erase(0,22)))
			else:
				text = str(float(text.erase(0,22)))
			childrail.get_node("speed").text = text
			childrail._on_speed_change()
	 # cycle through child data
	
	childrail.lines = []
	for point in childrail.points:
		point.reposition()
		childrail.lines.append(point.position)
	#visible and invisible rail color differ
	if end[9].begins_with("              param1: 0"): # invisible
		color = Color(.7,.7,.7,.5)
	else:
		color = Color(.2,.2,.2)
	
	#update the visuals
	childrail.rail.points = []
	childrail.get_node("preview").rail.points = []
	for point in childrail.points: #don't worry the duplicates are intentional (no weird scaling
		childrail.rail.add_point(point.position)
		childrail.get_node("preview").rail.add_point(point.position)
		childrail.rail.add_point(point.position)
		childrail.get_node("preview").rail.add_point(point.position)
	childrail.rail.add_point(childrail.get_node("end").position)
	childrail.get_node("preview").rail.add_point(childrail.get_node("end").position)
	childrail.rail.add_point(childrail.get_node("end").position)
	childrail.get_node("preview").rail.add_point(childrail.get_node("end").position)
	childrail.idnum = int(childrail.endplat[2].lstrip("              id_name: rail"))
	print(childrail.idnum)
	childrail.get_node("preview").backpath = childrail.path

func _process(delta):
	queue_redraw()
	var amount = 0
	var pressed = false
	for button in buttons:
		if button.is_hovered():
			amount += 1
		if button.button_pressed:
			pressed = true
	
	if amount != 0: #button is hovered
		if Input.is_action_just_pressed("MoveToBack"):
			get_parent().move_child(self,10)
		match get_parent().item:
			"tooledit":
				modulate = Color.GREEN_YELLOW
				if pressed and childrail != null:
					childrail.get_node("speed").show()
					childrail.get_node("speed").grab_focus()
					childrail.get_node("speed").set_caret_column(7)
			"tooldelete":
				modulate = Color.RED
				if pressed:
					get_parent().delete(self)
					get_parent().undolistadd({"Type":"Delete","Node":self})
			"toolproperty":
				modulate = Color.LIGHT_SKY_BLUE
				if pressed and get_parent().propertypanel == false:
					get_parent().editednode = self
					get_parent().propertypanel = true
					get_parent().parse([data,end,childrail.data,childrail.endplat])
					previousdata = data
					previousend = end
					previousplatdata = childrail.data
					previousplatend = childrail.endplat
					return
	else:
		modulate = Color.WHITE
	
	if Input.is_action_just_pressed("bridge"):
		if mode == 1:
			var railinst = railscene.instantiate()
			for line in points:
				railinst.path.append(line.position)
			railinst.path.append($end.position)
			add_child(railinst)
			childrail = railinst
			for group in childrail.get_groups():
				add_to_group(group)
			
			mode = 69
			
	if locked == false and !fillmode:
		if Input.is_action_just_pressed("addpoint"):
				newseg()
				
		if Input.is_action_just_pressed("bridge"):
			newseg()
			bridge()
	if Input.is_action_just_pressed("Shift"):
		fillmode = not fillmode
		

func newseg():
	if mode == 0:
		lines.append([$start.position,$end.position])
		
		var newpoint = pointScene.instantiate()
		newpoint.position = $start.position
		add_child(newpoint)
		points.append(newpoint)
		buttons.append(newpoint.get_node("Button"))
		dataseg = ["                - dir_x: 0.00000",
"                  dir_y: 0.00000",
"                  dir_z: 0.00000",
"                  id_name: rail" + str(idnum) + "/"+str(segments),
"                  link_info: []",
"                  link_num: !l 0",
"                  param0: -1.00000",
"                  param1: -1.00000",
"                  param2: -1.00000",
"                  param3: -1.00000",
"                  pnt0_x: " + str($end.position.x),
"                  pnt0_y: " + str(-$end.position.y),
"                  pnt0_z: 0.00000",
"                  pnt1_x: " + str($end.position.x),
"                  pnt1_y: " + str(-$end.position.y),
"                  pnt1_z: 0.00000",
"                  pnt2_x: " + str($end.position.x),
"                  pnt2_y: " + str(-$end.position.y),
"                  pnt2_z: 0.00000",
"                  scale_x: 1.00000",
"                  scale_y: 1.00000",
"                  scale_z: 1.00000",
"                  unit_name: Point"]
		data += dataseg
		$start.position = $end.position
		segments += 1

func pathdone(pos):
	if mode == 0:
		get_parent().idnum += 2
		mode = 1
		locked = true
		child(pos)
		buttons.append(get_node("end/Button"))

func child(pos):
	if mode == 1:
		var railinst = railscene.instantiate()
		railinst.loading = true
		railinst.get_node("start").position = pos
		for line in points:
			railinst.path.append(line.position)
		railinst.path.append($end.position)
		railinst.speed = speed
		add_child(railinst)
		childrail = railinst
		for group in childrail.get_groups():
			add_to_group(group)
		mode = 69 #nice

func bridge():
	loading = true
	if mode == 0:
		get_parent().idnum += 2
		mode = 1
		locked = true
		buttons.append(get_node("end/Button"))

func _draw():
	if locked == false and loading == false and fillmode == false:
		$end.position = get_parent().roundedmousepos
	draw_line($start.position,$end.position,Color(.3,.3,.3),2.25)
	for lineb in lines:
		draw_line(lineb[0],lineb[1],color,2.25)
	if locked == false and loading == false:
		pointcurve()

func EXPORT():
	if childrail != null and visible:
		childrail.EXPORT()
