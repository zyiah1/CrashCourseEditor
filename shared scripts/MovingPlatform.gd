extends Node2D

const pointscene: PackedScene = preload("res://point.tscn")

@export var pointtexture: Texture2D = preload("res://pointR.png")
@export var railtexture: Texture2D = preload("res://railwhite.png")
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
@onready var idnum = get_parent().idnum + 1

var fillamount: int = 10 #amount of points for the interpolation tool/slope thing
var fillmode:bool = false

func focus_entered():
	$rotation.visible = true

func focus_exited():
	$rotation.visible = false

func _ready():
	var inst = load("res://rail.tscn").instantiate()
	add_child(inst)
	move_child(inst, 0)
	
	
	rail = inst
	rail.texture = railtexture
	$rotation.connect("focus_entered", Callable(self, "focus_entered"))
	$rotation.connect("focus_exited", Callable(self, "focus_exited"))
	get_parent().buttons.append($end/Button)
	$rotation.text = str(speed)
	if loading == false:
		$start.position = get_parent().get_parent().roundedmousepos
		rail.add_point($start.position)
		$preview.rail.add_point($start.position)
	else:
		$rotation.hide()
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



@onready var endplat:PackedStringArray = ["              closed: CLOSE",
"              comment: !l -1",
"              id_name: rail" + str(idnum),
"              layer: LC",
"              link_info:",
"                - linkID: rail" + str(get_parent().idnum),
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
"              unit_name: Path"]

#Param 0 documentation
#0 invisible collision used for the map edges
#1000 Normal
#1100 Shows up as a music rail
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
#2380 Move after 0th checkpoint is activated
#2381 Move after 1st checkpoint is activated
#2382 Move after 2nd checkpoint is activated
#2383 Move after 3rd checkpoint is activated
#2384 Move after 4th checkpoint is activated
#2385 Move after 5th checkpoint is activated
#2386 Move after 6th checkpoint is activated
#2387 Move after 7th checkpoint is activated
#2388 Move after 8th checkpoint is activated
#2389 Move after 9th checkpoint is activated
#2390 Move after 10th checkpoint is activated
#2391 Move after 11th checkpoint is activated
#2392 move when level beat
#2393 used for that DK dying cutscene where the rails move to the fallen position after a brief delay
#2394 same as ^^^^ but more delay?
#2900 PathRail
#3110 Lspin unused
#3111 Rspin
#3112 MLtilt
#3113 MRtilt
#3140 pivitL
#3141 PivitR
#3200 auto Pivot but goes back
#3300 autoPivit stays no go back (default)
#3380 Rotate after 0th checkpoint is activated
#3381 Rotate after 1st checkpoint is activated
#3382 Rotate after 2nd checkpoint is activated
#3383 Rotate after 3rd checkpoint is activated
#3384 Rotate after 4th checkpoint is activated
#3385 Rotate after 5th checkpoint is activated
#3386 Rotate after 6th checkpoint is activated
#3387 Rotate after 7th checkpoint is activated
#3388 Rotate after 8th checkpoint is activated
#3389 Rotate after 9th checkpoint is activated
#3390 Rotate after 10th checkpoint is activated
#3391 Rotate after 11th checkpoint is activated
#3392 Rotate when level beat
#4300 param6 is how much to move camera y position (- = down)
#4900 invisble when I tried to load it (Might just be another way to do invisible track
#5010 Red| Rotate L Stick Message (Message things dont show if Param7 == -1, I think its delay before the message is shown)
#5011 Red| Rotate R Stick Message
#5012 Red| Tilt L Stick Message
#5013 Red| Tilt R Stick Message
#5040 Red| Press L Message
#5041 Red| Press R Message
#5060 Red| Be brave Message
#5100 ACTUAL MUSIC TILE
#5210 Blue| Rotate L Stick Message
#5211 Blue| Rotate R Stick Message
#5212 Blue| Tilt L Stick Message
#5213 Blue| Tilt R Stick Message
#5240 Blue| Press L Message
#5241 Blue| Press R Message
#5260 Blue| Be Brave Message



func _process(delta):
	$rotation.position = $start.position - Vector2(0,100)
	queue_redraw()
	if Input.is_action_just_pressed("accept"):
		$rotation.hide()
	if locked == false and fillmode == false:
		if Input.is_action_just_pressed("addpoint"):
			newseg()
			
		if Input.is_action_just_pressed("bridge"):
			newseg()
			if mode == 0:
				locked = true
				
				get_parent().get_parent().lineplacing = true
				$rotation.grab_focus()
				$rotation.set_caret_column(3)
	if Input.is_action_just_pressed("Shift"):
		fillmode = not fillmode

func newseg():
	lines.append([$start.position,$end.position])
	rail.add_point($end.position)
	$preview.rail.add_point($end.position)
	rail.add_point($end.position)
	$preview.rail.add_point($end.position)
	var newpoint = pointscene.instantiate()
	newpoint.texture = pointtexture
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
		newpoint.get_node("start").queue_free()
		newpoint.frame = 0


func done():
	if mode == 0:
		locked = true
		
		get_parent().get_parent().lineplacing = true

func _input(event):
	if event is InputEventMouseButton and fillmode and locked == false and loading == false:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			fillamount += 1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and fillamount > 2:
			fillamount -= 1

func pointcurve():
	if fillmode and locked == false:
		var changerate = 1.0/fillamount
		var weight = changerate
		var dots = []
		var cycle = fillamount
		while cycle > 1:
			dots.append($start.position.cubic_interpolate($end.position,$start/handle.global_position+$start/handle.position,$end/handle.global_position+$end/handle.position,weight))
			weight += changerate
			cycle -= 1
		for point in dots:
			draw_circle(point,5,Color.DIM_GRAY)
		if Input.is_action_just_pressed("addpoint") and not $end/handle.is_hovered() and not $start/handle.is_hovered() or Input.is_action_just_pressed("bridge"):
			dots.append($end.position)
			for point in dots:
				$end.position = point
				newseg()
			fillmode = false
			$start/handle.position = Vector2(-45,-14)
			$end/handle.position = Vector2(20,-14)
		if Input.is_action_just_pressed("bridge"):
			loading = true
			if mode == 0:
				locked = true
				get_parent().get_parent().lineplacing = true
				$rotation.grab_focus()
				$rotation.set_caret_column(3)

func _draw():
	if locked == false and loading == false:
		if !fillmode:
			$end.position = get_parent().get_parent().roundedmousepos
		pointcurve()
	draw_line($start.position,$end.position,color,4.5)
	#draw the image that appears between the points (fan)
	if midImage != null:
		$Mid.show()
		$Mid.texture = midImage
		$Mid.position = get_parent().points[0].position
	else:
		$Mid.hide()

func EXPORT():
	get_parent().get_parent().bridgedata += get_parent().data + get_parent().end + data + endplat







func _on_rotation_change():
	speed = float($rotation.text)
	var loop = 0
	for dat in endplat:
		if dat.begins_with("              param2:"):
			break
		loop += 1
	endplat[loop] = "              param2: " + str(speed)
	$preview.repeat = true
