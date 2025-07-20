extends Node2D

signal edit

@export var music: bool = false
@export var pointScene:PackedScene = preload("res://point.tscn")
@export var color:Color = Color.RED - Color(.2,0,0,0)
@export var size:float = 4.5

@export var Param0:String = "1000"
@export var Param1:String = "-1"

var loading:bool = false
var locked:bool = false
var segments:int = 1 #amount of segments
var lines = []
var points = []

var buttons = []




@onready var rail = $Rail
@onready var idnum = get_parent().idnum
@onready var end:PackedStringArray = ["              closed: CLOSE",
"              comment: !l -1",
"              id_name: rail" + str(idnum),
"              layer: LC",
"              link_info: []",
"              link_num: !l 0",
"              name: レール",
"              num_pnt: !l 2",
"              param0: "+Param0+".00000",
"              param1: "+Param1+".00000",
"              param2: -1.00000",
"              param3: -1.00000",
"              param4:  0.00000",
"              param5: -1.00000",
"              param6: -1.00000",
"              param7: -1.00000",#message that displays?
"              param8: -1.00000",
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

var previousdata:PackedStringArray
var previousend:PackedStringArray



func _process(delta):
	queue_redraw()
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
					get_parent().delete(self)
					get_parent().undolistadd({"Type":"Delete","Node":self})
			"proporties":
				modulate = Color.LIGHT_SKY_BLUE
				if pressed:
					if get_parent().propertypanel == false:
						get_parent().propertypanel = true
						get_parent().parse(data)
						get_parent().parse(end)
						get_parent().editednode = self
						previousdata = data
						previousend = end
						return
	else:
		modulate = Color.WHITE
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
	segments += 1
	
	if segments == 2:
		newpoint.get_node("start").queue_free()
		newpoint.frame = 0
	$start.position = $end.position
	$start.frame = 1

func propertyclose():
	#add the undo log
	if data != previousdata or end != previousend:
		get_parent().undolistadd({"Type":"PropertyRail","Data":[previousdata,data,previousend,end],"Node":self})
		previousdata = data
		previousend = end

func reposition():
	var currentpoint = 0
	var currentline = 0
	var count = -1
	var first = true
	var cycles = -1
	
	for line in end:
		
		if line.begins_with("              param0: 1") or line.begins_with("              param0: 5100"):
			for point in points: # reset point scale
				point.texture = preload("res://point.png")
				if point.frame == 0:
					point.scale = Vector2(.35,.35)
				if point.frame == 1:
					point.scale = Vector2(.25,.25)
			$start.texture = preload("res://point.png")
			$end.texture = preload("res://point.png")
			$start.scale = Vector2(.35,.35)
			$end.scale = Vector2(.35,.35)
			size = 4.5
			rail.width = 8
			
		match line:
			"              param0: 1000.00000":
				music = false
				color = Color.RED - Color(.2,0,0,0)
				rail.texture = load("res://rail.png")
			"              param0: 1200.00000":
				music = false
				color = Color(.13,.58,.87,1)
				rail.texture = load("res://railblue.png")
			"              param0: 0.00000":
				music = false
				rail.width = 40
				rail.texture = load("res://railinvisible.png")
				$start.scale = Vector2(.90,.90)
				$end.scale = Vector2(.90,.90)
				$start.texture = preload("res://pointinvisible.png")
				$end.texture = preload("res://pointinvisible.png")
				size = 27
				color = Color.GRAY
				for point in points:
					point.scale = Vector2(.90,.90)
					point.texture = preload("res://pointinvisible.png")
			"              param0: 5100.00000":
				music = true
				rail.texture = preload("res://wood.png")
				for point in points:
					point.scale = Vector2(.35,.35)
					point.texture = preload("res://pointmusic.png")
				$start.texture = preload("res://pointmusic.png")
				$end.texture = preload("res://pointmusic.png")
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

func EXPORT():
	if visible:
		get_parent().bridgedata += data + end
