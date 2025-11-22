extends Rail

const pointscene: PackedScene = preload("res://point.tscn")

@export var pointtexture: Texture2D = preload("uid://tmpumwmwcucm") #pointR.png
@export var rotationpoint: int = 0 
@export var railtexture: Texture2D = preload("uid://bw3l07oyd028f") #railwhite.png

var speed = 2.5
var drag = false
var firstpoint = true


func focus_entered():
	$rotation.show()
	$speed.show()

func focus_exited():
	$rotation.hide()
	$speed.hide()

func _ready():
	$start.show()
	loading = get_parent().loading
	var inst = load("res://rail.tscn").instantiate()
	add_child(inst)
	move_child(inst, 0)
	
	
	rail = inst
	rail.texture = railtexture
	$rotation.connect("focus_entered", Callable(self, "focus_entered"))
	$rotation.connect("focus_exited", Callable(self, "focus_exited"))
	$speed.connect("focus_entered", Callable(self, "focus_entered"))
	$speed.connect("focus_exited", Callable(self, "focus_exited"))
	$speed.set_caret_column(7)
	if loading == false:
		$start.position = Editor.roundedmousepos
	else:
		$rotation.hide()
		$speed.hide()
	$crank.position = $start.position
	$rotation.position = $crank.position + Vector2(-20,-100)
	$speed.position = $crank.position + Vector2(-20,-156)
	buttons.append($crank/Button)
	rail.add_point($start.position)
	$crank.rail.add_point($start.position)
	
	$start.set_data()
	end = ["              closed: CLOSE",
"              comment: !l -1",
"              id_name: rail" + str(idnum),
"              layer: LC",
"              link_info: []",
"              link_num: !l 0",
"              name: レール",
"              num_pnt: !l 2",
"              param0: " + str(Param0) + ".00000",
"              param1: " + str(int($rotation.text)), #max degree tilt
"              param2: "+str(speed)+"0000", #speed
"              param3: "+str(rotationpoint), #This is the point it rotates from: 0 = 1st 1 = 2nd ect.
"              param4: 0.00000",
"              param5: -1.00000",
"              param6: -1.00000",
"              param7: 3.00000",
"              param8: -1.00000",
"              param9: -1.00000",
"              type: Linear",
"              unit_name: Path"]

