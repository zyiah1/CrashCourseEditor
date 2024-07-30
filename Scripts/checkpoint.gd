extends Sprite

var localchecknum = 0
var drag = false
onready var id = get_parent().nodes.size()
var first = false

export (bool) var rotatable = false
export (bool) var scalable = false


onready var defaultSize = scale

onready var finaldata = [
		  "          - comment: !l -1",
			"            dir_x: 0.00000",
			"            dir_y: 0.00000",
			"            dir_z: 0.00000",
			"            id_name: obj" + str(get_parent().idnum),
			"            layer: LC",
			"            link_info: []",
			"            link_num: !l 0",
			"            name: Dkb_CheckPoint",
			"            param0: 2.00000",
			"            param1: 2.00000",
			"            param10: -1.00000",
			"            param11: -1.00000",
			"            param2: " + str(get_parent().checkpoints), #checkpointnumber
			"            param3: 1000.00000",
			"            param4: 3000.00000", #points rewarded
			"            param5: -1.00000",
			"            param6: -1.00000",
			"            param7: -1.00000",
			"            param8: -1.00000",
			"            param9: -1.00000",
			"            pos_x: " + str(position.x),
			"            pos_y: " + str(-position.y),
			"            pos_z: 0.00000",
			"            scale_x: 1.00000",
			"            scale_y: 1.00000",
			"            scale_z: 1.00000"]

onready var data = [
		  "          - comment: !l -1",
			"            dir_x: 0.00000",
			"            dir_y: 0.00000",
			"            dir_z: 0.00000",
			"            id_name: obj" + str(get_parent().idnum),
			"            layer: LC",
			"            link_info: []",
			"            link_num: !l 0",
			"            name: Dkb_CheckPoint",
			"            param0: 0.00000",
			"            param1: 0.00000",
			"            param10: -1.00000",
			"            param11: -1.00000",
			"            param2: " + str(get_parent().checkpoints), #checkpointnumber
			"            param3: 0.00000",
			"            param4: 500.00000", #points rewarded
			"            param5: -1.00000",
			"            param6: -1.00000",
			"            param7: -1.00000",
			"            param8: -1.00000",
			"            param9: -1.00000",
			"            pos_x: " + str(position.x),
			"            pos_y: " + str(-position.y),
			"            pos_z: 0.00000",
			"            scale_x: 1.00000",
			"            scale_y: 1.00000",
			"            scale_z: 1.00000"]



func _ready():
	if first == true:
		data = [
		  "          - comment: !l -1",
			"            dir_x: 0.00000",
			"            dir_y: 0.00000",
			"            dir_z: 0.00000",
			"            id_name: obj" + str(get_parent().idnum),
			"            layer: LC",
			"            link_info: []",
			"            link_num: !l 0",
			"            name: Dkb_CheckPoint",
			"            param0: 1.00000",
			"            param1: 1.00000",
			"            param10: -1.00000",
			"            param11: -1.00000",
			"            param2: 0.00000",
			"            param3: 0.00000",
			"            param4: 0.00000", #points rewarded
			"            param5: -1.00000",
			"            param6: -1.00000",
			"            param7: -1.00000",
			"            param8: -1.00000",
			"            param9: -1.00000",
			"            pos_x: " + str(position.x),
			"            pos_y: " + str(-position.y),
			"            pos_z: 0.00000",
			"            scale_x: 1.00000",
			"            scale_y: 1.00000",
			"            scale_z: 1.00000"]
	$RichTextLabel.bbcode_text = "[center]" + data[4]
	localchecknum = get_parent().idnum
	get_parent().idnum += 1
	get_parent().checkpoints += 1

func changetofirst():
	texture = $first.texture

func _process(delta):
	id = get_parent().nodes.find(self)
	if get_parent().data == true:
		if get_parent().item == "checkpoint":
			$RichTextLabel.visible = true
		else:
			$RichTextLabel.visible = false
		
	else:
		$RichTextLabel.visible = false
	
	if get_parent().item == "delete":
		if $Button.is_hovered():
			modulate = Color.red
		else:
			modulate = Color.white
	else:
		modulate = Color.white
	if drag == true:
		if get_parent().item == "delete":
			get_parent().nodes.remove(id)
			queue_free()
	
		if get_parent().item == "proporties":
			if get_parent().propertypanel == false:
				get_parent().propertypanel = true
				data[21] = "            pos_x: " + str(position.x)
				data[22] = "            pos_y: " + str(-position.y)
				get_parent().parse(data)
				get_parent().editednode = self
				return
		else:
			position = get_global_mouse_position().round()
	if is_queued_for_deletion():
		get_parent().checkpoints -= 1
func reposition():
	position.x = float(data[21].lstrip("            pos_x: "))
	position.y = -float(data[22].lstrip("            pos_y: "))
	if scalable:
		scale.x = float(data[24].lstrip("            scale_x: "))
		scale.y = float(data[25].lstrip("            scale_y: "))
		scale = scale*defaultSize #cause I'm stupid and everythings default scale is not 1
	if rotatable:
		rotation_degrees = float(data[3].lstrip("            dir_z: "))
	
	if data[9].begins_with("            param0: 0"):
		texture = preload("res://checkpoint.png")
	if data[9].begins_with("            param0: 1"):
		texture = preload("res://firstcheckpoint.png")
	if data[9].begins_with("            param0: 2"):
		texture = preload("res://fincheckpoint.png")
	if data[24].begins_with("            scale_x: -1"):
		flip_h = true
	else:
		flip_h = false

func EXPORT():
	data[21] = "            pos_x: " + str(position.x)
	data[22] = "            pos_y: " + str(-position.y)
	get_parent().objects += data


func _on_Button_button_down():
	drag = true


func _on_Button_button_up():
	drag = false
