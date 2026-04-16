extends Rail
class_name PathRail

var speed = 2
var mode = 0 #0 = path 1 = platform
var childrail = null
var child_id_num:int = 0
@export var railscene: PackedScene = preload("res://RMove.tscn")


var previousplatdata: PackedStringArray
var previousplatend: PackedStringArray


func _ready():
	if end[9].begins_with("              param1: 0"): # invisible
		color = Color(.7,.7,.7,.5)
	else:
		color = Color(.2,.2,.2)
	if loading == false:
		$start.position = get_parent().roundedmousepos
		idnum = Editor.idnum
		end[2] = "              id_name: rail" + str(idnum)

func propertyclose():
	var currentdata = get_data()
	var childcurrentdata = childrail.get_data()
	#add the undo log
	if currentdata != previousdata or end != previousend or childcurrentdata != previousplatdata or childrail.endplat != previousplatend:
		get_parent().undolistadd({"Type":"PropertyMoveRail","Data":[previousdata,currentdata,previousend,end,previousplatdata,childcurrentdata,previousplatend,childrail.endplat],"Node":self})
		previousdata = currentdata
		previousend = end
		previousplatdata = childcurrentdata
		previousplatend = childrail.endplat

func remove_point(pointID):
	super(pointID)
	childrail.get_node("preview").repeat = true

func change_points(points_array:Array,startpoint,endpoint):
	super(points_array,startpoint,endpoint)
	childrail.get_node("preview").repeat = true

