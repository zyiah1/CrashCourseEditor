extends Node2D
signal done

const point = preload("res://pointL.tscn")
var locked = false
var segments = 1
var line = null
var lines = []
var points = []
var mode = 0 #0 = path 1 = platform
var loading = false
var path = []
var speed = 2

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
"              name: レール", #means rail
"              num_pnt: !l 3",
"              param0: 2140.00000", #railtype
"              param1: 0.00000",
"              param2: " + str(speed), #speed
"              param3: 1.00000",#-1 == does not reset on respawn, 1 == does
"              param4:  0.00000", #
"              param5: -1.00000",
"              param6: -1.00000",
"              param7: 1.00000", #
"              param8: -1.00000",
"              param9: -1.00000",
"              type: Linear",
"              unit_name: Path"]



#0 invisible collision used for the map edges
#1000 Normal
#1200 blue normal
#2000 Automove but it stays and doesn't go back
#2110 Lcrank
#2111 Rcrank
#2140 Lmove
#2141 Rmove
#2150 fan
#2200 automove
#2300 Automove but it stays and doesn't go back
#2392 move when level beat
#3110 Lspin
#3111 Rspin
#3112 MLtilt
#3113 MRtilt
#3140 pivitL
#3141 PivitR
#3300 autoPivit
#3392 Rotate when level beat
#4900 crash
#5013
#5041 noise
#2900 Track


func _process(delta):
	update()
	if Input.is_action_just_pressed("accept"):
		$rotation.hide()
	if locked == false:
		if Input.is_action_just_pressed("undo"):
			if segments == 1:
				get_parent().idnum-=1
				get_parent().line = true
				queue_free()
				
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
	if locked == false and loading == false:
		$end.position = get_global_mouse_position()
	line = draw_line($start.position,$end.position,Color(.92,.98,.98),4.5)
	for lineb in lines:
		draw_line(lineb[0],lineb[1],Color.whitesmoke - Color(.1,.1,.1,0),4.5)
		

func EXPORT():
	get_parent().get_parent().bridgedata += get_parent().data + get_parent().end + data + endplat







func _on_rotation_change():
	speed = float($rotation.text)
	endplat[20] = "              param2: " + str(speed)
	$preview.repeat = true
