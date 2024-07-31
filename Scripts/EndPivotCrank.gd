extends Node2D
signal done

const point = preload("res://pointE.tscn")
var locked = false
@onready var id = get_parent().get_parent().nodes.size()
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

func _ready():
	$rotation.connect("focus_entered", Callable(self, "focus_entered"))
	$rotation.connect("focus_exited", Callable(self, "focus_exited"))
	$end/Button.connect("button_down", Callable(get_parent(), "_on_Button_button_down"))
	$end/Button.connect("button_up", Callable(get_parent(), "_on_Button_button_up"))
	$rotation.grab_focus()
	if loading == false:
		$start.position = get_global_mouse_position().round()
	else:
		$rotation.hide()
	$crank.position = $start.position
	$rotation.position = $crank.position + Vector2(-20,-100)
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

@onready var dataseg = ["                - comment: !l -1",
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

var end 




func _process(delta):
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
	if locked == false:
		if Input.is_action_just_pressed("undo"):
				get_parent().get_parent().idnum-=1
				get_parent().get_parent().line = true
				queue_free()
				
		if Input.is_action_just_pressed("addpoint"):
			
			lines.append([$start.position,$end.position])
			
			var newpoint = point.instantiate()
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
			
		if Input.is_action_just_pressed("bridge"):
			loading = true
			locked = true
			end = ["              closed: CLOSE",
"              comment: !l -1",
"              id_name: rail" + str(get_parent().get_parent().idnum),
"              layer: LC",
"              link_info: []",
"              link_num: !l 0",
"              name: レール",
"              num_pnt: !l 2",
"              param0: 3300.00000",
"              param1: " + str(int($rotation.text)), #max degree tilt
"              param2: 2.50000",
"              param3: 0.00000",
"              param4:  0.00000",
"              param5: -1.00000",
"              param6: -1.00000",
"              param7: 3.00000",
"              param8: -1.00000",
"              param9: -1.00000",
"              type: Linear",
"              unit_name: Path3D"]
			get_parent().get_parent().idnum += 1
			get_parent().get_parent().line = true
			buttons.append(get_node("end/Button"))
			$rotation.grab_focus()
			$rotation.set_caret_column(3)
	update()
	$crank.target = int($rotation.text)
	$crank.rotation_degrees = move_toward($crank.rotation_degrees,int($rotation.text),speed)
	if is_queued_for_deletion():
		get_parent().get_parent().Ain()
		get_parent().get_parent().railplace = -420
		

func newseg():
			lines.append([$start.position,$end.position])
			
			var newpoint = point.instantiate()
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
	end = ["              closed: CLOSE",
"              comment: !l -1",
"              id_name: rail" + str(get_parent().get_parent().idnum),
"              layer: LC",
"              link_info: []",
"              link_num: !l 0",
"              name: レール",
"              num_pnt: !l 2",
"              param0: 3300.00000",
"              param1: " + str(int($rotation.text)), #max degree tilt
"              param2: 2.50000",
"              param3: 0.00000",
"              param4: 0.00000",
"              param5: -1.00000",
"              param6: -1.00000",
"              param7: 3.00000",
"              param8: -1.00000",
"              param9: -1.00000",
"              type: Linear",
"              unit_name: Path3D"]
	get_parent().get_parent().idnum += 1
	get_parent().get_parent().bridgedata += data + end
	get_parent().get_parent().line = true
	buttons.append(get_node("end/Button"))

func _draw():
	$crank.lines = lines
	if loading == false and locked == false:
		$end.position = get_global_mouse_position().round()
	line = draw_line($start.position,$end.position,Color.RED + Color(0,.2,.2,0),4.5)
	for lineb in lines:
		draw_line(lineb[0],lineb[1],Color.RED - Color(.2,0,0,0),4.5)
		
	

func EXPORT():
	if end != null:
		if end[9] != null:
			end[9] = "              param1: " + str(-$crank.target)
			get_parent().get_parent().bridgedata += data + end

func _on_Button_button_down():
	drag = true
	


func _on_Button_button_up():
	drag = false