func reposition():
	change_points(points,$start,$end)
	idnum = int(end[2].lstrip("              id_name: rail"))
	
	for line in childrail.endplat: #change appearence of things based on their type
		if line.begins_with("              param0:"): #get the point kind
			var pointtexture = preload("uid://xp7hguu2wcws") #point.png
			childrail.get_node("preview").rail.texture = preload("uid://dd6bsp038gsk0") #railPurple.png
			childrail.rail.texture = preload("uid://bvrfm1i201crx") #rail.png
			childrail.midImage = null
			remove_from_group("AutoMove")
			remove_from_group("EndMove")
			
			#fan
			if line.begins_with("              param0: 2150"):
				childrail.midImage = preload("res://fan.png")
				childrail.rail.texture = preload("uid://bw3l07oyd028f") #railwhite.png
			#L points
			elif line.begins_with("              param0: 21"):
				pointtexture = preload("uid://covcxxp27opw") #pointL.png
				childrail.get_node("preview").rail.texture = preload("uid://d3hlcipa37df") #railblue.png
				childrail.rail.texture = preload("uid://bw3l07oyd028f") #railwhite.png
			if line.begins_with("              param0: 2110"):
				childrail.midImage = preload("uid://ckd1nvejuas1") #crankL.png
			#R points
			if line.begins_with("              param0: 2141") or line.begins_with("              param0: 2111"):
				pointtexture = preload("uid://tmpumwmwcucm") #pointR.png
				childrail.get_node("preview").rail.texture = preload("uid://bvrfm1i201crx") #rail.png
				childrail.rail.texture = preload("uid://bw3l07oyd028f") #railwhite.png
			if line.begins_with("              param0: 2111"):
				childrail.midImage = preload("uid://bvycd1a6kxdhr") #crankR.png
			#Auto points
			if line.begins_with("              param0: 2200") or line.begins_with("              param0: 2300") or line.begins_with("              param0: 2000") or line.begins_with("              param0: 4300"):
				add_to_group("AutoMove")
				pointtexture = preload("uid://dv1xfkkmbirrk") #pointA.png
				childrail.get_node("preview").rail.texture = preload("uid://ksbllqjphq5t") #railGreen.png
				childrail.rail.texture = preload("uid://bw3l07oyd028f") #railwhite.png
			#End Points
			if line.begins_with("              param0: 2380"):
				pointtexture = preload("uid://b7lahmfrodnve") #PointE0.png
			if line.begins_with("              param0: 2381"):
				pointtexture = preload("uid://djsdxta7ufsl8") #PointE1.png
			if line.begins_with("              param0: 2382"):
				pointtexture = preload("uid://b5k5uonnog4v6") #PointE2.png
			if line.begins_with("              param0: 2383"):
				pointtexture = preload("uid://boj4lu6r6g8ob") #PointE3.png
			if line.begins_with("              param0: 2384"):
				pointtexture = preload("uid://djuhfoj4eg0vh") #PointE4.png
			if line.begins_with("              param0: 2385"):
				pointtexture = preload("uid://b7idwkrvbv5kn") #PointE5.png
			if line.begins_with("              param0: 2386"):
				pointtexture = preload("uid://clwton8qfrc21") #PointE6.png
			if line.begins_with("              param0: 2387"):
				pointtexture = preload("uid://c8ygmxmmyuwsb") #PointE7.png
			if line.begins_with("              param0: 2388"):
				pointtexture = preload("uid://bhrjjon6md4xv") #PointE8.png
			if line.begins_with("              param0: 2389"):
				pointtexture = preload("uid://dr3tgkdixayt") #PointE9.png
			if line.begins_with("              param0: 2390"):
				pointtexture = preload("uid://bawmu7reyj84q") #PointE10.png
			if line.begins_with("              param0: 2391"):
				pointtexture = preload("uid://6e3rhcq5lbnp") #PointE11.png
			if line.begins_with("              param0: 2392") or line.begins_with("              param0: 2393") or line.begins_with("              param0: 2394"):
				pointtexture = preload("uid://dn2w76gtiqspv") #PointE.png
			for point in childrail.points:
				point.texture = pointtexture
			
			#if railPurple.png, and not a fan
			if childrail.get_node("preview").rail.texture == preload("uid://dd6bsp038gsk0") and not line.begins_with("              param0: 2150"):
				add_to_group("EndMove")
			childrail.get_node("end").texture = pointtexture
			childrail.get_node("start").texture = pointtexture
		if line.begins_with("              param2: "):
			var text = line
			if float(text.erase(0,22)) == int(text.erase(0,22)): #keeps number simple
				text = str(int(text.erase(0,22)))
			else:
				text = str(float(text.erase(0,22)))
			childrail.get_node("speed").text = text
			childrail._on_speed_change()
	 # cycle through child data
	
	childrail.rail.points = childrail.change_points(childrail.points,childrail.get_node("start"),childrail.get_node("end"))
	#visible and invisible rail color differ
	if end[9].begins_with("              param1: 0"): # invisible
		color = Color(.7,.7,.7,.5)
	else:
		color = Color(.2,.2,.2)
	
	#update the visuals
	childrail.get_node("preview").rail.points = childrail.rail.points
	childrail.idnum = int(childrail.endplat[2].lstrip("              id_name: rail"))
	print(childrail.idnum)


