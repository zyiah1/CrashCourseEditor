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
var points = []
var buttons = []

var fillamount: int = 10 #amount of points for the interpolation tool/slope thing
var fillmode:bool = false

var rail: Line2D
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
	rail.add_point($start.position)

var data:PackedStringArray = ["            - Points:"]
var previousdata:PackedStringArray
var previousend:PackedStringArray

var tool_modulate = {"tooledit":Color.GREEN_YELLOW,"tooldelete":Color.RED,"toolproperty":Color.LIGHT_SKY_BLUE,"toolmove":Color.NAVAJO_WHITE}

func tool_actions(amount,pressed):
	if amount != 0 or pressed: #button is hovered
		if Input.is_action_just_pressed("MoveToBack"):
			Editor.move_child(self,10)
		if Editor.item in tool_modulate: #modulate color
			modulate = tool_modulate.get(Editor.item)
	else:
		modulate = Color.WHITE
	if not pressed:
		return
	match Editor.item:
		"tooledit":
			emit_signal("edit")
		"tooldelete":
			Editor.delete(self)
			Editor.undolistadd({"Type":"Delete","Node":self})
		"toolproperty":
			if Editor.propertypanel == false:
				var currentdata = get_data()
				Editor.editednode = self
				Editor.propertypanel = true
				Editor.parse([currentdata,end])
				previousdata = currentdata
				previousend = end
				return


func _process(delta):
	queue_redraw()
	var amount = 0
	var pressed = false
	for button in buttons:
		var point = button.get_parent()
		var pointID = points.find(point)
		if button.is_hovered():
			amount += 1
			if Input.is_action_just_pressed("bridge") and Editor.item == "tooldelete" and points.size() > 2: #right click
				Editor.undolistadd({"Type":"DeletePoint","Node":self,"Data":get_data(),"PointID":pointID})
				remove_point(pointID)
		if button.button_pressed:
			pressed = true
			if Editor.item == "toolmove":
				point.position = Editor.roundedmousepos
				$start.position = $end.position
				rail.points[pointID*2] = point.position
				rail.points[pointID*2+1] = point.position
		
		
	tool_actions(amount, pressed)
	if locked == false and !fillmode:
		if Input.is_action_just_pressed("addpoint"):
			newseg()
			
		if Input.is_action_just_pressed("bridge"):
			newseg()
			bridge()
	if Input.is_action_just_pressed("Shift"):
		fillmode = not fillmode
		

func newseg():
	rail.add_point($end.position)
	rail.add_point($end.position)
	var newpoint = pointScene.instantiate()
	newpoint.position = $start.position
	if points.size() != 0:
		newpoint.comment = false #make it -dir instead of -comment
	add_child(newpoint)
	points.append(newpoint)
	buttons.append(newpoint.get_node("Button"))
	$end.set_data()
	segments += 1
	
	if segments == 2:
		newpoint.get_node("start").stop()
		newpoint.frame = 0
	$start.position = $end.position
	$start.frame = 1

func remove_point(pointID):
	var point = points[pointID]
	var button = point.get_node("Button")
	if rail != null:
		rail.remove_point(pointID*2+1)
		rail.remove_point(pointID*2)
	segments -= 1
	if point != $end:
		points.remove_at(pointID)
		buttons.erase(button)
		point.queue_free()
		var current_seg = 0
		points[0].make_big()
		for node in points: #redo segment numbers
			node.segments = current_seg
			current_seg += 1
			node.set_data()
	else:
		#remove the point before end and move end to it
		var newpoint = points[pointID-1]
		var newpos = newpoint.position
		buttons.erase(newpoint.get_node("Button"))
		points.erase(newpoint)
		newpoint.queue_free()
		$end.position = newpos
		$start.position = $end.position
		$end.segments = segments-1
		$end.set_data()

func add_point(pointID): #adds a point with the pointID value in the points array
	if pointID == points.size():
		pointID -= 1
	var newpoint = points[0].duplicate()
	add_child(newpoint)
	buttons.insert(pointID,newpoint.get_node("Button"))
	points.insert(pointID,newpoint)
	if rail != null:
		rail.points = []


func propertyclose():
	var currentdata = get_data()
	#add the undo log
	if currentdata != previousdata or end != previousend:
		
		Editor.undolistadd({"Type":"PropertyRail","Data":[previousdata,currentdata,previousend,end],"Node":self})
		previousdata = currentdata
		previousend = end

func change_points(points_array:Array,startpoint,endpoint):
	var rail_points = []
	for point in points_array:
		point.reposition()
		rail_points.append(point.position)
		rail_points.append(point.position)
	startpoint.position = endpoint.position
	return rail_points

func reposition():
	rail.points = change_points(points,$start,$end)
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
		if pointdata.size()<24:
			print("Small POINT DATA :")
			
		
		var maxline = pointdata.find("                  unit_name: Point") #account for different array sizes
		point.pointdata = pointdata.slice(0,maxline+1) #get each point slice
		
		var loop = 30
		while loop > 0: #remove the data we already got
			pointdata.remove_at(0)
			loop -= 1
			if pointdata[0] == "                  unit_name: Point":
				pointdata.remove_at(0)
				loop = 0 #end loop

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