func reposition():
	lines = change_points(points,$start,$end)
	for line in end:
		if line.begins_with("              param0:"): #get the point kind
			var newpointtexture = preload("uid://xp7hguu2wcws") #point.png
			var rotatetexture = preload("uid://dalli7fv0djlw") #pivotR.png
			$crank.rail.texture = preload("uid://dd6bsp038gsk0") #railPurple.png
			rail.texture = preload("uid://bvrfm1i201crx") #rail.png
			$crank2.hide()
			remove_from_group("EndSpin")
			remove_from_group("AutoSpin")
			
			
			#spin
			if line.begins_with("              param0: 3110"):
				newpointtexture = preload("uid://covcxxp27opw") #pointL.png
				$crank.rail.texture = preload("uid://d3hlcipa37df") #railblue.png
				rail.texture = preload("uid://bw3l07oyd028f") #railwhite.png
				rotatetexture = preload("uid://ckd1nvejuas1") #crankL.png
			if line.begins_with("              param0: 3111"):
				newpointtexture = preload("uid://tmpumwmwcucm") #pointR.png
				$crank.rail.texture = preload("uid://bvrfm1i201crx") #rail.png
				rail.texture = preload("uid://bw3l07oyd028f") #railwhite.png
				rotatetexture = preload("uid://bvycd1a6kxdhr") #crankR.png
			#L points
			if line.begins_with("              param0: 3140") or line.begins_with("              param0: 3150"):
				newpointtexture = preload("uid://covcxxp27opw") #pointL.png
				$crank.rail.texture = preload("uid://d3hlcipa37df") #railblue.png
				rail.texture = preload("uid://bw3l07oyd028f") #railwhite.png
				rotatetexture = preload("uid://c6428javeoxyj") #pivotL.png
			#R points
			if line.begins_with("              param0: 3141"):
				newpointtexture = preload("uid://tmpumwmwcucm") #pointR.png
				$crank.rail.texture = preload("uid://bvrfm1i201crx") #rail.png
				rail.texture = preload("uid://bw3l07oyd028f") #railwhite.png
			#Auto points
			if line.begins_with("              param0: 3200") or line.begins_with("              param0: 3300") or line.begins_with("              param0: 3322") or line.begins_with("              param0: 3423"):
				add_to_group("AutoSpin")
				newpointtexture = preload("uid://dv1xfkkmbirrk") #pointA.png
				$crank.rail.texture = preload("uid://ksbllqjphq5t") #railGreen.png
				rail.texture = preload("uid://bw3l07oyd028f") #railwhite.png
				rotatetexture = preload("uid://dv1xfkkmbirrk") #pointA.png
			
			#End Points
			if line.begins_with("              param0: 3380"):
				newpointtexture = preload("uid://b7lahmfrodnve") #PointE0.png
				rotatetexture = preload("uid://dtm0wfbnxxbs") #PivotE0.png
			if line.begins_with("              param0: 3381"):
				newpointtexture = preload("uid://djsdxta7ufsl8") #PointE1.png
				rotatetexture = preload("uid://cxtjtxpat0j3q") #PivotE1.png
			if line.begins_with("              param0: 3382"):
				newpointtexture = preload("uid://b5k5uonnog4v6") #PointE2.png
				rotatetexture = preload("uid://buuu0v3kvgd4g") #PivotE2.png
			if line.begins_with("              param0: 3383"):
				newpointtexture = preload("uid://boj4lu6r6g8ob") #PointE3.png
				rotatetexture = preload("uid://c5o0vxrndh4ta") #PivotE3.png
			if line.begins_with("              param0: 3384"):
				newpointtexture = preload("uid://djuhfoj4eg0vh") #PointE4.png
				rotatetexture = preload("uid://ck3qe33v2nkdn") #PivotE4.png
			if line.begins_with("              param0: 3385"):
				newpointtexture = preload("uid://b7idwkrvbv5kn") #PointE5.png
				rotatetexture = preload("uid://nbkxr8lpr1fl") #PivotE5.png
			if line.begins_with("              param0: 3386"):
				newpointtexture = preload("uid://clwton8qfrc21") #PointE6.png
				rotatetexture = preload("uid://bdv3hmel50r25") #PivotE6.png
			if line.begins_with("              param0: 3387"):
				newpointtexture = preload("uid://c8ygmxmmyuwsb") #PointE7.png
				rotatetexture = preload("uid://bjqff4mo6tikp")#PivotE7.png
			if line.begins_with("              param0: 3388"):
				newpointtexture = preload("uid://bhrjjon6md4xv") #PointE8.png
				rotatetexture = preload("uid://dkqx1463bw21j") #PivotE8.png
			if line.begins_with("              param0: 3389"):
				newpointtexture = preload("uid://dr3tgkdixayt") #PointE9.png
				rotatetexture = preload("uid://df5e6awwdow6y") #PivotE9.png
			if line.begins_with("              param0: 3390"):
				newpointtexture = preload("uid://bawmu7reyj84q") #PointE10.png
				rotatetexture = preload("uid://d0n8agu4e8pyo") #PivotE10.png
			if line.begins_with("              param0: 3391"):
				newpointtexture = preload("uid://6e3rhcq5lbnp") #PointE11.png
				rotatetexture = preload("uid://f6jfvr8qql3l") #PivotE11.png
			if line.begins_with("              param0: 3392") or line.begins_with("              param0: 3393") or line.begins_with("              param0: 3394"):
				newpointtexture = preload("uid://dn2w76gtiqspv") #PointE.png
				rotatetexture = preload("uid://bwp2oalixxe3l") #pivotEnd.png
			if line.begins_with("              param0: 3112"): # tilt platforsm
				newpointtexture = preload("uid://covcxxp27opw") #pointL.png
				$crank.rail.texture = preload("uid://d3hlcipa37df") #railblue.png
				rail.texture = preload("uid://bw3l07oyd028f") #railwhite.png
				$crank2.show()
				$crank2.rail.texture = preload("uid://c63l3sra6bhuk") #raildarkblue.png
				rotatetexture = preload("uid://dc3f47b4oampr") #pivotLS.png
			if line.begins_with("              param0: 3113"):
				newpointtexture = preload("uid://tmpumwmwcucm") #pointR.png
				$crank.rail.texture = preload("uid://bvrfm1i201crx") #rail.png
				rail.texture = preload("uid://bw3l07oyd028f") #railwhite.png
				$crank2.show()
				$crank2.rail.texture = preload("uid://dkkhc0srthw5r") #railmaroon.png
				rotatetexture = preload("uid://bm4jdwxs1nkev") #pivotRS.png
			for point in points:
				point.texture = newpointtexture
			
			if $crank.rail.texture == preload("uid://dd6bsp038gsk0"): #railPurple.png
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
	text = end[10].erase(0,22)
	if float(text) == int(text): #keeps number simple
		$speed.text = str(int(text))
	else:
		$speed.text = str(float(text))
	speed = float(text)
	$crank.target = float($rotation.text)
	$rotation.prev = $rotation.text
	$crank.rotation_degrees = 0
	$rotation.position = $crank.position + Vector2(-20,-100)
	$speed.position = $crank.position + Vector2(-20,-156)
	
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
	$end.scale = Vector2(.35,.35)
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
		$speed.hide()
	
	var amount = 0
	var pressed = false
	for button in buttons:
		if button.is_hovered():
			amount += 1
		if button.button_pressed:
			pressed = true
	
	if amount != 0: #button is hovered
		if Input.is_action_just_pressed("MoveToBack"):
			Editor.move_child(owner,10)
		match Editor.item:
			"tooledit":
				modulate = Color.GREEN_YELLOW
				if pressed:
					get_node("rotation").show()
					get_node("rotation").grab_focus()
					get_node("rotation").set_caret_column(7)
					get_node("speed").set_caret_column(7)
			"tooldelete":
				modulate = Color.RED
				if pressed:
					Editor.delete(owner)
					Editor.undolistadd({"Type":"Delete","Node":owner})
			"toolproperty":
				modulate = Color.LIGHT_SKY_BLUE
				if pressed and Editor.propertypanel == false:
					Editor.editednode = self
					Editor.propertypanel = true
					Editor.parse([get_data(),end])
					previousdata = get_data()
					previousend = end
					return
	else:
		modulate = Color.WHITE
	if locked == false and fillmode == false:
		if Input.is_action_just_pressed("addpoint"):
			newseg()
			
		if Input.is_action_just_pressed("bridge"):
			newseg()
			bridge()
	$crank.target = float($rotation.text)
	if Input.is_action_just_pressed("Shift"):
		fillmode = not fillmode

