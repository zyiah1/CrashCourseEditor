extends Node2D
signal finish

@export var point: PackedScene = preload("res://pointR.tscn")
@export var Param0: int = 2140
@export var reset: int = 1

@export var midImage:Texture2D = null
@export var color: Color = Color(.92,.98,.98)

var locked = false
var segments = 1
var line = null
var lines = []
var points = []
var mode = 0 #0 = path 1 = platform
var loading = false
var path = []
var speed = 2
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
	rail.texture = load("res://railwhite.png")
	$rotation.connect("focus_entered", Callable(self, "focus_entered"))
	$rotation.connect("focus_exited", Callable(self, "focus_exited"))
	$end/Button.connect("button_down", Callable(get_parent(), "_on_Button_button_down"))
	$end/Button.connect("button_up", Callable(get_parent(), "_on_Button_button_up"))
	get_parent().buttons.append($end/Button)
	$rotation.text = str(speed)
	if loading == false:
		$start.position = get_global_mouse_position()
	else:
		$rotation.hide()
	rail.add_point($start.position)
	$preview.rail.add_point($start.position)
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

@onready var dataseg = ["                - comment: !l -1",
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



@onready var endplat = ["              closed: CLOSE",
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
"              param0: "+str(Param0) + ".00000", #railtype
"              param1: 0.00000",#rotation for pivots
"              param2: " + str(speed) + ".00000", #speed
"              param3: "+str(reset),#-1 == does not reset on respawn, 1 == does
"              param4:  0.00000", #
"              param5: -1.00000",
"              param6: -1.00000",
"              param7: 1.00000", #
"              param8: -1.00000",
"              param9: -1.00000",
"              type: Linear",
"              unit_name: Path3D"]


#Param 0 documentation
#0 invisible collision used for the map edges
#1000 Normal
#1100 unused
#1200 blue normal
#2000 Automove but it stays and doesn't go back
#2011 unused
#2021 unused
#2110 Lcrank
#2111 Rcrank
#2140 Lmove
#2141 Rmove
#2150 fan
#2200 automove
#2300 Automove but it stays and doesn't go back
#2330 moving platform press X anywhere, doens't go back
#2380 move after area 0 checkpoint activated
#2390 Move after 10th checkpoint is activated
#2392 move when level beat
#3110 Lspin unused
#3111 Rspin
#3112 MLtilt
#3113 MRtilt
#3140 pivitL
#3141 PivitR
#3200 auto Pivot but goes back
#3300 autoPivit stays no go back (default)
#3392 Rotate when level beat
#4300 param6 is how much to move camera y position (- = down)
#4900 invisble when I tried to load it (Might just be another way to do invisible track
#5013 normal rail
#5040 normal rail
#5041 normal rail
#5060 appears in game as a normal rail, used in normal level as a path for end moving rail to follow despite having collision
#5100 ACTUAL MUSIC TILE
#5211 
#5240 
#5241 
#5260 Message Param7 chooses which thing to say, 0 == be brave
#2900 Track


func _process(delta):
	$rotation.position = $start.position - Vector2(0,100)
	queue_redraw()
	if Input.is_action_just_pressed("accept"):
		$rotation.hide()
	if locked == false:
		if Input.is_action_just_pressed("undo"):
			if segments == 1:
				get_parent().idnum-=1
				get_parent().lineplacing = true
				queue_free()
				
		if Input.is_action_just_pressed("addpoint"):
			newseg()
			
		if Input.is_action_just_pressed("bridge"):
			if mode == 0:
				locked = true
				
				get_parent().get_parent().lineplacing = true
				$rotation.grab_focus()
				$rotation.set_caret_column(3)
	if is_queued_for_deletion():
		get_parent().get_parent().Ain()
		get_parent().get_parent().railplace = -420
		get_parent().queue_free()
		get_parent().get_parent().lineplacing = true


func newseg():
	lines.append([$start.position,$end.position])
	rail.add_point($end.position)
	$preview.rail.add_point($end.position)
	var newpoint = point.instantiate()
	newpoint.position = $start.position
	add_child(newpoint)
	points.append(newpoint)
	get_parent().buttons.append(newpoint.get_node("Button"))
	newpoint.get_node("Button").connect("button_down", Callable(get_parent(), "_on_Button_button_down"))
	newpoint.get_node("Button").connect("button_up", Callable(get_parent(), "_on_Button_button_up"))
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
		
		get_parent().get_parent().lineplacing = true



func _draw():
	if locked == false and loading == false:
		$end.position = get_global_mouse_position()
	draw_line($start.position,$end.position,color,4.5)
	
	#draw the image that appears between the points
	if midImage != null:
		$Mid.texture = midImage
		var amount = 1
		var combinedpositions = $end.position
		
		if locked == false:
			amount = 2
			combinedpositions = $end.position+$start.position
		
		for node in points:
			amount += 1
			combinedpositions += node.position
		$Mid.position = (combinedpositions)/amount

func EXPORT():
	get_parent().get_parent().bridgedata += get_parent().data + get_parent().end + data + endplat







func _on_rotation_change():
	speed = float($rotation.text)
	endplat[20] = "              param2: " + str(speed)
	$preview.repeat = true
