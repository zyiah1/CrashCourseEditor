extends Node2D
signal done

const point = preload("res://point.tscn")
var locked = false
onready var id = get_parent().bridgedata.size()
var segments = 1
var line = null
var lines = []
var points = []
var loading = false

func _ready():
	if loading == false:
		$start.position = get_global_mouse_position().round()
	data = ["            - Points:",
"                - comment: !l -1",
"                  dir_x: 0.00000",
"                  dir_y: 0.00000",
"                  dir_z: 0.00000",
"                  id_name: rail" + str(get_parent().camnum) + "/0",
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
"                  id_name: rail" + str(get_parent().camnum) + "/"+str(segments),
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
"              id_name: rail" + str(get_parent().camnum),
"              layer: LC",
"              link_info: []",
"              link_num: !l 0",
"              name: レール",
"              num_pnt: !l 2",
"              param0: 0.00000",
"              param1: -1.00000",
"              param2: -1.00000",
"              param3: -1.00000",
"              param4:  0.00000",
"              param5: -1.00000",
"              param6: -1.00000",
"              param7: 0.00000",
"              param8: -1.00000",
"              param9: -1.00000",
"              type: Linear",
"              unit_name: Path"]




func _process(delta):
	if locked == false:
		if Input.is_action_just_pressed("undo"):
			if segments == 1:
				get_parent().idnum-=1
				get_parent().line = true
				queue_free()
			else:
				data.remove(points.size()+1*23)
				data.remove(points.size()+1*23)
				data.remove(points.size()+1*23)
				data.remove(points.size()+1*23)
				data.remove(points.size()+1*23)
				data.remove(points.size()+1*23)
				data.remove(points.size()+1*23)
				data.remove(points.size()+1*23)
				data.remove(points.size()+1*23)
				data.remove(points.size()+1*23)
				data.remove(points.size()+1*23)
				data.remove(points.size()+1*25)
				data.remove(points.size()+1*25)
				data.remove(points.size()+1*25)
				data.remove(points.size()+1*25)
				data.remove(points.size()+1*25)
				data.remove(points.size()+1*25)
				data.remove(points.size()+1*25)
				data.remove(points.size()+1*25)
				data.remove(points.size()+1*25)
				data.remove(points.size()+1*25)
				data.remove(points.size()+1*25)
				data.remove(points.size()+1*25)
				points[points.size()-1].queue_free()
				lines.remove(points.size()-1)
				points.remove(points.size()-1)
				segments -= 1
				
		if Input.is_action_just_pressed("addpoint"):
			
			lines.append([$start.position,$end.position])
			
			var newpoint = point.instance()
			newpoint.position = $start.position
			add_child(newpoint)
			points.append(newpoint)
			dataseg = ["                - comment: !l -1",
"                  dir_x: 0.00000",
"                  dir_y: 0.00000",
"                  dir_z: 0.00000",
"                  id_name: rail" + str(get_parent().camnum) + "/"+str(segments),
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
				newpoint.get_node("start").play("RESET")
			
		if Input.is_action_just_pressed("bridge"):
			loading = true
			locked = true
			get_parent().camnum += 1
			get_parent().bridgedata += data + end
			get_parent().line = true
		update()
	if is_queued_for_deletion():
		get_parent().Ain()
		get_parent().railplace = -420
		

func newseg():
			lines.append([$start.position,$end.position])
			
			var newpoint = point.instance()
			newpoint.position = $start.position
			add_child(newpoint)
			points.append(newpoint)
			dataseg = ["                - dir_x: 0.00000",
"                  dir_y: 0.00000",
"                  dir_z: 0.00000",
"                  id_name: rail" + str(get_parent().camnum) + "/"+str(segments),
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
				newpoint.get_node("start").play("RESET")


func done():
	locked = true
	get_parent().camnum += 1
	get_parent().bridgedata += data + end
	get_parent().line = true

func _draw():
	if loading == false:
		$end.position = get_global_mouse_position().round()
	line = draw_line($start.position,$end.position,Color(.22,.88,.28),4.5)
	for lineb in lines:
		draw_line(lineb[0],lineb[1],Color.limegreen - Color(.2,0,0,0),4.5)
