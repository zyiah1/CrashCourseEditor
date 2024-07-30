extends Sprite2D
var drag
@onready var id = get_parent().nodes.size()

@onready var data = [
		  "          - comment: !l -1",
			"            dir_x: 0.00000",
			"            dir_y: 0.00000",
			"            dir_z: 0.00000",
			"            id_name: obj" + str(get_parent().idnum),
			"            layer: LC",
			"            link_info: []",
			"            link_num: !l 0",
			"            name: Dkb_Banana",
			"            param0: 6.00000", #maybe points rewarded
			"            param1: -1.00000",
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
			"            pos_z: 0.00000",
			"            scale_x: 1.00000",
			"            scale_y: 1.00000",
			"            scale_z: 1.00000"]

func _ready():
	$RichTextLabel.text = "[center]" + data[4]
	get_parent().idnum += 1


func _process(delta):
	if get_parent().data == true:
		if get_parent().item == "banana":
			$RichTextLabel.visible = true
		else:
			$RichTextLabel.visible = false
	else:
		$RichTextLabel.visible = false
	id = get_parent().nodes.find(self)
	
	if get_parent().item == "delete":
		if $Button.is_hovered():
			modulate = Color.RED
		else:
			modulate = Color.WHITE
	else:
		modulate = Color.WHITE
	if drag == true:
		if get_parent().item == "delete":
			get_parent().nodes.remove_at(id)
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


func reposition():
	position.x = int(data[21].lstrip("            pos_x: "))
	position.y = -int(data[22].lstrip("            pos_y: "))






func _on_Button_button_down():
	drag = true


func _on_Button_button_up():
	drag = false
	
	

func EXPORT():
	data[21] = "            pos_x: " + str(position.x)
	data[22] = "            pos_y: " + str(-position.y)
	get_parent().objects += data
