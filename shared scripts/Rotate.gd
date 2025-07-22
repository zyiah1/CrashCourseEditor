extends Node2D

const pointscene: PackedScene = preload("res://point.tscn")

@export var pointtexture: Texture2D = preload("res://pointR.png")
@export var Param0: int = 3140
@export var rotationpoint: int = 0 
@export var color: Color = Color(.92,.98,.98)
@export var railtexture: Texture2D = load("res://railwhite.png")
@onready var idnum = get_parent().get_parent().idnum

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
	$rotation.show()

func focus_exited():
	$rotation.hide()

func _ready():
	loading = get_parent().loading
	var inst = load("res://rail.tscn").instantiate()
	add_child(inst)
	move_child(inst, 0)
	
	
	rail = inst
	rail.texture = railtexture
	$rotation.connect("focus_entered", Callable(self, "focus_entered"))
	$rotation.connect("focus_exited", Callable(self, "focus_exited"))
	if loading == false:
		$start.position = owner.get_parent().roundedmousepos
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

@onready var end:PackedStringArray = ["              closed: CLOSE",
"              comment: !l -1",
"              id_name: rail" + str(idnum),
"              layer: LC",
"              link_info: []",
"              link_num: !l 0",
"              name: レール",
"              num_pnt: !l 2",
"              param0: " + str(Param0) + ".00000",
"              param1: " + str(int($rotation.text)), #max degree tilt
"              param2: 2.50000", #speed
"              param3: "+str(rotationpoint), #This is the point it rotates from: 0 = 1st 1 = 2nd ect.
"              param4: 0.00000",
"              param5: -1.00000",
"              param6: -1.00000",
"              param7: 3.00000",
"              param8: -1.00000",
"              param9: -1.00000",
"              type: Linear",
"              unit_name: Path"]

func propertyclose():
	#add the undo log
	if data != previousdata or end != previousend:
		owner.get_parent().undolistadd({"Type":"PropertyRail","Data":[previousdata,data,previousend,end],"Node":self})
		previousdata = data
		previousend = end

func changepoints(raildata:PackedStringArray,startpoint:Node,endpoint:Node,pointarray:Array,linearray:Array) -> Array:
	var currentpoint = 0
	var currentline = 0
	var count = -1
	var first = true
	var cycles = -1
	
	for line in raildata:
		cycles += 1
		if currentpoint == pointarray.size():
			if line.begins_with("                  pnt0_x: "):
				startpoint.position.x = float(line.lstrip("                  pnt0_x: "))
				currentline = linearray.size() - 1
			if line.begins_with("                  pnt0_y: "):
				startpoint.position.y = -float(line.lstrip("                  pnt0_y: "))
				endpoint.position = startpoint.position
				linearray[currentline][1] = endpoint.position
				if pointarray.size() >= 2:
					linearray[currentline][0] = linearray[currentline-1][1]
			if line.begins_with("                  pnt1_x: "):
				raildata[cycles] = "                  pnt1_x: " + str(endpoint.position.x)
			if line.begins_with("                  pnt1_y: "):
				raildata[cycles] = "                  pnt1_y: " + str(-endpoint.position.y)
				
			if line.begins_with("                  pnt2_x: "):
				raildata[cycles] = "                  pnt2_x: " + str(endpoint.position.x)
			if line.begins_with("                  pnt2_y: "):
				raildata[cycles] = "                  pnt2_y: " + str(-endpoint.position.y)
		else:
			if line.begins_with("                  pnt0_x: "):
				count += 1
				if first == true:
					if count >= 2:
						count = 0
						currentline += 1
						first = false
				pointarray[currentpoint].position.x = float(line.lstrip("                  pnt0_x: "))
				if first == true:
					linearray[currentline][count].x = pointarray[currentpoint].position.x
				else:
					linearray[currentline][0].x = linearray[currentline - 1][1].x
					linearray[currentline][1].x = pointarray[currentpoint].position.x
			if line.begins_with("                  pnt0_y: "):
				pointarray[currentpoint].position.y = -float(line.lstrip("                  pnt0_y: "))
				if first == true:
					linearray[currentline][count].y = pointarray[currentpoint].position.y
				else:
					linearray[currentline][0].y = linearray[currentline - 1][1].y
					linearray[currentline][1].y = pointarray[currentpoint].position.y
					currentline += 1
				
			if line.begins_with("                  pnt1_x: "):
				raildata[cycles] = "                  pnt1_x: " + str(pointarray[currentpoint].position.x)
			if line.begins_with("                  pnt1_y: "):
				raildata[cycles] = "                  pnt1_y: " + str(-pointarray[currentpoint].position.y)
				
			if line.begins_with("                  pnt2_x: "):
				raildata[cycles] = "                  pnt2_x: " + str(pointarray[currentpoint].position.x)
			if line.begins_with("                  pnt2_y: "):
				raildata[cycles] = "                  pnt2_y: " + str(-pointarray[currentpoint].position.y)
				
				currentpoint += 1
	return linearray

