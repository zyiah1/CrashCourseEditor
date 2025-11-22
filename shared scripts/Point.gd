extends Sprite2D

@onready var idnum = get_parent().idnum
@onready var segments = get_parent().segments-1

var pointdata:PackedStringArray

func _ready():
	#if get_parent().loading == false: #if we aren't loading data, set the data
	set_data()

func set_data():
	idnum = get_parent().idnum
	pointdata = ["                - comment: !l -1",
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
"                  unit_name: Point"]

func reposition():
	position.x = float(pointdata[11].lstrip("                  pnt0_x: "))
	position.y = -float(pointdata[12].lstrip("                  pnt0_y: "))
