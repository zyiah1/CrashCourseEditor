extends Sprite2D
var drag
@onready var id = get_parent().nodes.size()
var loading = false


@export var ObjectName: String = "Dkb_Banana"

@export var Param0: float = -1
@export var Param1: float = -1
@export var Param10: float = -1
@export var Param11: float = -1
@export var Param2: float = -1
@export var Param3: float = -1
@export var Param4: float = -1
@export var Param5: float = -1
@export var Param6: float = -1
@export var Param7: float = -1
@export var Param8: float = -1
@export var Param9: float = -1

@export var PosZ: float = 0

@export var rotatable: bool = true
@export var scalable: bool = true


@onready var defaultSize = scale

@onready var data = [
		  "          - comment: !l -1",
			"            dir_x: 0.00000",
			"            dir_y: 0.00000",
			"            dir_z: 0.00000",
			"            id_name: obj" + str(get_parent().idnum),
			"            layer: LC",
			"            link_info: []",
			"            link_num: !l 0",
			"            name: "+ObjectName,
			"            param0: "+str(Param0), #maybe points rewarded (banana)
			"            param1: "+str(Param1),
			"            param10: "+str(Param10),
			"            param11: "+str(Param11),
			"            param2: "+str(Param2),
			"            param3: "+str(Param3),
			"            param4: "+str(Param4),
			"            param5: "+str(Param5),
			"            param6: "+str(Param6),
			"            param7: "+str(Param7),
			"            param8: "+str(Param8),
			"            param9: "+str(Param9),
			"            pos_x: " + str(position.x),
			"            pos_y: " + str(-position.y),
			"            pos_z: " + str(PosZ),
			"            scale_x: 1.00000",
			"            scale_y: 1.00000",
			"            scale_z: 1.00000"]

func _ready():
	get_parent().idnum += 1
	if loading == false:
		$pitch/slider.grab_focus()
	else:
		$pitch.hide()

func _process(delta):
	#if get_parent().movingLoop == true:
		#if get_parent().item == "banana":
		#	$RichTextLabel.visible = true
		#else:
		#	$RichTextLabel.visible = false
	#else:
		#$RichTextLabel.visible = false
	if Input.is_action_just_pressed("accept"):
		$pitch.hide()
	
	id = get_parent().nodes.find(self)
	modulate = Color.WHITE
	if get_parent().item == "edit":
		if $Button.is_hovered():
			modulate = Color.GREEN_YELLOW
		else:
			modulate = Color.WHITE
	
	if get_parent().item == "delete":
		if $Button.is_hovered():
			modulate = Color.RED
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
		if get_parent().item == "edit":
			
			var dirflip = false
			var ladderframe = int(data[9].lstrip("            param0: "))
			if data[3].begins_with("            dir_z: 180"):
				dirflip = true
			
			
			
			if dirflip == true:
				rotation_degrees = 0
				flip_v = true
				match ladderframe:
					1:
						ladderframe = 0
					2:
						ladderframe = -1
					3:
						ladderframe = -2
					4:
						ladderframe = -3
					5:
						ladderframe = -4
					6:
						ladderframe = -5
			$pitch.show()
			$pitch/slider.value = ladderframe
		if get_parent().item != "edit" and get_parent().item != "proporties":
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






func _on_Button_button_down():
	drag = true


func _on_Button_button_up():
	drag = false
	
	

func EXPORT():
	data[21] = "            pos_x: " + str(position.x)
	data[22] = "            pos_y: " + str(-position.y)
	get_parent().objects += data

func _on_slider_focus_entered():
	$pitch.show()


func _on_slider_focus_exited():
	$pitch.hide()
	if flip_v == true:
		rotation_degrees = 180
	else:
		rotation_degrees = 0
	flip_v = false

func _on_slider_value_changed(value):
	
	
	
	var laddernumber = value
	
	if value<1:
		flip_v = true
		data[3] = "            dir_z: 180.00000"
	else:
		flip_v = false
		data[3] = "            dir_z: 0.00000"
	match int(value):
		1:
			texture = preload("res://ladder1.png")
		2:
			texture = preload("res://ladder2.png")
		3:
			texture = preload("res://ladder.png")
		4:
			texture = preload("res://ladder4.png")
		5:
			texture = preload("res://ladder5.png")
		6:
			texture = preload("res://ladder6.png")
		0:
			texture = preload("res://ladder1.png")
			laddernumber = 1
		-1:
			texture = preload("res://ladder2.png")
			laddernumber = 2
		-2:
			texture = preload("res://ladder.png")
			laddernumber = 3
		-3:
			texture = preload("res://ladder4.png")
			laddernumber = 4
		-4:
			texture = preload("res://ladder5.png")
			laddernumber = 5
		-5:
			texture = preload("res://ladder6.png")
			laddernumber = 6
	data[9] = "            param0: "+str(laddernumber)+".00000"