func reposition():
	lines = changepoints(data,$start,$end,points,lines)
	for line in end:
		if line.begins_with("              param0:"): #get the point kind
			var newpointtexture = preload("res://point.png")
			var rotatetexture = preload("res://pivotR.png")
			$crank.rail.texture = preload("res://railPurple.png")
			rail.texture = preload("res://rail.png")
			$crank2.hide()
			remove_from_group("EndSpin")
			remove_from_group("AutoSpin")
			
			
			#spin
			if line.begins_with("              param0: 3110"):
				newpointtexture = preload("res://pointL.png")
				$crank.rail.texture = preload("res://railblue.png")
				rail.texture = preload("res://railwhite.png")
				rotatetexture = preload("res://crankL.png")
			if line.begins_with("              param0: 3111"):
				newpointtexture = preload("res://pointR.png")
				$crank.rail.texture = preload("res://rail.png")
				rail.texture = preload("res://railwhite.png")
				rotatetexture = preload("res://crankR.png")
			#L points
			if line.begins_with("              param0: 3140") or line.begins_with("              param0: 3150"):
				newpointtexture = preload("res://pointL.png")
				$crank.rail.texture = preload("res://railblue.png")
				rail.texture = preload("res://railwhite.png")
				rotatetexture = preload("res://pivotL.png")
			#R points
			if line.begins_with("              param0: 3141"):
				newpointtexture = preload("res://pointR.png")
				$crank.rail.texture = preload("res://rail.png")
				rail.texture = preload("res://railwhite.png")
			#Auto points
			if line.begins_with("              param0: 3200") or line.begins_with("              param0: 3300") or line.begins_with("              param0: 3322") or line.begins_with("              param0: 3423"):
				add_to_group("AutoSpin")
				newpointtexture = preload("res://pointA.png")
				$crank.rail.texture = preload("res://railGreen.png")
				rail.texture = preload("res://railwhite.png")
				rotatetexture = preload("res://pivotA.png")
			
			#End Points
			if line.begins_with("              param0: 3380"):
				newpointtexture = preload("res://PointE0.png")
				rotatetexture = preload("res://PivotE0.png")
			if line.begins_with("              param0: 3381"):
				newpointtexture = preload("res://PointE1.png")
				rotatetexture = preload("res://PivotE1.png")
			if line.begins_with("              param0: 3382"):
				newpointtexture = preload("res://PointE2.png")
				rotatetexture = preload("res://PivotE2.png")
			if line.begins_with("              param0: 3383"):
				newpointtexture = preload("res://PointE3.png")
				rotatetexture = preload("res://PivotE3.png")
			if line.begins_with("              param0: 3384"):
				newpointtexture = preload("res://PointE4.png")
				rotatetexture = preload("res://PivotE4.png")
			if line.begins_with("              param0: 3385"):
				newpointtexture = preload("res://PointE5.png")
				rotatetexture = preload("res://PivotE5.png")
			if line.begins_with("              param0: 3386"):
				newpointtexture = preload("res://PointE6.png")
				rotatetexture = preload("res://PivotE6.png")
			if line.begins_with("              param0: 3387"):
				newpointtexture = preload("res://PointE7.png")
				rotatetexture = preload("res://PivotE7.png")
			if line.begins_with("              param0: 3388"):
				newpointtexture = preload("res://PointE8.png")
				rotatetexture = preload("res://PivotE8.png")
			if line.begins_with("              param0: 3389"):
				newpointtexture = preload("res://PointE9.png")
				rotatetexture = preload("res://PivotE9.png")
			if line.begins_with("              param0: 3390"):
				newpointtexture = preload("res://PointE10.png")
				rotatetexture = preload("res://PivotE10.png")
			if line.begins_with("              param0: 3391"):
				newpointtexture = preload("res://PointE11.png")
				rotatetexture = preload("res://PivotE11.png")
			if line.begins_with("              param0: 3392") or line.begins_with("              param0: 3393") or line.begins_with("              param0: 3394"):
				newpointtexture = preload("res://pointE.png")
				rotatetexture = preload("res://pivotEnd.png")
			if line.begins_with("              param0: 3112"): # tilt platforsm
				newpointtexture = preload("res://pointL.png")
				$crank.rail.texture = preload("res://railblue.png")
				rail.texture = preload("res://railwhite.png")
				$crank2.show()
				$crank2.rail.texture = preload("res://raildarkblue.png")
				rotatetexture = preload("res://pivotLS.png")
			if line.begins_with("              param0: 3113"):
				newpointtexture = preload("res://pointR.png")
				$crank.rail.texture = preload("res://rail.png")
				rail.texture = preload("res://railwhite.png")
				$crank2.show()
				$crank2.rail.texture = preload("res://railmaroon.png")
				rotatetexture = preload("res://pivotRS.png")
			for point in points:
				point.texture = newpointtexture
			
			if $crank.rail.texture == preload("res://railPurple.png"):
				add_to_group("EndSpin")
			
			$end.texture = newpointtexture
			$start.texture = newpointtexture
			$crank/crank.texture = rotatetexture
			$crank2/crank2.texture = rotatetexture
	
	
	$crank.position = points[0].position
	var text = end[9]
	text = text.erase(0,22)
	if -float(text) == -int(text): #keeps number simple
		$rotation.text = str(-int(text))
	else:
		$rotation.text = str(-float(text))
	
	$crank.target = float($rotation.text)
	$rotation.prev = $rotation.text
	$crank.rotation_degrees = 0
	$rotation.position = $crank.position + Vector2(-20,-100)
	
	idnum = int(end[2].lstrip("              id_name: rail"))
	#update the visuals
	rail.points = []
	get_node("crank").rail.points = []
	for point in points:
		rail.add_point(point.position)
		get_node("crank").rail.add_point(point.position)
		rail.add_point(point.position)
		get_node("crank").rail.add_point(point.position)
		point.scale = Vector2(.25,.25)
	rail.add_point($end.position)
	get_node("crank").rail.add_point($end.position)
	rail.add_point($end.position)
	get_node("crank").rail.add_point($end.position)
	changepivotpoint()

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
			targetswappoint.scale = Vector2(.35,.35)
		targetswappoint.position = oldpos
	$start.position = $end.position

