extends Node2D
class_name Rail

signal edit

@export var music: bool = false
@export var pointScene:PackedScene = preload("res://point.tscn")
@export var color:Color = Color.RED - Color(.2,0,0,0)
@export var size:float = 4.5

@export var Param0:String = "1000"
@export var Param1:String = "-1"

var loading:bool = false
var locked:bool = false
var segments:int = 1 #number of segments
var lines = []
var points = []
var buttons = []

var fillamount: int = 10 #amount of points for the interpolation tool/slope thing
var fillmode:bool = false

var rail
@onready var Editor = Options.Editor
@onready var idnum = Editor.idnum
@onready var end:PackedStringArray = ["              closed: CLOSE",
"              comment: !l -1",
"              id_name: rail" + str(idnum),
"              layer: LC",
"              link_info: []",
"              link_num: !l 0",
"              name: レール",
"              num_pnt: !l 2",
"              param0: "+Param0+".00000", #railtype
"              param1: "+Param1+".00000", #-1 = visible, 0 = invisible
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
	rail = $Rail
	if loading == false:
		$start.position = Editor.roundedmousepos
	rail.add_point($start.position)
	
	
	$start.set_data()
	#data += $start.pointdata

var data:PackedStringArray = ["            - Points:"]
#var pointdata:Array[PackedStringArray]
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
			if Editor.item == "toolmove":
				button.get_parent().position = Editor.roundedmousepos
	
	if amount != 0: #button is hovered
		if Input.is_action_just_pressed("MoveToBack"):
			Editor.move_child(self,10)
		match Editor.item:
			"tooledit":
				modulate = Color.GREEN_YELLOW
				if pressed:
					emit_signal("edit")
			"tooldelete":
				modulate = Color.RED
				if pressed:
					Editor.delete(self)
					Editor.undolistadd({"Type":"Delete","Node":self})
			"toolproperty":
				modulate = Color.LIGHT_SKY_BLUE
				if pressed:
					if Editor.propertypanel == false:
						var currentdata = get_data()
						Editor.editednode = self
						Editor.propertypanel = true
						Editor.parse([currentdata,end])
						previousdata = currentdata
						previousend = end
						return
			"toolmove":
				modulate = Color.ORANGE
	else:
		modulate = Color.WHITE
	if locked == false and !fillmode:
		if Input.is_action_just_pressed("addpoint"):
			newseg()
			
		if Input.is_action_just_pressed("bridge"):
			newseg()
			bridge()
	if Input.is_action_just_pressed("Shift"):
		fillmode = not fillmode
		

func newseg():
	lines.append([$start.position,$end.position])
	rail.add_point($end.position)
	rail.add_point($end.position)
	var newpoint = pointScene.instantiate()
	newpoint.position = $start.position
	add_child(newpoint)
	points.append(newpoint)
	buttons.append(newpoint.get_node("Button"))
	$end.set_data()
	segments += 1
	
	if segments == 2:
		newpoint.get_node("start").queue_free()
		newpoint.frame = 0
	$start.position = $end.position
	$start.frame = 1

func propertyclose():
	var currentdata = get_data()
	#add the undo log
	if currentdata != previousdata or end != previousend:
		
		Editor.undolistadd({"Type":"PropertyRail","Data":[previousdata,currentdata,previousend,end],"Node":self})
		previousdata = currentdata
		previousend = end

func change_points(points_array:Array,startpoint,endpoint) -> Array:
	var linearray = []
	var previouspoint = null
	for point in points_array:
		point.reposition()
		if previouspoint != null:
			linearray.append([previouspoint.position,point.position])
		previouspoint = point
	startpoint.position = endpoint.position
	return linearray

func reposition():
	lines = change_points(points,$start,$end)
	for line in end:
		
		if line.begins_with("              param0: 1") or line.begins_with("              param0: 5100"):
			for point in points: # reset point scale
				point.texture = preload("uid://xp7hguu2wcws") #point.png
				if point.frame == 0:
					point.scale = Vector2(.35,.35)
				if point.frame == 1:
					point.scale = Vector2(.25,.25)
			size = 4.5
			rail.width = 8
			
		
		if line.begins_with("              param0: 1000") or line.begins_with("              param0: 50"):
			music = false
			color = Color.RED - Color(.2,0,0,0)
			rail.texture = preload("uid://bvrfm1i201crx") #rail.png
		if line.begins_with("              param0: 1200") or line.begins_with("              param0: 52"):
			music = false
			color = Color(.13,.58,.87,1)
			rail.texture = preload("uid://d3hlcipa37df") #railblue.png
		if line.begins_with("              param0: 0"):
			music = false
			rail.width = 40
			rail.texture = preload("uid://qy03g08go247") #railinvisible.png
			size = 27
			color = Color.GRAY
			for point in points:
				point.scale = Vector2(.90,.90)
				point.texture = preload("uid://f1etgbamm888") #pointinvisible.png
		if line.begins_with("              param0: 5100.00000"):
			music = true
			rail.texture = preload("uid://c7vmsjs2op5vu") #wood.png
			for point in points:
				point.scale = Vector2(.35,.35)
				point.texture = preload("uid://d17f750xfl6m0") #pointmusic.png
		elif line.begins_with("              param0: 5"): #probably a message Rail
			for point in points:
				point.texture = preload("uid://buskhmyq1lp3p") #pointmessage.png
		$start.texture = $end.texture
		$start.scale = $end.scale
	idnum = int(end[2].lstrip("              id_name: rail"))
	#update the visuals
	rail.points = []
	for point in points:
		rail.add_point(point.position)
		rail.add_point(point.position)

func done():
	points.append($end)
	$end.segments = segments-1
	$end.set_data()
	locked = true
	idnum += 1
	Editor.idnum += 1
	Editor.lineplacing = true
	buttons.append(get_node("end/Button"))

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
			bridge()

func bridge():
	loading = true
	done()

func set_point_data(newdata:PackedStringArray):
	var pointdata = newdata.duplicate()
	if pointdata.size()<1:
		return
	data = [pointdata[0]]
	pointdata.remove_at(0)
	for point in points:
		point.pointdata = pointdata.slice(0,24)
		var loop = 24
		while loop > 0:
			pointdata.remove_at(0)
			loop -= 1

func get_data():
	var totalpointdata:PackedStringArray = []
	for point in points:
		totalpointdata.append_array(point.pointdata)
	return data + totalpointdata

func _draw():
	if loading == false and fillmode == false:
		$end.position = Editor.roundedmousepos
	draw_line($start.position,$end.position,color + Color(.2,.2,.2),size)
	if loading == false:
		pointcurve()

func EXPORT():
	if visible:
		Editor.bridgedata += get_data() + end
