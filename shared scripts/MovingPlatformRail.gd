extends Node2D

const pointScene = preload("res://point2.tscn")


var speed = 2
var locked = false
@onready var id = get_parent().nodes.size()
@onready var idnum = get_parent().idnum
var segments = 1
var lines = []
var points = []
var mode = 0 #0 = path 1 = platform
var childrail = null
var loading = false
var drag = false
var buttons = []
var Param1: int = -1 #visiblie
var color = Color(.2,.2,.2)
@export var rail: PackedScene = preload("res://RMove.tscn")




@onready var dataseg:PackedStringArray = ["                - comment: !l -1",
"                  dir_x: 0.00000",
"                  dir_y: 0.00000",
"                  dir_z: 0.00000",
"                  id_name: rail" + str(idnum) + "/"+str(segments),
"                  link_info: []",
"                  link_num: !l 0",
"                  param0: -1.00000",
"                  param1: -1.00000",
"                  param2: -1.00000",
"                  param3: -1.00000",
"                  pnt0_x: " + str($start.position.x),
"                  pnt0_y: " + str(-$start.position.y),
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

var data:PackedStringArray

@onready var end:PackedStringArray = ["              closed: CLOSE",
"              comment: !l -1",
"              id_name: rail" + str(idnum),
"              layer: LC",
"              link_info: []",
"              link_num: !l 0",
"              name: レール",
"              num_pnt: !l 2",
"              param0: 2900.00000", #railtype
"              param1: "+str(Param1)+".00000", #-1 = visible, 0 = invisible
"              param2: -1.00000",
"              param3: -1.00000",
"              param4:  0.00000",
"              param5: -1.00000",
"              param6: -1.00000",
"              param7: -1.00000",
"              param8: -1.00000",
"              param9: -1.00000",
"              type: Linear",
"              unit_name: Path"]

func _ready():
	if end[9].begins_with("              param1: 0"): # invisible
		color = Color(.7,.7,.7,.5)
	else:
		color = Color(.2,.2,.2)
	if loading == false:
		$start.position = get_global_mouse_position()
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

func reposition():
	var currentpoint = 0
	var currentline = 0
	var count = -1
	var first = true
	var cycles = -1
	
	
	for line in data:
		cycles += 1
		if currentpoint == points.size():
			if line.begins_with("                  pnt0_x: "):
				$start.position.x = int(line.lstrip("                  pnt0_x: "))
				currentline = lines.size() - 1
			if line.begins_with("                  pnt0_y: "):
				$start.position.y = -int(line.lstrip("                  pnt0_y: "))
				$end.position = $start.position
				lines[currentline][1] = $end.position
				if points.size() >= 2:
					lines[currentline][0] = lines[currentline-1][1]
			if line.begins_with("                  pnt1_x: "):
				data[cycles] = "                  pnt1_x: " + str($end.position.x)
			if line.begins_with("                  pnt1_y: "):
				data[cycles] = "                  pnt1_y: " + str(-$end.position.y)
				
			if line.begins_with("                  pnt2_x: "):
				data[cycles] = "                  pnt2_x: " + str($end.position.x)
			if line.begins_with("                  pnt2_y: "):
				data[cycles] = "                  pnt2_y: " + str(-$end.position.y)
		else:
			if line.begins_with("                  pnt0_x: "):
				count += 1
				if first == true:
					if count >= 2:
						count = 0
						currentline += 1
						first = false
				points[currentpoint].position.x = int(line.lstrip("                  pnt0_x: "))
				if first == true:
					lines[currentline][count].x = points[currentpoint].position.x
				else:
					lines[currentline][0].x = lines[currentline - 1][1].x
					lines[currentline][1].x = points[currentpoint].position.x
			if line.begins_with("                  pnt0_y: "):
				points[currentpoint].position.y = -int(line.lstrip("                  pnt0_y: "))
				if first == true:
					lines[currentline][count].y = points[currentpoint].position.y
				else:
					lines[currentline][0].y = lines[currentline - 1][1].y
					lines[currentline][1].y = points[currentpoint].position.y
					currentline += 1
				
			if line.begins_with("                  pnt1_x: "):
				data[cycles] = "                  pnt1_x: " + str(points[currentpoint].position.x)
			if line.begins_with("                  pnt1_y: "):
				data[cycles] = "                  pnt1_y: " + str(-points[currentpoint].position.y)
				
			if line.begins_with("                  pnt2_x: "):
				data[cycles] = "                  pnt2_x: " + str(points[currentpoint].position.x)
			if line.begins_with("                  pnt2_y: "):
				data[cycles] = "                  pnt2_y: " + str(-points[currentpoint].position.y)
				
				currentpoint += 1
	idnum = int(end[2].lstrip("              id_name: rail"))
	childrail.path = []
	for line in points:
		childrail.path.append(line.position)
	childrail.path.append($end.position)
	childrail.get_node("preview").offset = Vector2.ZERO
	currentpoint = 0
	currentline = 0
	count = -1
	first = true
	cycles = -1
	for line in childrail.endplat:
		if line.begins_with("              param0:"): #get the point kind
			var pointtexture = preload("res://point.png")
			childrail.get_node("preview").rail.texture = preload("res://railPurple.png")
			childrail.rail.texture = preload("res://rail.png")
			childrail.midImage = null
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
			childrail.get_node("end").texture = pointtexture
			childrail.get_node("start").texture = pointtexture
		if line.begins_with("              param2: "):
			var text = line
			text = text.erase(0,22)
			childrail.get_node("rotation").text = text
			childrail._on_rotation_change()
	
	for line in childrail.data: # cycle through child data
		cycles += 1
		
			
			
			
		if currentpoint == childrail.points.size():
			if line.begins_with("                  pnt0_x: "):
				childrail.get_node("start").position.x = int(line.lstrip("                  pnt0_x: "))
				currentline = childrail.lines.size() - 1
			if line.begins_with("                  pnt0_y: "):
				childrail.get_node("start").position.y = -int(line.lstrip("                  pnt0_y: "))
				childrail.get_node("end").position = childrail.get_node("start").position
				childrail.lines[currentline][1] = childrail.get_node("end").position
				if childrail.points.size() >= 2:
					childrail.lines[currentline][0] = childrail.lines[currentline-1][1]
			if line.begins_with("                  pnt1_x: "):
				childrail.data[cycles] = "                  pnt1_x: " + str(childrail.get_node("end").position.x)
			if line.begins_with("                  pnt1_y: "):
				childrail.data[cycles] = "                  pnt1_y: " + str(-childrail.get_node("end").position.y)
				
			if line.begins_with("                  pnt2_x: "):
				childrail.data[cycles] = "                  pnt2_x: " + str(childrail.get_node("end").position.x)
			if line.begins_with("                  pnt2_y: "):
				childrail.data[cycles] = "                  pnt2_y: " + str(-childrail.get_node("end").position.y)
		else:
			if line.begins_with("                  pnt0_x: "):
				count += 1
				if first == true:
					if count >= 2:
						count = 0
						currentline += 1
						first = false
				childrail.points[currentpoint].position.x = int(line.lstrip("                  pnt0_x: "))
				if first == true:
					childrail.lines[currentline][count].x = childrail.points[currentpoint].position.x
				else:
					childrail.lines[currentline][0].x = childrail.lines[currentline - 1][1].x
					childrail.lines[currentline][1].x = childrail.points[currentpoint].position.x
			if line.begins_with("                  pnt0_y: "):
				childrail.points[currentpoint].position.y = -int(line.lstrip("                  pnt0_y: "))
				if first == true:
					childrail.lines[currentline][count].y = childrail.points[currentpoint].position.y
				else:
					childrail.lines[currentline][0].y = childrail.lines[currentline - 1][1].y
					childrail.lines[currentline][1].y = childrail.points[currentpoint].position.y
					currentline += 1
				
			if line.begins_with("                  pnt1_x: "):
				childrail.data[cycles] = "                  pnt1_x: " + str(childrail.points[currentpoint].position.x)
			if line.begins_with("                  pnt1_y: "):
				childrail.data[cycles] = "                  pnt1_y: " + str(-childrail.points[currentpoint].position.y)
				
			if line.begins_with("                  pnt2_x: "):
				childrail.data[cycles] = "                  pnt2_x: " + str(childrail.points[currentpoint].position.x)
			if line.begins_with("                  pnt2_y: "):
				childrail.data[cycles] = "                  pnt2_y: " + str(-childrail.points[currentpoint].position.y)
				
				currentpoint += 1
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
	id = get_parent().nodes.find(self)
	if get_parent().item == "delete":
		if drag == true:
			get_parent().nodes.remove_at(id)
			queue_free()
		var amount = 0
		
		for button in buttons:
			if button.is_hovered():
				modulate = Color.RED
				amount += 1
			if amount == 0:
				modulate = Color.WHITE
				drag = false
	if get_parent().item == "edit":
		if drag == true:
			if childrail != null:
				childrail.get_node("rotation").show()
				childrail.get_node("rotation").grab_focus()
				childrail.get_node("rotation").set_caret_column(7)
		var amount = 0
		
		for button in buttons:
			if button.is_hovered():
				modulate = Color.LIGHT_BLUE
				amount += 1
			if amount == 0:
				modulate = Color.WHITE
				drag = false
	if get_parent().item == "proporties":
		if drag == true:
			if get_parent().propertypanel == false:
				get_parent().propertypanel = true
				get_parent().parse(data)
				get_parent().parse(end)
				get_parent().parse(childrail.data)
				get_parent().parse(childrail.endplat)
				get_parent().editednode = self
				return
			
	if Input.is_action_just_pressed("bridge"):
		if mode == 1:
			var railinst = rail.instantiate()
			for line in points:
				railinst.path.append(line.position)
			railinst.path.append($end.position)
			add_child(railinst)
			childrail = railinst
			mode = 69
			
	if locked == false:
		if Input.is_action_just_pressed("addpoint"):
				newseg()
				
		if Input.is_action_just_pressed("bridge"):
			newseg()
			if mode == 0:
				get_parent().idnum += 2
				mode = 1
				locked = true
				buttons.append(get_node("end/Button"))
				add_to_group(str(rail.resource_path).lstrip("res://").rstrip(".tscn")) #adds to group depending on the type of object
				print(str(rail.resource_path).lstrip("res://").rstrip(".tscn"))


func newseg():
	if mode == 0:
		lines.append([$start.position,$end.position])
		
		var newpoint = pointScene.instantiate()
		newpoint.position = $start.position
		add_child(newpoint)
		points.append(newpoint)
		buttons.append(newpoint.get_node("Button"))
		newpoint.get_node("Button").connect("button_down", Callable(self, "_on_Button_button_down"))
		newpoint.get_node("Button").connect("button_up", Callable(self, "_on_Button_button_up"))
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

func done(pos):
	if mode == 0:
		get_parent().idnum += 2
		mode = 1
		locked = true
		child(pos)
		buttons.append(get_node("end/Button"))
		add_to_group(str(rail.resource_path).lstrip("res://").rstrip(".tscn")) #adds to group depending on the type of object

func child(pos):
	if mode == 1:
		var railinst = rail.instantiate()
		railinst.loading = true
		railinst.get_node("start").position = pos
		for line in points:
			railinst.path.append(line.position)
		railinst.path.append($end.position)
		railinst.speed = speed
		add_child(railinst)
		childrail = railinst
		mode = 69 #nice

func _draw():
	if locked == false and loading == false:
		$end.position = get_global_mouse_position()
	draw_line($start.position,$end.position,Color(.3,.3,.3),2.25)
	for lineb in lines:
		draw_line(lineb[0],lineb[1],color,2.25)

func EXPORT():
	if childrail != null and visible:
		childrail.EXPORT()

func _on_Button_button_down():
	drag = true
	


func _on_Button_button_up():
	drag = false
