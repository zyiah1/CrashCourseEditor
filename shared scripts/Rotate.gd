extends Node2D
signal finish

@export var pointScene: PackedScene = preload("res://pointL.tscn")
@export var Param0: int = 3140
@export var reset: int = 0
@export var color: Color = Color(.92,.98,.98)
@export var railtexture: Texture2D = load("res://railwhite.png")

@onready var id = get_parent().get_parent().nodes.size()

var locked = false
var segments = 1
var lines = []
var points = []
var loading = false
var speed = 1
var drag = false
var buttons = []
var first = true

var rail

func focus_entered():
	$rotation.visible = true

func focus_exited():
	$rotation.visible = false

func _ready():
	var inst = load("res://rail.tscn").instantiate()
	var reference_node = get_node("start")
	add_child(inst)
	var reference_index = reference_node.get_index()
	move_child(inst, reference_index + 1)
	
	
	rail = inst
	rail.texture = railtexture
	$rotation.connect("focus_entered", Callable(self, "focus_entered"))
	$rotation.connect("focus_exited", Callable(self, "focus_exited"))
	$end/Button.connect("button_down", Callable(get_parent(), "_on_Button_button_down"))
	$end/Button.connect("button_up", Callable(get_parent(), "_on_Button_button_up"))
	if loading == false:
		$start.position = get_global_mouse_position().round()
		$rotation.grab_focus()
	else:
		$rotation.hide()
	$crank.position = $start.position
	$rotation.position = $crank.position + Vector2(-20,-100)
	buttons.append($crank/Button)
	rail.add_point($start.position)
	$crank.rail.add_point($start.position)
	
	data = ["            - Points:",
"                - comment: !l -1",
"                  dir_x: 0.00000",
"                  dir_y: 0.00000",
"                  dir_z: 0.00000",
"                  id_name: rail" + str(get_parent().get_parent().idnum) + "/0",
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
"                  id_name: rail" + str(get_parent().get_parent().idnum) + "/"+str(segments),
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
"              id_name: rail" + str(get_parent().get_parent().idnum),
"              layer: LC",
"              link_info: []",
"              link_num: !l 0",
"              name: レール",
"              num_pnt: !l 2",
"              param0: " + str(Param0) + ".00000",
"              param1: " + str(int($rotation.text)), #max degree tilt
"              param2: 2.50000",
"              param3: "+str(reset), #This is the point it rotates from: 0 = 1st 1 = 2nd ect.
"              param4:  0.00000",
"              param5: -1.00000",
"              param6: -1.00000",
"              param7: 3.00000",
"              param8: -1.00000",
"              param9: -1.00000",
"              type: Linear",
"              unit_name: Path"]


func reposition():
	var currentpoint = 0
	var currentline = 0
	var count = -1
	var firstPoint = true
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
				if firstPoint == true:
					if count >= 2:
						count = 0
						currentline += 1
						firstPoint = false
				points[currentpoint].position.x = int(line.lstrip("                  pnt0_x: "))
				if firstPoint == true:
					lines[currentline][count].x = points[currentpoint].position.x
				else:
					lines[currentline][0].x = lines[currentline - 1][1].x
					lines[currentline][1].x = points[currentpoint].position.x
			if line.begins_with("                  pnt0_y: "):
				points[currentpoint].position.y = -int(line.lstrip("                  pnt0_y: "))
				if firstPoint == true:
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
	$crank.position = points[0].position
	var text = end[9]
	text = text.erase(0,22)
	$rotation.text = str(-float(text))
	$crank.target = float($rotation.text)
	$rotation.prev = $rotation.text
	$crank.rotation_degrees = 0
	$rotation.position = $crank.position + Vector2(-20,-100)
	changepivotpoint()
	#update the visuals
	rail.points = []
	get_node("crank").rail.points = []
	for point in points:
		rail.add_point(point.position)
		get_node("crank").rail.add_point(point.position)
		rail.add_point(point.position)
		get_node("crank").rail.add_point(point.position)
	rail.add_point($end.position)
	get_node("crank").rail.add_point($end.position)
	rail.add_point($end.position)
	get_node("crank").rail.add_point($end.position)

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
		targetswappoint.position = oldpos

