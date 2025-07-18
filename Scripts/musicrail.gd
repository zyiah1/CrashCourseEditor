extends Node2D

signal edit
var pointscene = preload("res://musicpoint.tscn")
var locked = false
@onready var id = get_parent().nodes.size()
var segments = 1
var points = []
var loading = false
var color = Color(0.9, 0.58, 0.34)
var buttons = []
@onready var rail = $Rail


@onready var end:PackedStringArray = ["              closed: CLOSE",
"              comment: !l -1",
"              id_name: rail" + str(get_parent().idnum),
"              layer: LC",
"              link_info: []",
"              link_num: !l 0",
"              name: レール",
"              num_pnt: !l 2",
"              param0: 5100.00000",
"              param1: 0.00000",#the music tuning thing in game goes 1-7 does not use decimal values
"              param2: -1.00000",
"              param3: -1.00000",
"              param4:  0.00000",
"              param5: -1.00000",
"              param6: -1.00000",
"              param7: -1.00000",
"              param8: 0.00000", #0 = wait to play noise -1 = no restrictions?
"              param9: -1.00000",
"              type: Linear",
"              unit_name: Path"]






func _ready():
	if loading == false:
		$start.position = get_global_mouse_position().round()
	rail.add_point($start.position)
	data = ["            - Points:",
"                - comment: !l -1",
"                  dir_x: 0.00000",
"                  dir_y: 0.00000",
"                  dir_z: 0.00000",
"                  id_name: rail" + str(get_parent().idnum) + "/0",
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
"                  id_name: rail" + str(get_parent().idnum) + "/"+str(segments),
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
	if Input.is_action_just_pressed("accept"):
		$pitch.hide()
	
	queue_redraw()
	id = get_parent().nodes.find(self)
	
	
	var amount = 0
	var pressed = false
	for button in buttons:
		if button.is_hovered():
			amount += 1
		if button.button_pressed:
			pressed = true
	
	if amount != 0: #button is hovered
		match get_parent().item:
			"edit":
				modulate = Color.GREEN_YELLOW
				if pressed:
					emit_signal("edit")
			"delete":
				modulate = Color.RED
				if pressed:
					get_parent().nodes.remove_at(id)
			"proporties":
				modulate = Color.LIGHT_SKY_BLUE
				if pressed:
					if get_parent().propertypanel == false:
						get_parent().propertypanel = true
						get_parent().parse(data)
						get_parent().parse(end)
						get_parent().editednode = self
						return
	else:
		modulate = Color.WHITE
	if locked == false:
		if Input.is_action_just_pressed("addpoint"):
			newseg()
			
		if Input.is_action_just_pressed("bridge"):
			newseg()
			loading = true
			locked = true
			get_parent().idnum += 1
			get_parent().lineplacing = true
			buttons.append(get_node("end/Button"))


func newseg():
	rail.add_point($end.position)
	rail.add_point($end.position)
	var newpoint = pointscene.instantiate()
	newpoint.position = $start.position
	add_child(newpoint)
	points.append(newpoint)
	buttons.append(newpoint.get_node("Button"))
	newpoint.get_node("Button").connect("button_down", Callable(self, "_on_Button_button_down"))
	newpoint.get_node("Button").connect("button_up", Callable(self, "_on_Button_button_up"))
	dataseg = ["                - dir_x: 0.00000",
"                  dir_y: 0.00000",
"                  dir_z: 0.00000",
"                  id_name: rail" + str(get_parent().idnum) + "/"+str(segments),
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
	



func reposition():
	var currentpoint = 0
	var count = -1
	var first = true
	var cycles = -1
	
	
	
	for line in data:
		cycles += 1
		if currentpoint == points.size():
			if line.begins_with("                  pnt0_x: "):
				$start.position.x = int(line.lstrip("                  pnt0_x: "))
			if line.begins_with("                  pnt0_y: "):
				$start.position.y = -int(line.lstrip("                  pnt0_y: "))
				$end.position = $start.position
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
						first = false
				points[currentpoint].position.x = int(line.lstrip("                  pnt0_x: "))
			if line.begins_with("                  pnt0_y: "):
				points[currentpoint].position.y = -int(line.lstrip("                  pnt0_y: "))
				
			if line.begins_with("                  pnt1_x: "):
				data[cycles] = "                  pnt1_x: " + str(points[currentpoint].position.x)
			if line.begins_with("                  pnt1_y: "):
				data[cycles] = "                  pnt1_y: " + str(-points[currentpoint].position.y)
				
			if line.begins_with("                  pnt2_x: "):
				data[cycles] = "                  pnt2_x: " + str(points[currentpoint].position.x)
			if line.begins_with("                  pnt2_y: "):
				data[cycles] = "                  pnt2_y: " + str(-points[currentpoint].position.y)
				
				currentpoint += 1
	$pitch.position = $start.position
	#update the visuals
	rail.points = []
	for point in points:
		rail.add_point(point.position)
		rail.add_point(point.position)
	rail.add_point($end.position)
	rail.add_point($end.position)

func done():
	locked = true
	get_parent().idnum += 1
	get_parent().lineplacing = true
	buttons.append(get_node("end/Button"))

func _draw():
	if loading == false:
		$end.position = get_global_mouse_position().round()
	draw_line($start.position,$end.position,color+Color(.001,.00,.001),8)

func EXPORT():
	get_parent().bridgedata += data + end