func newseg():
	lines.append([$start.position,$end.position])
	rail.add_point($end.position)
	$crank.rail.add_point($end.position)
	rail.add_point($end.position)
	$crank.rail.add_point($end.position)
	var newpoint = pointscene.instantiate()
	newpoint.texture = pointtexture
	newpoint.position = $start.position
	if firstpoint == true:
		newpoint.hide()
		firstpoint = false
		$start.self_modulate.a = 1
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

func _on_speed_change():
	speed = float($speed.text)
	var loop = 0
	for dat in end:
		if dat.begins_with("              param2:"):
			break
		loop += 1
	end[loop] = "              param2: " + str(speed)
	$crank.rotation_degrees = 0

func bridge():
	points.append($end)
	$end.segments = segments-1
	$end.set_data()
	loading = true
	locked = true
	end[9] = "              param1: " + str(-float($rotation.text)) #max degree tilt
	Editor.idnum += 1
	Editor.lineplacing = true
	buttons.append(get_node("end/Button"))
	$rotation.grab_focus()
	$rotation.set_caret_column(3)

func done():
	points.append($end)
	$end.segments = segments-1
	$end.set_data()
	locked = true
	Editor.idnum += 1
	Editor.lineplacing = true
	buttons.append(get_node("end/Button"))

func _draw():
	if loading == false and locked == false and fillmode == false:
		$end.position = Editor.roundedmousepos
	draw_line($start.position,$end.position,color,4.5)
	if loading == false and locked == false:
		pointcurve()

func EXPORT():
	if end != null:
		if end[9] != null:
			end[9] = "              param1: " + str(-$crank.target)
			Editor.bridgedata += get_data() + end
