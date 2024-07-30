extends Sprite

var drag = false
onready var id = get_parent().nodes.size()

onready var data = [
		  "          - comment: !l -1",
			"            dir_x: 0.00000",
			"            dir_y: 0.00000",
			"            dir_z: 0.00000",
			"            id_name: obj" + str(get_parent().idnum),
			"            layer: L2",
			"            link_info: []",
			"            link_num: !l 0",
			"            name: Dkb_ChalkEntrance",
			"            param0: 0.00000",
			"            param1: 1.00000",
			"            param10: -1.00000",
			"            param11: -1.00000",
			"            param2: -1.00000",
			"            param3: -1.00000",
			"            param4: -1.00000",
			"            param5: -1.00000",
			"            param6: -1.00000",
			"            param7: -1.00000",
			"            param8: -1.00000",
			"            param9: -1.00000",
			"            pos_x: " + str(position.x),
			"            pos_y: " + str(-position.y),
			"            pos_z: -6.90000",
			"            scale_x: 1.00000",
			"            scale_y: 1.00000",
			"            scale_z: 1.00000"]

func _ready():
	$RichTextLabel.bbcode_text = "[center]" + data[4]
	get_parent().idnum += 1





func _process(delta):
	id = get_parent().nodes.find(self)
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
	
	if get_parent().data == true:
		if get_parent().item == "door":
			$RichTextLabel.visible = true
		else:
			$RichTextLabel.visible = false
	else:
		$RichTextLabel.visible = false
	
	


func reposition():
	position.x = int(data[21].lstrip("            pos_x: "))
	position.y = -int(data[22].lstrip("            pos_y: "))

func EXPORT():
	data[21] = "            pos_x: " + str(position.x)
	data[22] = "            pos_y: " + str(-position.y)
	get_parent().objects += data


func _on_Button_button_down():
	drag = true


func _on_Button_button_up():
	drag = false
