extends Sprite2D

@onready var idnum = get_parent().idnum
@onready var segments = get_parent().segments-1

var pointdata:PackedStringArray
@export var comment:bool = true #if - comment: !l -1: false = - dir_x:

var previouspos:Vector2 

func _ready():
	if get_node_or_null("Button") != null:
		get_node("Button").connect("button_up",Callable(self,"button_up"))
		get_node("Button").connect("button_down",Callable(self,"button_down"))
		get_node("Button").connect("mouse_entered",Callable(self,"button_hovered"))
	else:
		push_warning('null!!',get_parent().scene_file_path)
		print("null!")
	#print("MY ID IS ",idnum, " name is ", name)
	set_data()

func button_hovered():
	if get_parent().Editor.item.begins_with("tool"):
		if get_parent().Editor.item == "toolmove":
			$Button.mouse_default_cursor_shape = 6
		self_modulate = Color(2,2,2)
		await get_node("Button").mouse_exited
		if not get_node("Button").button_pressed:
			self_modulate = Color(1,1,1)
			$Button.mouse_default_cursor_shape = 0

func button_down():
	if get_parent().Editor.item == "toolmove":
		previouspos = position

func button_up():
	set_data()
	if get_parent().Editor.item == "toolmove":
		get_parent().Editor.undolistadd({"Type":"TransformPoint","Node":get_parent(),"PointID":get_parent().points.find(self),"Data":[previouspos,position]})
		print("pointTransformed")

func set_data():
	idnum = get_parent().idnum
	if comment:
		pointdata = ["                - comment: !l -1","                  dir_x: 0.00000"]
	else:
		pointdata = ["                - dir_x: 0.00000"]
	pointdata.append_array(["                  dir_y: 0.00000",
"                  dir_z: 0.00000",
"                  id_name: rail" + str(idnum) + "/"+str(segments),
"                  link_info: []",
"                  link_num: !l 0",
"                  param0: -1.00000",
"                  param1: -1.00000",
"                  param2: -1.00000",
"                  param3: -1.00000",
"                  pnt0_x: " + str(position.x),
"                  pnt0_y: " + str(-position.y),
"                  pnt0_z: 0.00000",
"                  pnt1_x: " + str(position.x),
"                  pnt1_y: " + str(-position.y),
"                  pnt1_z: 0.00000",
"                  pnt2_x: " + str(position.x),
"                  pnt2_y: " + str(-position.y),
"                  pnt2_z: 0.00000",
"                  scale_x: 1.00000",
"                  scale_y: 1.00000",
"                  scale_z: 1.00000",
"                  unit_name: Point"])

func reposition():
	idnum = get_parent().idnum
	var dataoffset:int = 0
	if pointdata[0] == "                - comment: !l -1":
		comment = true
	else:
		comment = false
		dataoffset = -1
	
	#print("THE X ",pointdata[11+dataoffset])
	position.x = float(pointdata[11+dataoffset].lstrip("                  pnt0_x: "))
	position.y = -float(pointdata[12+dataoffset].lstrip("                  pnt0_y: "))

func make_big():
	if get_node_or_null("start") != null:
		$start.play("RESET")
