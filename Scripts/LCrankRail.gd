extends Node2D
signal done

const point = preload("res://point2.tscn")
var locked = false
onready var id = get_parent().nodes.size()
var segments = 1
var line = null
var lines = []
var points = []
var mode = 0 #0 = path 1 = platform
var idnum
var childrail = null
var loading = false
var speed
var drag = false
var buttons = []

func _ready():
	idnum = int(get_parent().idnum)
	if loading == false:
		$start.position = get_global_mouse_position()
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

onready var end = ["              closed: CLOSE",
"              comment: !l -1",
"              id_name: rail" + str(get_parent().idnum),
"              layer: LC",
"              link_info: []",
"              link_num: !l 0",
"              name: レール",
"              num_pnt: !l 2",
"              param0: 2900.00000", #railtype
"              param1: -1.00000",
"              param2: -1.00000",
"              param3: -1.00000",
"              param4:  0.00000",
"              param5: -1.00000",
"              param6: -1.00000",
"              param7: -1.00000",
"              param8: -1.00000",
"              param9: -1.00000",
"              type: Linear",
"              unit_name: Path"]




func reposition():
	var currentpoint = 0
	var currentline = 0
	var count = -1
	var first = true
	var cycles = -1
	
	
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
	childrail.path = []
	for line in points:
		childrail.path.append(line.position)
	childrail.path.append($end.position)
	childrail.get_node("preview").offset = Vector2.ZERO
	currentpoint = 0
	currentline = 0
	count = -1
	first = true
	cycles = -1
	for line in childrail.endplat:
		if line.begins_with("              param2: "):
			var text = line
			text.erase(0,22)
			childrail.get_node("rotation").text = text
			childrail._on_rotation_change()
	
	for line in childrail.data:
		cycles += 1
		if currentpoint == childrail.points.size():
			if line.begins_with("                  pnt0_x: "):
				childrail.get_node("start").position.x = int(line.lstrip("                  pnt0_x: "))
				currentline = childrail.lines.size() - 1
			if line.begins_with("                  pnt0_y: "):
				childrail.get_node("start").position.y = -int(line.lstrip("                  pnt0_y: "))
				childrail.get_node("end").position = childrail.get_node("start").position
				childrail.lines[currentline][1] = childrail.get_node("end").position
				if childrail.points.size() >= 2:
					childrail.lines[currentline][0] = childrail.lines[currentline-1][1]
			if line.begins_with("                  pnt1_x: "):
				childrail.data[cycles] = "                  pnt1_x: " + str(childrail.get_node("end").position.x)
			if line.begins_with("                  pnt1_y: "):
				childrail.data[cycles] = "                  pnt1_y: " + str(-childrail.get_node("end").position.y)
				
			if line.begins_with("                  pnt2_x: "):
				childrail.data[cycles] = "                  pnt2_x: " + str(childrail.get_node("end").position.x)
			if line.begins_with("                  pnt2_y: "):
				childrail.data[cycles] = "                  pnt2_y: " + str(-childrail.get_node("end").position.y)
		else:
			if line.begins_with("                  pnt0_x: "):
				count += 1
				if first == true:
					if count >= 2:
						count = 0
						currentline += 1
						first = false
				childrail.points[currentpoint].position.x = int(line.lstrip("                  pnt0_x: "))
				if first == true:
					childrail.lines[currentline][count].x = childrail.points[currentpoint].position.x
				else:
					childrail.lines[currentline][0].x = childrail.lines[currentline - 1][1].x
					childrail.lines[currentline][1].x = childrail.points[currentpoint].position.x
			if line.begins_with("                  pnt0_y: "):
				childrail.points[currentpoint].position.y = -int(line.lstrip("                  pnt0_y: "))
				if first == true:
					childrail.lines[currentline][count].y = childrail.points[currentpoint].position.y
				else:
					childrail.lines[currentline][0].y = childrail.lines[currentline - 1][1].y
					childrail.lines[currentline][1].y = childrail.points[currentpoint].position.y
					currentline += 1
				
			if line.begins_with("                  pnt1_x: "):
				childrail.data[cycles] = "                  pnt1_x: " + str(childrail.points[currentpoint].position.x)
			if line.begins_with("                  pnt1_y: "):
				childrail.data[cycles] = "                  pnt1_y: " + str(-childrail.points[currentpoint].position.y)
				
			if line.begins_with("                  pnt2_x: "):
				childrail.data[cycles] = "                  pnt2_x: " + str(childrail.points[currentpoint].position.x)
			if line.begins_with("                  pnt2_y: "):
				childrail.data[cycles] = "                  pnt2_y: " + str(-childrail.points[currentpoint].position.y)
				
				currentpoint += 1


