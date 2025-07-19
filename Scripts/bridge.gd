extends Node2D

var pointScene = preload("res://point.tscn")
var drag = false
var locked = false
var segments = 1
var lines = []
var points = []
var loading = false
var color = Color.RED - Color(.2,0,0,0)
var buttons = []
var invisible = false
var size = 4.5


@onready var rail = $Rail
@onready var id = get_parent().nodes.size()
@onready var idnum = get_parent().idnum
@onready var end:PackedStringArray = ["              closed: CLOSE",
"              comment: !l -1",
"              id_name: rail" + str(idnum),
"              layer: LC",
"              link_info: []",
"              link_num: !l 0",
"              name: レール",
"              num_pnt: !l 2",
"              param0: 1000.00000",
"              param1: -1.00000",
"              param2: -1.00000",
"              param3: -1.00000",
"              param4:  0.00000",
"              param5: -1.00000",
"              param6: -1.00000",
"              param7: -1.00000",#message that displays?
"              param8: 0.00000",
"              param9: -1.00000",
"              type: Linear",
"              unit_name: Path"]






func _ready():
	if loading == false:
		$start.position = get_global_mouse_position().round()
		if get_parent().mode == 2:
			color = Color(.13,.58,.87,1)
		if get_parent().mode == 3:
			invisible = true
	if color == Color(.13,.58,.87,1): #if it's blue
		end[8] = "              param0: 1200.00000"
		rail.texture = load("res://railblue.png")
	if invisible == true:
		pointScene = preload("res://Bigpoint.tscn")
		$start.scale =  Vector2(.90,.90)
		$end.scale =  Vector2(.90,.90)
		size = size*6
		rail.width = 40
		end[8] = "              param0: 0.00000"
		color = Color.GRAY
	
	rail.add_point($start.position)
	
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
	if get_parent().item == "proporties":
		if drag == true:
			if get_parent().propertypanel == false:
				get_parent().propertypanel = true
				get_parent().parse(data)
				get_parent().parse(end)
				get_parent().editednode = self
				return
	if locked == false:
		if Input.is_action_just_pressed("addpoint"):
			newseg()
			
		if Input.is_action_just_pressed("bridge"):
			newseg()
			loading = true
			done()
		

func newseg():
	lines.append([$start.position,$end.position])
	rail.add_point($end.position)
	rail.add_point($end.position)
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
	$start.frame = 1
	segments += 1
	
	if segments == 2:
		newpoint.get_node("start").play("RESET")



func reposition():
	var currentpoint = 0
	var currentline = 0
	var count = -1
	var first = true
	var cycles = -1
	
	for line in end:
		if line.begins_with("              param0: 1"):
			invisible = false
			rail.width = 8
			if $start.scale == Vector2(.35,.35)*3:
				$start.scale = Vector2(.35,.35)
				$end.scale = Vector2(.35,.35)
				size = 4.5
				for point in points:
					
					point.scale = point.scale/3
		if line == "              param0: 1000.00000":
			color = Color.RED - Color(.2,0,0,0)
			rail.texture = load("res://rail.png")
		if line == "              param0: 1200.00000":
			color = Color(.13,.58,.87,1)
			rail.texture = load("res://railblue.png")
		if line == "              param0: 0.00000":
			invisible = true
			if $start.scale == Vector2(.35,.35):
				$start.scale = $start.scale*3
				$end.scale = $end.scale*3
				size = size*6
				color = Color.GRAY
				for point in points:
					point.scale = Vector2(.90,.90)
	
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
	#update the visuals
	rail.points = []
	for point in points:
		rail.add_point(point.position)
		rail.add_point(point.position)
	rail.add_point($end.position)
	rail.add_point($end.position)
	
func done():
	locked = true
	idnum += 1
	get_parent().idnum += 1
	get_parent().lineplacing = true
	buttons.append(get_node("end/Button"))


func _draw():
	if loading == false:
		$end.position = get_global_mouse_position().round()
	draw_line($start.position,$end.position,color + Color(.2,.2,.2),size)
	if invisible:
		rail.hide()
		for lineb in lines:
			draw_line(lineb[0],lineb[1],color,size)
	else:
		rail.show()

func EXPORT():
	get_parent().bridgedata += data + end


func _on_Button_button_down():
	drag = true
	


func _on_Button_button_up():
	drag = false
