extends Node2D


const point = preload("res://point.tscn")
var locked = false
var segments = 1
var line = null
var lines = []
var points = []
var mode = 0 #0 = path 1 = platform
var loading = false
var path = []
var speed = 2
var TextFocus = false

func focus_entered():
	$rotation.visible = true

func focus_exited():
	$rotation.visible = false

func _ready():
	$rotation.connect("focus_entered",self,"focus_entered")
	$rotation.connect("focus_exited",self,"focus_exited")
	$end/Button.connect("button_down",get_parent(),"_on_Button_button_down")
	$end/Button.connect("button_up",get_parent(),"_on_Button_button_up")
	get_parent().buttons.append($end/Button)
	$rotation.text = str(speed)
	if loading == false:
		$start.position = get_global_mouse_position()
	else:
		$rotation.hide()
	$rotation.rect_position = $start.position - Vector2(0,100)
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

onready var dataseg = ["                - comment: !l -1",
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

var data



onready var endplat = ["              closed: CLOSE",
"              comment: !l -1",
"              id_name: rail" + str(get_parent().idnum),
"              layer: LC",
"              link_info:",
"                - linkID: rail" + str(get_parent().idnum - 1),
"                  param0: -1.00000",
"                  param1: -1.00000",
"                  param2: -1.00000",
"                  param3: -1.00000",
"                  param4: -1.00000",
"                  param5: -1.00000",
"                  param6: -1.00000",
"                  param7: -1.00000",
"                  type: Rail_Rail",
"              link_num: !l 1",
"              name: 繝ｬ繝ｼ繝ｫ", #network
"              num_pnt: !l 2",
"              param0: 2150.00000", #railtype
"              param1: 0.00000",
"              param2: " + str(speed), #speed???
"              param3: 1.00000",
"              param4:  0.00000",
"              param5: -1.00000",
"              param6: -1.00000",
"              param7: 1.00000",
"              param8: -1.00000",
"              param9: -1.00000",
"              type: Linear",
"              unit_name: Path"]




func _process(delta):
	update()
	if Input.is_action_just_pressed("accept"):
		$rotation.hide()
	if locked == false:
		if Input.is_action_just_pressed("undo"):
			if segments == 1:
				get_parent().idnum-=1
				get_parent().line = true
				
		if Input.is_action_just_pressed("addpoint"):
			
			lines.append([$start.position,$end.position])
			
			var newpoint = point.instance()
			newpoint.position = $start.position
			add_child(newpoint)
			points.append(newpoint)
			get_parent().buttons.append(newpoint.get_node("Button"))
			newpoint.get_node("Button").connect("button_down",get_parent(),"_on_Button_button_down")
			newpoint.get_node("Button").connect("button_up",get_parent(),"_on_Button_button_up")
			dataseg = ["                - comment: !l -1",
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
			if mode == 0:
				locked = true
				
				get_parent().get_parent().line = true
				$rotation.grab_focus()
				$rotation.cursor_set_column(3)
	if is_queued_for_deletion():
		get_parent().get_parent().Ain()
		get_parent().get_parent().railplace = -420
		get_parent().queue_free()
		get_parent().get_parent().line = true


func newseg():
	
	lines.append([$start.position,$end.position])
	
	var newpoint = point.instance()
	newpoint.position = $start.position
	add_child(newpoint)
	points.append(newpoint)
	get_parent().buttons.append(newpoint.get_node("Button"))
	newpoint.get_node("Button").connect("button_down",get_parent(),"_on_Button_button_down")
	newpoint.get_node("Button").connect("button_up",get_parent(),"_on_Button_button_up")
	dataseg = ["                - comment: !l -1",
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
	$blade.position = ($start.position + $end.position)/2
	$start.position = $end.position
	$start.frame = 1
	segments += 1
	
	if segments == 2:
		newpoint.get_node("start").play("RESET")
	
func done():
	if mode == 0:
		locked = true
		
		get_parent().get_parent().line = true


func _draw():
	if points.size() >= 2:
		$blade.position = (points[0].position + points[1].position)/2
	else:
		if $start.position != $end.position:
			$blade.position = ($start.position + $end.position)/2
		if points.size() == 1:
			$blade.position = ($start.position + points[0].position)/2
	if locked == false and loading == false:
		$end.position = get_global_mouse_position()
	line = draw_line($start.position,$end.position,Color(.92,.98,.98),4.5)
	$preview.lines = lines
	for lineb in lines:
		draw_line(lineb[0],lineb[1],Color.whitesmoke - Color(.1,.1,.1,0),4.5)

func EXPORT():
	get_parent().get_parent().bridgedata += get_parent().data + get_parent().end + data + endplat


func _on_rotation_change():
	speed = float($rotation.text)
	endplat[20] = "              param2: " + str(speed)
	$preview.repeat = true