func _process(delta):
	update()
	id = get_parent().nodes.find(self)
	if get_parent().item == "delete":
		if drag == true:
			get_parent().nodes.remove(id)
			queue_free()
		var amount = 0
		
		for button in buttons:
			if button.is_hovered():
				modulate = Color.red
				amount += 1
			if amount == 0:
				modulate = Color.white
				drag = false
	if get_parent().item == "edit":
		if drag == true:
			if childrail != null:
				childrail.get_node("rotation").show()
				childrail.get_node("rotation").grab_focus()
				childrail.get_node("rotation").cursor_set_column(7)
		var amount = 0
		
		for button in buttons:
			if button.is_hovered():
				modulate = Color.lightblue
				amount += 1
			if amount == 0:
				modulate = Color.white
				drag = false
	if get_parent().item == "proporties":
		if drag == true:
			if get_parent().propertypanel == false:
				get_parent().propertypanel = true
				get_parent().parse(data)
				get_parent().parse(end)
				get_parent().parse(childrail.data)
				get_parent().parse(childrail.endplat)
				get_parent().editednode = self
				return
	if Input.is_action_just_pressed("bridge"):
		if mode == 1:
			var rail = preload("res://Lcrank.tscn")
			var railinst = rail.instance()
			for line in points:
				railinst.path.append(line.position)
			railinst.path.append($end.position)
			add_child(railinst)
			childrail = railinst
			mode = 69
	if locked == false:
		if Input.is_action_just_pressed("undo"):
			if segments == 1:
				get_parent().idnum-=1
				get_parent().line = true
				
		if Input.is_action_just_pressed("addpoint"):
			if mode == 0:
				lines.append([$start.position,$end.position])
				
				var newpoint = point.instance()
				newpoint.position = $start.position
				add_child(newpoint)
				points.append(newpoint)
				buttons.append(newpoint.get_node("Button"))
				newpoint.get_node("Button").connect("button_down",self,"_on_Button_button_down")
				newpoint.get_node("Button").connect("button_up",self,"_on_Button_button_up")
				dataseg = ["                - dir_x: 0.00000",
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
				segments += 1
				
				
		if Input.is_action_just_pressed("bridge"):
			if mode == 0:
				get_parent().idnum += 2
				idnum += 1
				mode = 1
				locked = true
				buttons.append(get_node("end/Button"))
	if is_queued_for_deletion():
		get_parent().Ain()
		get_parent().railplace = -420
		queue_free()
		get_parent().line = true


func newseg():
	if mode == 0:
		lines.append([$start.position,$end.position])
		
		var newpoint = point.instance()
		newpoint.position = $start.position
		add_child(newpoint)
		points.append(newpoint)
		buttons.append(newpoint.get_node("Button"))
		newpoint.get_node("Button").connect("button_down",self,"_on_Button_button_down")
		newpoint.get_node("Button").connect("button_up",self,"_on_Button_button_up")
		dataseg = ["                - dir_x: 0.00000",
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
		segments += 1
		
		
func done(pos):
	if mode == 0:
		get_parent().idnum += 2
		idnum += 1
		mode = 1
		locked = true
		child(pos)
		buttons.append(get_node("end/Button"))

func child(pos):
	if mode == 1:
		var rail = preload("res://Lcrank.tscn")
		var railinst = rail.instance()
		railinst.loading = true
		railinst.get_node("start").position = pos
		for line in points:
			railinst.path.append(line.position)
		railinst.path.append($end.position)
		railinst.speed = speed
		add_child(railinst)
		childrail = railinst
		mode = 69

func _draw():
	if locked == false and loading == false:
		$end.position = get_global_mouse_position()
	line = draw_line($start.position,$end.position,Color(.3,.3,.3),4.5/2)
	for lineb in lines:
		draw_line(lineb[0],lineb[1],Color(.2,.2,.2),4.5/2)


func EXPORT():
	if childrail != null:
		childrail.EXPORT()


func _on_Button_button_down():
	drag = true
	


func _on_Button_button_up():
	drag = false
