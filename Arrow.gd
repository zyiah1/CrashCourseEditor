extends Sprite

var drag = false
onready var id = get_parent().nodes.size()
var type = "arrow"

export (bool) var rotatable = true
export (bool) var scalable = true


export var defaultSize = Vector2(3,3)

onready var data = [
		  "          - comment: !l -1",
			"            dir_x: 0.00000",
			"            dir_y: 0.00000",
			"            dir_z: 0.00000",
			"            id_name: obj" + str(get_parent().idnum),
			"            layer: L2",
			"            link_info: []",
			"            link_num: !l 0",
			"            name: Dkb_ChalkYajirushi_00",
			"            param0: -1.00000", #animation
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
	texture = preload("res://Arrow.png")
	$Button.rect_position = Vector2(66,-169)
	$Button.rect_size = Vector2(133,95)
	match type:
		"rotate":
			data[8] = "            name: Dkb_ChalkYajirushi_Kaiten"
			texture = preload("res://ArrowKaiten.png")
			$Button.rect_position = Vector2(-162,-66)
			$Button.rect_size = Vector2(353,132)
		"big":
			data[8] = "            name: Dkb_ChalkYajirushi_Arrow"
			texture = preload("res://BigArrow.png")
			$Button.rect_position = Vector2(-184,-147)
			$Button.rect_size = Vector2(368,287)
		"45":
			data[8] = "            name: Dkb_ChalkYajirushi_45"
			texture = preload("res://Arrow45.png")
			$Button.rect_position = Vector2(37,-213)
			$Button.rect_size = Vector2(103,81)
		"90":
			data[8] = "            name: Dkb_ChalkYajirushi_90"
			texture = preload("res://Arrow90.png")
			$Button.rect_position = Vector2(15,-213)
			$Button.rect_size = Vector2(206,191)
		"180":
			data[8] = "            name: Dkb_ChalkYajirushi_180"
			texture = preload("res://Arrow180.png")
			$Button.rect_position = Vector2(-118,-206)
			$Button.rect_size = Vector2(287,199)
	get_parent().idnum += 1





func _process(delta):
	if data[3] == "            dir_z: 45.00000":
		scale.x = -0.136
	else:
		scale.x = 0.136
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
	
	
	


func reposition():
	position.x = float(data[21].lstrip("            pos_x: "))
	position.y = -float(data[22].lstrip("            pos_y: "))
	if scalable:
		scale.x = float(data[24].lstrip("            scale_x: "))
		scale.y = float(data[25].lstrip("            scale_y: "))
		scale = scale*defaultSize #cause I'm stupid and everythings default scale is not 1
	if rotatable:
		rotation_degrees = float(data[3].lstrip("            dir_z: "))

func EXPORT():
	data[21] = "            pos_x: " + str(position.x)
	data[22] = "            pos_y: " + str(-position.y)
	get_parent().objects += data


func _on_Button_button_down():
	drag = true


func _on_Button_button_up():
	drag = false