func _process(delta):
	
	#update the lines
	queue_redraw()
	if Input.is_action_just_pressed("accept"):
		$rotation.hide()
	id = get_parent().get_parent().nodes.find(get_parent())
	if get_parent().get_parent().item == "delete":
		if drag == true:
			get_parent().get_parent().nodes.remove_at(id)
			get_parent().queue_free()
		var amount = 0
		
		for button in buttons:
			if button.is_hovered():
				modulate = Color.RED
				amount += 1
			if amount == 0:
				modulate = Color.WHITE
				drag = false
	if get_parent().get_parent().item == "edit":
		if drag == true:
			get_node("rotation").show()
			get_node("rotation").grab_focus()
			get_node("rotation").set_caret_column(7)
		var amount = 0
		
		for button in buttons:
			if button.is_hovered():
				modulate = Color.LIGHT_BLUE
				amount += 1
			if amount == 0:
				modulate = Color.WHITE
				drag = false
	if get_parent().get_parent().item == "proporties":
		if drag == true:
			if get_parent().get_parent().propertypanel == false:
				get_parent().get_parent().propertypanel = true
				get_parent().get_parent().parse(data)
				get_parent().get_parent().parse(end)
				get_parent().get_parent().editednode = self
				return
	if locked == false:
		if Input.is_action_just_pressed("undo"):
				get_parent().get_parent().idnum-=1
				get_parent().get_parent().lineplacing = true
				queue_free()
				
		if Input.is_action_just_pressed("addpoint"):
			newseg()
			
		if Input.is_action_just_pressed("bridge"):
			loading = true
			locked = true
			end[9] = "              param1: " + str(-int($rotation.text)) #max degree tilt
			get_parent().get_parent().idnum += 1
			get_parent().get_parent().lineplacing = true
			buttons.append(get_node("end/Button"))
			$rotation.grab_focus()
			$rotation.set_caret_column(3)
	$crank.target = int($rotation.text)
	if is_queued_for_deletion():
		get_parent().get_parent().Ain()
		get_parent().get_parent().railplace = -420
		

func newseg():
	lines.append([$start.position,$end.position])
	rail.add_point($end.position)
	$crank.rail.add_point($end.position)
	rail.add_point($end.position)
	$crank.rail.add_point($end.position)
	var newpoint = pointScene.instantiate()
	newpoint.position = $start.position
	if first == true:
		newpoint.hide()
		first = false
		$start.show()
	add_child(newpoint)
	points.append(newpoint)
	buttons.append(newpoint.get_node("Button"))
	newpoint.get_node("Button").connect("button_down", Callable(self, "_on_Button_button_down"))
	newpoint.get_node("Button").connect("button_up", Callable(self, "_on_Button_button_up"))
	dataseg = ["                - dir_x: 0.00000",
"                  dir_y: 0.00000",
"                  dir_z: 0.00000",
"                  id_name: rail" + str(get_parent().get_parent().idnum) + "/"+str(segments),
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


func done():
	locked = true
	get_parent().get_parent().idnum += 1
	get_parent().get_parent().bridgedata += data + end
	get_parent().get_parent().lineplacing = true
	buttons.append(get_node("end/Button"))


func _draw():
	
	if loading == false and locked == false:
		$end.position = get_global_mouse_position().round()
	draw_line($start.position,$end.position,color,4.5)

func EXPORT():
	if end != null:
		if end[9] != null:
			end[9] = "              param1: " + str(-$crank.target)
			get_parent().get_parent().bridgedata += data + end



func _on_Button_button_down():
	drag = true
	


func _on_Button_button_up():
	drag = false


func _on_rotation_rotationupdated(text):
	end[9] = "              param1: " + str(-int(text))


