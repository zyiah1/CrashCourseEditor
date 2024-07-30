extends Sprite


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
			"            param0: -1.00000",
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
			"            pos_z: -6.90000",
			"            scale_x: 1.00000",
			"            scale_y: 1.00000",
			"            scale_z: 1.00000"]

func _ready():
	$RichTextLabel.bbcode_text = "[center]" + data[4]
	get_parent().idnum += 1
	get_parent().objects += data




func _process(delta):
	
	if get_parent().data == true:
		$RichTextLabel.visible = true
	else:
		$RichTextLabel.visible = false
	
	

