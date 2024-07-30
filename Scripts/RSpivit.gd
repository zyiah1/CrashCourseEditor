extends Node2D


const point = preload("res://pointR.tscn")
var locked = false
onready var id = get_parent().get_parent().nodes.size()
var segments = 1
var line = null
var lines = []
var points = []
var loading = false
var speed = 1
var drag = false
var buttons = []
var first = true

func focus_entered():
	$rotation.visible = true

func focus_exited():
	$rotation.visible = false

func changepivotpoint():
	var line = end[11]
	line.erase(19,1)
	if int(line.lstrip("              param: ")) != 0:
		var oldpos = $crank.position
		var targetswappoint = null
		if points.size()-1 < int(line.lstrip("              param: ")):
			$crank.position = $end.position #last point not in point array aab
			targetswappoint = $end
		else:
			$crank.position = points[int(line.lstrip("              param: "))].position
			targetswappoint = points[int(line.lstrip("              param: "))]
		targetswappoint.position = oldpos
	$crank2.position = $crank.position

func _ready():
	$rotation.connect("focus_entered",self,"focus_entered")
	$rotation.connect("focus_exited",self,"focus_exited")
	$end/Button.connect("button_down",get_parent(),"_on_Button_button_down")
	$end/Button.connect("button_up",get_parent(),"_on_Button_button_up")
	$rotation.grab_focus()
	if loading == false:
		$start.position = get_global_mouse_position().round()
	else:
		$rotation.hide()
	$crank.position = $start.position
	$rotation.rect_position = $crank.position + Vector2(-20,-100)
	buttons.append($crank/Button)
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

onready var dataseg = ["                - comment: !l -1",
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

var data

onready var end = ["              closed: CLOSE",
"              comment: !l -1",
"              id_name: rail" + str(get_parent().get_parent().idnum),
"              layer: LC",
"              link_info: []",
"              link_num: !l 0",
"              name: レール",
"              num_pnt: !l 2",
"              param0: 3113.00000",
"              param1: " + str(int($crank.rotation_degrees)), #max degree tilt
"              param2: 2.50000",
"              param3: 0.00000",
"              param4: 0.00000",
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
	$crank.position = points[0].position
	var text = end[9]
	text.erase(0,22)
	$rotation.text = str(-int(text))
	$crank.target = int($rotation.text)
	$crank2.target = int($rotation.text)
	$crank.rotation_degrees = 0
	$crank2.rotation_degrees = 0
	changepivotpoint()

func _process(delta):
	update()
	if Input.is_action_just_pressed("accept"):
		$rotation.hide()
	id = get_parent().get_parent().nodes.find(get_parent())
	if get_parent().get_parent().item == "delete":
		if drag == true:
			get_parent().get_parent().nodes.remove(id)
			get_parent().queue_free()
		var amount = 0
		
		for button in buttons:
			if button.is_hovered():
				modulate = Color.red
				amount += 1
			if amount == 0:
				modulate = Color.white
				drag = false
	if get_parent().get_parent().item == "edit":
		if drag == true:
			get_node("rotation").show()
			get_node("rotation").grab_focus()
			get_node("rotation").cursor_set_column(7)
		var amount = 0
		
		for button in buttons:
			if button.is_hovered():
				modulate = Color.lightblue
				amount += 1
			if amount == 0:
				modulate = Color.white
				drag = false
	if get_parent().get_parent().item == "proporties":
		if drag == true:
			if get_parent().get_parent().propertypanel == false:
				get_parent().get_parent().propertypanel = true
				get_parent().get_parent().parse(data)
				get_parent().get_parent().parse(end)
				get_parent().get_parent().editednode = self
				return
	var middle = $start.position
	var amount = 1
	for point in points:
		amount += 1
		middle += point.position
	
	
	$crank2.position = $crank.position
	$crank2.lines = $crank.lines
	
	if locked == false:
		if Input.is_action_just_pressed("undo"):
				get_parent().get_parent().idnum-=1
				get_parent().get_parent().line = true
				queue_free()
				
		if Input.is_action_just_pressed("addpoint"):
			
			lines.append([$start.position,$end.position])
			
			var newpoint = point.instance()
			newpoint.position = $start.position
			if first == true:
				newpoint.hide()
				first = false
				$start.show()
			add_child(newpoint)
			points.append(newpoint)
			buttons.append(newpoint.get_node("Button"))
			newpoint.get_node("Button").connect("button_down",self,"_on_Button_button_down")
			newpoint.get_node("Button").connect("button_up",self,"_on_Button_button_up")
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
			
		if Input.is_action_just_pressed("bridge"):
			loading = true
			locked = true
			end[9] = "              param1: " + str(-int($rotation.text)) #max degree tilt
			get_parent().get_parent().idnum += 1
			get_parent().get_parent().line = true
			buttons.append(get_node("end/Button"))
			$rotation.grab_focus()
			$rotation.cursor_set_column(3)
	$crank.target = int($rotation.text)
	$crank2.target = -int($rotation.text)
	
	if is_queued_for_deletion():
		get_parent().get_parent().Ain()
		get_parent().get_parent().railplace = -420
		

func newseg():
			lines.append([$start.position,$end.position])
			
			var newpoint = point.instance()
			newpoint.position = $start.position
			if first == true:
				newpoint.hide()
				first = false
				$start.show()
			add_child(newpoint)
			points.append(newpoint)
			buttons.append(newpoint.get_node("Button"))
			newpoint.get_node("Button").connect("button_down",self,"_on_Button_button_down")
			newpoint.get_node("Button").connect("button_up",self,"_on_Button_button_up")
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
	end[9] = "              param1: " + str(-int($rotation.text)) #max degree tilt
	get_parent().get_parent().idnum += 1
	get_parent().get_parent().bridgedata += data + end
	get_parent().get_parent().line = true
	buttons.append(get_node("end/Button"))

func _draw():
	$crank.lines = lines
	if loading == false and locked == false:
		$end.position = get_global_mouse_position().round()
	line = draw_line($start.position,$end.position,Color(.82,.88,.88),4.5)
	for lineb in lines:
		draw_line(lineb[0],lineb[1],Color.white - Color(.2,.2,.2,0),4.5)
		
	

func EXPORT():
	if end != null:
		if end[9] != null:
			end[9] = "              param1: " + str(-$crank.target)
			get_parent().get_parent().bridgedata += data + end


func _on_Button_button_down():
	drag = true
	


func _on_Button_button_up():
	drag = false


func _on_rotation_rotationupdated(string):
	end[9] = "              param1: " + str(-int(string))