func _process(delta):
	queue_redraw()
	var amount = 0
	var pressed = false
	for button in buttons:
		var point = button.get_parent()
		var pointID = points.find(point)
		var childpoint = false
		if childrail != null:
			if point in childrail.points:
				pointID = childrail.points.find(point)
				childpoint = true
		if button.is_hovered():
			amount += 1
			if Input.is_action_just_pressed("bridge") and Editor.item == "tooldelete": #right click
				if childpoint and childrail.points.size() > 2:
					Editor.undolistadd({"Type":"DeletePoint","Node":childrail,"Data":childrail.get_data(),"PointID":pointID})
					childrail.remove_point(pointID)
				elif points.size() > 2:
					Editor.undolistadd({"Type":"DeletePoint","Node":self,"Data":get_data(),"PointID":pointID})
					remove_point(pointID)
					childrail.get_node("preview").repeat = true
		if button.button_pressed:
			pressed = true
			if Editor.item == "toolmove":
				point.position = Editor.roundedmousepos
				if childpoint:
					childrail.rail.points[pointID*2] = point.position
					childrail.rail.points[pointID*2+1] = point.position
					childrail.get_node("preview").rail.points = childrail.rail.points
				$start.position = $end.position
				childrail.get_node("start").position = childrail.get_node("end").position
				childrail.get_node("preview").repeat = true
	if amount != 0 or pressed: #button is hovered
		if Input.is_action_just_pressed("MoveToBack"):
			get_parent().move_child(self,10)
		match get_parent().item:
			"tooledit":
				modulate = Color.GREEN_YELLOW
				if pressed and childrail != null:
					childrail.get_node("speed").show()
					childrail.get_node("speed").grab_focus()
					childrail.get_node("speed").set_caret_column(7)
			"tooldelete":
				modulate = Color.RED
				if pressed:
					get_parent().delete(self)
					get_parent().undolistadd({"Type":"Delete","Node":self})
			"toolproperty":
				modulate = Color.LIGHT_SKY_BLUE
				if pressed and get_parent().propertypanel == false:
					var currentdata = get_data()
					var childcurrentdata = childrail.get_data()
					get_parent().editednode = self
					get_parent().propertypanel = true
					get_parent().parse([currentdata,end,childcurrentdata,childrail.endplat])
					previousdata = currentdata
					previousend = end
					previousplatdata = childcurrentdata
					previousplatend = childrail.endplat
					return
			"toolmove":
				modulate = Color.ANTIQUE_WHITE
	else:
		modulate = Color.WHITE
	
	if Input.is_action_just_pressed("bridge"):
		if mode == 1: #starts the child rail's first point
			points.append($end)
			var railinst = railscene.instantiate()
			add_child(railinst)
			childrail = railinst
			for group in childrail.get_groups():
				add_to_group(group)
			mode = 69
			
	if locked == false and !fillmode:
		if Input.is_action_just_pressed("addpoint"):
				newseg()
				
		if Input.is_action_just_pressed("bridge"):
			newseg()
			bridge()
	if Input.is_action_just_pressed("Shift"):
		fillmode = not fillmode

func newseg():
	if mode == 0:
		var newpoint = pointScene.instantiate()
		newpoint.position = $start.position
		if points.size() != 0:
			newpoint.comment = false #make it -dir instead of -comment
		add_child(newpoint)
		points.append(newpoint)
		buttons.append(newpoint.get_node("Button"))
		$end.set_data()
		segments += 1
		$start.position = $end.position

func bridge():
	loading = true
	if mode == 0:
		Editor.idnum += 1
		$end.segments = segments-1
		$end.set_data()
		mode = 1
		locked = true
		buttons.append(get_node("end/Button"))

func pathdone(pos):
	if mode == 0:
		points.append($end)
		$end.segments = segments-1
		$end.set_data()
		Editor.idnum += 1
		mode = 1
		locked = true
		child(pos)
		buttons.append(get_node("end/Button"))

func child(pos):
	if mode == 1:
		var railinst = railscene.instantiate()
		railinst.loading = true
		railinst.get_node("start").position = pos
		railinst.speed = speed
		if loading:
			railinst.idnum = child_id_num
		add_child(railinst)
		childrail = railinst
		for group in childrail.get_groups():
			add_to_group(group)
		mode = 69 #nice



func _draw():
	if locked == false and loading == false and fillmode == false:
		$end.position = get_parent().roundedmousepos
	draw_line($start.position,$end.position,Color(.3,.3,.3),2.25) #draw the placing of the rail
	for point in points: # draw the rail
		if point != points[0]:
			draw_line(points[points.find(point)-1].position,point.position,color,2.25)
		draw_line(points[points.size()-1].position,$start.position,color,2.25)
	if locked == false and loading == false:
		pointcurve()

func EXPORT():
	if childrail != null and visible:
		childrail.EXPORT()