func _process(delta):
	#update the lines
	queue_redraw()
	if Input.is_action_just_pressed("accept"):
		$rotation.hide()

	
	var amount = 0
	var pressed = false
	for button in buttons:
		if button.is_hovered():
			amount += 1
		if button.button_pressed:
			pressed = true
	
	if amount != 0: #button is hovered
		match owner.get_parent().item:
			"edit":
				modulate = Color.GREEN_YELLOW
				if pressed:
					get_node("rotation").show()
					get_node("rotation").grab_focus()
					get_node("rotation").set_caret_column(7)
			"delete":
				modulate = Color.RED
				if pressed:

					owner.get_parent().delete(owner)
					owner.get_parent().undolistadd({"Type":"Delete","Node":owner})
			"proporties":
				modulate = Color.LIGHT_SKY_BLUE
				if pressed and owner.get_parent().propertypanel == false:
					get_parent().get_parent().editednode = self
					get_parent().get_parent().propertypanel = true
					get_parent().get_parent().parse([data,end])
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
			locked = true
			end[9] = "              param1: " + str(-int($rotation.text)) #max degree tilt
			get_parent().get_parent().idnum += 1
			get_parent().get_parent().lineplacing = true
			buttons.append(get_node("end/Button"))
			$rotation.grab_focus()
			$rotation.set_caret_column(3)
	$crank.target = int($rotation.text)
		

func newseg():
	lines.append([$start.position,$end.position])
	rail.add_point($end.position)
	$crank.rail.add_point($end.position)
	rail.add_point($end.position)
	$crank.rail.add_point($end.position)
	var newpoint = pointscene.instantiate()
	newpoint.texture = pointtexture
	newpoint.position = $start.position
	if first == true:
		newpoint.hide()
		first = false
		$start.show()
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
	$start.position = $end.position
	$start.frame = 1
	segments += 1
	
	if segments == 2:
		newpoint.get_node("start").queue_free()
		newpoint.frame = 0



func done():
	locked = true
	get_parent().get_parent().idnum += 1
	get_parent().get_parent().bridgedata += data + end
	get_parent().get_parent().lineplacing = true
	buttons.append(get_node("end/Button"))


func _draw():
	if loading == false and locked == false:
		$end.position = owner.get_parent().roundedmousepos
	draw_line($start.position,$end.position,color,4.5)

func EXPORT():
	if end != null:
		if end[9] != null:
			end[9] = "              param1: " + str(-$crank.target)
			get_parent().get_parent().bridgedata += data + end



func _on_rotation_rotationupdated(text):
	end[9] = "              param1: " + str(-int(text))
